'use strict';

// ---------------------------------------------------------------------------
// Builds the printable HTML for the 80mm customer receipt and kitchen ticket.
// Pure formatting only — receives an already-loaded order object (with its
// snapshotted items) plus the language code. No DB access here.
//
// Each order item may carry a `tag` (e.g. 'scharf' / 'Chili') copied from the
// menu at sale time; the kitchen ticket surfaces it prominently.
// ---------------------------------------------------------------------------

const BUSINESS = {
  name: 'THRONBURGER',
  tagline: 'Berlin × Hewlêr — Empire City, Erbil',
};

// Minimal on-ticket label translations (kept local so printed documents are
// correct regardless of renderer state).
const L = {
  en: {
    order: 'Order', table: 'Table', cashier: 'Cashier', subtotal: 'Subtotal',
    discount: 'Discount', total: 'TOTAL', payment: 'Payment', cash: 'Cash', card: 'Card',
    dinein: 'Dine-in', takeaway: 'Takeaway', delivery: 'Delivery',
    thanks: 'Thank you! / Danke!', customer: 'Customer',
  },
  de: {
    order: 'Bestellung', table: 'Tisch', cashier: 'Kassierer', subtotal: 'Zwischensumme',
    discount: 'Rabatt', total: 'GESAMT', payment: 'Zahlung', cash: 'Bar', card: 'Karte',
    dinein: 'Vor Ort', takeaway: 'Zum Mitnehmen', delivery: 'Lieferung',
    thanks: 'Thank you! / Danke!', customer: 'Kunde',
  },
  tr: {
    order: 'Sipariş', table: 'Masa', cashier: 'Kasiyer', subtotal: 'Ara Toplam',
    discount: 'İndirim', total: 'TOPLAM', payment: 'Ödeme', cash: 'Nakit', card: 'Kart',
    dinein: 'Masada', takeaway: 'Paket', delivery: 'Kurye',
    thanks: 'Thank you! / Danke!', customer: 'Müşteri',
  },
};

