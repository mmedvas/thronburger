'use strict';

const { getDb, resetMenu } = require('./db');

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

function nowLocal() {
  return getDb().prepare("SELECT datetime('now','localtime') AS ts").get().ts;
}

function todayRange() {
  const db = getDb();
  const row = db
    .prepare(
      "SELECT date('now','localtime') || ' 00:00:00' AS f, datetime('now','localtime') AS t"
    )
    .get();
  return { from: row.f, to: row.t };
}

// ---------------------------------------------------------------------------
// Menu
// ---------------------------------------------------------------------------

function listMenu({ activeOnly = false } = {}) {
  const db = getDb();
  const where = activeOnly ? 'WHERE active = 1' : '';
  const rows = db
    .prepare(
      `SELECT id, name, category, price, tag, active, image, ingredients, extras
       FROM menu_items ${where}
       ORDER BY category, name`
    )
    .all();
  // Parse the JSON ingredient/extras lists into arrays for the renderer.
  for (const r of rows) {
    try { r.ingredients = r.ingredients ? JSON.parse(r.ingredients) : []; }
    catch (_) { r.ingredients = []; }
    try { r.extras = r.extras ? JSON.parse(r.extras) : []; }
    catch (_) { r.extras = []; }
  }
  return rows;
}

// Accept an array or a comma-separated string; store a JSON array string ('' when empty).
function ingredientsToJson(val) {
  let list = [];
  if (Array.isArray(val)) list = val;
  else if (typeof val === 'string') list = val.split(',');
  list = list.map((s) => String(s).trim()).filter(Boolean);
  return list.length ? JSON.stringify(list) : '';
}

// Normalize extras (array of {name, price}) to a JSON string ('' when empty).
function extrasToJson(val) {
  if (!Array.isArray(val)) return '';
  const list = val
    .map((e) => ({ name: String(e.name || '').trim(), price: Math.round(Number(e.price) || 0) }))
    .filter((e) => e.name);
  return list.length ? JSON.stringify(list) : '';
}

function addMenuItem({ name, category, price, tag = '', image = '', ingredients, extras }) {
  const db = getDb();
  const info = db
    .prepare(
      'INSERT INTO menu_items (name, category, price, tag, active, image, ingredients, extras) VALUES (?, ?, ?, ?, 1, ?, ?, ?)'
    )
    .run(String(name).trim(), category, Math.round(price), tag || '', image || '', ingredientsToJson(ingredients), extrasToJson(extras));
  return { id: info.lastInsertRowid };
}

function updateMenuItem({ id, name, price, tag, category, image, ingredients, extras }) {
  const db = getDb();
  const cur = db.prepare('SELECT * FROM menu_items WHERE id = ?').get(id);
  if (!cur) throw new Error('Menu item not found');
  db.prepare(
    'UPDATE menu_items SET name = ?, price = ?, tag = ?, category = ?, image = ?, ingredients = ?, extras = ? WHERE id = ?'
  ).run(
    name !== undefined ? String(name).trim() : cur.name,
    price !== undefined ? Math.round(price) : cur.price,
    tag !== undefined ? tag : cur.tag,
    category !== undefined ? category : cur.category,
    image !== undefined ? image : cur.image,
    ingredients !== undefined ? ingredientsToJson(ingredients) : (cur.ingredients || ''),
    extras !== undefined ? extrasToJson(extras) : (cur.extras || ''),
    id
  );
  return { ok: true };
}

function setMenuActive({ id, active }) {
  getDb().prepare('UPDATE menu_items SET active = ? WHERE id = ?').run(active ? 1 : 0, id);
  return { ok: true };
}

function resetMenuToDefault() {
  resetMenu();
  return { ok: true };
}

// ---------------------------------------------------------------------------
// Categories (add / rename / delete / (de)activate)
// ---------------------------------------------------------------------------

function slugify(s) {
  return String(s).toLowerCase().trim().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
}

function listCategories({ activeOnly = false } = {}) {
  const where = activeOnly ? 'WHERE active = 1' : '';
  return getDb()
    .prepare(`SELECT id, key, label, sort_order, active FROM categories ${where} ORDER BY sort_order, id`)
    .all();
}

