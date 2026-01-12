import './globals.css'
import type { Metadata } from 'next'
import { ToastProvider } from '@/components/ui'

export const metadata: Metadata = {
  title: 'V.O.M Admin',
  description: 'V.O.M 통합 관리자 솔루션',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ko">
      <body>
        <ToastProvider>
          {children}
        </ToastProvider>
      </body>
    </html>
  )
}
