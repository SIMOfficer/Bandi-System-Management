'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

const links = [
  { href: '/', label: 'Dashboard' },
  { href: '/clients', label: 'Klien' },
  { href: '/catalog', label: 'Katalog' },
  { href: '/quotations', label: 'Quotation' },
  { href: '/invoices', label: 'Invoice' },
  { href: '/receipts', label: 'Tanda Terima' },
  { href: '/finance', label: 'Keuangan' },
]

export function Nav({ businessName }: { businessName: string }) {
  const pathname = usePathname()
  const router = useRouter()

  async function handleSignOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.replace('/login')
    router.refresh()
  }

  return (
    <header className="border-b border-neutral-200 bg-white">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-2 px-4 py-3">
        <div className="flex items-center gap-6">
          <span className="text-sm font-semibold text-neutral-900">{businessName}</span>
          <nav className="flex flex-wrap gap-1">
            {links.map((link) => {
              const active = pathname === link.href
              return (
                <Link
                  key={link.href}
                  href={link.href}
                  className={`rounded-md px-3 py-1.5 text-sm ${
                    active
                      ? 'bg-neutral-900 text-white'
                      : 'text-neutral-600 hover:bg-neutral-100'
                  }`}
                >
                  {link.label}
                </Link>
              )
            })}
          </nav>
        </div>
        <button
          onClick={handleSignOut}
          className="rounded-md px-3 py-1.5 text-sm text-neutral-600 hover:bg-neutral-100"
        >
          Keluar
        </button>
      </div>
    </header>
  )
}
