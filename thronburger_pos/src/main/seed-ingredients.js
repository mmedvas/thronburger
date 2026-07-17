'use strict';

// Default ingredient lists per item, transcribed from the printed Thronburger
// menu. Used to seed menu_items.ingredients and to backfill existing databases.
// Cashiers can remove any of these per order (prints as "No <ingredient>").
// Items not on the printed menu (smash, fingers, tortilla, drinks) start empty
// and can be filled in from the Menu screen.

module.exports = {
  // ── Beef Burgers ────────────────────────────────────────────────
  'Classic Burger': ['beef', 'red onions', 'tomato', 'pickle', 'salad', 'fried onions', 'special sauce'],
  'Cheese Burger': ['beef', 'cheese', 'red onions', 'tomato', 'pickle', 'salad', 'fried onions', 'special sauce'],
  'Double Beef Chili Burger': ['double beef', 'double cheese', 'red onions', 'tomato', 'salad', 'fried onions', 'jalapenos', 'special sauce'],
  'Spicy Mexican Burger': ['beef', 'cheese', 'red onions', 'tomato', 'pickle', 'salad', 'fried onions', 'mexican sauce'],
  'Egg Burger': ['beef', 'cheese', 'egg', 'red onions', 'tomato', 'pickle', 'salad', 'fried onions', 'special sauce'],
  'Berlin Burger': ['beef', 'cheese', 'red onions', 'tomato', 'eggplant', 'pickle', 'salad', 'courgette', 'pepper', 'potato', 'fried onions', 'breaded mozzarella', 'special sauce'],
  'Special Burger': ['beef', 'cheese', 'red onions', 'tomato', 'eggplant', 'pickle', 'salad', 'courgette', 'pepper', 'potato', 'fried onions', 'halloumi cheese', 'special sauce'],

  // ── Chicken Burgers ─────────────────────────────────────────────
  'Chicken Cheese': ['chicken', 'cheese', 'red onions', 'tomato', 'pickle', 'salad', 'fried onions', 'special sauce'],
  'Crispy Chicken': ['crispy chicken', 'cheese', 'red onions', 'tomato', 'pickle', 'salad', 'fried onions', 'special sauce'],

  // ── Hot Dogs ────────────────────────────────────────────────────
  'Classic Hot Dog': ['beef', 'fried onions', 'pickle', 'special sauce'],
  'Chili Cheese Hot Dog': ['beef', 'cheese', 'fried onions', 'jalapenos', 'special sauce'],
  'Spicy Mexican Hot Dog': ['beef', 'cheese', 'fried onions', 'jalapenos', 'mexican sauce'],
};
