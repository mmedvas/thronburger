'use strict';

TB.screens.pos = {
  async mount(root) {
    const t = TB.t;
    const state = {
      items: [],
      activeCat: 'all',
      cart: [], // { id, item_name, category, price, qty, note, tag }
      orderType: 'dinein',
      table: '',
      customer: '',
      discount: 0,
    };

    try {
      state.items = await TB.call(window.pos.menu.list({ activeOnly: true }));
      await TB.reloadCategories();
    } catch (e) {
      TB.toast(e.message, 'error');
    }

    const layout = TB.el('div', { class: 'pos' });
    const left = TB.el('div', { class: 'left' });
    const cart = TB.el('div', { class: 'cart' });
    layout.appendChild(left);
    layout.appendChild(cart);
    TB.clear(root).appendChild(layout);

    // ---- Category chips ----
    const chips = TB.el('div', { class: 'chips' });
    const cats = ['all'].concat(
      (TB.state.categories || []).filter((c) => c.active).map((c) => c.key)
    );
    const grid = TB.el('div', { class: 'grid' });

    const renderChips = () => {
      TB.clear(chips);
      cats.forEach((c) => {
        chips.appendChild(
          TB.el('button', {
            class: 'chip' + (state.activeCat === c ? ' active' : ''),
            text: TB.catLabel(c),
            onClick: () => {
              state.activeCat = c;
              renderChips();
              renderGrid();
            },
          })
        );
      });
    };

    const renderGrid = () => {
      TB.clear(grid);
      const list = state.items.filter(
        (i) => state.activeCat === 'all' || i.category === state.activeCat
      );
      list.forEach((it) => {
        const card = TB.el('button', { class: 'item-card' + (it.image ? ' has-img' : ''), onClick: () => addToCart(it) }, [
          it.image ? TB.el('div', { class: 'item-img' }, [TB.el('img', { src: it.image, alt: it.name })]) : null,
          TB.el('div', { class: 'item-body' }, [
            TB.el('div', {}, [
              TB.el('div', { class: 'nm', text: it.name }),
              it.tag ? TB.el('span', { class: 'tag', text: it.tag }) : null,
            ]),
            TB.el('div', { class: 'pr', text: TB.iqd(it.price) }),
          ]),
        ]);
        grid.appendChild(card);
      });
    };

    left.appendChild(chips);
    left.appendChild(grid);
    renderChips();
    renderGrid();

    // ---- Cart ----
    function addToCart(it) {
      // Only stack identical, un-customized lines.
      const line = state.cart.find(
        (l) => l.id === it.id && !l.note && (!l.removed || !l.removed.length) && (!l.extras || !l.extras.length)
      );
      if (line) line.qty += 1;
      else
        state.cart.push({
          id: it.id,
          item_name: it.name,
          category: it.category,
          price: it.price,
          qty: 1,
          note: '',
          removed: [],
          extras: [], // selected paid add-ons [{name, price}]
          ingredients: Array.isArray(it.ingredients) ? it.ingredients : [],
          availExtras: Array.isArray(it.extras) ? it.extras : [],
          tag: it.tag || '',
        });
      renderCart();
    }

    // Unit price = base price + selected extras.
    function unitPrice(l) {
      return l.price + (l.extras || []).reduce((s, e) => s + (Number(e.price) || 0), 0);
    }

    // Combine removed ingredients + added extras + free note into the printed note.
    function buildNote(l) {
      const parts = (l.removed || []).map((r) => t('no') + ' ' + r);
      (l.extras || []).forEach((e) => parts.push('+ ' + e.name));
      if (l.note) parts.push(l.note);
      return parts.join(', ');
    }

    function totals() {
      const subtotal = state.cart.reduce((s, l) => s + unitPrice(l) * l.qty, 0);
      const disc = Number(state.discount) || 0;
      const total = Math.round(subtotal * (1 - disc / 100));
      return { subtotal, total };
    }

    const linesBox = TB.el('div', { class: 'lines' });
    const footBox = TB.el('div', { class: 'foot' });

    const seg = (val, key) =>
      TB.el('button', {
        class: state.orderType === val ? 'active' : '',
        text: t(key),
        onClick: () => {
          state.orderType = val;
          // Dine-in uses a table; takeaway/delivery use a customer name.
          if (val === 'dinein') state.customer = '';
          else state.table = '';
          renderCartHead();
        },
      });

    const cartHead = TB.el('div', { class: 'cart-head' });
    function renderCartHead() {
      TB.clear(cartHead);
      cartHead.appendChild(
        TB.el('div', { class: 'seg' }, [
          seg('dinein', 'dinein'),
          seg('takeaway', 'takeaway'),
          seg('delivery', 'delivery'),
        ])
      );
      // Dine-in → table number only. Takeaway/Delivery → customer name only.
      if (state.orderType === 'dinein') {
        cartHead.appendChild(TB.el('input', {
          class: 'field', style: 'margin-top:10px', placeholder: t('tableNo'), value: state.table,
          onInput: (e) => (state.table = e.target.value),
        }));
      } else {
        cartHead.appendChild(TB.el('input', {
          class: 'field', style: 'margin-top:10px', placeholder: t('customerName'), value: state.customer,
          onInput: (e) => (state.customer = e.target.value),
        }));
      }
    }

    function renderLines() {
      TB.clear(linesBox);
      if (!state.cart.length) {
        linesBox.appendChild(TB.el('div', { class: 'empty-hint', text: t('cartEmpty') }));
        return;
      }
      state.cart.forEach((l, idx) => {
        const noteText = buildNote(l);
        const line = TB.el('div', { class: 'cline' }, [
          TB.el('div', { class: 'cl-main' }, [
            TB.el('div', { class: 'cl-name', text: l.item_name }),
            noteText ? TB.el('div', { class: 'cl-note', text: '↳ ' + noteText }) : null,
            TB.el('div', { class: 'cl-controls' }, [
              TB.el('div', { class: 'qty' }, [
                TB.el('button', { text: '−', onClick: () => { l.qty = Math.max(1, l.qty - 1); renderCart(); } }),
                TB.el('span', { class: 'n', text: String(l.qty) }),
                TB.el('button', { text: '+', onClick: () => { l.qty += 1; renderCart(); } }),
              ]),
              TB.el('button', { class: 'btn sm', text: '✎ ' + t('customize'), onClick: () => customizeLine(idx) }),
              TB.el('button', { class: 'btn sm', text: '✕ ' + t('remove'), onClick: () => { state.cart.splice(idx, 1); renderCart(); } }),
            ]),
          ]),
          TB.el('div', { class: 'cl-price', text: TB.iqd(unitPrice(l) * l.qty) }),
        ]);
        linesBox.appendChild(line);
      });
    }

    function customizeLine(idx) {
      const l = state.cart[idx];
      const removed = new Set(l.removed || []);
      const addedNames = new Set((l.extras || []).map((e) => e.name));

      const wrap = TB.el('div', { style: 'min-width:360px;max-width:460px' }, [
        TB.el('h3', { text: t('customize') + ' — ' + l.item_name }),
      ]);

      const liveTotal = TB.el('span', {});
      const updateTotal = () => {
        const extraSum = (l.availExtras || [])
          .filter((e) => addedNames.has(e.name))
          .reduce((s, e) => s + (Number(e.price) || 0), 0);
        liveTotal.textContent = TB.iqd(l.price + extraSum);
      };

      // Remove ingredients: checklist — checked = keep, unchecked = removed.
      if (l.ingredients && l.ingredients.length) {
        wrap.appendChild(TB.el('div', { class: 'lbl', text: t('removeIngredients') }));
        const listEl = TB.el('div', { class: 'check-list' });
        l.ingredients.forEach((ing) => {
          const cb = TB.el('input', { type: 'checkbox' });
          cb.checked = !removed.has(ing);
          const row = TB.el('label', { class: 'check-row' + (removed.has(ing) ? ' off' : '') }, [
            cb, TB.el('span', { text: ing }),
          ]);
          cb.addEventListener('change', () => {
            if (cb.checked) removed.delete(ing);
            else removed.add(ing);
            row.className = 'check-row' + (cb.checked ? '' : ' off');
          });
          listEl.appendChild(row);
        });
        wrap.appendChild(listEl);
      }

      // Add paid extras: checklist — checked = added (price included).
      if (l.availExtras && l.availExtras.length) {
        wrap.appendChild(TB.el('div', { class: 'lbl', text: t('addExtras'), style: 'margin-top:10px' }));
        const listEl = TB.el('div', { class: 'check-list' });
        l.availExtras.forEach((ex) => {
          const cb = TB.el('input', { type: 'checkbox' });
          cb.checked = addedNames.has(ex.name);
          const row = TB.el('label', { class: 'check-row' }, [
            cb,
            TB.el('span', { text: ex.name }),
            TB.el('span', { class: 'ex-price', text: '+' + TB.iqd(ex.price) }),
          ]);
          cb.addEventListener('change', () => {
            if (cb.checked) addedNames.add(ex.name);
            else addedNames.delete(ex.name);
            updateTotal();
          });
          listEl.appendChild(row);
        });
        wrap.appendChild(listEl);
      }

      wrap.appendChild(TB.el('div', { class: 'lbl', text: t('note'), style: 'margin-top:10px' }));
      const ta = TB.el('textarea', { class: 'field', rows: '2', placeholder: t('notePlaceholder') });
      ta.value = l.note || '';
      wrap.appendChild(ta);

      wrap.appendChild(TB.el('div', { class: 'row', style: 'margin-top:10px' }, [
        TB.el('span', { class: 'k', text: t('total') + ' / 1' }),
        liveTotal,
      ]));
      updateTotal();

      const m = TB.modal(wrap);
      wrap.appendChild(
        TB.el('div', { class: 'actions' }, [
          TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
          TB.el('button', {
            class: 'btn primary', text: t('save'),
            onClick: () => {
              l.removed = (l.ingredients || []).filter((i) => removed.has(i));
              l.extras = (l.availExtras || []).filter((e) => addedNames.has(e.name));
              l.note = ta.value.trim();
              m.close();
              renderCart();
            },
          }),
        ])
      );
    }

    function renderFoot() {
      TB.clear(footBox);
      const { subtotal, total } = totals();
      const discInput = TB.el('input', {
        class: 'field', type: 'number', min: '0', max: '100', value: String(state.discount),
        style: 'width:90px', onInput: (e) => { state.discount = Math.min(100, Math.max(0, Number(e.target.value) || 0)); renderFoot(); },
      });
      footBox.appendChild(TB.el('div', { class: 'row' }, [
        TB.el('span', { class: 'k', text: t('subtotal') }),
        TB.el('span', { text: TB.iqd(subtotal) }),
      ]));
      footBox.appendChild(TB.el('div', { class: 'row' }, [
        TB.el('span', { class: 'k', text: t('discount') + ' %' }),
        discInput,
      ]));
      footBox.appendChild(TB.el('div', { class: 'row' }, [
        TB.el('span', { class: 'k', text: t('total') }),
        TB.el('span', { class: 'grand', text: TB.iqd(total) }),
      ]));
      footBox.appendChild(
        TB.el('button', {
          class: 'btn primary big', style: 'width:100%;margin-top:10px',
          text: t('completePrint'), onClick: complete,
        })
      );
    }

    function renderCart() {
      renderLines();
      renderFoot();
    }

    // ---- Complete & pay ----
    async function complete() {
      if (!state.cart.length) return TB.toast(t('cartEmpty'), 'error');
      const wrap = TB.el('div', {}, [TB.el('h3', { text: t('choosePayment') })]);
      const m = TB.modal(wrap);
      const pay = async (method) => {
        m.close();
        await saveOrder(method);
      };
      wrap.appendChild(
        TB.el('div', { class: 'pay-choice' }, [
          TB.el('button', { class: 'btn big', text: '💵 ' + t('cash'), onClick: () => pay('cash') }),
          TB.el('button', { class: 'btn primary big', text: '💳 ' + t('card'), onClick: () => pay('card') }),
        ])
      );
    }

    async function saveOrder(method) {
      const payload = {
        order_type: state.orderType,
        table_no: state.table,
        customer: state.customer,
        staff_id: TB.state.user.id,
        payment_method: method,
        discount_pct: Number(state.discount) || 0,
        items: state.cart.map((l) => ({
          item_name: l.item_name, category: l.category, price: unitPrice(l), qty: l.qty, note: buildNote(l),
        })),
      };
      try {
        const res = await TB.call(window.pos.orders.create(payload));
        const n = res.order.id;
        if (res.printResult && res.printResult.errors && res.printResult.errors.length) {
          TB.toast(t('printFailed'), 'error');
        } else {
          TB.toast(t('orderSaved', { n }), 'ok');
        }
        // reset cart, keep order type
        state.cart = [];
        state.table = '';
        state.customer = '';
        state.discount = 0;
        renderCartHead();
        renderCart();
      } catch (e) {
        TB.toast(e.message, 'error');
      }
    }

    cart.appendChild(cartHead);
    cart.appendChild(linesBox);
    cart.appendChild(footBox);
    renderCartHead();
    renderCart();

    // Enter-key shortcut hook (wired by app.js).
    TB.activeComplete = complete;
  },

  unmount() {
    TB.activeComplete = null;
  },
};
