'use strict';

TB.screens.menu = {
  async mount(root) {
    const t = TB.t;
    let cats = []; // [{ id, key, label, active }]
    let items = [];

    const page = TB.el('div', { class: 'page' });
    page.appendChild(TB.el('h2', { text: t('menuMgmt') }));
    const toolbar = TB.el('div', { class: 'toolbar' }, [
      TB.el('button', { class: 'btn primary', text: '+ ' + t('addItem'), onClick: addItemDialog }),
      TB.el('button', { class: 'btn', text: t('manageCategories'), onClick: manageCategories }),
      TB.el('button', { class: 'btn danger', text: t('resetMenu'), onClick: resetMenu }),
    ]);
    page.appendChild(toolbar);
    const tblWrap = TB.el('div', { class: 'scroll', style: 'max-height:calc(100% - 120px)' });
    page.appendChild(tblWrap);
    TB.clear(root).appendChild(page);

    async function load() {
      try {
        cats = await TB.call(window.pos.categories.list({}));
        TB.state.categories = cats;
        items = await TB.call(window.pos.menu.list({}));
      } catch (e) { TB.toast(e.message, 'error'); }
      render();
    }

    function catSelect(value, onChange) {
      const sel = TB.el('select', { class: 'field', onChange });
      cats.forEach((c) => {
        const o = TB.el('option', { value: c.key, text: c.label });
        if (c.key === value) o.selected = true;
        sel.appendChild(o);
      });
      return sel;
    }

    // ---- Category manager (add / rename / delete / (de)activate) ----
    function manageCategories() {
      const listBox = TB.el('div', {});
      const wrap = TB.el('div', { style: 'min-width:420px;max-width:520px' }, [
        TB.el('h3', { text: t('manageCategories') }),
        listBox,
      ]);
      const m = TB.modal(wrap);

      const refresh = () => {
        TB.clear(listBox);
        cats.forEach((c) => {
          const nameI = TB.el('input', { class: 'field', value: c.label, style: 'flex:1' });
          nameI.addEventListener('change', () => catAction(() => window.pos.categories.rename({ id: c.id, label: nameI.value })));
          const row = TB.el('div', { class: 'toolbar', style: 'margin:6px 0' }, [
            nameI,
            TB.el('button', { class: c.active ? 'btn' : 'btn primary', text: c.active ? t('deactivate') : t('activate'),
              onClick: () => catAction(() => window.pos.categories.setActive({ id: c.id, active: c.active ? 0 : 1 })) }),
            TB.el('button', { class: 'btn danger', text: '✕', title: t('deleteCategory'),
              onClick: () => catAction(() => window.pos.categories.delete({ id: c.id })) }),
          ]);
          listBox.appendChild(row);
        });
        const newI = TB.el('input', { class: 'field', placeholder: t('categoryName'), style: 'flex:1' });
        const addRow = TB.el('div', { class: 'toolbar', style: 'margin-top:12px' }, [
          newI,
          TB.el('button', { class: 'btn primary', text: '+ ' + t('add'),
            onClick: () => { if (newI.value.trim()) catAction(() => window.pos.categories.add({ label: newI.value.trim() })); } }),
        ]);
        listBox.appendChild(addRow);
      };

      async function catAction(fn) {
        try { await TB.call(fn()); await load(); refresh(); }
        catch (e) { TB.toast(e.message, 'error'); }
      }

      refresh();
    }

    function render() {
      TB.clear(tblWrap);
      const tbl = TB.el('table', { class: 'tbl' });
      tbl.appendChild(TB.el('thead', {}, TB.el('tr', {}, [
        TB.el('th', { text: t('photo') }),
        TB.el('th', { text: t('name') }),
        TB.el('th', { text: t('category') }),
        TB.el('th', { text: t('price') + ' (IQD)' }),
        TB.el('th', { text: t('tag') }),
        TB.el('th', { text: t('actions') }),
      ])));
      const tb = TB.el('tbody');
      items.forEach((it) => {
        const nameI = TB.el('input', { class: 'field', value: it.name });
        nameI.addEventListener('change', () => update(it.id, { name: nameI.value }));
        const priceI = TB.el('input', { class: 'field', type: 'number', min: '0', value: String(it.price), style: 'width:120px' });
        priceI.addEventListener('change', () => update(it.id, { price: Number(priceI.value) || 0 }));
        const tagI = TB.el('input', { class: 'field', value: it.tag || '', style: 'width:120px' });
        tagI.addEventListener('change', () => update(it.id, { tag: tagI.value }));
        const cat = catSelect(it.category, (e) => update(it.id, { category: e.target.value }));

        const toggle = TB.el('button', {
          class: it.active ? 'btn' : 'btn primary',
          text: it.active ? t('deactivate') : t('activate'),
          onClick: () => setActive(it.id, it.active ? 0 : 1),
        });

        const thumb = TB.el('div', { class: 'menu-thumb' });
        if (it.image) thumb.appendChild(TB.el('img', { src: it.image, alt: it.name }));
        else thumb.appendChild(TB.el('div', { class: 'thumb-empty', text: '🍔' }));
        const photoCell = TB.el('div', { class: 'photo-cell' }, [
          thumb,
          TB.el('div', { class: 'photo-btns' }, [
            TB.el('button', {
              class: 'iconbtn',
              text: it.image ? t('changePhoto') : '＋ ' + t('addPhoto'),
              onClick: () => choosePhoto(it.id),
            }),
            it.image
              ? TB.el('button', { class: 'iconbtn', text: '✕', title: t('removePhoto'), onClick: () => setImage(it.id, '') })
              : null,
          ]),
        ]);

        const nIngr = (it.ingredients && it.ingredients.length) || 0;
        const nExtra = (it.extras && it.extras.length) || 0;
        const ingrBtn = TB.el('button', {
          class: 'btn', text: t('ingredients') + (nIngr ? ' (' + nIngr + ')' : ''),
          onClick: () => editIngredients(it),
        });
        const extraBtn = TB.el('button', {
          class: 'btn', text: t('extras') + (nExtra ? ' (' + nExtra + ')' : ''),
          onClick: () => editExtras(it),
        });

        tb.appendChild(TB.el('tr', { class: it.active ? '' : 'inactive-row' }, [
          TB.el('td', {}, photoCell),
          TB.el('td', {}, nameI),
          TB.el('td', {}, cat),
          TB.el('td', {}, priceI),
          TB.el('td', {}, tagI),
          TB.el('td', {}, TB.el('div', { class: 'toolbar', style: 'margin:0' }, [ingrBtn, extraBtn, toggle])),
        ]));
      });
      tbl.appendChild(tb);
      tblWrap.appendChild(tbl);
    }

    async function update(id, patch) {
      try { await TB.call(window.pos.menu.update(Object.assign({ id }, patch))); TB.toast(t('saved'), 'ok'); }
      catch (e) { TB.toast(e.message, 'error'); await load(); }
    }
    async function setActive(id, active) {
      try { await TB.call(window.pos.menu.setActive({ id, active })); await load(); }
      catch (e) { TB.toast(e.message, 'error'); }
    }

    // Save an image (or '' to remove) and refresh so the thumbnail updates.
    async function setImage(id, image) {
      try { await TB.call(window.pos.menu.update({ id, image })); TB.toast(t('saved'), 'ok'); await load(); }
      catch (e) { TB.toast(e.message, 'error'); }
    }

    // Open a file picker and shrink the chosen photo to a ~320px JPEG data URI
    // (stays small in the DB and prints/renders fast) entirely in the browser.
    function choosePhoto(id) {
      const input = document.createElement('input');
      input.type = 'file';
      input.accept = 'image/*';
      input.onchange = () => {
        const file = input.files && input.files[0];
        if (!file) return;
        resizeToDataUrl(file, 320, (url) => setImage(id, url));
      };
      input.click();
    }

    function resizeToDataUrl(file, max, cb) {
      const reader = new FileReader();
      reader.onload = () => {
        const img = new Image();
        img.onload = () => {
          const scale = Math.min(1, max / Math.max(img.width, img.height));
          const w = Math.max(1, Math.round(img.width * scale));
          const h = Math.max(1, Math.round(img.height * scale));
          const c = document.createElement('canvas');
          c.width = w; c.height = h;
          c.getContext('2d').drawImage(img, 0, 0, w, h);
          cb(c.toDataURL('image/jpeg', 0.82));
        };
        img.onerror = () => TB.toast('Invalid image', 'error');
        img.src = reader.result;
      };
      reader.onerror = () => TB.toast('Could not read file', 'error');
      reader.readAsDataURL(file);
    }

    function addItemDialog() {
      const nameI = TB.el('input', { class: 'field', placeholder: t('name') });
      const priceI = TB.el('input', { class: 'field', type: 'number', min: '0', placeholder: t('price') });
      const tagI = TB.el('input', { class: 'field', placeholder: t('tag') + ' (scharf / Chili)' });
      const cat = catSelect(cats[0] ? cats[0].key : '', null);
      const wrap = TB.el('div', {}, [
        TB.el('h3', { text: t('addItem') }),
        TB.el('label', { class: 'lbl', text: t('name') }), nameI,
        TB.el('label', { class: 'lbl', text: t('category'), style: 'margin-top:8px' }), cat,
        TB.el('label', { class: 'lbl', text: t('price') + ' (IQD)', style: 'margin-top:8px' }), priceI,
        TB.el('label', { class: 'lbl', text: t('tag'), style: 'margin-top:8px' }), tagI,
      ]);
      const m = TB.modal(wrap);
      wrap.appendChild(TB.el('div', { class: 'actions' }, [
        TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
        TB.el('button', { class: 'btn primary', text: t('add'), onClick: async () => {
          const name = nameI.value.trim();
          const price = Number(priceI.value) || 0;
          if (!name) return TB.toast(t('name'), 'error');
          try {
            await TB.call(window.pos.menu.add({ name, category: cat.value, price, tag: tagI.value.trim() }));
            m.close(); TB.toast(t('itemAdded'), 'ok'); await load();
          } catch (e) { TB.toast(e.message, 'error'); }
        } }),
      ]));
      setTimeout(() => nameI.focus(), 30);
    }

    // Chip-based ingredient editor: type + Enter (or comma) to add, ✕ to remove.
    function editIngredients(it) {
      const list = (it.ingredients || []).slice();
      const chipsBox = TB.el('div', { class: 'ingr-chips', style: 'margin:8px 0' });
      const input = TB.el('input', { class: 'field', placeholder: t('addIngredientHint') });

      const renderChips = () => {
        TB.clear(chipsBox);
        if (!list.length) chipsBox.appendChild(TB.el('span', { class: 'muted', text: t('none') }));
        list.forEach((ing, i) => {
          chipsBox.appendChild(TB.el('span', { class: 'ingr-chip editable' }, [
            document.createTextNode(ing + ' '),
            TB.el('button', { class: 'chip-x', text: '✕', onClick: () => { list.splice(i, 1); renderChips(); } }),
          ]));
        });
      };
      const addFromInput = () => {
        input.value.split(',').map((s) => s.trim()).filter(Boolean).forEach((v) => {
          if (!list.some((x) => x.toLowerCase() === v.toLowerCase())) list.push(v);
        });
        input.value = '';
        renderChips();
      };
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ',') { e.preventDefault(); addFromInput(); }
      });

      const wrap = TB.el('div', { style: 'min-width:400px;max-width:520px' }, [
        TB.el('h3', { text: t('ingredients') + ' — ' + it.name }),
        TB.el('div', { class: 'lbl', text: t('ingredientsHint') }),
        chipsBox,
        TB.el('div', { class: 'toolbar', style: 'margin:0' }, [
          input,
          TB.el('button', { class: 'btn', text: '+ ' + t('add'), onClick: addFromInput }),
        ]),
      ]);
      renderChips();
      const m = TB.modal(wrap);
      wrap.appendChild(TB.el('div', { class: 'actions' }, [
        TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
        TB.el('button', {
          class: 'btn primary', text: t('save'),
          onClick: async () => {
            addFromInput(); // capture any pending typed text
            try { await TB.call(window.pos.menu.update({ id: it.id, ingredients: list })); m.close(); TB.toast(t('saved'), 'ok'); await load(); }
            catch (e) { TB.toast(e.message, 'error'); }
          },
        }),
      ]));
      setTimeout(() => input.focus(), 30);
    }

    // Extras editor: rows of {name, price} the owner can add/remove.
    function editExtras(it) {
      const list = (it.extras || []).map((e) => ({ name: e.name, price: e.price }));
      const rowsBox = TB.el('div', { style: 'margin:8px 0' });

      const renderRows = () => {
        TB.clear(rowsBox);
        list.forEach((ex, i) => {
          const nameI = TB.el('input', { class: 'field', value: ex.name, placeholder: t('name'), style: 'flex:1' });
          nameI.addEventListener('input', () => (ex.name = nameI.value));
          const priceI = TB.el('input', { class: 'field', type: 'number', min: '0', value: String(ex.price), style: 'width:110px' });
          priceI.addEventListener('input', () => (ex.price = Number(priceI.value) || 0));
          rowsBox.appendChild(TB.el('div', { class: 'toolbar', style: 'margin:4px 0' }, [
            nameI, priceI, TB.el('span', { class: 'muted', text: 'IQD' }),
            TB.el('button', { class: 'btn danger', text: '✕', onClick: () => { list.splice(i, 1); renderRows(); } }),
          ]));
        });
      };

      const wrap = TB.el('div', { style: 'min-width:420px;max-width:540px' }, [
        TB.el('h3', { text: t('extras') + ' — ' + it.name }),
        TB.el('div', { class: 'lbl', text: t('extrasHint') }),
        rowsBox,
        TB.el('button', { class: 'btn', text: '+ ' + t('add'), onClick: () => { list.push({ name: '', price: 0 }); renderRows(); } }),
      ]);
      renderRows();
      const m = TB.modal(wrap);
      wrap.appendChild(TB.el('div', { class: 'actions' }, [
        TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
        TB.el('button', {
          class: 'btn primary', text: t('save'),
          onClick: async () => {
            const clean = list.map((e) => ({ name: String(e.name).trim(), price: Math.round(Number(e.price) || 0) })).filter((e) => e.name);
            try { await TB.call(window.pos.menu.update({ id: it.id, extras: clean })); m.close(); TB.toast(t('saved'), 'ok'); await load(); }
            catch (e) { TB.toast(e.message, 'error'); }
          },
        }),
      ]));
    }

    function resetMenu() {
      TB.confirm(t('resetMenu'), t('resetMenuConfirm'), async () => {
        try { await TB.call(window.pos.menu.reset()); TB.toast(t('saved'), 'ok'); await load(); }
        catch (e) { TB.toast(e.message, 'error'); }
      });
    }

    await load();
  },
};