function addCategory({ label }) {
  const db = getDb();
  const name = String(label || '').trim();
  if (!name) throw new Error('Category name is required');
  let key = slugify(name);
  if (!key) throw new Error('Category name must contain letters or numbers');
  // Ensure a unique key.
  const exists = (k) => db.prepare('SELECT 1 FROM categories WHERE key = ?').get(k);
  if (exists(key)) {
    let i = 2;
    while (exists(key + '_' + i)) i++;
    key = key + '_' + i;
  }
  const maxOrder = db.prepare('SELECT COALESCE(MAX(sort_order), 0) AS m FROM categories').get().m;
  const info = db
    .prepare('INSERT INTO categories (key, label, sort_order, active) VALUES (?, ?, ?, 1)')
    .run(key, name, maxOrder + 1);
  return { id: info.lastInsertRowid, key };
}

function renameCategory({ id, label }) {
  const name = String(label || '').trim();
  if (!name) throw new Error('Category name is required');
  getDb().prepare('UPDATE categories SET label = ? WHERE id = ?').run(name, id);
  return { ok: true };
}

function setCategoryActive({ id, active }) {
  getDb().prepare('UPDATE categories SET active = ? WHERE id = ?').run(active ? 1 : 0, id);
  return { ok: true };
}

function deleteCategory({ id }) {
  const db = getDb();
  const cat = db.prepare('SELECT key FROM categories WHERE id = ?').get(id);
  if (!cat) return { ok: true };
  const inUse = db.prepare('SELECT COUNT(*) AS n FROM menu_items WHERE category = ?').get(cat.key).n;
  if (inUse > 0) throw new Error(`Category is used by ${inUse} item(s). Move or delete them first.`);
  db.prepare('DELETE FROM categories WHERE id = ?').run(id);
  return { ok: true };
}

// ---------------------------------------------------------------------------
// Staff / auth
// ---------------------------------------------------------------------------

function verifyPin(pin) {
  const s = getDb()
    .prepare('SELECT id, name, role FROM staff WHERE pin = ? AND active = 1')
    .get(String(pin));
  return s || null;
}

/** True when the supplied PIN belongs to an active admin (used for voids). */
function isAdminPin(pin) {
  const s = getDb()
    .prepare("SELECT id FROM staff WHERE pin = ? AND role = 'admin' AND active = 1")
    .get(String(pin));
  return !!s;
}

/** True when the given staff id is an active admin. */
function isAdminStaff(id) {
  const s = getDb()
    .prepare("SELECT id FROM staff WHERE id = ? AND role = 'admin' AND active = 1")
    .get(id);
  return !!s;
}

function listStaff() {
  return getDb().prepare('SELECT id, name, pin, role, active FROM staff ORDER BY id').all();
}

function addStaff({ name, pin, role = 'cashier' }) {
  if (!/^\d{4}$/.test(String(pin))) throw new Error('PIN must be exactly 4 digits');
  const db = getDb();
  const info = db
    .prepare('INSERT INTO staff (name, pin, role, active) VALUES (?, ?, ?, 1)')
    .run(String(name).trim(), String(pin), role);
  return { id: info.lastInsertRowid };
}

function setStaffActive({ id, active }) {
  getDb().prepare('UPDATE staff SET active = ? WHERE id = ?').run(active ? 1 : 0, id);
  return { ok: true };
}

function changePin({ id, pin }) {
  if (!/^\d{4}$/.test(String(pin))) throw new Error('PIN must be exactly 4 digits');
  getDb().prepare('UPDATE staff SET pin = ? WHERE id = ?').run(String(pin), id);
  return { ok: true };
}

// ---------------------------------------------------------------------------
// Orders
// ---------------------------------------------------------------------------

function createOrder(payload) {
  const db = getDb();
  const {
    order_type,
    table_no = '',
    customer = '',
    staff_id,
    payment_method,
    discount_pct = 0,
    items = [],
  } = payload;

  if (!items.length) throw new Error('Cannot save an empty order');

  const subtotal = items.reduce((s, it) => s + Math.round(it.price) * Math.round(it.qty), 0);
  const disc = Number(discount_pct) || 0;
  const total = Math.round(subtotal * (1 - disc / 100));

  const tx = db.transaction(() => {
    const info = db
      .prepare(
        `INSERT INTO orders
          (order_type, table_no, customer, staff_id, payment_method,
           subtotal, discount_pct, total, voided)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)`
      )
      .run(order_type, table_no, customer, staff_id, payment_method, subtotal, disc, total);
    const orderId = info.lastInsertRowid;
    const insItem = db.prepare(
      `INSERT INTO order_items (order_id, item_name, category, price, qty, note)
       VALUES (?, ?, ?, ?, ?, ?)`
    );
    for (const it of items) {
      insItem.run(orderId, it.item_name, it.category, Math.round(it.price), Math.round(it.qty), it.note || '');
    }
    return orderId;
  });

  const id = tx();
  return getOrder(id);
}

