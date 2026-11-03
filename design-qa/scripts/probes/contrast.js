// design-qa machine probe: rendered contrast. Output: array of failing elements; [] = pass.
(() => {
  const cv = document.createElement('canvas'); cv.width = cv.height = 1;
  const ctx = cv.getContext('2d', { willReadFrequently: true });
  const parse = v => { if (!v) return null;
    ctx.fillStyle = '#123456'; ctx.fillStyle = v;
    if (ctx.fillStyle === '#123456' && v.replace(/\s/g,'').toLowerCase() !== '#123456') return null;
    ctx.clearRect(0,0,1,1); ctx.fillRect(0,0,1,1);
    const d = ctx.getImageData(0,0,1,1).data; return [d[0], d[1], d[2], d[3]/255]; };
  const lum = ([r,g,b]) => { const f = v => { v/=255; return v<=.03928 ? v/12.92 : ((v+.055)/1.055)**2.4 };
    return .2126*f(r)+.7152*f(g)+.0722*f(b); };
  const over = (top, bot) => { const a = top[3] + bot[3]*(1-top[3]); if (!a) return [0,0,0,0];
    return [0,1,2].map(i => (top[i]*top[3] + bot[i]*bot[3]*(1-top[3]))/a).concat([a]); };
  const bgOf = el => { let acc = [0,0,0,0];
    for (let n = el; n; n = n.parentElement) {
      const c = parse(getComputedStyle(n).backgroundColor); if (!c || c[3] === 0) continue;
      acc = over(acc, c); if (acc[3] >= 0.999) return acc;
    } return over(acc, [255,255,255,1]); };
  const ratio = (a, b) => { const L1 = lum(a), L2 = lum(b); return (Math.max(L1,L2)+.05)/(Math.min(L1,L2)+.05); };
  const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const checked = e => vis(e) && !!e.offsetHeight && !e.closest('.ss-stage');   // stageshow stage content: film.mjs owns it
  // text: any element with a direct text node; placeholders for inputs
  const isField = e => e.matches('input,textarea');
  const ownText = e => [...e.childNodes].some(n => n.nodeType === 3 && n.textContent.trim());
  const textOf = e => { return isField(e) ? e.placeholder : (ownText(e) ? e.textContent : ''); };
  const textColor = (e, st) => isField(e) ? (getComputedStyle(e,'::placeholder').color || st.color) : st.color;
  const floorOf = st => { const px = parseFloat(st.fontSize), bold = parseInt(st.fontWeight) >= 700;   // large text: 24px, or 18.66px bold
    return (px >= 24 || (px >= 18.66 && bold)) ? 3 : 4.5; };
  const textFail = (e, st) => { const text = textOf(e); if (!text?.trim()) return null;
    const fg = parse(textColor(e, st)); if (!fg) return {t:text.slice(0,30), r:'MANUAL — unparseable color'};
    const bg = bgOf(e), r = ratio(over(fg, bg), bg), floor = floorOf(st);   // element's own background sits behind its text
    return r < floor ? {t:text.slice(0,30), r:+r.toFixed(2), need:floor} : null; };
  // non-text: control borders need 3:1 against the surrounding surface
  const borderedControl = (e, st) => { return e.matches('input,select,textarea,button,[role=button]') && parseFloat(st.borderTopWidth) > 0
    && st.borderTopStyle !== 'none' && !/rgba\(0, 0, 0, 0\)|transparent/.test(st.borderTopColor); };
  const controlName = e => e.name || e.type || e.tagName;
  const borderFail = (e, st) => { if (!borderedControl(e, st)) return null;
    const bc = parse(st.borderTopColor), bg = bgOf(e.parentElement || e); if (!bc) return null;
    const r = ratio(over(bc, bg), bg);
    return r < 3 ? {t:'border:' + controlName(e), r:+r.toFixed(2), need:3} : null; };
  const fails = [];
  for (const e of document.querySelectorAll('*')) { if (!checked(e)) continue;
    const st = getComputedStyle(e);
    for (const row of [textFail(e, st), borderFail(e, st)]) if (row) fails.push(row); }
  return fails.slice(0,40);
})()
