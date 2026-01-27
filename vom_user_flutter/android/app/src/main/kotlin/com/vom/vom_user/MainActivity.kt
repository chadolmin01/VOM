package com.vom.vom_user

import android.content.Intent
import android.content.Context
import android.content.pm.PackageManager
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val NFC_CHANNEL = "com.vom.vom_user/nfc"
    private val PHONE_CHANNEL = "com.vom.vom_user/phone"
    private var nfcMethodChannel: MethodChannel? = null
    private var phoneMethodChannel: MethodChannel? = null
    private val READ_PHONE_STATE_REQUEST_CODE = 1001
    private var initialNfcTagId: String? = null // 앱 시작 시 NFC 태그 ID 저장

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        nfcMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NFC_CHANNEL)
        phoneMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHONE_CHANNEL)
        
        // NFC Method Channel 설정
        nfcMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialNfcTagId" -> {
                    // 앱 시작 시 저장된 NFC 태그 ID 반환 (한 번만)
                    val tagId = initialNfcTagId
                    initialNfcTagId = null // 반환 후 초기화
                    result.success(tagId)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // 전화번호 읽기 Method Channel 설정
        phoneMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "readPhoneNumber" -> {
                    readPhoneNumber(result)
                }
                "requestPhonePermission" -> {
                    requestPhonePermission(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleNfcIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNfcIntent(intent)
    }

    private fun handleNfcIntent(intent: Intent?) {
        if (intent == null) return

        val action = intent.action
        if (NfcAdapter.ACTION_NDEF_DISCOVERED == action ||
            NfcAdapter.ACTION_TECH_DISCOVERED == action ||
            NfcAdapter.ACTION_TAG_DISCOVERED == action) {

            val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
            tag?.let {
                val tagId = it.id.joinToString("") { byte -> "%02X".format(byte) }
                
                // 앱 시작 시점(onCreate)에서 호출된 경우: 저장해두고 나중에 Flutter에서 요청하면 반환
                if (initialNfcTagId == null) {
                    initialNfcTagId = tagId
                }
                
                // 앱이 이미 실행 중인 경우: 즉시 Flutter로 전송
                nfcMethodChannel?.invokeMethod("onNfcTagDiscovered", tagId)
            }
        }
    }

    // 전화번호 읽기 함수
    private fun readPhoneNumber(result: MethodChannel.Result) {
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_PHONE_STATE) 
            != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "전화번호 읽기 권한이 필요합니다.", null)
            return
        }

        try {
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            var phoneNumber: String? = null

            // Android 8.0 이상에서는 READ_PHONE_NUMBERS 권한 필요
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_PHONE_NUMBERS) 
                    == PackageManager.PERMISSION_GRANTED) {
                    phoneNumber = telephonyManager.line1Number
                }
            } else {
                phoneNumber = telephonyManager.line1Number
            }

            // 전화번호가 없거나 비어있으면 null 반환
            if (phoneNumber.isNullOrBlank()) {
                result.success(null)
            } else {
                // 한국 전화번호 형식으로 정리 (010-1234-5678)
                val cleanedNumber = phoneNumber.replace(Regex("[^0-9]"), "")
                val formattedNumber = when {
                    cleanedNumber.startsWith("82") && cleanedNumber.length == 12 -> {
                        "0${cleanedNumber.substring(2)}"
                    }
                    cleanedNumber.length == 11 && cleanedNumber.startsWith("010") -> {
                        cleanedNumber
                    }
                    else -> cleanedNumber
                }
                result.success(formattedNumber)
            }
        } catch (e: Exception) {
            result.error("READ_ERROR", "전화번호를 읽는 중 오류가 발생했습니다: ${e.message}", null)
        }
    }

    // 전화번호 읽기 권한 요청
    private fun requestPhonePermission(result: MethodChannel.Result) {
        val permissions = mutableListOf<String>()
        permissions.add(android.Manifest.permission.READ_PHONE_STATE)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            permissions.add(android.Manifest.permission.READ_PHONE_NUMBERS)
        }

        val permissionsToRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (permissionsToRequest.isEmpty()) {
            result.success(true)
        } else {
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest.toTypedArray(),
                READ_PHONE_STATE_REQUEST_CODE
            )
            // 권한 요청 결과는 onRequestPermissionsResult에서 처리
            result.success(false)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == READ_PHONE_STATE_REQUEST_CODE) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            phoneMethodChannel?.invokeMethod("onPhonePermissionResult", allGranted)
        }
    }
}
