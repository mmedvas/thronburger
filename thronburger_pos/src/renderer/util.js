'use strict';

// Global namespace shared by all renderer scripts (classic <script> loading,
// no ES modules — contextIsolation is on and nodeIntegration is off).
window.TB = window.TB || {};
TB.state = {
  user: null, // { id, name, role }
  lang: 'en',
  screen: 'pos',
  settings: {},
};
TB.screens = {};

// Unwrap the { ok, data, error } envelope returned by every IPC handler.
TB.call = async function call(promise) {
  const r = await promise;
  if (!r || !r.ok) throw new Error((r && r.error) || 'Unknown error');
  return r.data;
};

// Tiny DOM builder. props supports: class, text, html, on{Event}, dataset, and
// any attribute. children may be nodes or strings.
TB.el = function el(tag, props = {}, children = []) {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(props)) {
    if (v == null) continue;
    if (k === 'class') node.className = v;
    else if (k === 'text') node.textContent = v;
    else if (k === 'html') node.innerHTML = v;
    else if (k === 'dataset') Object.assign(node.dataset, v);
    else if (k.startsWith('on') && typeof v === 'function')
      node.addEventListener(k.slice(2).toLowerCase(), v);
    else node.setAttribute(k, v);
  }
  const kids = Array.isArray(children) ? children : [children];
  for (const c of kids) {
    if (c == null) continue;
    node.appendChild(typeof c === 'string' ? document.createTextNode(c) : c);
  }
  return node;
};

TB.clear = function clear(node) {
  while (node.firstChild) node.removeChild(node.firstChild);
  return node;
};

// IQD amounts are always whole numbers.
TB.iqd = function iqd(n) {
  return Number(n || 0).toLocaleString('en-US') + ' IQD';
};

TB.toast = function toast(message, type = 'info') {
  let host = document.querySelector('.toasts');
  if (!host) {
    host = TB.el('div', { class: 'toasts' });
    document.body.appendChild(host);
  }
  const cls = type === 'error' ? 'toast err' : type === 'ok' ? 'toast ok' : 'toast';
  const t = TB.el('div', { class: cls, text: message });
  host.appendChild(t);
  setTimeout(() => t.remove(), 3600);
};

// Generic modal. content is a DOM node; returns a close() function.
TB.modal = function modal(content) {
  const back = TB.el('div', { class: 'modal-back' });
  const box = TB.el('div', { class: 'modal' }, [content]);
  back.appendChild(box);
  back.addEventListener('mousedown', (e) => {
    if (e.target === back) close();
  });
  document.body.appendChild(back);
  const close = () => back.remove();
  return { close, back };
};

// Small confirm dialog. onYes runs on confirm.
TB.confirm = function confirmDialog(title, message, onYes) {
  const t = TB.t;
  const body = TB.el('div', {}, [
    TB.el('h3', { text: title }),
    TB.el('p', { class: 'muted', text: message || '' }),
  ]);
  const wrap = TB.el('div', {}, [body]);
  const m = TB.modal(wrap);
  const actions = TB.el('div', { class: 'actions' }, [
    TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
    TB.el('button', {
      class: 'btn danger', text: t('confirm'),
      onClick: () => { m.close(); onYes && onYes(); },
    }),
  ]);
  wrap.appendChild(actions);
};
