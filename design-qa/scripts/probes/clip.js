// design-qa render probe: clip. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const MONEY = /[$€£¥₹]\s?\d|\d[\d,.]*\s?(%|[kKMB]\b|USD|EUR|GBP|AED|SAR)/;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const out = {fail: [], judge: []};
  for (const e of document.querySelectorAll('body *')) {
    const box = e.getBoundingClientRect();
    if (!vis(e) || box.width <= TOL || box.height <= TOL || e.matches('input,textarea,select,option,script,style')) continue;
    const texts = [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
    if (!texts.length) continue;
    const s = getComputedStyle(e), ps = e.parentElement && getComputedStyle(e.parentElement);
    if (/auto|scroll/.test(s.overflowX + s.overflowY) || (ps && /auto|scroll/.test(ps.overflowX + ps.overflowY))) continue;
    let left = Infinity, right = -Infinity;
    for (const n of texts) { const g = document.createRange(); g.selectNodeContents(n);
      for (const q of g.getClientRects()) if (q.width > TOL) { left = Math.min(left, q.left); right = Math.max(right, q.right); } }
    const t = e.textContent.trim().replace(/\s+/g, ' '), row = {t: t.slice(0, 40), scroll: e.scrollWidth, client: e.clientWidth};
    const cutX = e.scrollWidth > e.clientWidth + TOL, cutY = e.scrollHeight - e.clientHeight >= parseFloat(s.fontSize);
    const clamped = s.webkitLineClamp !== 'none' && e.scrollHeight > e.clientHeight + TOL;
    if (s.overflowX === 'visible' && s.overflowY === 'visible') {
      if (left < box.left - TOL || right > box.right + TOL) out.fail.push({...row, why: 'spills out of its box'});
      continue; }
    const truncated = (s.textOverflow === 'ellipsis' && cutX) || clamped;
    if (!truncated) { if (cutX || cutY) out.fail.push({...row, why: 'cut without ellipsis'}); continue; }
    const holder = e.closest('[title],[aria-label]');
    const full = holder && (holder.title || holder.getAttribute('aria-label') || '').includes(t);
    if (e.matches('h1,h2,h3,h4,h5,h6') || MONEY.test(t)) out.fail.push({...row, why: 'title, money or metric truncated'});
    else if (!full) out.fail.push({...row, why: 'truncated, full value unreachable'});
    else out.judge.push({...row, why: 'truncated: confirm the design fixes this width'});
  }
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  return {tier: out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS',
    counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail,
    ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; })()
