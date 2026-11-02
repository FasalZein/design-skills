// design-qa render probe: wrap. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const MONEY = /[$€£¥₹]\s?\d|\d[\d,.]*\s?(%|[kKMB]\b|USD|EUR|GBP|AED|SAR)/;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clear = c => /rgba\(0, 0, 0, 0\)|transparent/.test(c);
  const clipBox = n => { let c = null;   // visible area: intersect EVERY clipping ancestor, per clipped axis
    for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) { const s = getComputedStyle(a);
      const x = s.overflowX !== 'visible', y = s.overflowY !== 'visible'; if (!x && !y) continue;
      const r = a.getBoundingClientRect(); c = c || {left: -Infinity, right: Infinity, top: -Infinity, bottom: Infinity};
      if (x) { c.left = Math.max(c.left, r.left); c.right = Math.min(c.right, r.right); }
      if (y) { c.top = Math.max(c.top, r.top); c.bottom = Math.min(c.bottom, r.bottom); } }
    return c; };
  const shown = (q, c) => q.width > TOL && q.height > TOL && (!c ||
    (Math.min(q.bottom, c.bottom) - Math.max(q.top, c.top) > TOL && Math.min(q.right, c.right) - Math.max(q.left, c.left) > TOL));
  const lines = e => { const tops = [], it = document.createTreeWalker(e, NodeFilter.SHOW_TEXT);
    for (let n; (n = it.nextNode());) { if (!n.textContent.trim() || !vis(n.parentElement)) continue;
      const c = clipBox(n), g = document.createRange(); g.selectNodeContents(n);
      for (const q of g.getClientRects()) if (shown(q, c) && !tops.some(t => Math.abs(t - q.top) < q.height / 2)) tops.push(q.top); }
    return tops.length; };
  const inlineOnly = e => [...e.querySelectorAll('*')].every(d => /^inline|contents|none/.test(getComputedStyle(d).display));
  const isControl = e => { if (e.matches('button,[role=button],[role=tab],summary')) return true;
    if (!e.matches('a')) return false; const s = getComputedStyle(e);
    return s.display !== 'inline' && (!clear(s.backgroundColor) || parseFloat(s.borderTopWidth) > 0); };
  const out = {fail: [], judge: []};
  for (const e of document.querySelectorAll('body *')) {
    const box = e.getBoundingClientRect();
    if (!vis(e) || box.width <= TOL || box.height <= TOL || !inlineOnly(e)) continue;
    const control = isControl(e);
    if (!control && ![...e.childNodes].some(n => n.nodeType === 3 && n.textContent.trim())) continue;
    if (!control && e.parentElement?.closest('button,[role=button],[role=tab],summary')) continue;   // reported with its control
    const n = lines(e); if (n < 2) continue;
    const t = e.textContent.trim().replace(/\s+/g, ' '), row = {t: t.slice(0, 40), lines: n};
    if (control) out.fail.push({...row, why: 'control label wraps'});
    else if (!/\s/.test(t)) out.fail.push({...row, why: 'word broken across lines'});
    else if (MONEY.test(t) && t.split(' ').length <= 4) out.fail.push({...row, why: 'money or metric wraps'});
    else if (e.matches('label,th,dt,legend')) out.judge.push({...row, why: 'label wraps'});
  }
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  return {tier: out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS',
    counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail,
    ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; })()
