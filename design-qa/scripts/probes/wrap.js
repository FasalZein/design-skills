// design-qa render probe: wrap. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clear = c => /rgba\(0, 0, 0, 0\)|transparent/.test(c);
  const clipAxis = (c, r, on, lo, hi) => { if (on) { c[lo] = Math.max(c[lo], r[lo]); c[hi] = Math.min(c[hi], r[hi]); } };
  const clipTo = (c, a) => { const s = getComputedStyle(a), x = s.overflowX !== 'visible', y = s.overflowY !== 'visible';
    if (!x && !y) return c;   // this ancestor clips neither axis
    c = c || {left: -Infinity, right: Infinity, top: -Infinity, bottom: Infinity};
    const r = a.getBoundingClientRect(); clipAxis(c, r, x, 'left', 'right'); clipAxis(c, r, y, 'top', 'bottom'); return c; };
  const clipBox = n => { let c = null;   // visible area: intersect EVERY clipping ancestor, per clipped axis
    for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) c = clipTo(c, a);
    return c; };
  const shown = (q, c) => q.width > TOL && q.height > TOL && (!c ||
    (Math.min(q.bottom, c.bottom) - Math.max(q.top, c.top) > TOL && Math.min(q.right, c.right) - Math.max(q.left, c.left) > TOL));
  const staged = e => !!e.parentElement?.closest('.ss-stage');   // stageshow stage content: film.mjs owns it
  const rects = (n, g) => { const c = clipBox(n); return [...g.getClientRects()].filter(q => shown(q, c)); };
  const whole = n => { const g = document.createRange(); g.selectNodeContents(n); return rects(n, g); };
  const texts = e => { const r = [], it = document.createTreeWalker(e, NodeFilter.SHOW_TEXT);
    for (let n; (n = it.nextNode());) if (n.textContent.trim() && vis(n.parentElement) && whole(n).length) r.push(n);
    return r; };
  const count = qs => { const tops = []; for (const q of qs) if (!tops.some(t => Math.abs(t - q.top) < q.height / 2)) tops.push(q.top); return tops.length; };
  const lines = e => count(texts(e).flatMap(whole));
  const split = e => { for (const n of e.childNodes) if (n.nodeType === 3)   // first token (between spaces and dashes) set on two lines
      for (const m of n.textContent.matchAll(/[^\s\-–—\/]+/g)) { const g = document.createRange();
        g.setStart(n, m.index); g.setEnd(n, m.index + m[0].length); if (count(rects(n, g)) > 1) return m[0]; }
    return null; };
  const inlineOnly = e => [...e.querySelectorAll('*')].every(d => /^inline|contents|none/.test(getComputedStyle(d).display));
  const isControl = e => { if (e.matches('button,[role=button],[role=tab],summary')) return true;
    if (!e.matches('a')) return false; const s = getComputedStyle(e);
    return s.display !== 'inline' && (!clear(s.backgroundColor) || parseFloat(s.borderTopWidth) > 0); };
  const measured = e => { const box = e.getBoundingClientRect(); return !staged(e) && vis(e) && box.width > TOL && box.height > TOL; };
  // A finding is [tier, why]. The rendered label of a control: one visible text, whatever wrapper holds it;
  // several texts (name over email) are fields, not one label.
  const controlFinding = e => { if (!inlineOnly(e) && (e.matches('a') || texts(e).length !== 1)) return null;
    return lines(e) > 1 ? ['fail', 'control label wraps'] : null; };
  const ownText = e => [...e.childNodes].some(n => n.nodeType === 3 && n.textContent.trim());
  const inControl = e => !!e.parentElement?.closest('button,[role=button],[role=tab],summary');   // reported with its control
  const plainText = e => inlineOnly(e) && ownText(e) && !inControl(e);
  const breakFinding = e => { const w = split(e);   // titles, money and metric labels wrap between words (Gate 8); a split number goes to review
    if (w) return /\d/.test(w) ? ['judge', 'number or money token split across lines'] : ['fail', 'word broken across lines'];
    return e.matches('label,th,dt,legend') && lines(e) > 1 ? ['judge', 'label wraps'] : null; };
  const finding = e => { if (!measured(e)) return null;
    if (isControl(e)) return controlFinding(e);
    return plainText(e) ? breakFinding(e) : null; };
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  const report = out => ({tier: out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS',
    counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail,
    ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})});
  const out = {fail: [], judge: []};
  for (const e of document.querySelectorAll('body *')) { const found = finding(e);
    if (found) out[found[0]].push({t: e.textContent.trim().replace(/\s+/g, ' ').slice(0, 40), lines: lines(e), why: found[1]}); }
  return report(out); })()
