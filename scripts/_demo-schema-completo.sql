-- =============================================
-- USUARIOS
-- =============================================
CREATE TABLE usuarios (
  id TEXT PRIMARY KEY,
  auth_uid UUID UNIQUE,
  email TEXT,
  name TEXT,
  role TEXT CHECK (role IN ('admin', 'seller', 'customer')) DEFAULT 'customer',
  seller_id TEXT,
  employee_type TEXT CHECK (employee_type IN ('vendedor', 'transportista', 'ambos')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- PRODUCTOS
-- =============================================
CREATE TABLE productos (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  brand TEXT,
  code TEXT,
  price NUMERIC(12,2) DEFAULT 0,
  selling_price NUMERIC(12,2) DEFAULT 0,
  stock INTEGER DEFAULT 0,
  min_stock INTEGER DEFAULT 0,
  image_url TEXT,
  disabled BOOLEAN DEFAULT false,
  unidades_por_bulto INTEGER,
  se_divide_en TEXT,
  precio_venta NUMERIC(12,2),
  ganancia_global NUMERIC(8,2),
  ganancia_individual NUMERIC(8,2),
  codigo TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_productos_category ON productos(category);
CREATE INDEX idx_productos_code ON productos(code);
CREATE INDEX idx_productos_disabled ON productos(disabled);

-- =============================================
-- MAYORISTA_PRODUCTOS
-- =============================================
CREATE TABLE mayorista_productos (
  id TEXT PRIMARY KEY,
  codigo TEXT,
  codigo_barras TEXT DEFAULT '',
  descripcion TEXT,
  precio_lista NUMERIC(12,2),
  rubro TEXT DEFAULT '',
  subrubro TEXT DEFAULT '',
  categoria TEXT DEFAULT '',
  habilitado BOOLEAN DEFAULT false,
  producto_id TEXT REFERENCES productos(id),
  stock_local INTEGER DEFAULT 0,
  stock_transito INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_mp_codigo ON mayorista_productos(codigo);
CREATE INDEX idx_mp_habilitado ON mayorista_productos(habilitado);
CREATE INDEX idx_mp_producto_id ON mayorista_productos(producto_id);

-- =============================================
-- CLIENTES
-- =============================================
CREATE TABLE clientes (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  dni TEXT,
  cuit TEXT,
  tax_category TEXT,
  credit_limit NUMERIC(12,2) DEFAULT 0,
  current_balance NUMERIC(12,2) DEFAULT 0,
  addresses JSONB DEFAULT '[]'::jsonb,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_clientes_dni ON clientes(dni);
CREATE INDEX idx_clientes_cuit ON clientes(cuit);
CREATE INDEX idx_clientes_email ON clientes(email);

-- =============================================
-- VENDEDORES
-- =============================================
CREATE TABLE vendedores (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  employee_type TEXT CHECK (employee_type IN ('vendedor', 'transportista', 'ambos')),
  commission_rate NUMERIC(5,2) DEFAULT 10,
  transportista_commission_rate NUMERIC(5,2) DEFAULT 10,
  total_sales NUMERIC(12,2) DEFAULT 0,
  total_commission NUMERIC(12,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- VENTAS
-- =============================================
CREATE TABLE ventas (
  id TEXT PRIMARY KEY,
  sale_number TEXT,
  client_id TEXT REFERENCES clientes(id),
  client_name TEXT,
  client_phone TEXT,
  seller_id TEXT REFERENCES vendedores(id),
  seller_name TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  subtotal NUMERIC(12,2) DEFAULT 0,
  tax NUMERIC(12,2) DEFAULT 0,
  total NUMERIC(12,2) DEFAULT 0,
  payment_type TEXT CHECK (payment_type IN ('cash', 'credit', 'mixed')),
  cash_amount NUMERIC(12,2),
  credit_amount NUMERIC(12,2),
  status TEXT DEFAULT 'completed',
  source TEXT DEFAULT 'direct',
  order_id TEXT,
  delivery_method TEXT DEFAULT 'pickup',
  delivery_address TEXT,
  invoice_emitted BOOLEAN DEFAULT false,
  invoice_number TEXT,
  invoice_status TEXT,
  invoice_pdf_base64 TEXT,
  invoice_pdf_url TEXT,
  invoice_whatsapp_url TEXT,
  afip_data JSONB,
  remito_number TEXT,
  remito_pdf_base64 TEXT,
  remito_pdf_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_ventas_client ON ventas(client_id);
CREATE INDEX idx_ventas_seller ON ventas(seller_id);
CREATE INDEX idx_ventas_created ON ventas(created_at DESC);

-- =============================================
-- TRANSACCIONES
-- =============================================
CREATE TABLE transacciones (
  id TEXT PRIMARY KEY,
  client_id TEXT REFERENCES clientes(id),
  type TEXT CHECK (type IN ('debt', 'payment')),
  amount NUMERIC(12,2) NOT NULL,
  description TEXT,
  sale_id TEXT REFERENCES ventas(id),
  date TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_transacciones_client ON transacciones(client_id);

-- =============================================
-- PEDIDOS
-- =============================================
CREATE TABLE pedidos (
  id TEXT PRIMARY KEY,
  client_id TEXT REFERENCES clientes(id),
  client_name TEXT,
  seller_id TEXT REFERENCES vendedores(id),
  seller_name TEXT,
  transportista_id TEXT REFERENCES vendedores(id),
  transportista_name TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  checked_items JSONB DEFAULT '[]'::jsonb,
  status TEXT CHECK (status IN ('pending', 'preparation', 'delivery', 'completed')) DEFAULT 'pending',
  address TEXT,
  lat NUMERIC(10,7),
  lng NUMERIC(10,7),
  source TEXT,
  sale_id TEXT,
  invoice_number TEXT,
  invoice_pdf_base64 TEXT,
  remito_number TEXT,
  remito_pdf_base64 TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_pedidos_status ON pedidos(status);
CREATE INDEX idx_pedidos_transportista ON pedidos(transportista_id);
CREATE INDEX idx_pedidos_created ON pedidos(created_at DESC);

-- =============================================
-- COMISIONES
-- =============================================
CREATE TABLE comisiones (
  id TEXT PRIMARY KEY,
  seller_id TEXT REFERENCES vendedores(id),
  seller_name TEXT,
  sale_id TEXT REFERENCES ventas(id),
  sale_total NUMERIC(12,2),
  commission_rate NUMERIC(5,4),
  commission_amount NUMERIC(12,2),
  is_paid BOOLEAN DEFAULT false,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_comisiones_seller ON comisiones(seller_id);
CREATE INDEX idx_comisiones_paid ON comisiones(is_paid);

-- =============================================
-- CAJA
-- =============================================
CREATE TABLE caja (
  id TEXT PRIMARY KEY,
  date TEXT,
  type TEXT,
  amount NUMERIC(12,2),
  description TEXT,
  user_id TEXT,
  user_name TEXT,
  sale_id TEXT,
  payment_method TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_caja_date ON caja(date);
CREATE INDEX idx_caja_type ON caja(type);

-- =============================================
-- AUDITORIA
-- =============================================
CREATE TABLE auditoria (
  id TEXT PRIMARY KEY,
  action TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  user_id TEXT,
  user_email TEXT,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_auditoria_entity ON auditoria(entity_type, entity_id);
CREATE INDEX idx_auditoria_created ON auditoria(created_at DESC);

-- =============================================
-- LISTAS DE PRECIOS
-- =============================================
CREATE TABLE listas_precios (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  multiplier NUMERIC(6,4) DEFAULT 1.0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- STOCK MOVIMIENTOS
-- =============================================
CREATE TABLE stock_movimientos (
  id SERIAL PRIMARY KEY,
  mayorista_producto_id TEXT REFERENCES mayorista_productos(id),
  tipo TEXT NOT NULL,
  cantidad INTEGER NOT NULL,
  stock_anterior INTEGER,
  stock_posterior INTEGER,
  motivo TEXT,
  venta_id TEXT,
  usuario_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_stock_mov_mp ON stock_movimientos(mayorista_producto_id);

-- =============================================
-- PEDIDOS MAYORISTA
-- =============================================
CREATE TABLE pedidos_mayorista (
  id TEXT PRIMARY KEY,
  estado TEXT CHECK (estado IN ('borrador', 'enviado', 'recibido_parcial', 'cerrado')),
  productos JSONB DEFAULT '[]'::jsonb,
  notas TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- CONFIGURACION
-- =============================================
CREATE TABLE configuracion (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================
-- TRIGGERS: updated_at automático
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_productos BEFORE UPDATE ON productos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_mp BEFORE UPDATE ON mayorista_productos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_clientes BEFORE UPDATE ON clientes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_vendedores BEFORE UPDATE ON vendedores FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_ventas BEFORE UPDATE ON ventas FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_pedidos BEFORE UPDATE ON pedidos FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_listas BEFORE UPDATE ON listas_precios FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_pm BEFORE UPDATE ON pedidos_mayorista FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_usuarios BEFORE UPDATE ON usuarios FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =============================================
-- DESHABILITAR RLS en todas las tablas
-- =============================================
ALTER TABLE usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE productos DISABLE ROW LEVEL SECURITY;
ALTER TABLE mayorista_productos DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE vendedores DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas DISABLE ROW LEVEL SECURITY;
ALTER TABLE transacciones DISABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos DISABLE ROW LEVEL SECURITY;
ALTER TABLE comisiones DISABLE ROW LEVEL SECURITY;
ALTER TABLE caja DISABLE ROW LEVEL SECURITY;
ALTER TABLE auditoria DISABLE ROW LEVEL SECURITY;
ALTER TABLE listas_precios DISABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movimientos DISABLE ROW LEVEL SECURITY;
ALTER TABLE pedidos_mayorista DISABLE ROW LEVEL SECURITY;
ALTER TABLE configuracion DISABLE ROW LEVEL SECURITY;

-- =============================================
-- RPC: processSale atómico
-- =============================================
CREATE OR REPLACE FUNCTION process_sale(sale_data JSONB)
RETURNS JSONB AS $$
DECLARE
  v_sale_id TEXT;
  v_item JSONB;
  v_total NUMERIC;
  v_credit_amount NUMERIC;
BEGIN
  v_sale_id := sale_data->>'id';
  v_total := (sale_data->>'total')::NUMERIC;

  -- 1. Insertar venta
  INSERT INTO ventas (id, sale_number, client_id, client_name, client_phone,
    seller_id, seller_name, items, subtotal, tax, total,
    payment_type, cash_amount, credit_amount, status, source,
    order_id, delivery_method, delivery_address)
  VALUES (
    v_sale_id, sale_data->>'sale_number', sale_data->>'client_id',
    sale_data->>'client_name', sale_data->>'client_phone',
    sale_data->>'seller_id', sale_data->>'seller_name',
    sale_data->'items', (sale_data->>'subtotal')::NUMERIC,
    (sale_data->>'tax')::NUMERIC, v_total,
    sale_data->>'payment_type', (sale_data->>'cash_amount')::NUMERIC,
    (sale_data->>'credit_amount')::NUMERIC,
    COALESCE(sale_data->>'status', 'completed'),
    COALESCE(sale_data->>'source', 'direct'),
    sale_data->>'order_id',
    COALESCE(sale_data->>'delivery_method', 'pickup'),
    sale_data->>'delivery_address'
  );

  -- 2. Descontar stock
  FOR v_item IN SELECT * FROM jsonb_array_elements(sale_data->'items')
  LOOP
    UPDATE productos
    SET stock = stock - (v_item->>'quantity')::INTEGER
    WHERE id = v_item->'product'->>'id';
  END LOOP;

  -- 3. Crédito del cliente
  v_credit_amount := COALESCE((sale_data->>'credit_amount')::NUMERIC, 0);
  IF v_credit_amount > 0 AND sale_data->>'client_id' IS NOT NULL THEN
    UPDATE clientes
    SET current_balance = current_balance + v_credit_amount
    WHERE id = sale_data->>'client_id';

    INSERT INTO transacciones (id, client_id, type, amount, description, sale_id)
    VALUES ('trans_' || v_sale_id, sale_data->>'client_id', 'debt',
            v_credit_amount, 'Venta a crédito', v_sale_id);
  END IF;

  -- 4. Comisión del vendedor
  IF sale_data->>'seller_id' IS NOT NULL THEN
    INSERT INTO comisiones (id, seller_id, seller_name, sale_id, sale_total,
      commission_rate, commission_amount)
    VALUES ('com_' || v_sale_id, sale_data->>'seller_id',
            sale_data->>'seller_name', v_sale_id, v_total, 0.1, v_total * 0.1);

    UPDATE vendedores
    SET total_sales = total_sales + v_total,
        total_commission = total_commission + (v_total * 0.1)
    WHERE id = sale_data->>'seller_id';
  END IF;

  RETURN jsonb_build_object('sale_id', v_sale_id, 'success', true);
END;
$$ LANGUAGE plpgsql;

-- Aplicar ganancia global a todos los productos habilitados (excepto los que tienen precio individual)
CREATE OR REPLACE FUNCTION apply_ganancia_global(p_porcentaje NUMERIC)
RETURNS INTEGER AS $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE productos p
  SET price = ROUND(mp.precio_lista * (1 + p_porcentaje / 100), 2),
      precio_venta = ROUND(mp.precio_lista * (1 + p_porcentaje / 100), 2),
      ganancia_global = p_porcentaje,
      ganancia_individual = 0
  FROM mayorista_productos mp
  WHERE mp.producto_id = p.id
    AND mp.habilitado = true
    AND mp.precio_lista IS NOT NULL
    AND (p.ganancia_individual IS NULL OR p.ganancia_individual = 0);

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RETURN v_updated;
END;
$$ LANGUAGE plpgsql;

-- ============ COLUMNAS ADICIONALES ============
-- Columnas adicionales que el codigo necesita y no estan en el schema original

-- productos: campos extra
ALTER TABLE productos ADD COLUMN IF NOT EXISTS base TEXT DEFAULT 'crema';
ALTER TABLE productos ADD COLUMN IF NOT EXISTS brand TEXT DEFAULT 'Sin identificar';
ALTER TABLE productos ADD COLUMN IF NOT EXISTS sin_tacc BOOLEAN DEFAULT false;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS notes TEXT;

-- clientes: campo address y notes
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS address TEXT;

-- ventas: campos adicionales del flujo de ventas
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_cuit TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_dni TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_email TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_address TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_tax_category TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_phone TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_name TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'efectivo';
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS overpayment NUMERIC(12,2);
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS discount NUMERIC(12,2);
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS discount_type TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS delivery_method TEXT DEFAULT 'pickup';
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_emitted BOOLEAN DEFAULT false;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_drive_url TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_drive_file_id TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS remito_drive_url TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS remito_drive_file_id TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS seller_name TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS source TEXT DEFAULT 'direct';

-- comisiones: campos adicionales
ALTER TABLE comisiones ADD COLUMN IF NOT EXISTS sale_number TEXT;
ALTER TABLE comisiones ADD COLUMN IF NOT EXISTS client_name TEXT;

-- pedidos: campos adicionales
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS client_phone TEXT;
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS client_email TEXT;
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS delivery_method TEXT;
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS discount NUMERIC(12,2);
ALTER TABLE pedidos ADD COLUMN IF NOT EXISTS discount_type TEXT;

-- mayorista_productos: campos adicionales
ALTER TABLE mayorista_productos ADD COLUMN IF NOT EXISTS codigo_barras TEXT;
ALTER TABLE mayorista_productos ADD COLUMN IF NOT EXISTS nombre TEXT;
ALTER TABLE mayorista_productos ADD COLUMN IF NOT EXISTS rubro TEXT;
ALTER TABLE mayorista_productos ADD COLUMN IF NOT EXISTS subrubro TEXT;
ALTER TABLE mayorista_productos ADD COLUMN IF NOT EXISTS categoria TEXT;

-- caja: columnas del flujo apertura/cierre
ALTER TABLE caja ADD COLUMN IF NOT EXISTS opened_at TIMESTAMPTZ;
ALTER TABLE caja ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ;
ALTER TABLE caja ADD COLUMN IF NOT EXISTS opened_by TEXT;
ALTER TABLE caja ADD COLUMN IF NOT EXISTS closed_by TEXT;
ALTER TABLE caja ADD COLUMN IF NOT EXISTS initial_amount NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS final_amount NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS expected_amount NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS difference NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'open';
ALTER TABLE caja ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE caja ADD COLUMN IF NOT EXISTS sales_count INTEGER;
ALTER TABLE caja ADD COLUMN IF NOT EXISTS total_sales NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS cash_total NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS credit_total NUMERIC(12,2);
ALTER TABLE caja ADD COLUMN IF NOT EXISTS transfer_total NUMERIC(12,2);

-- ventas: columnas PDF
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_pdf_base64 TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_pdf_generated_at TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_filename TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_pdf_size INTEGER;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS remito_pdf_base64 TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS remito_pdf_generated_at TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS remito_filename TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS remito_pdf_size INTEGER;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS client_data JSONB;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS invoice_status TEXT;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS afip_data JSONB;

-- Permitir status adicionales en ventas (pendiente, listo para mayorista)
ALTER TABLE ventas DROP CONSTRAINT IF EXISTS ventas_status_check;

-- Permitir status adicionales en pedidos
ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS pedidos_status_check;

-- ============ CUENTA CORRIENTE / COBRANZAS ============
-- Migración: Cuenta Corriente + Cobranzas
-- Ejecutar en Supabase SQL Editor

-- 1. Agregar vendedor asignado a clientes
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS seller_id TEXT REFERENCES vendedores(id);
CREATE INDEX IF NOT EXISTS idx_clientes_seller_id ON clientes(seller_id);

-- 2. Tabla de comprobantes de pago
CREATE TABLE IF NOT EXISTS comprobantes_pago (
  id TEXT PRIMARY KEY,
  client_id TEXT NOT NULL REFERENCES clientes(id),
  seller_id TEXT NOT NULL REFERENCES vendedores(id),
  amount NUMERIC(12,2) NOT NULL,
  notes TEXT,
  file_url TEXT NOT NULL,
  file_name TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT,
  transaction_id TEXT REFERENCES transacciones(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comprobantes_status ON comprobantes_pago(status);
CREATE INDEX IF NOT EXISTS idx_comprobantes_seller ON comprobantes_pago(seller_id);
CREATE INDEX IF NOT EXISTS idx_comprobantes_client ON comprobantes_pago(client_id);

-- 3. Bucket de storage (crear manualmente en Supabase Dashboard):
-- Nombre: comprobantes
-- Public: false (acceso via signed URLs)
-- Allowed MIME types: image/jpeg, image/png, image/webp, application/pdf

-- ============ CLASIFICACION DEUDA ============
-- Agregar clasificación de deuda a clientes
-- Valores: 'normal' (default), 'moroso', 'incobrable'
ALTER TABLE clientes
ADD COLUMN IF NOT EXISTS debt_classification TEXT DEFAULT 'normal';

-- ============ PAGOS COMISIONES ============
-- Tabla para registrar los pagos/reseteos de comisiones
CREATE TABLE IF NOT EXISTS pagos_comisiones (
  id TEXT PRIMARY KEY,
  seller_id TEXT NOT NULL REFERENCES vendedores(id),
  seller_name TEXT NOT NULL,
  monto NUMERIC(12,2) NOT NULL,
  cantidad_comisiones INTEGER NOT NULL DEFAULT 0,
  nota TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pagos_comisiones_seller ON pagos_comisiones(seller_id);

-- ============ COLUMNAS OFERTAS (usadas por products-service) ============
ALTER TABLE productos ADD COLUMN IF NOT EXISTS precio_base NUMERIC(12,2);
ALTER TABLE productos ADD COLUMN IF NOT EXISTS descuento NUMERIC(8,2) DEFAULT 0;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS regalo_mismo BOOLEAN DEFAULT false;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS regalo_mismo_max NUMERIC(12,2);
ALTER TABLE productos ADD COLUMN IF NOT EXISTS regalo_otro_max NUMERIC(12,2);
ALTER TABLE productos ADD COLUMN IF NOT EXISTS regalo_producto_id TEXT;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS regalo_producto_nombre TEXT;
