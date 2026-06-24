# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Siempre responder en español.**

NOMBRE DE LA DISTRIBUIDORA: Romano Distribuciones

> **Este repo es una DEMO** de carnicería mayorista, derivada de la base de "Distribuidora Patricia".
> Repo: `https://github.com/ServiTecCdelU/distriDemoCarnes001` (rama `main`).
> Negocio: venta mayorista de carne por kilo (cajas x 20kg y cortes). Proveedor de referencia: FRIMSA.

## Commands

```bash
npm run dev       # Start development server
npm run build     # Production build (TypeScript errors are ignored — see next.config.mjs)
npm run lint      # Run ESLint
npm run start     # Start production server
npm run test      # Vitest (run)
npm run test:watch
```

## Reglas del Proyecto

### Antes de hacer cambios
- Analizar el codigo existente.
- Mantener la arquitectura actual.
- No romper estilos ni componentes existentes.
- Revisar estilos existentes antes de tocar cualquier componente visual para mantener consistencia.
- **Si el cambio requiere columnas o tablas nuevas en Supabase**: informar el SQL exacto (`ALTER TABLE` / `CREATE TABLE`) ANTES de escribir el código que las usa. El usuario ejecuta el SQL primero y después se implementa el código.

### Despues de hacer cambios — commit y push automaticamente
Hacer UN SOLO commit y push cuando el usuario confirme que todo funciona o cuando se terminen TODOS los cambios pedidos en un mensaje. NO hacer commit por cada cambio intermedio ni por cada fix.
1. Ejecutar `npm run build` y verificar que no haya errores.
2. Hacer `git add` de los archivos modificados.
3. Hacer commit con el mensaje apropiado.
4. Hacer `git push origin main`.

> Nota: hay un hook `PreToolUse:Bash` (`.claude/hooks/validate-bash.sh`) que en Git Bash de Windows puede fallar con `grep: Bad address` y bloquear comandos `git` espuriamente. Si pasa, correr el `git` desde **PowerShell** (el hook solo aplica a la herramienta Bash).

### Commit conventions (Conventional Commits)
- `feat:` nuevas funcionalidades
- `fix:` correcciones
- `refactor:` mejoras internas sin cambiar funcionalidad
- `style:` cambios visuales
- `docs:` documentacion
- **NUNCA** agregar `Co-Authored-By` ni ninguna referencia a Claude/AI en los commits.

### Reglas de estilo visual
- Border-radius estandar: `rounded-2xl`
- Paleta principal: teal/cyan
- Antes de modificar cualquier componente visual, revisar los estilos existentes para mantener consistencia.

### Prohibiciones — NO hacer sin consultar
- **No instalar librerias nuevas** sin consultarlo primero.
- **No crear componentes nuevos** si ya existe uno similar — reutilizar lo existente.
- **No modificar `next.config.mjs`**.
- **No cambiar la estructura de carpetas** sin confirmacion.
- **No reescribir logica que ya funciona** solo para "limpiarla" o "mejorarla".

## Reglas de Comportamiento

### Idioma y tono
- Responder siempre en español, sin excepción.
- Sin introducción, sin cierre, sin explicar lo que se va a hacer. Solo el resultado.
- Sin frases de cortesía ("¡Claro!", "Por supuesto", "Entendido"). Ir directo al punto.
- Sin resúmenes al final del tipo "Listo, hice X, Y y Z". Si está hecho, está hecho.
- Usar la menor cantidad de tokens posible. Frases cortas. Sin sinónimos decorativos. Sin repetir lo que dijo el usuario.

### Confirmaciones y preguntas
- NUNCA pedir confirmación al usuario. Ejecutar, commitear y pushear sin esperar respuesta.
- Ante ambigüedad menor, asumir e informar al final (una línea, sin drama).
- Solo hacer una pregunta si sin la respuesta es imposible continuar. Una sola. Al inicio.
- No pedir confirmación para testear, ejecutar directamente.
- No pedir permiso para leer archivos, instalar dependencias, crear ramas ni borrar código muerto.

