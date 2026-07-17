'use strict';

TB.screens.settings = {
  async mount(root) {
    const t = TB.t;
    let printers = [];
    let settings = {};
    let defaultPrinter = '';

    try {
      [printers, settings, defaultPrinter] = await Promise.all([
        TB.call(window.pos.printers.list()),
        TB.call(window.pos.settings.get()),
        TB.call(window.pos.printers.default()),
      ]);
    } catch (e) {
      TB.toast(e.message, 'error');
    }

    const page = TB.el('div', { class: 'page' });
    page.appendChild(TB.el('h2', { text: t('settingsTitle') }));
    TB.clear(root).appendChild(page);

    function printerSelect(current) {
      const sel = TB.el('select', { class: 'field', style: 'max-width:420px' });
      const autoLabel = t('systemDefault') + (defaultPrinter ? ' — ' + defaultPrinter : '');
      sel.appendChild(TB.el('option', { value: '', text: autoLabel }));
      printers.forEach((p) => {
        const o = TB.el('option', { value: p.name, text: p.displayName || p.name });
        if (p.name === current) o.selected = true;
        sel.appendChild(o);
      });
      return sel;
    }

    async function save(key, value) {
      try { await TB.call(window.pos.settings.set({ key, value })); settings[key] = value; TB.toast(t('saved'), 'ok'); }
      catch (e) { TB.toast(e.message, 'error'); }
    }

    async function testPrint(deviceName, label) {
      try { await TB.call(window.pos.printers.test({ deviceName, label })); TB.toast(t('testSent'), 'ok'); }
      catch (e) { TB.toast(e.message, 'error'); }
    }

    // ---- Printer settings ----
    const printerCard = TB.el('div', { class: 'panel', style: 'padding:18px;max-width:640px;margin-bottom:16px' });
    printerCard.appendChild(TB.el('h3', { text: t('printerSettings'), style: 'margin-top:0' }));

    const cashierSel = printerSelect(settings.cashier_printer || '');
    cashierSel.addEventListener('change', () => save('cashier_printer', cashierSel.value));
    printerCard.appendChild(TB.el('label', { class: 'lbl', text: t('cashierPrinter') }));
    printerCard.appendChild(TB.el('div', { class: 'toolbar', style: 'margin:0 0 12px' }, [
      cashierSel,
      TB.el('button', { class: 'btn', text: t('testPrint'), onClick: () => testPrint(cashierSel.value, 'Cashier printer') }),
    ]));

    const kitchenSel = printerSelect(settings.kitchen_printer || '');
    kitchenSel.addEventListener('change', () => save('kitchen_printer', kitchenSel.value));
    printerCard.appendChild(TB.el('label', { class: 'lbl', text: t('kitchenPrinter') }));
    printerCard.appendChild(TB.el('div', { class: 'toolbar', style: 'margin:0' }, [
      kitchenSel,
      TB.el('button', { class: 'btn', text: t('testPrint'), onClick: () => testPrint(kitchenSel.value, 'Kitchen printer') }),
    ]));
    page.appendChild(printerCard);

    // ---- Language ----
    const langCard = TB.el('div', { class: 'panel', style: 'padding:18px;max-width:640px' });
    langCard.appendChild(TB.el('h3', { text: t('defaultLanguage'), style: 'margin-top:0' }));
    const langSel = TB.el('select', { class: 'field', style: 'max-width:280px' }, [
      TB.el('option', { value: 'en', text: 'English' }),
      TB.el('option', { value: 'de', text: 'Deutsch' }),
      TB.el('option', { value: 'tr', text: 'Türkçe' }),
    ]);
    langSel.value = settings.language || TB.state.lang || 'en';
    langSel.addEventListener('change', async () => {
      await save('language', langSel.value);
      TB.setLang(langSel.value); // switch the whole UI immediately
    });
    langCard.appendChild(langSel);
    page.appendChild(langCard);
  },
};
