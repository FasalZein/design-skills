// design-qa render probe: overlap. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const clipAxis = (c, r, on, lo, hi) => { if (on) { c[lo] = Math.max(c[lo], r[lo]); c[hi] = Math.min(c[hi], r[hi]); } };
  const clipTo = (c, a) => { const s = getComputedStyle(a), x = s.overflowX !== 'visible', y = s.overflowY !== 'visible';
    if (!x && !y) return c;   // this ancestor clips neither axis
    c = c || {left: -Infinity, right: Infinity, top: -Infinity, bottom: Infinity};
    const r = a.getBoundingClientRect(); clipAxis(c, r, x, 'left', 'right'); clipAxis(c, r, y, 'top', 'bottom'); return c; };
  const clipBox = n => { let c = null;   // visible area: intersect EVERY clipping ancestor, per clipped axis
    for (let a = n.parentElement; a && a !== document.body; a = a.parentElement) c = clipTo(c, a);
    return c; };
  const cut = (q, c) => { if (!c) return q; const l = Math.max(q.left, c.left), r = Math.min(q.right, c.right), t = Math.max(q.top, c.top), b = Math.min(q.bottom, c.bottom);
    return {left: l, right: r, top: t, bottom: b, width: r - l, height: b - t}; };
  const block = e => { for (let n = e; n; n = n.parentElement) if (!/^inline/.test(getComputedStyle(n).display) || n === document.body) return n; };
  const layered = (e, stop) => { for (let n = e; n && n !== stop; n = n.parentElement) { const s = getComputedStyle(n);
      if (/absolute|fixed|sticky/.test(s.position) || s.transform !== 'none') return true; } return false; };
  const MEDIA = 'img,svg,video,canvas', BOX = 'button,input,select,textarea,[role=button],' + MEDIA, HOST = 'button,svg,[role=button]';
  // Items: visible boxes and text lines, each cut to the area its clipping ancestors show.
  const skipped = e => !!e.parentElement?.closest('.ss-stage') || !vis(e);   // stageshow stage content: film.mjs owns it
  const standalone = e => e.matches(BOX) && !e.parentElement.closest(HOST);   // a control or media box not inside a button or svg
  const boxItem = (e, extra) => { const r = cut(e.getBoundingClientRect(), clipBox(e)); return r.width > TOL && r.height > TOL ? [{e, r, ...extra}] : []; };
  const hiddenText = s => /rgba\(0, 0, 0, 0\)|transparent/.test(s.webkitTextFillColor) && s.backgroundClip !== 'text';
  const lineBox = (q, lh) => { const trim = lh && q.height > lh ? (q.height - lh) / 2 : 0;
    return {left: q.left, right: q.right, top: q.top + trim, bottom: q.bottom - trim}; };
  const lineItems = (e, n, lh) => { const c = clipBox(n), g = document.createRange(); g.selectNodeContents(n);
    return [...g.getClientRects()].map(q => cut(lineBox(q, lh), c)).filter(r => r.right - r.left > TOL && r.bottom - r.top > TOL)
      .map(r => ({e, r, text: n.textContent.trim()})); };
  const textItems = e => { const s = getComputedStyle(e); if (hiddenText(s)) return [];
    const lh = parseFloat(s.lineHeight) || 0;   // 'normal' parses to NaN: keep the glyph box
    return [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim()).flatMap(n => lineItems(e, n, lh)); };
  const itemsOf = e => { if (skipped(e)) return [];
    if (e.matches('.ss-stage')) return boxItem(e, {});   // the stage box still meets its host siblings
    if (standalone(e)) return boxItem(e, {media: e.matches(MEDIA)});
    return e.closest(HOST) ? [] : textItems(e); };
  // Pairs: two items that meet, unless they are nested or text runs in one line box.
  const nested = (a, b) => a.e === b.e || a.e.contains(b.e) || b.e.contains(a.e);
  const meet = (a, b) => { const w = Math.min(a.r.right, b.r.right) - Math.max(a.r.left, b.r.left), h = Math.min(a.r.bottom, b.r.bottom) - Math.max(a.r.top, b.r.top);
    return w > TOL && h > TOL ? {w, h} : null; };
  const inline = x => getComputedStyle(x.e).display === 'inline';
  const sameLine = (a, b) => !!(a.text && b.text) && inline(a) && inline(b) && block(a.e) === block(b.e);   // text runs in one line box; inline-block, control and media boxes still collide
  const commonAncestor = (a, b) => { let c = a.parentElement; while (c && !c.contains(b)) c = c.parentElement; return c; };
  const gridStack = common => !!common && /grid/.test(getComputedStyle(common).display);
  const twin = (a, b) => !!(a.media && b.media) || !!(a.text && a.text === b.text);   // two media boxes, or one repeated text
  // A layered, grid-stacked or twin pair may overlap by design: JUDGE. Any other pair: FAIL.
  const tierOf = (a, b) => { const common = commonAncestor(a.e, b.e); return layered(a.e, common) || layered(b.e, common) || gridStack(common) || twin(a, b) ? 'judge' : 'fail'; };
  const name = x => (x.textContent.trim() || x.getAttribute('aria-label') || x.tagName).slice(0, 25);
  const items = [...document.querySelectorAll('body *')].flatMap(itemsOf);
  const out = {fail: [], judge: []}, seen = new Set(), all = [...document.querySelectorAll('*')];
  const checkPair = (a, b) => { if (nested(a, b)) return;
    const m = meet(a, b); if (!m || sameLine(a, b)) return;
    const key = [all.indexOf(a.e), all.indexOf(b.e)].sort((x, y) => x - y).join('-');
    if (seen.has(key)) return; seen.add(key);
    out[tierOf(a, b)].push({a: name(a.e), b: name(b.e), w: Math.round(m.w), h: Math.round(m.h)}); };
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  const report = () => { const tier = out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS';
    return {tier, counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail, ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; };
  for (let i = 0; i < items.length; i++) for (let j = i + 1; j < items.length; j++) checkPair(items[i], items[j]);
  return report(); })()