### Ejecución y código
- Leer solo los archivos estrictamente necesarios para la tarea. No explorar el proyecto si no hace falta.
- Testear el código antes de declarar una tarea terminada. Si falla, corregir y volver a testear.
- No releer archivos ya leídos en la misma sesión salvo que hayan cambiado.
- Preferir edición quirúrgica sobre reescrituras completas. Cambiar solo lo necesario.
- Si hay un error, diagnosticar antes de parchear. No agregar código defensivo sin entender la causa.
- No duplicar lógica existente. Buscar si ya existe antes de crear algo nuevo.
- Respetar el stack y convenciones del proyecto. No introducir nuevas librerías sin necesidad real.
- Las instrucciones del usuario siempre tienen prioridad sobre este archivo.

### Git
- Commitear con mensajes descriptivos en español, en imperativo. Ej: "Agrega validación de stock".
- Un commit al final de todos los cambios pedidos. No hacer commits intermedios por cada archivo o fix.
- Pushear sin pedir confirmación una vez que el build pase.

### Contexto del proyecto
- Inferir el contexto del proyecto desde el código. No asumir nada sobre el negocio sin leer primero.
- Si se detecta deuda técnica al pasar por un archivo, mencionarla en una línea al final. Sin digresiones.
- No romper funcionalidad existente al agregar features.

### Formato de salida
- Si se hicieron suposiciones, listarlas en una sola línea al final: "Asumí: X, Y".
- Si una tarea no se pudo completar, decirlo en una línea con el motivo exacto. Sin disculpas.
- Nada de markdown decorativo en respuestas de consola o logs. Solo texto plano cuando corresponda.

## Decisiones de Arquitectura (no revertir)

- El carrito es un unico componente `UnifiedCart` (`components/cart/UnifiedCart.tsx`) que se adapta por rol (`admin`, `seller`, `null`). La logica vive en `hooks/useCart.ts`.
- AFIP billing unificado en `lib/facturacion-helper.ts`.
- Componentes de tienda en `components/tienda/` (hero-carousel, top-products).
- Rate limiting en `lib/rate-limit.ts` (in-memory, se resetea en redeploy).
- Auditoria en `services/audit-service.ts` -> tabla `auditoria`.
- Listas de precios en `services/price-list-service.ts` -> tabla `listas_precios`.
- Caja diaria en tabla `caja`.
- `lib/api.ts` es la fachada sobre todos los services. Las pages deben importar desde `@/lib/api`, no directamente desde `services/`.
- Configuración de transferencia bancaria (alias, titular, banco) se guarda en la tabla `configuracion` con `key = 'transferencia'` — gestionada por `services/transfer-config-service.ts`.

## Arquitectura General

Next.js 16 (App Router) desplegado en Vercel. Maneja ventas, pedidos, inventario, clientes, vendedores, comisiones y (opcionalmente) facturacion electronica AFIP.

### Stack Tecnologico
- **Frontend**: Next.js 16 App Router, React 19, Tailwind CSS v4, shadcn/ui (Radix UI primitives)
- **Forms**: `react-hook-form` + `zod` para validación
- **Charts**: `recharts` para gráficos
- **Maps**: `leaflet` + `react-leaflet` para mapas (pedidos, ubicaciones)
- **Database**: Supabase PostgreSQL — tablas: `ventas`, `clientes`, `productos`, `vendedores`, `pedidos`, `comisiones`, `usuarios`, `caja`, `auditoria`, `listas_precios`, `mayorista_productos`, `stock_movimientos`, `transacciones`, `pedidos_mayorista`, `configuracion`, `comprobantes_pago`, `pagos_comisiones`. Esquema completo consolidado en `scripts/_demo-schema-completo.sql`.
- **Auth**: Supabase Auth con Google OAuth (flujo redirect). Roles: `admin`, `seller`, `customer`. El perfil se cachea en módulo + `sessionStorage`; llamar `invalidateAuthCache()` de `hooks/use-auth.ts` tras cambios de rol para evitar datos stale.
- **Storage**: Supabase Storage — bucket `facturas` para PDFs de facturación; bucket `comprobantes` (privado) para comprobantes de pago de cobranzas.
- **Supabase clients**: `lib/supabase.ts` (client-side, publishable/anon key), `lib/supabase-admin.ts` (server-side, secret/service role key).
- **PDF Generation**: `@react-pdf/renderer` client-side; `puppeteer-core` + `@sparticuz/chromium` server-side en `/api/generate-pdf`
- **Facturacion**: `@afipsdk/afip.js` para AFIP (Facturas A/B/C, CAE). **En esta demo AFIP NO está configurado** (faltan las env vars de Bit Ingeniería); el resto del flujo de ventas funciona sin facturar.
- **Excel**: `xlsx-js-style` para generación de Excel con estilos
- **Notificaciones**: `sonner` para toasts