function getOrder(id) {
  const db = getDb();
  const order = db
    .prepare(
      `SELECT o.*, s.name AS staff_name
       FROM orders o LEFT JOIN staff s ON s.id = o.staff_id
       WHERE o.id = ?`
    )
    .get(id);
  if (!order) return null;
  // Best-effort spicy tag for the kitchen ticket: order_items is a snapshot and
  // does not store the tag, so look it up from the current menu by name.
  order.items = db
    .prepare(
      `SELECT oi.*,
              (SELECT m.tag FROM menu_items m WHERE m.name = oi.item_name LIMIT 1) AS tag
       FROM order_items oi WHERE oi.order_id = ? ORDER BY oi.id`
    )
    .all(id);
  return order;
}

function listOrders({ limit = 300 } = {}) {
  return getDb()
    .prepare(
      `SELECT o.id, o.created_at, o.order_type, o.table_no, o.customer,
              o.payment_method, o.total, o.voided, s.name AS staff_name
       FROM orders o LEFT JOIN staff s ON s.id = o.staff_id
       ORDER BY o.id DESC
       LIMIT ?`
    )
    .all(limit);
}

function voidOrder({ id, adminPin, staffId }) {
  // Allowed if an admin is already logged in, or a valid admin PIN is supplied.
  const allowed = (staffId && isAdminStaff(staffId)) || (adminPin && isAdminPin(adminPin));
  if (!allowed) throw new Error('Admin PIN required to void an order');
  getDb().prepare('UPDATE orders SET voided = 1 WHERE id = ?').run(id);
  return { ok: true };
}

// ---------------------------------------------------------------------------
// Reports (all exclude voided orders)
// ---------------------------------------------------------------------------

function reportSummary({ from, to } = {}) {
  const db = getDb();
  const range = from && to ? { from, to } : todayRange();
  const p = [range.from, range.to];
  const base = 'FROM orders o WHERE o.voided = 0 AND o.created_at BETWEEN ? AND ?';

  const kpi = db
    .prepare(
      `SELECT COALESCE(SUM(o.total),0) AS revenue,
              COUNT(*) AS orders,
              COALESCE(SUM(o.total),0) * 1.0 / NULLIF(COUNT(*),0) AS avg_order
       ${base}`
    )
    .get(...p);

  const itemsSold = db
    .prepare(
      `SELECT COALESCE(SUM(oi.qty),0) AS n
       FROM order_items oi JOIN orders o ON o.id = oi.order_id
       WHERE o.voided = 0 AND o.created_at BETWEEN ? AND ?`
    )
    .get(...p).n;

  const topItems = db
    .prepare(
      `SELECT oi.item_name AS label, SUM(oi.qty) AS qty, SUM(oi.qty*oi.price) AS revenue
       FROM order_items oi JOIN orders o ON o.id = oi.order_id
       WHERE o.voided = 0 AND o.created_at BETWEEN ? AND ?
       GROUP BY oi.item_name ORDER BY qty DESC LIMIT 10`
    )
    .all(...p);

  const byCategory = db
    .prepare(
      `SELECT oi.category AS label, SUM(oi.qty*oi.price) AS revenue
       FROM order_items oi JOIN orders o ON o.id = oi.order_id
       WHERE o.voided = 0 AND o.created_at BETWEEN ? AND ?
       GROUP BY oi.category ORDER BY revenue DESC`
    )
    .all(...p);

  const byType = db
    .prepare(`SELECT o.order_type AS label, COUNT(*) AS orders ${base} GROUP BY o.order_type`)
    .all(...p);

  const byHour = db
    .prepare(
      `SELECT strftime('%H', o.created_at) AS label, SUM(o.total) AS revenue
       ${base} GROUP BY label ORDER BY label`
    )
    .all(...p);

  const byCashier = db
    .prepare(
      `SELECT COALESCE(s.name,'—') AS label, SUM(o.total) AS revenue
       FROM orders o LEFT JOIN staff s ON s.id = o.staff_id
       WHERE o.voided = 0 AND o.created_at BETWEEN ? AND ?
       GROUP BY o.staff_id ORDER BY revenue DESC`
    )
    .all(...p);

  const byPayment = db
    .prepare(`SELECT o.payment_method AS label, SUM(o.total) AS revenue ${base} GROUP BY o.payment_method`)
    .all(...p);

  return {
    range,
    kpi: {
      revenue: kpi.revenue,
      orders: kpi.orders,
      avg_order: Math.round(kpi.avg_order || 0),
      items_sold: itemsSold,
    },
    topItems,
    byCategory,
    byType,
    byHour,
    byCashier,
    byPayment,
  };
}

