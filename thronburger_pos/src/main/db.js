'use strict';

const path = require('path');
const fs = require('fs');
const Database = require('better-sqlite3');
const { MENU_ITEMS, DEFAULT_SETTINGS } = require('./seed');
const IMAGES = require('./seed-images'); // { itemName: dataURI }
const INGREDIENTS = require('./seed-ingredients'); // { itemName: [ingredient, ...] }

let db = null;

const SCHEMA = `
-- Categories are data (add/delete from the Menu screen), not a fixed enum.
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,         -- stable slug stored on menu_items.category
  label TEXT NOT NULL,              -- display name
  sort_order INTEGER DEFAULT 0,
  active INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT NOT NULL,           -- references categories.key (not a fixed enum)
  price INTEGER NOT NULL,
  tag TEXT DEFAULT '',
  active INTEGER DEFAULT 1,
  image TEXT DEFAULT '',            -- resized base64 thumbnail (data URI), offline
  ingredients TEXT DEFAULT '',      -- JSON array of removable ingredients
  extras TEXT DEFAULT ''            -- JSON array of paid add-ons [{name, price}]
);

CREATE TABLE IF NOT EXISTS staff (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  pin TEXT NOT NULL UNIQUE,
  role TEXT CHECK(role IN ('admin','cashier')) DEFAULT 'cashier',
  active INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT DEFAULT (datetime('now','localtime')),
  order_type TEXT CHECK(order_type IN ('dinein','takeaway','delivery')),
  table_no TEXT DEFAULT '',
  customer TEXT DEFAULT '',
  staff_id INTEGER REFERENCES staff(id),
  payment_method TEXT CHECK(payment_method IN ('cash','card')),
  subtotal INTEGER NOT NULL,
  discount_pct REAL DEFAULT 0,
  total INTEGER NOT NULL,
  voided INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER REFERENCES orders(id),
  item_name TEXT NOT NULL,
  category TEXT NOT NULL,
  price INTEGER NOT NULL,
  qty INTEGER NOT NULL,
  note TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS z_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at TEXT DEFAULT (datetime('now','localtime')),
  from_ts TEXT NOT NULL,
  to_ts TEXT NOT NULL,
  totals_json TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT
);

CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_staff ON orders(staff_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
`;

/**
 * Open (or create) the database at the given file path and ensure the schema
 * and first-run seed data exist. Idempotent — safe to call once at startup.
 */
function initDb(dbPath) {
  db = new Database(dbPath);
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');
  db.exec(SCHEMA);
  migrate();
  seedIfEmpty();
  backfillImages();
  backfillIngredients();
  backfillExtras();
  return db;
}

function getDb() {
  if (!db) throw new Error('Database not initialized. Call initDb() first.');
  return db;
}

/** Add columns that were introduced after the first release. */
function migrate() {
  const cols = db.prepare('PRAGMA table_info(menu_items)').all();
  if (!cols.some((c) => c.name === 'image')) {
    db.exec("ALTER TABLE menu_items ADD COLUMN image TEXT DEFAULT ''");
  }
  if (!cols.some((c) => c.name === 'ingredients')) {
    db.exec("ALTER TABLE menu_items ADD COLUMN ingredients TEXT DEFAULT ''");
  }
  if (!cols.some((c) => c.name === 'extras')) {
    db.exec("ALTER TABLE menu_items ADD COLUMN extras TEXT DEFAULT ''");
  }
  dropCategoryCheck();
}