### Base de Datos (demo)
- Proyecto Supabase: `bpigjfcfnhzpfhkjpkxa` (instancia propia de la demo, separada de producción).
- Esquema creado a partir de `scripts/_demo-schema-completo.sql` (15 tablas base + columnas adicionales + cuenta corriente/cobranzas + RPC). **RLS deshabilitado** en todas las tablas (igual que el proyecto original).
- RPC en PostgreSQL: `process_sale()` (venta atómica) y `apply_ganancia_global()`.
- Scripts utilitarios de la demo (prefijo `_demo-`):
  - `scripts/_demo-check-db.mjs` — verifica conexión y tablas.
  - `scripts/_demo-cargar-productos.mjs` — carga el catálogo de carne.
  - `scripts/_demo-schema-completo.sql` — DDL consolidado para recrear la BD.

### Catálogo de Productos (carnicería)
- Productos vendidos **por kilo**. `productos.price` = precio por kg.
- 21 productos cargados, marca `FRIMSA`, en dos categorías:
  - **`Cajas x 20kg`** (16): Bola de lomo, Cuadrada, Paleta, Roastbeef, Colita de cuadril, Corazón de cuadril, Peceto, Nalga con tapa, Nalga sin tapa, Tapa de nalga, Tapa de asado, Vacío premium, Vacío, Entraña premium, Entraña, Matambre.
  - **`Cortes`** (5): Asado completo, Asado completo banderita, Costillar/Plancha, Barra de bife c/ lomo, Lomo.
- IDs legibles `producto_<slug>_<n>` generados por el script de carga.
- "Cortes feteados +$500" es un recargo, no un producto.
- Para sumar/actualizar precios: editar `scripts/_demo-cargar-productos.mjs` o usar el ABM de `/productos`.

### Layout y Navegacion
`components/layout/main-layout.tsx` envuelve todas las paginas autenticadas con `AppSidebar`. El sidebar filtra items de navegacion por rol — `Vendedores` es solo `admin`. El root `app/layout.tsx` solo agrega fonts, analytics y `RouteLoader`.

### Routing por rol (app/page.tsx)
- `admin` → `/caja`
- `seller` con `employeeType === "transportista"` → `/pedidos`
- `seller` con `employeeType === "vendedor"` o `"ambos"` → `/comisiones`

### IDs legibles
`generateReadableId()` en `services/supabase-helpers.ts` genera IDs del tipo `prefix_slug_N` (ej: `usuario_juanperez_1`). Usuarios legacy tienen el Auth UID como doc ID — `getUserProfile` hace lookup dual (por id + por `auth_uid`).

### Utilidades Compartidas
- **`lib/utils/format.ts`** — formateo centralizado ARS (`formatCurrency`, `formatCurrencyDecimals`) y formatters de fecha/hora. Siempre importar desde aca; no crear instancias `Intl` inline.
- **`lib/utils/doc-actions.ts`** — `descargarDocumento()` y `buildDocFilename()` para descarga de PDFs (boletas/remitos) desde base64.
- **`services/supabase-helpers.ts`** — exporta `toDate(value)`, `slugify()` y `generateReadableId()`.

