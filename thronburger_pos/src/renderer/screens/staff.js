'use strict';

TB.screens.staff = {
  async mount(root) {
    const t = TB.t;
    let staff = [];

    const page = TB.el('div', { class: 'page' });
    page.appendChild(TB.el('h2', { text: t('staffMgmt') }));
    page.appendChild(TB.el('div', { class: 'toolbar' }, [
      TB.el('button', { class: 'btn primary', text: '+ ' + t('addStaff'), onClick: addDialog }),
    ]));
    const tblWrap = TB.el('div', { class: 'scroll' });
    page.appendChild(tblWrap);
    TB.clear(root).appendChild(page);

    async function load() {
      try { staff = await TB.call(window.pos.staff.list()); }
      catch (e) { TB.toast(e.message, 'error'); }
      render();
    }

    function render() {
      TB.clear(tblWrap);
      const tbl = TB.el('table', { class: 'tbl' });
      tbl.appendChild(TB.el('thead', {}, TB.el('tr', {}, [
        TB.el('th', { text: t('name') }),
        TB.el('th', { text: t('role') }),
        TB.el('th', { text: t('pin') }),
        TB.el('th', { text: t('actions') }),
      ])));
      const tb = TB.el('tbody');
      staff.forEach((s) => {
        const roleLabel = s.role === 'admin' ? t('admin') : t('cashier_role');
        const toggle = TB.el('button', {
          class: s.active ? 'btn' : 'btn primary',
          text: s.active ? t('deactivate') : t('activate'),
          onClick: () => setActive(s.id, s.active ? 0 : 1),
        });
        tb.appendChild(TB.el('tr', { class: s.active ? '' : 'inactive-row' }, [
          TB.el('td', { text: s.name }),
          TB.el('td', { text: roleLabel }),
          TB.el('td', { text: '••••' }),
          TB.el('td', {}, TB.el('div', { class: 'toolbar', style: 'margin:0' }, [
            TB.el('button', { class: 'btn', text: t('changePin'), onClick: () => changePinDialog(s) }),
            toggle,
          ])),
        ]));
      });
      tbl.appendChild(tb);
      tblWrap.appendChild(tbl);
    }

    async function setActive(id, active) {
      try { await TB.call(window.pos.staff.setActive({ id, active })); await load(); }
      catch (e) { TB.toast(e.message, 'error'); }
    }

    function addDialog() {
      const nameI = TB.el('input', { class: 'field', placeholder: t('name') });
      const pinI = TB.el('input', { class: 'field', maxlength: '4', inputmode: 'numeric', placeholder: '4-digit PIN' });
      const roleSel = TB.el('select', { class: 'field' }, [
        TB.el('option', { value: 'cashier', text: t('cashier_role') }),
        TB.el('option', { value: 'admin', text: t('admin') }),
      ]);
      const wrap = TB.el('div', {}, [
        TB.el('h3', { text: t('addStaff') }),
        TB.el('label', { class: 'lbl', text: t('name') }), nameI,
        TB.el('label', { class: 'lbl', text: t('role'), style: 'margin-top:8px' }), roleSel,
        TB.el('label', { class: 'lbl', text: t('pin'), style: 'margin-top:8px' }), pinI,
      ]);
      const m = TB.modal(wrap);
      wrap.appendChild(TB.el('div', { class: 'actions' }, [
        TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
        TB.el('button', { class: 'btn primary', text: t('add'), onClick: async () => {
          const name = nameI.value.trim();
          if (!name) return TB.toast(t('name'), 'error');
          if (!/^\d{4}$/.test(pinI.value)) return TB.toast(t('pinMustBe4'), 'error');
          try {
            await TB.call(window.pos.staff.add({ name, pin: pinI.value, role: roleSel.value }));
            m.close(); TB.toast(t('staffAdded'), 'ok'); await load();
          } catch (e) { TB.toast(e.message, 'error'); }
        } }),
      ]));
      setTimeout(() => nameI.focus(), 30);
    }

    function changePinDialog(s) {
      const pinI = TB.el('input', { class: 'field', maxlength: '4', inputmode: 'numeric', placeholder: '••••' });
      const wrap = TB.el('div', {}, [
        TB.el('h3', { text: t('changePin') + ' — ' + s.name }),
        TB.el('label', { class: 'lbl', text: t('newPin') }), pinI,
      ]);
      const m = TB.modal(wrap);
      wrap.appendChild(TB.el('div', { class: 'actions' }, [
        TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
        TB.el('button', { class: 'btn primary', text: t('save'), onClick: async () => {
          if (!/^\d{4}$/.test(pinI.value)) return TB.toast(t('pinMustBe4'), 'error');
          try {
            await TB.call(window.pos.staff.changePin({ id: s.id, pin: pinI.value }));
            m.close(); TB.toast(t('saved'), 'ok'); await load();
          } catch (e) { TB.toast(e.message, 'error'); }
        } }),
      ]));
      setTimeout(() => pinI.focus(), 30);
    }

    await load();
  },
};
