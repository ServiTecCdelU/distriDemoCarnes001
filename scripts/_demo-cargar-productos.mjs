import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
const env = readFileSync('.env.local', 'utf8')
const get = k => env.match(new RegExp(k + '=(.+)'))[1].trim()
const sb = createClient(get('NEXT_PUBLIC_SUPABASE_URL'), get('SUPABASE_SERVICE_ROLE_KEY'))

// Lista de precios ROMANO Distribuciones (FRIMSA) - precio por KG
const CAJAS = [
  ['Bola de lomo', 13100],
  ['Cuadrada', 13100],
  ['Paleta', 13440],
  ['Roastbeef', 13440],
  ['Colita de cuadril', 17430],
  ['Corazón de cuadril', 15720],
  ['Peceto', 14010],
  ['Nalga con tapa', 14580],
  ['Nalga sin tapa', 15720],
  ['Tapa de nalga', 12870],
  ['Tapa de asado', 12870],
  ['Vacío premium', 16300],
  ['Vacío', 15150],
  ['Entraña premium', 26000],
  ['Entraña', 16900],
  ['Matambre', 9500],
]
const CORTES = [
  ['Asado completo', 13660, 'matambre/entraña/vacío/costillar'],
  ['Asado completo banderita', 13660, ''],
  ['Costillar/Plancha', 12000, ''],
  ['Barra de bife c/ lomo', 13800, ''],
  ['Lomo', 22000, ''],
]

function slugify(s) {
  return s.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '').slice(0, 20)
}

const rows = []
let n = 0
for (const [name, price] of CAJAS) {
  n++
  rows.push({
    id: `producto_${slugify(name)}_${n}`,
    name, description: 'Caja x 20kg · precio por kg', category: 'Cajas x 20kg',
    brand: 'FRIMSA', price, precio_venta: price, stock: 50, disabled: false,
  })
}
for (const [name, price, desc] of CORTES) {
  n++
  rows.push({
    id: `producto_${slugify(name)}_${n}`,
    name, description: desc ? `Corte · ${desc} · precio por kg` : 'Corte · precio por kg',
    category: 'Cortes', brand: 'FRIMSA', price, precio_venta: price, stock: 50, disabled: false,
  })
}

const { data, error } = await sb.from('productos').insert(rows).select('id,name,price,category')
if (error) { console.error('ERROR:', JSON.stringify(error)); process.exit(1) }
console.log('Insertados:', data.length)
for (const p of data) console.log(`  ${p.category.padEnd(12)} ${p.name.padEnd(28)} $${p.price}`)