function esc(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function iqd(n) {
  return Number(n || 0).toLocaleString('en-US') + ' IQD';
}

function fmtDateTime(ts) {
  // ts is "YYYY-MM-DD HH:MM:SS" — already local time; display as-is.
  return esc(ts || '');
}

function fmtTime(ts) {
  const m = /\d{2}:\d{2}/.exec(ts || '');
  return m ? m[0] : '';
}

function typeLabel(t, lang) {
  return (L[lang] || L.en)[t] || t;
}

// ---------------------------------------------------------------------------
// Customer receipt (80mm)
// ---------------------------------------------------------------------------

function customerReceiptHtml(order, lang = 'en') {
  const t = L[lang] || L.en;
  const rows = order.items
    .map((it) => {
      const line = Math.round(it.price) * Math.round(it.qty);
      const note = it.note ? `<div class="note">↳ ${esc(it.note)}</div>` : '';
      return `<tr class="item">
          <td class="qn">${it.qty}× ${esc(it.item_name)}${note}</td>
          <td class="lp">${iqd(line)}</td>
        </tr>`;
    })
    .join('');

  const discountRow =
    order.discount_pct && order.discount_pct > 0
      ? `<tr><td>${t.discount} (${order.discount_pct}%)</td><td class="r">−${iqd(order.subtotal - order.total)}</td></tr>`
      : '';

  return baseDoc('receipt', `
    <div class="brand">
      <div class="logo">${BUSINESS.name}</div>
      <div class="tag">${BUSINESS.tagline}</div>
    </div>
    <div class="hr"></div>
    <div class="meta">
      <div><b>${t.order} #${order.id}</b></div>
      <div>${fmtDateTime(order.created_at)}</div>
      <div>${typeLabel(order.order_type, lang)}${order.table_no ? ' · ' + t.table + ' ' + esc(order.table_no) : ''}</div>
      ${order.customer ? `<div>${t.customer}: ${esc(order.customer)}</div>` : ''}
      <div>${t.cashier}: ${esc(order.staff_name || '')}</div>
    </div>
    <div class="hr"></div>
    <table class="items">${rows}</table>
    <div class="hr"></div>
    <table class="totals">
      <tr><td>${t.subtotal}</td><td class="r">${iqd(order.subtotal)}</td></tr>
      ${discountRow}
      <tr class="grand"><td>${t.total}</td><td class="r">${iqd(order.total)}</td></tr>
      <tr><td>${t.payment}</td><td class="r">${order.payment_method === 'cash' ? t.cash : t.card}</td></tr>
    </table>
    <div class="hr"></div>
    <div class="thanks">${t.thanks}</div>
  `);
}

// ---------------------------------------------------------------------------
// Kitchen ticket (80mm, large & readable from a distance, no prices)
// ---------------------------------------------------------------------------

function kitchenTicketHtml(order, lang = 'en') {
  const rows = order.items
    .map((it) => {
      const tag = it.tag ? ` <span class="ktag">(${esc(it.tag)})</span>` : '';
      const note = it.note ? `<div class="knote">↳ ${esc(it.note)}</div>` : '';
      return `<div class="kitem">${it.qty}× ${esc(it.item_name)}${tag}${note}</div>`;
    })
    .join('');

  const typeCaps = typeLabel(order.order_type, lang).toUpperCase();

  return baseDoc('kitchen', `
    <div class="korder">#${order.id}</div>
    <div class="ktype">${esc(typeCaps)}${order.table_no ? ' · ' + esc(order.table_no) : ''}</div>
    <div class="ktime">${fmtTime(order.created_at)}</div>
    <div class="khr"></div>
    ${rows}
  `);
}

// ---------------------------------------------------------------------------
// Shared document shell + CSS (inlined; 80mm width)
// ---------------------------------------------------------------------------

function baseDoc(kind, body) {
  return `<!doctype html><html><head><meta charset="utf-8">
  <style>
    @page { size: 80mm auto; margin: 0; }
    * { box-sizing: border-box; }
    body {
      width: 80mm; margin: 0; padding: 4mm 3mm;
      font-family: 'Segoe UI', Arial, sans-serif; color: #000; background: #fff;
      -webkit-print-color-adjust: exact;
    }
    .hr { border-top: 1px dashed #000; margin: 6px 0; }
    /* receipt */
    .brand { text-align: center; }
    .logo { font-size: 22px; font-weight: 800; letter-spacing: 2px; }
    .tag { font-size: 11px; margin-top: 2px; }
    .meta { font-size: 12px; line-height: 1.5; }
    table.items { width: 100%; border-collapse: collapse; font-size: 13px; }
    table.items td { vertical-align: top; padding: 2px 0; }
    table.items .lp { text-align: right; white-space: nowrap; padding-left: 6px; }
    .note { font-style: italic; font-size: 11px; margin-top: 1px; }
    table.totals { width: 100%; border-collapse: collapse; font-size: 13px; }
    table.totals td { padding: 2px 0; }
    table.totals .r { text-align: right; }
    table.totals .grand td { font-size: 18px; font-weight: 800; padding-top: 4px; }
    .thanks { text-align: center; font-size: 12px; margin-top: 8px; }
    /* kitchen */
    .korder { text-align: center; font-size: 54px; font-weight: 900; line-height: 1; }
    .ktype { text-align: center; font-size: 20px; font-weight: 800; margin-top: 4px; }
    .ktime { text-align: center; font-size: 16px; margin-top: 2px; }
    .khr { border-top: 2px solid #000; margin: 8px 0; }
    .kitem { font-size: 22px; font-weight: 800; margin: 8px 0; line-height: 1.15; }
    .ktag { font-weight: 900; }
    .knote { font-size: 15px; font-style: italic; font-weight: 500; margin-left: 12px; }
  </style></head><body class="${kind}">${body}</body></html>`;
}

module.exports = { customerReceiptHtml, kitchenTicketHtml, BUSINESS };
