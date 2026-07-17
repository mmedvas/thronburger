'use strict';

// Fullscreen numeric PIN pad. On a correct PIN it hands the staff record to
// TB.onLogin (defined in app.js).
TB.screens.login = {
  mount(root) {
    const t = TB.t;
    let pin = '';

    const dots = TB.el('div', { class: 'pin-dots' });
    const error = TB.el('div', { class: 'pin-error' });

    const renderDots = () => {
      TB.clear(dots);
      for (let i = 0; i < 4; i++) {
        dots.appendChild(TB.el('div', { class: 'dot' + (i < pin.length ? ' on' : '') }));
      }
    };

    const submit = async () => {
      try {
        const staff = await TB.call(window.pos.auth.verifyPin(pin));
        if (staff) {
          error.textContent = '';
          TB.onLogin(staff);
        } else {
          error.textContent = t('wrongPin');
          pin = '';
          renderDots();
        }
      } catch (e) {
        error.textContent = e.message;
        pin = '';
        renderDots();
      }
    };

    const press = (d) => {
      if (pin.length >= 4) return;
      pin += d;
      renderDots();
      if (pin.length === 4) setTimeout(submit, 120);
    };
    const back = () => {
      pin = pin.slice(0, -1);
      error.textContent = '';
      renderDots();
    };

    const pad = TB.el('div', { class: 'pinpad' });
    ['1', '2', '3', '4', '5', '6', '7', '8', '9'].forEach((d) =>
      pad.appendChild(TB.el('button', { text: d, onClick: () => press(d) }))
    );
    pad.appendChild(TB.el('button', { class: 'wide', text: '⌫', onClick: back }));
    pad.appendChild(TB.el('button', { text: '0', onClick: () => press('0') }));
    pad.appendChild(TB.el('button', { text: '✓', onClick: submit }));

    const view = TB.el('div', { class: 'login' }, [
      TB.el('div', { class: 'logo' }, [
        TB.el('div', { class: 'l1', html: 'THRON<span class="accent">BURGER</span>' }),
        TB.el('div', { class: 'l2', text: 'Berlin × Hewlêr — Empire City, Erbil' }),
      ]),
      TB.el('div', { class: 'muted', text: t('enterPin') }),
      dots,
      error,
      pad,
    ]);

    TB.clear(root).appendChild(view);
    renderDots();

    // Hardware keyboard support on the login screen.
    this._key = (e) => {
      if (e.key >= '0' && e.key <= '9') press(e.key);
      else if (e.key === 'Backspace') back();
      else if (e.key === 'Enter') submit();
    };
    document.addEventListener('keydown', this._key);
  },

  unmount() {
    if (this._key) document.removeEventListener('keydown', this._key);
  },
};