// Older databases created menu_items with a fixed CHECK on category. Rebuild
// the table without it so custom categories can be added.
function dropCategoryCheck() {
  const row = db.prepare("SELECT sql FROM sqlite_master WHERE type='table' AND name='menu_items'").get();
  if (!row || !/CHECK\s*\(\s*category/i.test(row.sql)) return;
  const tx = db.transaction(() => {
    db.exec(`CREATE TABLE menu_items_new (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      price INTEGER NOT NULL,
      tag TEXT DEFAULT '',
      active INTEGER DEFAULT 1,
      image TEXT DEFAULT '',
      ingredients TEXT DEFAULT '',
      extras TEXT DEFAULT ''
    )`);
    db.exec(`INSERT INTO menu_items_new (id, name, category, price, tag, active, image, ingredients, extras)
             SELECT id, name, category, price, tag, active,
                    COALESCE(image, ''), COALESCE(ingredients, ''), COALESCE(extras, '') FROM menu_items`);
    db.exec('DROP TABLE menu_items');
    db.exec('ALTER TABLE menu_items_new RENAME TO menu_items');
    db.exec('CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id)');
  });
  tx();
}

const DEFAULT_CATEGORIES = [
  { key: 'beef', label: 'Beef' },
  { key: 'smash', label: 'Smash' },
  { key: 'chicken', label: 'Chicken' },
  { key: 'hotdog', label: 'Hot Dogs' },
  { key: 'fingers', label: 'Fingers' },
  { key: 'drinks', label: 'Drinks' },
];

function seedIfEmpty() {
  seedCategories();
  seedMenu();
  seedStaff();
  seedSettings();
}

function seedCategories() {
  const count = db.prepare('SELECT COUNT(*) AS n FROM categories').get().n;
  if (count > 0) return;
  const insert = db.prepare('INSERT INTO categories (key, label, sort_order, active) VALUES (?, ?, ?, 1)');
  const tx = db.transaction(() => {
    DEFAULT_CATEGORIES.forEach((c, i) => insert.run(c.key, c.label, i + 1));
  });
  tx();
}

/** Insert the default menu only when the table is empty (first run / reset). */
function seedMenu() {
  const count = db.prepare('SELECT COUNT(*) AS n FROM menu_items').get().n;
  if (count > 0) return;
  const insert = db.prepare(
    'INSERT INTO menu_items (name, category, price, tag, active, image, ingredients, extras) VALUES (?, ?, ?, ?, 1, ?, ?, ?)'
  );
  const tx = db.transaction((items) => {
    for (const it of items) {
      insert.run(it.name, it.category, it.price, it.tag || '', IMAGES[it.name] || '', ingredientsJson(it.name), extrasJson(it.category));
    }
  });
  tx(MENU_ITEMS);
}

function ingredientsJson(name) {
  const list = INGREDIENTS[name];
  return list && list.length ? JSON.stringify(list) : '';
}

// Example paid extras per category (owner can edit/add/remove in the Menu).
const DEFAULT_EXTRAS = {
  beef: [{ name: 'Extra cheese', price: 2000 }, { name: 'Extra sauce', price: 1000 }],
  smash: [{ name: 'Extra cheese', price: 2000 }, { name: 'Extra sauce', price: 1000 }],
  chicken: [{ name: 'Extra cheese', price: 2000 }, { name: 'Extra sauce', price: 1000 }],
  hotdog: [{ name: 'Extra cheese', price: 2000 }],
  fingers: [{ name: 'Extra sauce', price: 1000 }],
};

function extrasJson(category) {
  const list = DEFAULT_EXTRAS[category];
  return list && list.length ? JSON.stringify(list) : '';
}

function backfillExtras() {
  const flag = db.prepare("SELECT value FROM settings WHERE key = 'extras_seeded'").get();
  if (flag && flag.value === '1') return;
  const upd = db.prepare("UPDATE menu_items SET extras = ? WHERE category = ? AND (extras IS NULL OR extras = '')");
  const tx = db.transaction(() => {
    for (const [cat, list] of Object.entries(DEFAULT_EXTRAS)) upd.run(JSON.stringify(list), cat);
    db.prepare("INSERT INTO settings (key, value) VALUES ('extras_seeded', '1') ON CONFLICT(key) DO UPDATE SET value = '1'").run();
  });
  tx();
}

/** Seed the single default admin (name "Admin", pin "1234"). */
function seedStaff() {
  const count = db.prepare('SELECT COUNT(*) AS n FROM staff').get().n;
  if (count > 0) return;
  db.prepare(
    "INSERT INTO staff (name, pin, role, active) VALUES ('Admin', '1234', 'admin', 1)"
  ).run();
}

/**
 * One-time: fill photos for any items that don't have one yet, matched by name.
 * Guarded by a settings flag so it never fights a photo the user removed later.
 */
function backfillImages() {
  const flag = db.prepare("SELECT value FROM settings WHERE key = 'images_seeded'").get();
  if (flag && flag.value === '1') return;
  const upd = db.prepare("UPDATE menu_items SET image = ? WHERE name = ? AND (image IS NULL OR image = '')");
  const tx = db.transaction(() => {
    for (const [name, uri] of Object.entries(IMAGES)) upd.run(uri, name);
    db.prepare(
      "INSERT INTO settings (key, value) VALUES ('images_seeded', '1') ON CONFLICT(key) DO UPDATE SET value = '1'"
    ).run();
  });
  tx();
}

/** One-time: fill default ingredients for items that don't have any yet. */
function backfillIngredients() {
  const flag = db.prepare("SELECT value FROM settings WHERE key = 'ingredients_seeded'").get();
  if (flag && flag.value === '1') return;
  const upd = db.prepare("UPDATE menu_items SET ingredients = ? WHERE name = ? AND (ingredients IS NULL OR ingredients = '')");
  const tx = db.transaction(() => {
    for (const [name, list] of Object.entries(INGREDIENTS)) {
      if (list && list.length) upd.run(JSON.stringify(list), name);
    }
    db.prepare(
      "INSERT INTO settings (key, value) VALUES ('ingredients_seeded', '1') ON CONFLICT(key) DO UPDATE SET value = '1'"
    ).run();
  });
  tx();
}

function seedSettings() {
  const upsert = db.prepare(
    'INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO NOTHING'
  );
  for (const [k, v] of Object.entries(DEFAULT_SETTINGS)) upsert.run(k, v);
}

/**
 * Wipe the menu and re-seed the default menu. Used by the "Reset to default
 * menu" button. Orders keep their own item snapshots, so history is unaffected.
 */
function resetMenu() {
  const tx = db.transaction(() => {
    db.prepare('DELETE FROM menu_items').run();
    db.prepare("DELETE FROM sqlite_sequence WHERE name = 'menu_items'").run();
    const insert = db.prepare(
      'INSERT INTO menu_items (name, category, price, tag, active, image, ingredients, extras) VALUES (?, ?, ?, ?, 1, ?, ?, ?)'
    );
    for (const it of MENU_ITEMS) {
      insert.run(it.name, it.category, it.price, it.tag || '', IMAGES[it.name] || '', ingredientsJson(it.name), extrasJson(it.category));
    }
  });
  tx();
}

module.exports = { initDb, getDb, resetMenu };
