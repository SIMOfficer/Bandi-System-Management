import { createClient } from '@/lib/supabase/server'

export async function getBusinessContext() {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return { supabase, user: null, business: null }
  }

  const { data: business } = await supabase
    .from('business')
    .select('*')
    .single()

  return { supabase, user, business }
}
