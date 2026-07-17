'use strict';

TB.screens.orders = {
  async mount(root) {
    const t = TB.t;
    let orders = [];
    let selectedId = null;

    const page = TB.el('div', { class: 'page' });
    page.appendChild(TB.el('h2', { text: t('orderHistory') }));
    const split = TB.el('div', { class: 'split' });
    const listBox = TB.el('div', { class: 'list' });
    const detail = TB.el('div', { class: 'panel', style: 'padding:18px;overflow-y:auto' });
    split.appendChild(listBox);
    split.appendChild(detail);
    page.appendChild(split);
    TB.clear(root).appendChild(page);

    async function loadList() {
      try {
        orders = await TB.call(window.pos.orders.list({ limit: 300 }));
      } catch (e) {
        TB.toast(e.message, 'error');
      }
      renderList();
    }

    function renderList() {
      TB.clear(listBox);
      if (!orders.length) {
        listBox.appendChild(TB.el('div', { class: 'muted', text: t('noOrders') }));
        return;
      }
      orders.forEach((o) => {
        const meta = `${TB.t(o.order_type)} · ${o.table_no ? t('table') + ' ' + o.table_no + ' · ' : ''}${o.created_at} · ${o.staff_name || ''}`;
        const row = TB.el('div', {
          class: 'orow' + (o.voided ? ' voided' : '') + (o.id === selectedId ? ' sel' : ''),
          onClick: () => selectOrder(o.id),
        }, [
          TB.el('div', { class: 'oid', text: '#' + o.id }),
          TB.el('div', {}, [
            TB.el('div', { class: 'ometa', text: meta }),
            o.voided ? TB.el('span', { class: 'badge void', text: t('voided') }) : null,
          ]),
          TB.el('div', { class: 'ototal', text: TB.iqd(o.total) }),
        ]);
        listBox.appendChild(row);
      });
    }

    async function selectOrder(id) {
      selectedId = id;
      renderList();
      let order;
      try {
        order = await TB.call(window.pos.orders.get(id));
      } catch (e) {
        return TB.toast(e.message, 'error');
      }
      renderDetail(order);
    }

    function renderDetail(o) {
      TB.clear(detail);
      if (!o) {
        detail.appendChild(TB.el('div', { class: 'muted', text: t('selectOrderHint') }));
        return;
      }
      const header = TB.el('div', {}, [
        TB.el('h2', { text: '#' + o.id + (o.voided ? ' — ' + t('voided') : '') }),
        TB.el('div', { class: 'muted', text: `${TB.t(o.order_type)}${o.table_no ? ' · ' + t('table') + ' ' + o.table_no : ''} · ${o.created_at}` }),
        TB.el('div', { class: 'muted', text: `${t('cashier')}: ${o.staff_name || '—'} · ${t('payment')}: ${o.payment_method === 'cash' ? t('cash') : t('card')}` }),
        o.customer ? TB.el('div', { class: 'muted', text: o.customer }) : null,
      ]);
      detail.appendChild(header);

      const tbl = TB.el('table', { class: 'tbl', style: 'margin-top:14px' });
      tbl.appendChild(TB.el('thead', {}, TB.el('tr', {}, [
        TB.el('th', { text: t('item') }),
        TB.el('th', { text: t('price') }),
      ])));
      const tb = TB.el('tbody');
      o.items.forEach((it) => {
        tb.appendChild(TB.el('tr', {}, [
          TB.el('td', {}, [
            TB.el('div', { text: `${it.qty}× ${it.item_name}` }),
            it.note ? TB.el('div', { class: 'muted', text: '↳ ' + it.note }) : null,
          ]),
          TB.el('td', { text: TB.iqd(it.price * it.qty) }),
        ]));
      });
      tbl.appendChild(tb);
      detail.appendChild(tbl);

      const totals = TB.el('div', { style: 'margin-top:12px' }, [
        TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('subtotal') }), TB.el('span', { text: TB.iqd(o.subtotal) })]),
        o.discount_pct ? TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('discount') + ' ' + o.discount_pct + '%' }), TB.el('span', { text: '−' + TB.iqd(o.subtotal - o.total) })]) : null,
        TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('total') }), TB.el('span', { class: 'grand', style: 'font-size:22px', text: TB.iqd(o.total) })]),
      ]);
      detail.appendChild(totals);

      const actions = TB.el('div', { class: 'toolbar', style: 'margin-top:16px' }, [
        TB.el('button', { class: 'btn', text: t('reprintReceipt'), onClick: () => reprint('receipt', o.id) }),
        TB.el('button', { class: 'btn', text: t('reprintKitchen'), onClick: () => reprint('kitchen', o.id) }),
        o.voided ? null : TB.el('button', { class: 'btn danger', text: t('void'), onClick: () => voidOrder(o.id) }),
      ]);
      detail.appendChild(actions);
    }

    async function reprint(which, id) {
      try {
        if (which === 'receipt') await TB.call(window.pos.orders.reprintReceipt(id));
        else await TB.call(window.pos.orders.reprintKitchen(id));
        TB.toast(t('reprinted'), 'ok');
      } catch (e) {
        TB.toast(e.message, 'error');
      }
    }

    async function doVoid(id, adminPin) {
      try {
        await TB.call(window.pos.orders.void({ id, adminPin, staffId: TB.state.user.id }));
        TB.toast(t('orderVoided'), 'ok');
        await loadList();
        await selectOrder(id);
      } catch (e) {
        TB.toast(e.message, 'error');
      }
    }

    function voidOrder(id) {
      if (TB.state.user.role === 'admin') {
        TB.confirm(t('void') + ' #' + id, '', () => doVoid(id, null));
        return;
      }
      // Cashier: prompt for an admin PIN.
      const input = TB.el('input', { class: 'field', type: 'password', maxlength: '4', placeholder: '••••' });
      const wrap = TB.el('div', {}, [
        TB.el('h3', { text: t('adminPinRequired') }),
        TB.el('p', { class: 'muted', text: t('enterAdminPin') }),
        input,
      ]);
      const m = TB.modal(wrap);
      wrap.appendChild(TB.el('div', { class: 'actions' }, [
        TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
        TB.el('button', { class: 'btn danger', text: t('void'), onClick: () => { const pin = input.value; m.close(); doVoid(id, pin); } }),
      ]));
      setTimeout(() => input.focus(), 30);
    }

    renderDetail(null);
    await loadList();
  },
};