// ---------------------------------------------------------------------------
// Z-Reports
// ---------------------------------------------------------------------------

function lastZReport() {
  return getDb().prepare('SELECT * FROM z_reports ORDER BY id DESC LIMIT 1').get() || null;
}

/** Build (but do not save) the Z-report covering everything since the last one. */
function computeZReport() {
  const db = getDb();
  const last = lastZReport();
  // Lower bound is EXCLUSIVE of the previous Z-report's cutoff (so nothing is
  // reported twice). For the first-ever Z-report there is no lower bound, so
  // every order up to now is included — a strict "> earliest order" would wrong
  // ly drop the very first orders that share that timestamp.
  const lo = last ? last.to_ts : null;
  const to = nowLocal();
  // Displayed "from": previous cutoff, else the earliest order, else now.
  const from =
    lo ||
    db.prepare("SELECT COALESCE(MIN(created_at), ?) AS f FROM orders").get(to).f;

  const loClause = lo ? 'created_at > @lo AND ' : '';
  const params = lo ? { lo, hi: to } : { hi: to };

  const totals = db
    .prepare(
      `SELECT COALESCE(SUM(total),0) AS revenue, COUNT(*) AS orders,
              COALESCE(SUM(CASE WHEN payment_method='cash' THEN total ELSE 0 END),0) AS cash,
              COALESCE(SUM(CASE WHEN payment_method='card' THEN total ELSE 0 END),0) AS card
       FROM orders WHERE voided = 0 AND ${loClause}created_at <= @hi`
    )
    .get(params);

  const voidedCount = db
    .prepare(`SELECT COUNT(*) AS n FROM orders WHERE voided = 1 AND ${loClause}created_at <= @hi`)
    .get(params).n;

  const perCashier = db
    .prepare(
      `SELECT COALESCE(s.name,'—') AS name, SUM(o.total) AS revenue
       FROM orders o LEFT JOIN staff s ON s.id = o.staff_id
       WHERE o.voided = 0 AND ${loClause ? 'o.created_at > @lo AND ' : ''}o.created_at <= @hi
       GROUP BY o.staff_id ORDER BY revenue DESC`
    )
    .all(params);

  const perCategory = db
    .prepare(
      `SELECT oi.category AS category, SUM(oi.qty*oi.price) AS revenue
       FROM order_items oi JOIN orders o ON o.id = oi.order_id
       WHERE o.voided = 0 AND ${loClause ? 'o.created_at > @lo AND ' : ''}o.created_at <= @hi
       GROUP BY oi.category ORDER BY revenue DESC`
    )
    .all(params);

  return {
    from_ts: from,
    to_ts: to,
    revenue: totals.revenue,
    orders: totals.orders,
    avg_order: totals.orders ? Math.round(totals.revenue / totals.orders) : 0,
    cash: totals.cash,
    card: totals.card,
    voided_count: voidedCount,
    per_cashier: perCashier,
    per_category: perCategory,
  };
}

function saveZReport(data) {
  const db = getDb();
  const info = db
    .prepare('INSERT INTO z_reports (from_ts, to_ts, totals_json) VALUES (?, ?, ?)')
    .run(data.from_ts, data.to_ts, JSON.stringify(data));
  return getZReport(info.lastInsertRowid);
}

function listZReports() {
  return getDb()
    .prepare('SELECT id, created_at, from_ts, to_ts FROM z_reports ORDER BY id DESC')
    .all();
}

function getZReport(id) {
  const row = getDb().prepare('SELECT * FROM z_reports WHERE id = ?').get(id);
  if (!row) return null;
  const data = JSON.parse(row.totals_json);
  return { id: row.id, created_at: row.created_at, ...data };
}

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

function getSettings() {
  const rows = getDb().prepare('SELECT key, value FROM settings').all();
  const out = {};
  for (const r of rows) out[r.key] = r.value;
  return out;
}

function setSetting({ key, value }) {
  getDb()
    .prepare(
      'INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value'
    )
    .run(key, value == null ? '' : String(value));
  return { ok: true };
}

module.exports = {
  // menu
  listMenu, addMenuItem, updateMenuItem, setMenuActive, resetMenuToDefault,
  // categories
  listCategories, addCategory, renameCategory, setCategoryActive, deleteCategory,
  // staff
  verifyPin, isAdminPin, listStaff, addStaff, setStaffActive, changePin,
  // orders
  createOrder, getOrder, listOrders, voidOrder,
  // reports
  reportSummary, computeZReport, saveZReport, listZReports, getZReport,
  // settings
  getSettings, setSetting,
};
