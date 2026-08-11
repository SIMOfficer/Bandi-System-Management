export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export interface Database {
  public: {
    Views: Record<string, never>
    Functions: Record<string, never>
    Tables: {
      business: {
        Row: {
          id: string
          name: string
          address: string | null
          phone: string | null
          bank_account: string | null
          logo_url: string | null
          invoice_prefix: string
          quotation_prefix: string
          receipt_prefix: string
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['business']['Row']> & { name: string }
        Update: Partial<Database['public']['Tables']['business']['Row']>
        Relationships: []
      }
      business_users: {
        Row: {
          business_id: string
          user_id: string
          display_name: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['business_users']['Row']> & {
          business_id: string
          user_id: string
        }
        Update: Partial<Database['public']['Tables']['business_users']['Row']>
        Relationships: []
      }
      clients: {
        Row: {
          id: string
          business_id: string
          name: string
          phone: string | null
          address: string | null
          notes: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['clients']['Row']> & {
          business_id: string
          name: string
        }
        Update: Partial<Database['public']['Tables']['clients']['Row']>
        Relationships: []
      }
      catalog_items: {
        Row: {
          id: string
          business_id: string
          name: string
          unit: string
          default_price: number
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['catalog_items']['Row']> & {
          business_id: string
          name: string
        }
        Update: Partial<Database['public']['Tables']['catalog_items']['Row']>
        Relationships: []
      }
      quotations: {
        Row: {
          id: string
          business_id: string
          number: string
          client_id: string | null
          status: 'draft' | 'sent' | 'accepted' | 'rejected'
          issue_date: string
          valid_until: string | null
          notes: string | null
          subtotal: number
          discount: number
          total: number
          created_by: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['quotations']['Row']> & {
          business_id: string
          number: string
        }
        Update: Partial<Database['public']['Tables']['quotations']['Row']>
        Relationships: []
      }
      quotation_items: {
        Row: {
          id: string
          quotation_id: string
          catalog_item_id: string | null
          description: string
          qty: number
          unit: string
          unit_price: number
          line_total: number
          sort_order: number
        }
        Insert: Partial<Database['public']['Tables']['quotation_items']['Row']> & {
          quotation_id: string
          description: string
        }
        Update: Partial<Database['public']['Tables']['quotation_items']['Row']>
        Relationships: []
      }
      invoices: {
        Row: {
          id: string
          business_id: string
          number: string
          client_id: string | null
          quotation_id: string | null
          status: 'unpaid' | 'partial' | 'paid'
          issue_date: string
          due_date: string | null
          notes: string | null
          subtotal: number
          discount: number
          total: number
          amount_paid: number
          created_by: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['invoices']['Row']> & {
          business_id: string
          number: string
        }
        Update: Partial<Database['public']['Tables']['invoices']['Row']>
        Relationships: []
      }
      invoice_items: {
        Row: {
          id: string
          invoice_id: string
          catalog_item_id: string | null
          description: string
          qty: number
          unit: string
          unit_price: number
          line_total: number
          sort_order: number
        }
        Insert: Partial<Database['public']['Tables']['invoice_items']['Row']> & {
          invoice_id: string
          description: string
        }
        Update: Partial<Database['public']['Tables']['invoice_items']['Row']>
        Relationships: []
      }
      finance_categories: {
        Row: {
          id: string
          business_id: string
          name: string
          type: 'income' | 'expense'
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['finance_categories']['Row']> & {
          business_id: string
          name: string
          type: 'income' | 'expense'
        }
        Update: Partial<Database['public']['Tables']['finance_categories']['Row']>
        Relationships: []
      }
      finance_transactions: {
        Row: {
          id: string
          business_id: string
          type: 'income' | 'expense'
          amount: number
          category_id: string | null
          description: string | null
          txn_date: string
          source: 'manual' | 'invoice_payment'
          invoice_id: string | null
          created_by: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['finance_transactions']['Row']> & {
          business_id: string
          type: 'income' | 'expense'
          amount: number
        }
        Update: Partial<Database['public']['Tables']['finance_transactions']['Row']>
        Relationships: []
      }
      payments: {
        Row: {
          id: string
          business_id: string
          invoice_id: string
          amount: number
          method: string
          paid_date: string
          notes: string | null
          finance_transaction_id: string | null
          created_by: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['payments']['Row']> & {
          business_id: string
          invoice_id: string
          amount: number
        }
        Update: Partial<Database['public']['Tables']['payments']['Row']>
        Relationships: []
      }
      receipts: {
        Row: {
          id: string
          business_id: string
          number: string
          client_id: string | null
          invoice_id: string | null
          kind: 'goods' | 'payment'
          description: string
          given_by: string | null
          received_by: string | null
          issue_date: string
          created_by: string | null
          created_at: string
        }
        Insert: Partial<Database['public']['Tables']['receipts']['Row']> & {
          business_id: string
          number: string
          description: string
        }
        Update: Partial<Database['public']['Tables']['receipts']['Row']>
        Relationships: []
      }
    }
  }
}
