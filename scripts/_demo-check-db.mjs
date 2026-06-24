import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
const env = readFileSync('.env.local', 'utf8')
const get = k => env.match(new RegExp(k + '=(.+)'))[1].trim()
const url = get('NEXT_PUBLIC_SUPABASE_URL')
const key = get('SUPABASE_SERVICE_ROLE_KEY')
console.log('URL:', url)
console.log('KEY prefix:', key.slice(0, 12), 'len:', key.length)
const sb = createClient(url, key)
const r = await sb.from('productos').select('id,name', { count: 'exact' }).limit(2)
console.log('error:', JSON.stringify(r.error))
console.log('status:', r.status, r.statusText)
console.log('count:', r.count)
console.log('data:', JSON.stringify(r.data))
