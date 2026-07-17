'use strict';

// Boot + shell + router. Loaded last, after all screens have registered
// themselves on TB.screens.
(function () {
  const el = TB.el;
  const root = document.getElementById('root');

  let mainEl = null;
  let headerEl = null;
  let idleTimer = null;

  const ADMIN_ONLY = new Set(['menu', 'staff', 'settings']);
  const NAV = ['pos', 'orders', 'reports', 'menu', 'staff', 'settings'];

  // ---- Auth ----
  TB.onLogin = function onLogin(staff) {
    TB.state.user = staff;
    buildShell();
    navigate('pos');
    resetIdle();
  };

  TB.logout = function logout() {
    unmountCurrent();
    TB.state.user = null;
    clearTimeout(idleTimer);
    showLogin();
  };

  function unmountCurrent() {
    const scr = TB.screens[TB.state.screen];
    if (scr && typeof scr.unmount === 'function') {
      try { scr.unmount(); } catch (_) {}
    }
  }

  function showLogin() {
    TB.clear(root);
    TB.state.screen = 'login';
    TB.screens.login.mount(root);
  }

  // ---- Shell / header ----
  function buildShell() {
    const shell = el('div', { class: 'shell' });
    headerEl = el('div', { class: 'header' });
    mainEl = el('div', { class: 'main' });
    shell.appendChild(headerEl);
    shell.appendChild(mainEl);
    TB.clear(root).appendChild(shell);
    renderHeader();
  }

  function renderHeader() {
    const t = TB.t;
    const isAdmin = TB.state.user && TB.state.user.role === 'admin';
    TB.clear(headerEl);

    headerEl.appendChild(el('div', { class: 'brandmark' }, [
      el('div', { class: 'b1', html: 'THRON<span class="accent">BURGER</span>' }),
      el('div', { class: 'b2', text: 'POS' }),
    ]));

    const nav = el('div', { class: 'nav' });
    NAV.forEach((name) => {
      if (ADMIN_ONLY.has(name) && !isAdmin) return;
      nav.appendChild(el('button', {
        class: TB.state.screen === name ? 'active' : '',
        text: t(name),
        onClick: () => navigate(name),
      }));
    });
    headerEl.appendChild(nav);

    headerEl.appendChild(el('div', { class: 'spacer' }));

    const langs = el('div', { class: 'langs' });
    ['en', 'de', 'tr'].forEach((lg) => {
      langs.appendChild(el('button', {
        class: TB.state.lang === lg ? 'active' : '',
        text: lg.toUpperCase(),
        onClick: () => TB.setLang(lg),
      }));
    });
    headerEl.appendChild(langs);

    headerEl.appendChild(el('div', { class: 'user-chip' }, [
      el('div', { class: 'who' }, [
        el('div', { class: 'nm', text: TB.state.user.name }),
        el('div', { class: 'rl', text: isAdmin ? t('admin') : t('cashier_role') }),
      ]),
      el('button', { class: 'btn-logout', text: t('logout'), onClick: () => TB.logout() }),
    ]));
  }

  // ---- Router ----
  function navigate(name) {
    if (!TB.state.user) return;
    if (ADMIN_ONLY.has(name) && TB.state.user.role !== 'admin') {
      TB.toast(TB.t('mustBeAdmin'), 'error');
      return;
    }
    unmountCurrent();
    TB.state.screen = name;
    renderHeader();
    const scr = TB.screens[name];
    Promise.resolve(scr.mount(mainEl)).catch((e) => TB.toast(e.message, 'error'));
  }
  TB.navigate = navigate;

  // ---- Language ----
  TB.setLang = function setLang(lang) {
    TB.state.lang = lang;
    window.pos.settings.set({ key: 'language', value: lang }).catch(() => {});
    if (TB.state.user) {
      renderHeader();
      navigate(TB.state.screen); // re-render current screen in the new language
    } else {
      showLogin();
    }
  };

  // ---- Auto-lock after 5 minutes of inactivity ----
  function resetIdle() {
    clearTimeout(idleTimer);
    idleTimer = setTimeout(() => {
      if (TB.state.user) TB.logout();
    }, 5 * 60 * 1000);
  }
  ['mousemove', 'mousedown', 'keydown', 'click', 'touchstart', 'wheel'].forEach((ev) =>
    document.addEventListener(ev, () => { if (TB.state.user) resetIdle(); }, true)
  );

  // ---- Keyboard: Enter completes the order on the POS screen ----
  document.addEventListener('keydown', (e) => {
    if (e.key !== 'Enter') return;
    if (!TB.state.user || TB.state.screen !== 'pos') return;
    if (document.querySelector('.modal-back')) return; // a dialog is open
    const tag = (e.target && e.target.tagName) || '';
    if (/INPUT|TEXTAREA|SELECT/.test(tag)) return; // typing in a field
    if (typeof TB.activeComplete === 'function') TB.activeComplete();
  });

  // ---- Main-process menu shortcuts (F1/F2/F3) ----
  window.pos.onNavigate((screen) => { if (TB.state.user) navigate(screen); });

  // ---- Start ----
  // Kept in TB.state so category labels resolve on every screen.
  TB.reloadCategories = async function reloadCategories() {
    try { TB.state.categories = await TB.call(window.pos.categories.list({})); }
    catch (_) { TB.state.categories = []; }
    return TB.state.categories;
  };

  async function boot() {
    try {
      const settings = await TB.call(window.pos.settings.get());
      TB.state.settings = settings || {};
      TB.state.lang = (settings && settings.language) || 'en';
    } catch (_) {
      TB.state.lang = 'en';
    }
    await TB.reloadCategories();
    showLogin();
  }

  boot();
})();
