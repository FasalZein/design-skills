// design-qa render probe: clip. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const MONEY = /[$€£¥₹]\s?\d|\d[\d,.]*\s?(%|[kKMB]\b|USD|EUR|GBP|AED|SAR)/;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const staged = e => !!e.parentElement?.closest('.ss-stage');   // stageshow stage content: film.mjs owns it
  const clipper = e => { for (let a = e; a && a !== document.body; a = a.parentElement) { const s = getComputedStyle(a);
      if (/auto|scroll/.test(s.overflowX + s.overflowY)) return null;   // a scroll region keeps its content reachable
      if (/hidden|clip/.test(s.overflowX + s.overflowY)) return a; }   // the nearest box that cuts overflow
    return null; };
  const TRIGGER = 'a[href],button,[role=button],[role=link],[aria-describedby],[data-tooltip]';   // a detail or tooltip path
  const out = {fail: [], judge: []}, done = new Set();
  for (const e of document.querySelectorAll('body *')) {
    const box = e.getBoundingClientRect();
    if (staged(e) || !vis(e) || box.width <= TOL || box.height <= TOL || e.matches('input,textarea,select,option,script,style')) continue;
    const texts = [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
    if (!texts.length) continue;
    const s = getComputedStyle(e), ps = e.parentElement && getComputedStyle(e.parentElement);
    if (/auto|scroll/.test(s.overflowX + s.overflowY) || (ps && /auto|scroll/.test(ps.overflowX + ps.overflowY))) continue;
    const c = clipper(e), k = c && c.getBoundingClientRect(), lh = parseFloat(s.lineHeight) || 0;
    const inner = c && {left: k.left + c.clientLeft, top: k.top + c.clientTop, right: k.left + c.clientLeft + c.clientWidth, bottom: k.top + c.clientTop + c.clientHeight};
    let left = Infinity, right = -Infinity, partial = false;   // partial: a line the clip box shows only in part
    for (const n of texts) { const g = document.createRange(); g.selectNodeContents(n);
      for (const q of g.getClientRects()) { if (q.width <= TOL) continue; left = Math.min(left, q.left); right = Math.max(right, q.right);
        if (!c) continue; const trim = lh && q.height > lh ? (q.height - lh) / 2 : 0, top = q.top + trim, bottom = q.bottom - trim;   // the line box, so descenders past it are not a cut
        const seen = Math.min(q.right, inner.right) - Math.max(q.left, inner.left) > TOL && Math.min(bottom, inner.bottom) - Math.max(top, inner.top) > TOL;
        if (seen && (q.left < inner.left - TOL || q.right > inner.right + TOL || top < inner.top - TOL || bottom > inner.bottom + TOL)) partial = true; } }
    const row = x => ({t: x.textContent.trim().replace(/\s+/g, ' ').slice(0, 40), scroll: x.scrollWidth, client: x.clientWidth});
    if (s.overflowX === 'visible' && s.overflowY === 'visible' && (left < box.left - TOL || right > box.right + TOL)) {
      out.fail.push({...row(e), why: 'spills out of its box'}); continue; }
    if (!c || done.has(c)) continue;
    const cs = getComputedStyle(c), cutX = c.scrollWidth > c.clientWidth + TOL;
    const cut = partial || (c === e && (cutX || c.scrollHeight - c.clientHeight >= parseFloat(s.fontSize)));
    if (!cut) continue; done.add(c);
    const t = c.textContent.trim().replace(/\s+/g, ' ');
    const clamped = cs.webkitLineClamp !== 'none' && c.scrollHeight > c.clientHeight + TOL;
    const truncated = (cs.textOverflow === 'ellipsis' && cutX) || clamped;
    if (!truncated) { out.fail.push({...row(c), why: 'cut without ellipsis'}); continue; }
    const holder = e.closest('[title],[aria-label]');
    const full = holder && (holder.title || holder.getAttribute('aria-label') || '').includes(t);
    if (c.matches('h1,h2,h3,h4,h5,h6') || e.matches('h1,h2,h3,h4,h5,h6') || MONEY.test(t)) out.fail.push({...row(c), why: 'title, money or metric truncated'});
    else if (full) out.judge.push({...row(c), why: 'truncated: confirm the design fixes this width'});
    else if (e.closest(TRIGGER) || c.querySelector(TRIGGER)) out.judge.push({...row(c), why: 'truncated: verify the detail or tooltip path shows the full value'});
    else out.fail.push({...row(c), why: 'truncated, full value unreachable'});
  }
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  return {tier: out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS',
    counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail,
    ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; })()
