'use strict';

// Dependency-free horizontal bar charts (no external libraries — fully offline).
// Each chart is a titled card containing label / bar / value rows.

TB.charts = {
  /**
   * @param {string} title           already-translated card title
   * @param {Array<{label,value}>} rows
   * @param {object} opt             { format?: (v)=>string, labelFn?: (l)=>string }
   */
  bar(title, rows, opt = {}) {
    const format = opt.format || ((v) => String(v));
    const labelFn = opt.labelFn || ((l) => String(l));
    const max = rows.reduce((m, r) => Math.max(m, Number(r.value) || 0), 0) || 1;

    const card = TB.el('div', { class: 'chart-card' }, [TB.el('h3', { text: title })]);

    if (!rows.length) {
      card.appendChild(TB.el('div', { class: 'muted', text: '—' }));
      return card;
    }

    for (const r of rows) {
      const pct = Math.max(2, Math.round((Number(r.value) / max) * 100));
      const row = TB.el('div', { class: 'bar-row' }, [
        TB.el('div', { class: 'bl', text: labelFn(r.label), title: labelFn(r.label) }),
        TB.el('div', { class: 'bar-track' }, [
          TB.el('div', { class: 'bar-fill', style: `width:${pct}%` }),
        ]),
        TB.el('div', { class: 'bv', text: format(r.value) }),
      ]);
      card.appendChild(row);
    }
    return card;
  },
};
