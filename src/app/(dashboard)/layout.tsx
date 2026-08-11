import { getBusinessContext } from '@/lib/business'
import { Nav } from '@/components/nav'

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { business } = await getBusinessContext()

  if (!business) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-neutral-50 px-4">
        <div className="max-w-md space-y-2 rounded-xl border border-neutral-200 bg-white p-6 text-center shadow-sm">
          <h1 className="text-lg font-semibold text-neutral-900">Akun belum terhubung ke bisnis</h1>
          <p className="text-sm text-neutral-500">
            Akun Anda sudah login tapi belum ditautkan ke data bisnis. Minta admin menambahkan baris
            di tabel <code>business_users</code> pada Supabase.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-neutral-50">
      <Nav businessName={business.name} />
      <main className="mx-auto max-w-6xl px-4 py-6">{children}</main>
    </div>
  )
}
