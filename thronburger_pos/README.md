# Thronburger POS

Offline Windows point-of-sale for **Thronburger** — Berlin × Hewlêr, Empire City, Erbil.
Built with Electron + better-sqlite3. 100% offline — no internet, no cloud, no accounts.

---

## Quick start (3 commands)

```bash
npm install      # installs Electron + builds the native SQLite module
npm run dev       # launches the app for testing
npm run dist      # builds the Windows installer (run this on Windows — see below)
```

The installer is produced at:

```
dist/Thronburger-POS-Setup-1.0.0.exe
```

---

## First run

- The database is created automatically at
  `%APPDATA%\Thronburger POS\thronburger.db` (on Windows) and seeded with the full
  Thronburger menu and one admin account.
- **Default admin PIN: `1234`** (name "Admin"). Change it under **Staff** once you're in.

---

## Using the app

| Screen | What it does |
|--------|--------------|
| **PIN login** | Fullscreen number pad. Auto-locks after 5 minutes idle. |
| **POS** | Tap categories → tap items → set order type / table / customer, add notes & discount → **Complete & Print** → pick Cash or Card. Prints receipt + kitchen ticket automatically. |
| **Orders** | Full history, newest first. Reprint receipt / kitchen ticket, or void (admins only; cashiers must enter an admin PIN). Voided orders show struck-through. |
| **Reports** | KPIs + bar charts (top items, revenue by category/hour/cashier, orders by type, cash vs card). Admins pick any date range; cashiers see today only. **Z-Report** button (admin) covers everything since the last Z-report, then saves + prints it. |
| **Menu** (admin) | Add items, edit name/price/tag/category inline, deactivate/reactivate, or reset to the default menu. |
| **Staff** (admin) | Add staff, change any PIN (including the admin PIN), deactivate. |
| **Settings** (admin) | Pick the cashier + kitchen printers from installed Windows printers, test-print each, and set the default language. |

**Languages:** EN / DE / TR buttons in the header switch the whole UI instantly; the choice is saved.

**Keyboard shortcuts:** `F1` POS · `F2` Orders · `F3` Reports · `Enter` complete order (on POS) · `Ctrl+Q` quit.

---

## Printing

- Uses silent printing (no dialogs). Set both printers under **Settings**.
- **Customer receipt** → cashier printer (80mm): logo, order details, items with notes,
  totals, payment, trilingual thank-you.
- **Kitchen ticket** → kitchen printer (80mm): giant order number, order type, time, and
  large bold items with spicy tags and notes — no prices.
- **One-printer shops:** point both dropdowns at the same printer. The receipt prints first,
  then the kitchen ticket as a second job (the printer cuts between them).
- If you don't choose a printer, the Windows **default printer** is used.

---

## Backups

On every app start the database is copied to `%APPDATA%\Thronburger POS\backups\`
(the last 30 copies are kept). To restore, close the app and copy a backup file back to
`thronburger.db`.

---

## Manual steps after building

1. **Build on Windows.** `better-sqlite3` is a native module and the NSIS installer target
   is Windows-only. Run `npm install` then `npm run dist` **on a Windows 10/11 x64 machine**
   to produce `dist/Thronburger-POS-Setup-1.0.0.exe`. (Building on macOS/Linux runs the app
   fine for testing via `npm run dev`, but cannot produce the Windows `.exe` reliably.)
2. **(Optional) App icon.** Drop a 256×256 `icon.ico` into the `build/` folder before
   `npm run dist` to brand the installer and window. Without it, the default Electron icon
   is used (the app still builds and runs).
3. **Printers.** On the shop PC, open **Settings** and select the cashier and kitchen
   printers, then use **Test print** on each.
4. **Change the admin PIN** under **Staff** (default is `1234`).

---

## Notes

- Menu prices/names are seeded from the live Thronburger menu. The live menu had one
  `tortilla` item, which is folded into the **Chicken** category (the six POS categories are
  beef, smash, chicken, hotdog, fingers, drinks). You can recategorize it anytime in **Menu**.
- Menu items live **only** in the database — the POS grid, receipts, kitchen tickets, and
  reports all read from it. Editing the menu updates everything; past receipts keep their
  original snapshot.

## Security

`contextIsolation` is on, `nodeIntegration` is off, and the renderer has no direct database
or filesystem access — everything goes through the preload bridge (`window.pos.*`) and IPC.

## Project layout

```
thronburger_pos/
  package.json            electron-builder + scripts
  src/main/               main process
    main.js               app lifecycle, window, menu shortcuts
    db.js                 schema + first-run seed + menu reset
    seed.js               the Thronburger menu (source of truth for seeding)
    queries.js            all SQL (orders, reports, z-reports, staff, settings)
    printing.js           silent 80mm printing
    receipt-template.js   customer receipt + kitchen ticket HTML (EN/DE/TR)
    backup.js             daily DB backup, keep 30
    ipc.js                IPC handlers + z-report print
  src/preload/preload.js  contextBridge window.pos API
  src/renderer/           UI (no Node access)
    index.html styles.css app.js i18n.js util.js charts.js
    screens/              login, pos, orders, reports, menu, staff, settings
```
