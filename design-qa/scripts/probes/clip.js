// design-qa render probe: clip. Output {tier, counts, fail[, judge]}; see reference/live-verification.md.
(() => { const TOL = 1;
  const MONEY = /[$€£¥₹]\s?\d|\d[\d,.]*\s?(%|[kKMB]\b|USD|EUR|GBP|AED|SAR)/;
  const HEADING = 'h1,h2,h3,h4,h5,h6';
  const TRIGGER = 'a[href],button,[role=button],[role=link],[aria-describedby],[data-tooltip]';   // a detail or tooltip path
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const staged = e => !!e.parentElement?.closest('.ss-stage');   // stageshow stage content: film.mjs owns it
  const scrolls = s => /auto|scroll/.test(s.overflowX + s.overflowY);
  const clipper = e => { for (let a = e; a && a !== document.body; a = a.parentElement) { const s = getComputedStyle(a);
      if (scrolls(s)) return null;   // a scroll region keeps its content reachable
      if (/hidden|clip/.test(s.overflowX + s.overflowY)) return a; }   // the nearest box that cuts overflow
    return null; };
  // Candidate text: the direct text nodes of a visible, sized, non-field element that is not in or at a scroll region.
  const measured = e => { const box = e.getBoundingClientRect();
    return !staged(e) && vis(e) && box.width > TOL && box.height > TOL && !e.matches('input,textarea,select,option,script,style'); };
  const inScroll = e => { const p = e.parentElement; return scrolls(getComputedStyle(e)) || (!!p && scrolls(getComputedStyle(p))); };
  const ownText = e => [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
  const measuredText = e => { if (!measured(e)) return []; const texts = ownText(e); return texts.length && inScroll(e) ? [] : texts; };
  // Text line geometry against the clip box.
  const lineRects = n => { const g = document.createRange(); g.selectNodeContents(n); return [...g.getClientRects()].filter(q => q.width > TOL); };
  const innerBox = c => { const k = c.getBoundingClientRect(), left = k.left + c.clientLeft, top = k.top + c.clientTop;
    return {left, top, right: left + c.clientWidth, bottom: top + c.clientHeight}; };
  const lineBox = (q, s) => { const lh = parseFloat(s.lineHeight) || 0, trim = lh && q.height > lh ? (q.height - lh) / 2 : 0;
    return {left: q.left, right: q.right, top: q.top + trim, bottom: q.bottom - trim}; };   // the line box, so descenders past it are not a cut
  const meets = (a, b) => Math.min(a.right, b.right) - Math.max(a.left, b.left) > TOL && Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top) > TOL;
  const sticksOut = (a, b) => a.left < b.left - TOL || a.right > b.right + TOL || a.top < b.top - TOL || a.bottom > b.bottom + TOL;
  // partlyShown: the clip box shows a text line only in part.
  const partlyShown = (rects, c, s) => { const inner = innerBox(c);
    return rects.some(q => { const line = lineBox(q, s); return meets(line, inner) && sticksOut(line, inner); }); };
  const spills = (e, s, rects) => { const box = e.getBoundingClientRect();
    return s.overflowX === 'visible' && s.overflowY === 'visible' && rects.some(q => q.left < box.left - TOL || q.right > box.right + TOL); };
  const cutX = c => c.scrollWidth > c.clientWidth + TOL;
  const isCut = (c, e, s, rects) => partlyShown(rects, c, s) || (c === e && (cutX(c) || c.scrollHeight - c.clientHeight >= parseFloat(s.fontSize)));
  const truncated = c => { const cs = getComputedStyle(c);
    return (cs.textOverflow === 'ellipsis' && cutX(c)) || (cs.webkitLineClamp !== 'none' && c.scrollHeight > c.clientHeight + TOL); };
  // Where the reader can still get the full value of a truncated text.
  const keyValue = (e, c, t) => c.matches(HEADING) || e.matches(HEADING) || MONEY.test(t);
  const fullInLabel = (e, t) => { const holder = e.closest('[title],[aria-label]');
    return !!holder && (holder.title || holder.getAttribute('aria-label') || '').includes(t); };
  const hasDetail = (e, c) => !!(e.closest(TRIGGER) || c.querySelector(TRIGGER));
  const verdict = (e, c, t) => { if (keyValue(e, c, t)) return ['fail', 'title, money or metric truncated'];
    if (fullInLabel(e, t)) return ['judge', 'truncated: confirm the design fixes this width'];
    if (hasDetail(e, c)) return ['judge', 'truncated: verify the detail or tooltip path shows the full value'];
    return ['fail', 'truncated, full value unreachable']; };
  const row = x => ({t: x.textContent.trim().replace(/\s+/g, ' ').slice(0, 40), scroll: x.scrollWidth, client: x.clientWidth});
  const out = {fail: [], judge: []}, done = new Set();
  const judgeCut = (e, c) => { if (done.has(c)) return; done.add(c);   // one row per clip box
    if (!truncated(c)) return out.fail.push({...row(c), why: 'cut without ellipsis'});
    const [tier, why] = verdict(e, c, c.textContent.trim().replace(/\s+/g, ' '));
    out[tier].push({...row(c), why}); };
  const check = e => { const texts = measuredText(e); if (!texts.length) return;
    const s = getComputedStyle(e), c = clipper(e), rects = texts.flatMap(lineRects);
    if (spills(e, s, rects)) out.fail.push({...row(e), why: 'spills out of its box'});
    else if (c && isCut(c, e, s, rects)) judgeCut(e, c); };
  // Counts per tier and every FAIL row; JUDGE rows only when the caller sets DQ_JUDGE=1 first.
  const report = () => { const tier = out.fail.length ? 'FAIL' : out.judge.length ? 'JUDGE' : 'PASS';
    return {tier, counts: {fail: out.fail.length, judge: out.judge.length}, fail: out.fail, ...(globalThis.DQ_JUDGE ? {judge: out.judge} : {})}; };
  for (const e of document.querySelectorAll('body *')) check(e);
  return report(); })()
