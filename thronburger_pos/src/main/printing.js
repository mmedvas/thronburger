'use strict';

const { BrowserWindow } = require('electron');
const { customerReceiptHtml, kitchenTicketHtml } = require('./receipt-template');

/**
 * Render an HTML string in a hidden window and print it silently to the given
 * device. Resolves once the print job has been handed to the OS spooler.
 *
 * @param {string} html          full HTML document
 * @param {string} deviceName    Windows printer name; '' => system default
 */
function printHtml(html, deviceName) {
  return new Promise((resolve, reject) => {
    const win = new BrowserWindow({
      show: false,
      webPreferences: { offscreen: false, sandbox: true },
    });

    let settled = false;
    const done = (err) => {
      if (settled) return;
      settled = true;
      // Give the spooler a beat before tearing the window down.
      setTimeout(() => {
        if (!win.isDestroyed()) win.destroy();
      }, 500);
      err ? reject(err) : resolve();
    };

    win.webContents.once('did-finish-load', () => {
      const opts = {
        silent: true,
        printBackground: true,
        margins: { marginType: 'none' },
        // 80mm width (in microns). Height auto-flows for thermal roll paper.
        pageSize: { width: 80000, height: 297000 },
      };
      if (deviceName) opts.deviceName = deviceName;
      win.webContents.print(opts, (success, failureReason) => {
        if (!success) done(new Error(failureReason || 'Print failed'));
        else done();
      });
    });

    win.webContents.once('did-fail-load', (_e, code, desc) =>
      done(new Error(`Failed to load print doc: ${desc} (${code})`))
    );

    win.loadURL('data:text/html;charset=utf-8,' + encodeURIComponent(html));
  });
}

/** Print an arbitrary pre-built HTML doc (used for the Z-report). */
async function printRaw(html, deviceName) {
  await printHtml(html, deviceName || '');
  return { ok: true };
}

/**
 * Print both documents for a completed order. When the cashier and kitchen
 * printers are the same physical device (one-printer shops), the receipt prints
 * first, then the kitchen ticket immediately after — each as its own job so the
 * printer feeds/cuts between them.
 */
async function printOrderDocuments(order, settings, lang = 'en') {
  const cashier = settings.cashier_printer || '';
  const kitchen = settings.kitchen_printer || '';
  const result = { receipt: false, kitchen: false, errors: [] };

  try {
    await printHtml(customerReceiptHtml(order, lang), cashier);
    result.receipt = true;
  } catch (e) {
    result.errors.push('receipt: ' + e.message);
  }

  try {
    await printHtml(kitchenTicketHtml(order, lang), kitchen);
    result.kitchen = true;
  } catch (e) {
    result.errors.push('kitchen: ' + e.message);
  }

  return result;
}

async function reprintReceipt(order, settings, lang = 'en') {
  await printHtml(customerReceiptHtml(order, lang), settings.cashier_printer || '');
  return { ok: true };
}

async function reprintKitchen(order, settings, lang = 'en') {
  await printHtml(kitchenTicketHtml(order, lang), settings.kitchen_printer || '');
  return { ok: true };
}

/** Simple test page for the Settings "Test print" buttons. */
async function testPrint(deviceName, label) {
  const html = `<!doctype html><html><head><meta charset="utf-8">
    <style>@page{size:80mm auto;margin:0}
      body{width:80mm;margin:0;padding:6mm 3mm;font-family:Arial,sans-serif;text-align:center}
      h1{font-size:20px;margin:0 0 8px} .l{font-size:14px} .b{border-top:1px dashed #000;margin:8px 0}</style>
    </head><body>
      <h1>THRONBURGER POS</h1>
      <div class="l">${label || 'Test print'}</div>
      <div class="b"></div>
      <div class="l">Printer OK ✔</div>
      <div class="l">Berlin × Hewlêr — Erbil</div>
    </body></html>`;
  await printHtml(html, deviceName || '');
  return { ok: true };
}

module.exports = {
  printOrderDocuments,
  reprintReceipt,
  reprintKitchen,
  testPrint,
  printRaw,
};
