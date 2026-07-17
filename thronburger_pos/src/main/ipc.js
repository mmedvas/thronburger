'use strict';

const { ipcMain } = require('electron');
const q = require('./queries');
const printing = require('./printing');

/**
 * Register every IPC handler. All renderer <-> DB / printer access flows
 * through here; the renderer never touches Node or the database directly.
 *
 * @param {() => import('electron').BrowserWindow} getMainWindow
 */
function registerIpc(getMainWindow) {
  const handle = (channel, fn) =>
    ipcMain.handle(channel, async (_evt, payload) => {
      try {
        const data = await fn(payload);
        return { ok: true, data };
      } catch (err) {
        return { ok: false, error: err.message || String(err) };
      }
    });

  const lang = () => q.getSettings().language || 'en';

  // Resolve the Windows default printer so printing "just works" once a printer
  // is installed, even before anything is chosen in Settings.
  async function defaultPrinter() {
    const win = getMainWindow();
    if (!win) return '';
    try {
      const ps = await win.webContents.getPrintersAsync();
      const d = ps.find((p) => p.isDefault) || ps[0];
      return d ? d.name : '';
    } catch (_) {
      return '';
    }
  }

  // Settings with cashier/kitchen printers filled in from the default when empty.
  async function effectiveSettings() {
    const s = q.getSettings();
    if (!s.cashier_printer || !s.kitchen_printer) {
      const def = await defaultPrinter();
      if (!s.cashier_printer) s.cashier_printer = def;
      if (!s.kitchen_printer) s.kitchen_printer = def;
    }
    return s;
  }

  // ── Auth ──────────────────────────────────────────────
  handle('auth:verifyPin', (pin) => q.verifyPin(pin));

  // ── Menu ──────────────────────────────────────────────
  handle('menu:list', (opts) => q.listMenu(opts || {}));
  handle('menu:add', (p) => q.addMenuItem(p));
  handle('menu:update', (p) => q.updateMenuItem(p));
  handle('menu:setActive', (p) => q.setMenuActive(p));
  handle('menu:reset', () => q.resetMenuToDefault());

  // ── Categories ────────────────────────────────────────
  handle('category:list', (opts) => q.listCategories(opts || {}));
  handle('category:add', (p) => q.addCategory(p));
  handle('category:rename', (p) => q.renameCategory(p));
  handle('category:setActive', (p) => q.setCategoryActive(p));
  handle('category:delete', (p) => q.deleteCategory(p));

  // ── Staff ─────────────────────────────────────────────
  handle('staff:list', () => q.listStaff());
  handle('staff:add', (p) => q.addStaff(p));
  handle('staff:setActive', (p) => q.setStaffActive(p));
  handle('staff:changePin', (p) => q.changePin(p));

  // ── Orders (create also prints both documents) ─────────
  handle('order:create', async (payload) => {
    const order = q.createOrder(payload);
    const settings = await effectiveSettings();
    const printResult = await printing.printOrderDocuments(order, settings, settings.language || 'en');
    return { order, printResult };
  });
  handle('order:get', (id) => q.getOrder(id));
  handle('order:list', (opts) => q.listOrders(opts || {}));
  handle('order:void', (p) => q.voidOrder(p));
  handle('order:reprintReceipt', async (id) => {
    const order = q.getOrder(id);
    if (!order) throw new Error('Order not found');
    return printing.reprintReceipt(order, await effectiveSettings(), lang());
  });
  handle('order:reprintKitchen', async (id) => {
    const order = q.getOrder(id);
    if (!order) throw new Error('Order not found');
    return printing.reprintKitchen(order, await effectiveSettings(), lang());
  });

  // ── Reports & Z-reports ───────────────────────────────
  handle('report:summary', (range) => q.reportSummary(range || {}));
  handle('report:zCompute', () => q.computeZReport());
  handle('report:zSave', async (data) => {
    const saved = q.saveZReport(data);
    await printZReport(saved, (await effectiveSettings()).cashier_printer);
    return saved;
  });
  handle('report:zList', () => q.listZReports());
  handle('report:zGet', (id) => q.getZReport(id));
  handle('report:zReprint', async (id) => {
    const z = q.getZReport(id);
    if (!z) throw new Error('Z-report not found');
    await printZReport(z, (await effectiveSettings()).cashier_printer);
    return { ok: true };
  });

  // ── Settings & printers ───────────────────────────────
  handle('settings:get', () => q.getSettings());
  handle('settings:set', (p) => q.setSetting(p));
  handle('print:listPrinters', async () => {
    const win = getMainWindow();
    if (!win) return [];
    const printers = await win.webContents.getPrintersAsync();
    return printers.map((p) => ({ name: p.name, displayName: p.displayName, isDefault: p.isDefault }));
  });
  handle('print:test', async (p) => {
    const device = (p && p.deviceName) || (await defaultPrinter());
    return printing.testPrint(device, p && p.label);
  });
  handle('print:default', () => defaultPrinter());
}

// Z-report 80mm print helper (composes queries output into a printable doc).
async function printZReport(z, printerName) {
  const iqd = (n) => Number(n || 0).toLocaleString('en-US') + ' IQD';
  const cashierRows = (z.per_cashier || [])
    .map((c) => `<tr><td>${esc(c.name)}</td><td class="r">${iqd(c.revenue)}</td></tr>`)
    .join('');
  const catRows = (z.per_category || [])
    .map((c) => `<tr><td>${esc(c.category)}</td><td class="r">${iqd(c.revenue)}</td></tr>`)
    .join('');
  const html = `<!doctype html><html><head><meta charset="utf-8"><style>
    @page{size:80mm auto;margin:0}
    body{width:80mm;margin:0;padding:5mm 3mm;font-family:Arial,sans-serif;color:#000}
    h1{font-size:18px;text-align:center;margin:0} .sub{text-align:center;font-size:11px;margin:2px 0 6px}
    .hr{border-top:1px dashed #000;margin:6px 0}
    table{width:100%;border-collapse:collapse;font-size:13px} td{padding:2px 0}
    .r{text-align:right} .big td{font-size:16px;font-weight:800}
    .sec{font-weight:700;margin:6px 0 2px;font-size:12px}
  </style></head><body>
    <h1>Z-REPORT</h1>
    <div class="sub">THRONBURGER — Erbil</div>
    <div class="hr"></div>
    <table>
      <tr><td>From</td><td class="r">${esc(z.from_ts)}</td></tr>
      <tr><td>To</td><td class="r">${esc(z.to_ts)}</td></tr>
    </table>
    <div class="hr"></div>
    <table>
      <tr class="big"><td>Revenue</td><td class="r">${iqd(z.revenue)}</td></tr>
      <tr><td>Orders</td><td class="r">${z.orders}</td></tr>
      <tr><td>Average order</td><td class="r">${iqd(z.avg_order)}</td></tr>
      <tr><td>Cash</td><td class="r">${iqd(z.cash)}</td></tr>
      <tr><td>Card</td><td class="r">${iqd(z.card)}</td></tr>
      <tr><td>Voided</td><td class="r">${z.voided_count}</td></tr>
    </table>
    <div class="sec">Per cashier</div>
    <table>${cashierRows || '<tr><td>—</td></tr>'}</table>
    <div class="sec">Per category</div>
    <table>${catRows || '<tr><td>—</td></tr>'}</table>
    <div class="hr"></div>
    <div class="sub">Generated ${esc(z.created_at || '')}</div>
  </body></html>`;
  await printing.printRaw(html, printerName || '');
}

function esc(s) {
  return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

module.exports = { registerIpc };
