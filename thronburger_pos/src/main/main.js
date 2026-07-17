'use strict';

const path = require('path');
const { app, BrowserWindow, Menu } = require('electron');
const { initDb } = require('./db');
const { runDailyBackup } = require('./backup');
const { registerIpc } = require('./ipc');

let mainWindow = null;
let dbHandle = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 900,
    show: false,
    backgroundColor: '#161513',
    title: 'Thronburger POS',
    // PNG loads on every OS; electron-builder still uses build/icon.ico for the
    // Windows installer + .exe icon.
    icon: path.join(__dirname, '..', '..', 'build', 'icon.png'),
    webPreferences: {
      preload: path.join(__dirname, '..', 'preload', 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false, // preload uses require(); DB stays in main via IPC only
      spellcheck: false,
    },
  });

  mainWindow.once('ready-to-show', () => {
    mainWindow.maximize();
    mainWindow.show();
  });

  mainWindow.loadFile(path.join(__dirname, '..', 'renderer', 'index.html'));
  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function buildMenu() {
  const nav = (screen) => () => mainWindow && mainWindow.webContents.send('shortcut:nav', screen);
  const template = [
    {
      label: 'Thronburger POS',
      submenu: [
        { label: 'POS', accelerator: 'F1', click: nav('pos') },
        { label: 'Orders', accelerator: 'F2', click: nav('orders') },
        { label: 'Reports', accelerator: 'F3', click: nav('reports') },
        { type: 'separator' },
        // Enter = "complete order" is handled in the renderer so it never
        // swallows Enter while typing in a field or a note.
        { label: 'Quit', accelerator: 'CommandOrControl+Q', click: () => app.quit() },
      ],
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'togglefullscreen' },
      ],
    },
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

app.whenReady().then(async () => {
  const dbPath = path.join(app.getPath('userData'), 'thronburger.db');
  dbHandle = initDb(dbPath);

  try {
    await runDailyBackup(dbHandle, app.getPath('userData'));
  } catch (err) {
    console.error('Backup failed (non-fatal):', err.message);
  }

  registerIpc(() => mainWindow);
  buildMenu();
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (dbHandle) {
    try {
      dbHandle.close();
    } catch (_) {
      /* ignore */
    }
  }
  app.quit();
});
