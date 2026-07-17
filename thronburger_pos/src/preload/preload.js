'use strict';

const { contextBridge, ipcRenderer } = require('electron');

// Whitelisted API surface exposed to the renderer. The renderer has no Node
// access and no direct database handle — everything goes through invoke().
const call = (channel, payload) => ipcRenderer.invoke(channel, payload);

const api = {
  auth: {
    verifyPin: (pin) => call('auth:verifyPin', pin),
  },
  menu: {
    list: (opts) => call('menu:list', opts),
    add: (item) => call('menu:add', item),
    update: (item) => call('menu:update', item),
    setActive: (p) => call('menu:setActive', p),
    reset: () => call('menu:reset'),
  },
  categories: {
    list: (opts) => call('category:list', opts),
    add: (p) => call('category:add', p),
    rename: (p) => call('category:rename', p),
    setActive: (p) => call('category:setActive', p),
    delete: (p) => call('category:delete', p),
  },
  staff: {
    list: () => call('staff:list'),
    add: (s) => call('staff:add', s),
    setActive: (p) => call('staff:setActive', p),
    changePin: (p) => call('staff:changePin', p),
  },
  orders: {
    create: (payload) => call('order:create', payload),
    get: (id) => call('order:get', id),
    list: (opts) => call('order:list', opts),
    void: (p) => call('order:void', p),
    reprintReceipt: (id) => call('order:reprintReceipt', id),
    reprintKitchen: (id) => call('order:reprintKitchen', id),
  },
  reports: {
    summary: (range) => call('report:summary', range),
    zCompute: () => call('report:zCompute'),
    zSave: (data) => call('report:zSave', data),
    zList: () => call('report:zList'),
    zGet: (id) => call('report:zGet', id),
    zReprint: (id) => call('report:zReprint', id),
  },
  settings: {
    get: () => call('settings:get'),
    set: (p) => call('settings:set', p),
  },
  printers: {
    list: () => call('print:listPrinters'),
    test: (p) => call('print:test', p),
    default: () => call('print:default'),
  },
  // Menu-bar keyboard shortcuts (F1/F2/F3) arrive from the main process.
  onNavigate: (cb) => {
    ipcRenderer.on('shortcut:nav', (_e, screen) => cb(screen));
  },
  onCompleteOrder: (cb) => {
    ipcRenderer.on('shortcut:complete', () => cb());
  },
};

contextBridge.exposeInMainWorld('pos', api);
