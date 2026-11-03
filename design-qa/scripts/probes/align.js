// design-qa render probe: align. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1, STEP = 4;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clipAxis = (c, r, on, lo, hi) => { if (on) { c[lo] = Math.max(c[lo], r[lo]); c[hi] = Math.min(c[hi], r[hi]); } };
  const clipTo = (c, a) => { const s = getComputedStyle(a), x = s.overflowX !== 'visible', y = s.overflowY !== 'visible';
    if (!x && !y) return c;   // this ancestor clips neither axis
    c = c || {left: -Infinity, right: Infinity, top: -Infinity, bottom: Infinity};
    const r = a.getBoundingClientRect(); clipAxis(c, r, x, 'left', 'right'); clipAxis(c, r, y, 'top', 'bottom'); return c; };
  const clipBox = n => { let c = null;   // visible area: intersect EVERY clipping ancestor, per clipped axis
    for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) c = clipTo(c, a);
    return c; };
  const shown = (r, c) => !c || (Math.min(r.bottom, c.bottom) - Math.max(r.top, c.top) > TOL && Math.min(r.right, c.right) - Math.max(r.left, c.left) > TOL);
  const kids = p => [...p.children].filter(c => { const r = c.getBoundingClientRect();   // stage content (film.mjs owns it) and boxes hidden by a clipping ancestor are skipped
    return !p.closest('.ss-stage') && vis(c) && r.width > TOL && r.height > TOL && shown(r, clipBox(c)) && !/absolute|fixed/.test(getComputedStyle(c).position); });
  const inlineOnly = e => [...e.querySelectorAll('*')].every(d => /^inline|contents|none/.test(getComputedStyle(d).display));
  const isLabel = c => !c.matches('svg,img') && c.textContent.trim() && inlineOnly(c);
  const isIcon = c => c.matches('svg,img') || (c.children.length === 1 && c.children[0].matches('svg,img') && !c.textContent.trim());
  const rects = c => { const g = document.createRange(); g.selectNodeContents(c); return [...g.getClientRects()].filter(q => q.width > TOL && q.height > TOL); };
  const firstLine = c => { const it = document.createTreeWalker(c, NodeFilter.SHOW_TEXT, {acceptNode: n => n.textContent.trim() ? 1 : 3});
    const n = it.nextNode(); if (!n) return null; const g = document.createRange(); g.selectNodeContents(n); return g.getClientRects()[0]; };
  const lineCount = c => { const tops = []; for (const q of rects(c)) if (!tops.some(t => Math.abs(t - q.top) < q.height / 2)) tops.push(q.top); return tops.length; };
  const baseline = c => { const it = document.createTreeWalker(c, NodeFilter.SHOW_TEXT, {acceptNode: n => n.textContent.trim() ? 1 : 3});
    const n = it.nextNode(); if (!n || /flex|grid/.test(getComputedStyle(n.parentNode).display)) return null;   // a marker in a flex or grid box becomes an item, not inline
    const m = document.createElement('span');
    m.style.cssText = 'display:inline-block;width:0;height:0;vertical-align:baseline';
    n.parentNode.insertBefore(m, n); const y = m.getBoundingClientRect().top; m.remove(); return {y, fs: getComputedStyle(n.parentNode).fontSize}; };
  const sameRow = (a, b) => { const x = a.getBoundingClientRect(), y = b.getBoundingClientRect(); return Math.min(x.bottom, y.bottom) - Math.max(x.top, y.top) > TOL; };
  const cy = r => r.top + r.height / 2;
  const name = c => (c.textContent.trim() || c.getAttribute('aria-label') || c.tagName).slice(0, 25);
  const out = {fail: [], judge: []};
  const grade = (d, row, judgeOnly) => { d = Math.round(d * 10) / 10; if (d <= TOL) return;
    (d < STEP || judgeOnly ? out.judge : out.fail).push({...row, off: d}); };
  for (const p of document.querySelectorAll('body, body *')) {
    if (!vis(p)) continue;
    const s = getComputedStyle(p), cs = kids(p); if (cs.length < 2) continue;
    if (/flex/.test(s.display) && !/column/.test(s.flexDirection)) for (let i = 1; i < cs.length; i++) {
      const [a, b] = [cs[i - 1], cs[i]]; if (!sameRow(a, b)) continue;
      const icon = isIcon(a) ? a : isIcon(b) ? b : null, text = icon === a ? b : a;
      if (icon && text.textContent.trim()) { const l = firstLine(text); if (!l) continue;
        const ic = cy(icon.getBoundingClientRect()), multi = lineCount(text) > 1;
        if (multi && Math.abs(ic - cy(text.getBoundingClientRect())) <= TOL) continue;
        grade(Math.abs(ic - cy(l)), {kind: 'icon-text', a: name(icon), b: name(text)}, multi); }
      else if (!icon && isLabel(a) && isLabel(b) && lineCount(a) === 1 && lineCount(b) === 1) {
        const x = baseline(a), y = baseline(b); if (!x || !y) continue;
        grade(Math.abs(x.y - y.y), {kind: 'label-value', a: name(a), b: name(b)}, x.fs !== y.fs); }
    }
    const stack = (/flex/.test(s.display) && /column/.test(s.flexDirection)) || s.display === 'block';
    const labels = stack ? cs.filter(c => isLabel(c) && !/^inline/.test(getComputedStyle(c).display)) : [];
    if (labels.length >= 2) { const lefts = labels.map(c => Math.round(c.getBoundingClientRect().left));
      const count = {}; lefts.forEach(l => count[l] = (count[l] || 0) + 1);
      const mode = +Object.keys(count).sort((x, y) => count[y] - count[x])[0];
      const pr = p.getBoundingClientRect();
      labels.forEach((c, i) => { const r = c.getBoundingClientRect(), d = Math.abs(lefts[i] - mode);
        const centred = Math.abs((r.left - pr.left) - (pr.right - r.right)) <= TOL && r.width < pr.width - TOL;
        const moving = getComputedStyle(c).transform !== 'none' || s.transform !== 'none';
        grade(d, {kind: 'stack-left', a: name(c), b: name(p)}, centred || moving || d % STEP === 0); });
    }
  }
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  return {tier: out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS',
    counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail,
    ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; })()
