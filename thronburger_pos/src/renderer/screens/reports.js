'use strict';

TB.screens.reports = {
  async mount(root) {
    const t = TB.t;
    const isAdmin = TB.state.user.role === 'admin';

    const page = TB.el('div', { class: 'page' });
    page.appendChild(TB.el('h2', { text: t('reports') }));
    if (!isAdmin) page.appendChild(TB.el('div', { class: 'muted', text: t('cashiersToday') }));
    TB.clear(root).appendChild(page);

    const todayStr = () => {
      const d = new Date();
      const p = (n) => String(n).padStart(2, '0');
      return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
    };

    const fromInput = TB.el('input', { class: 'field', type: 'date', value: todayStr(), style: 'width:170px' });
    const toInput = TB.el('input', { class: 'field', type: 'date', value: todayStr(), style: 'width:170px' });

    const kpiRow = TB.el('div', { class: 'kpis' });
    const chartsBox = TB.el('div', { class: 'charts' });

    if (isAdmin) {
      const toolbar = TB.el('div', { class: 'toolbar' }, [
        TB.el('div', {}, [TB.el('label', { class: 'lbl', text: t('from') }), fromInput]),
        TB.el('div', {}, [TB.el('label', { class: 'lbl', text: t('to') }), toInput]),
        TB.el('button', { class: 'btn primary', text: t('apply'), onClick: () => load(currentRange()) }),
        TB.el('button', { class: 'btn', text: t('today'), onClick: () => { fromInput.value = todayStr(); toInput.value = todayStr(); load(null); } }),
      ]);
      page.appendChild(toolbar);
    }

    page.appendChild(kpiRow);
    page.appendChild(chartsBox);

    function currentRange() {
      if (!isAdmin) return null;
      return { from: fromInput.value + ' 00:00:00', to: toInput.value + ' 23:59:59' };
    }

    async function load(range) {
      let s;
      try {
        s = await TB.call(window.pos.reports.summary(range || {}));
      } catch (e) {
        return TB.toast(e.message, 'error');
      }
      renderKpis(s.kpi);
      renderCharts(s);
    }

    function renderKpis(k) {
      TB.clear(kpiRow);
      const kpi = (val, label) => TB.el('div', { class: 'kpi' }, [
        TB.el('div', { class: 'v', text: val }),
        TB.el('div', { class: 'l', text: label }),
      ]);
      kpiRow.appendChild(kpi(TB.iqd(k.revenue), t('revenue')));
      kpiRow.appendChild(kpi(String(k.orders), t('orderCount')));
      kpiRow.appendChild(kpi(TB.iqd(k.avg_order), t('avgOrder')));
      kpiRow.appendChild(kpi(String(k.items_sold), t('itemsSold')));
    }

    function renderCharts(s) {
      TB.clear(chartsBox);
      const iqd = (v) => TB.iqd(v);
      const num = (v) => String(v);

      chartsBox.appendChild(TB.charts.bar(t('topItems'),
        s.topItems.map((r) => ({ label: r.label, value: r.qty })), { format: num }));

      chartsBox.appendChild(TB.charts.bar(t('revByCategory'),
        s.byCategory.map((r) => ({ label: r.label, value: r.revenue })),
        { format: iqd, labelFn: (l) => TB.catLabel(l) }));

      chartsBox.appendChild(TB.charts.bar(t('ordersByType'),
        s.byType.map((r) => ({ label: r.label, value: r.orders })),
        { format: num, labelFn: (l) => TB.t(l) }));

      chartsBox.appendChild(TB.charts.bar(t('revByHour'),
        s.byHour.map((r) => ({ label: r.label + ':00', value: r.revenue })), { format: iqd }));

      chartsBox.appendChild(TB.charts.bar(t('revPerCashier'),
        s.byCashier.map((r) => ({ label: r.label, value: r.revenue })), { format: iqd }));

      chartsBox.appendChild(TB.charts.bar(t('cashVsCard'),
        s.byPayment.map((r) => ({ label: r.label, value: r.revenue })),
        { format: iqd, labelFn: (l) => (l === 'cash' ? t('cash') : t('card')) }));
    }

    // ---- Z-report (admin only) ----
    if (isAdmin) {
      const zSection = TB.el('div', { style: 'margin-top:24px' });
      zSection.appendChild(TB.el('h2', { text: t('zReport') }));
      const zActions = TB.el('div', { class: 'toolbar' }, [
        TB.el('button', { class: 'btn primary', text: t('generateZReport'), onClick: generateZ }),
      ]);
      zSection.appendChild(zActions);
      const zList = TB.el('div', { class: 'list' });
      zSection.appendChild(TB.el('h3', { text: t('pastZReports'), style: 'margin:14px 0 8px' }));
      zSection.appendChild(zList);
      page.appendChild(zSection);

      async function loadZList() {
        let list = [];
        try { list = await TB.call(window.pos.reports.zList()); } catch (e) { TB.toast(e.message, 'error'); }
        TB.clear(zList);
        if (!list.length) { zList.appendChild(TB.el('div', { class: 'muted', text: '—' })); return; }
        list.forEach((z) => {
          zList.appendChild(TB.el('div', { class: 'orow' }, [
            TB.el('div', { class: 'oid', text: 'Z' + z.id }),
            TB.el('div', { class: 'ometa', text: `${z.from_ts} → ${z.to_ts}` }),
            TB.el('button', { class: 'btn', text: t('reprint'), onClick: async () => {
              try { await TB.call(window.pos.reports.zReprint(z.id)); TB.toast(t('reprinted'), 'ok'); }
              catch (e) { TB.toast(e.message, 'error'); }
            } }),
          ]));
        });
      }

      async function generateZ() {
        let data;
        try { data = await TB.call(window.pos.reports.zCompute()); }
        catch (e) { return TB.toast(e.message, 'error'); }

        const summary = TB.el('div', {}, [
          TB.el('h3', { text: t('zReport') }),
          TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('revenue') }), TB.el('span', { text: TB.iqd(data.revenue) })]),
          TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('orderCount') }), TB.el('span', { text: String(data.orders) })]),
          TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('cash') }), TB.el('span', { text: TB.iqd(data.cash) })]),
          TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('card') }), TB.el('span', { text: TB.iqd(data.card) })]),
          TB.el('div', { class: 'row' }, [TB.el('span', { class: 'k', text: t('voided') }), TB.el('span', { text: String(data.voided_count) })]),
          TB.el('p', { class: 'muted', text: t('zReportConfirm') }),
        ]);
        const m = TB.modal(summary);
        summary.appendChild(TB.el('div', { class: 'actions' }, [
          TB.el('button', { class: 'btn', text: t('cancel'), onClick: () => m.close() }),
          TB.el('button', { class: 'btn primary', text: t('generateZReport'), onClick: async () => {
            m.close();
            try { await TB.call(window.pos.reports.zSave(data)); TB.toast(t('zSaved'), 'ok'); await loadZList(); }
            catch (e) { TB.toast(e.message, 'error'); }
          } }),
        ]));
      }

      loadZList();
    }

    await load(null);
  },
};