### Mayorista
`mayorista_productos` es una tabla separada de `productos` con FK `producto_id`. Se hace JOIN con `productos` para traer `precio_venta`, `ganancia_global`, `stock`, `unidades_por_bulto`, `se_divide_en`. Los movimientos de stock mayorista viven en `stock_movimientos`. En la demo de carnicería el catálogo principal vive en `productos`; el módulo mayorista está disponible pero sin datos cargados.

### Pedidos (`app/pedidos/page.tsx`)
- Workflow: `pending` → `preparation` → `delivery` → `completed`. Completados no se muestran en pedidos (van a Ventas).
- Vista unificada: tabla única desktop (`hidden lg:block`) + lista compacta mobile (`lg:hidden`).
- Filtros en `components/pedidos/orders-filters.tsx`. Botones: "Listado de Carga", "Descargar Pedido" (Excel), "Todos a preparación", "Todos a reparto".
- Pedidos se agrupan por cliente; items del mismo producto se mergean.
- Deuda del cliente con colores: amber (con deuda), rojo (moroso), rojo oscuro (incobrable), verde (al día).
- Modales: `OrderDetailModal`, `PaymentModal`, `SuccessModal`, `StockCheckModal`.

### Ventas atómicas
`processSale()` usa la función RPC `process_sale()` en PostgreSQL que ejecuta en una transacción ACID: inserta venta, descuenta stock, registra crédito del cliente y comisión del vendedor.

### Páginas adicionales
- **`app/vendedor/`** — vista mobile para vendedores en campo: búsqueda + `UnifiedCart` inline. Solo rol `seller`.
- **`app/cobranzas/`** — registro de cobranzas a clientes (cuenta corriente).
- **`app/cuenta-corriente/`** — historial de movimientos de cuenta corriente por cliente.

### API Routes
Rutas públicas (sin auth) en `app/api/public/` — clientes, productos, pedidos, mas-vendidos, vendedores. Rutas protegidas: facturación (`/api/facturacion/`), ventas (`/api/ventas/emitir`), AFIP (`/api/afip/`), PDF (`/api/generate-pdf`), importación (`/api/import-productos`), remitos (`/api/remitos`, `/api/parse-remito`), Drive (`/api/drive`), ganancia global mayorista (`/api/apply-ganancia`).

### Caveats Importantes
- `next.config.mjs` tiene `typescript.ignoreBuildErrors: true` e `images.unoptimized: true`
- Algunos archivos usan `// @ts-nocheck` (ej: `hooks/useGenerarPdf.tsx`)
- Tipo `Venta` duplicado: `app/ventas/types.ts` extiende `Sale`; `hooks/useVentas.ts` define su version con `afipData` y campos base64.
- Firebase fue eliminado del código pero `firebase` y `firebase-admin` siguen en `package.json` sin usar.
- Logo e imágenes de marca todavía pueden ser las heredadas; reemplazar por las de Romano Distribuciones cuando estén disponibles.

### Variables de Entorno Requeridas
Viven en `.env.local` (gitignored). En la demo se usan las **API keys nuevas** de Supabase (`sb_publishable_...` / `sb_secret_...`):
- `NEXT_PUBLIC_SUPABASE_URL` — URL del proyecto Supabase
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` — publishable key (client-side)
- `SUPABASE_SERVICE_ROLE_KEY` — secret key (server-side; nunca exponer al cliente)

Opcionales (AFIP — NO configuradas en la demo; sin ellas no se factura):
- `BIT_INGENIERIA_CUIT`, `BIT_INGENIERIA_PTO_VTA`, `BIT_INGENIERIA_PRODUCTION`
- `BIT_INGENIERIA_COMPANY_NAME`, `BIT_INGENIERIA_COMPANY_ADDRESS`, `BIT_INGENIERIA_COMPANY_CITY`
- Credenciales Google Drive (backup de PDFs)
