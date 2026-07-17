'use strict';

// ---------------------------------------------------------------------------
// Seed data for first run.
//
// Menu ported verbatim (names + IQD prices) from the live Thronburger source
// of truth: thronburger_app/seed_menu.js + seed_menu_additions.js.
//
// Category mapping to the six POS categories (beef, smash, chicken, hotdog,
// fingers, drinks):
//   - live "burgers"  -> "beef"
//   - live "hotdogs"  -> "hotdog"
//   - live "tortilla" -> "chicken"  (single item folded in; editable in Menu)
//   - smash / chicken / fingers / drinks unchanged
//
// Spicy items receive tags ('scharf' for Mexican-style, 'Chili' for chili).
// Nothing here is read at runtime after the first seed — the menu_items table
// is the single source of truth thereafter.
// ---------------------------------------------------------------------------

const MENU_ITEMS = [
  // ── Beef Burgers ────────────────────────────────────────────────
  { name: 'Classic Burger', category: 'beef', price: 8000, tag: '' },
  { name: 'Cheese Burger', category: 'beef', price: 8500, tag: '' },
  { name: 'Double Beef Chili Burger', category: 'beef', price: 11000, tag: 'Chili' },
  { name: 'Spicy Mexican Burger', category: 'beef', price: 9000, tag: 'scharf' },
  { name: 'Egg Burger', category: 'beef', price: 9000, tag: '' },
  { name: 'Berlin Burger', category: 'beef', price: 13000, tag: '' },
  { name: 'Special Burger', category: 'beef', price: 13000, tag: '' },

  // ── Smash Burgers ───────────────────────────────────────────────
  { name: 'Original', category: 'smash', price: 7000, tag: '' },
  { name: 'Double', category: 'smash', price: 8500, tag: '' },
  { name: 'Chili', category: 'smash', price: 7500, tag: 'Chili' },
  { name: 'Spicy Mexican', category: 'smash', price: 7500, tag: 'scharf' },
  { name: 'Egg', category: 'smash', price: 7500, tag: '' },

  // ── Chicken Burgers ─────────────────────────────────────────────
  { name: 'Chicken Cheese', category: 'chicken', price: 6500, tag: '' },
  { name: 'Crispy Chicken', category: 'chicken', price: 6000, tag: '' },
  { name: 'Tortilla', category: 'chicken', price: 7500, tag: '' },

  // ── Hot Dogs ────────────────────────────────────────────────────
  { name: 'Classic Hot Dog', category: 'hotdog', price: 5000, tag: '' },
  { name: 'Chili Cheese Hot Dog', category: 'hotdog', price: 5500, tag: 'Chili' },
  { name: 'Spicy Mexican Hot Dog', category: 'hotdog', price: 5500, tag: 'scharf' },

  // ── Fingers / Sides ─────────────────────────────────────────────
  { name: 'French Fries', category: 'fingers', price: 3500, tag: '' },
  { name: 'Curly Fries', category: 'fingers', price: 4500, tag: '' },
  { name: 'Onion Rings (8pcs)', category: 'fingers', price: 5000, tag: '' },
  { name: 'Mozzarella Sticks (6pcs)', category: 'fingers', price: 5000, tag: '' },
  { name: 'Hot Wings (6pcs)', category: 'fingers', price: 5000, tag: 'scharf' },
  { name: 'Chicken Nuggets (8pcs)', category: 'fingers', price: 5000, tag: '' },

  // ── Drinks ──────────────────────────────────────────────────────
  { name: 'Water', category: 'drinks', price: 500, tag: '' },
  { name: 'Coca Cola', category: 'drinks', price: 1000, tag: '' },
];

const DEFAULT_SETTINGS = {
  language: 'en',
  cashier_printer: '',
  kitchen_printer: '',
};

module.exports = { MENU_ITEMS, DEFAULT_SETTINGS };
