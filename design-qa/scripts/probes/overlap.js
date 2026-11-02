// design-qa render probe: overlap. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clipBox = n => { let c = null;   // visible area: intersect EVERY clipping ancestor, per clipped axis
    for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) { const s = getComputedStyle(a);
      const x = s.overflowX !== 'visible', y = s.overflowY !== 'visible'; if (!x && !y) continue;
      const r = a.getBoundingClientRect(); c = c || {left: -Infinity, right: Infinity, top: -Infinity, bottom: Infinity};
      if (x) { c.left = Math.max(c.left, r.left); c.right = Math.min(c.right, r.right); }
      if (y) { c.top = Math.max(c.top, r.top); c.bottom = Math.min(c.bottom, r.bottom); } }
    return c; };
  const cut = (q, c) => { if (!c) return q; const l = Math.max(q.left, c.left), r = Math.min(q.right, c.right), t = Math.max(q.top, c.top), b = Math.min(q.bottom, c.bottom);
    return {left: l, right: r, top: t, bottom: b, width: r - l, height: b - t}; };
  const block = e => { for (let n = e; n; n = n.parentElement) if (!/^inline/.test(getComputedStyle(n).display) || n === document.body) return n; };
  const layered = (e, stop) => { for (let n = e; n && n !== stop; n = n.parentElement) { const s = getComputedStyle(n);
      if (/absolute|fixed|sticky/.test(s.position) || s.transform !== 'none') return true; } return false; };
  const MEDIA = 'img,svg,video,canvas', BOX = 'button,input,select,textarea,[role=button],' + MEDIA;
  const items = [];
  for (const e of document.querySelectorAll('body *')) {
    if (!vis(e)) continue;
    if (e.matches(BOX) && !e.parentElement.closest('button,svg,[role=button]')) {
      const r = cut(e.getBoundingClientRect(), clipBox(e)); if (r.width > TOL && r.height > TOL) items.push({e, r, media: e.matches(MEDIA)}); continue; }
    if (e.closest('button,svg,[role=button]')) continue;
    const s = getComputedStyle(e);
    if (/rgba\(0, 0, 0, 0\)|transparent/.test(s.webkitTextFillColor) && s.backgroundClip !== 'text') continue;
    for (const n of e.childNodes) { if (n.nodeType !== 3 || !n.textContent.trim()) continue;
      const c = clipBox(n), g = document.createRange(); g.selectNodeContents(n);
      const lh = parseFloat(s.lineHeight) || 0;   // 'normal' parses to NaN: keep the glyph box
      for (const q of g.getClientRects()) { const trim = lh && q.height > lh ? (q.height - lh) / 2 : 0;
        const r = cut({left: q.left, right: q.right, top: q.top + trim, bottom: q.bottom - trim}, c);
        if (r.right - r.left > TOL && r.bottom - r.top > TOL) items.push({e, r, text: n.textContent.trim()}); } }
  }
  const out = {fail: [], judge: []}, seen = new Set(), all = [...document.querySelectorAll('*')];
  for (let i = 0; i < items.length; i++) for (let j = i + 1; j < items.length; j++) {
    const a = items[i], b = items[j];
    if (a.e === b.e || a.e.contains(b.e) || b.e.contains(a.e)) continue;
    const w = Math.min(a.r.right, b.r.right) - Math.max(a.r.left, b.r.left);
    const h = Math.min(a.r.bottom, b.r.bottom) - Math.max(a.r.top, b.r.top);
    if (w <= TOL || h <= TOL) continue;
    if (/^inline/.test(getComputedStyle(a.e).display) && /^inline/.test(getComputedStyle(b.e).display) && block(a.e) === block(b.e)) continue;
    const key = [all.indexOf(a.e), all.indexOf(b.e)].sort((x, y) => x - y).join('-');
    if (seen.has(key)) continue; seen.add(key);
    let common = a.e.parentElement; while (common && !common.contains(b.e)) common = common.parentElement;
    const name = x => (x.textContent.trim() || x.getAttribute('aria-label') || x.tagName).slice(0, 25);
    const row = {a: name(a.e), b: name(b.e), w: Math.round(w), h: Math.round(h)};
    const gridStack = common && /grid/.test(getComputedStyle(common).display);
    const deliberate = layered(a.e, common) || layered(b.e, common) || gridStack || (a.media && b.media) || (a.text && a.text === b.text);
    (deliberate ? out.judge : out.fail).push(row);
  }
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  return {tier: out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS',
    counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail,
    ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; })()
