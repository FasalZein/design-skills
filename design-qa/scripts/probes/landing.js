// design-qa machine probe: landing continuity (marketing, 1440px). Output {rules, transitions}.
(() => { const vw = innerWidth;
  const sectionLevel = e => { const p = e.parentElement;
    return e.matches('section,footer,header') || (p && (p === document.body || p.tagName === 'MAIN')); };
  const seam = (e, s, r) => {
    const top = parseFloat(s.borderTopWidth) > 0 && s.borderTopStyle !== 'none';
    const bot = parseFloat(s.borderBottomWidth) > 0 && s.borderBottomStyle !== 'none';
    const hr = e.tagName === 'HR' || (r.height <= 2 && !/rgba\(0, 0, 0, 0\)|transparent/.test(s.backgroundColor));
    const shadow = /(^|,)\s*(inset\s+)?0(px)?\s+-?[12]px\s+0/.test(s.boxShadow || '');
    let pseudo = false;
    for (const which of ['::before','::after']) { const ps = getComputedStyle(e, which);
      if (ps.content !== 'none' && parseFloat(ps.height) <= 2 && parseFloat(ps.width) > vw*0.5
          && !/rgba\(0, 0, 0, 0\)|transparent/.test(ps.backgroundColor)) pseudo = true; }
    return top || bot || hr || shadow || pseudo; };
  const names = [...document.querySelectorAll('*')].filter(e => {
    const r = e.getBoundingClientRect(); if (r.width < vw*0.6) return false;
    const s = getComputedStyle(e);
    if (s.position === 'sticky' || s.position === 'fixed') return false;
    if (e.closest('table,thead,tbody,ul,ol,.ss-stage')) return false;   // .ss-stage: stageshow stage content, film.mjs owns it
    if (!sectionLevel(e)) return false;   // component-internal seams are anatomy; screenshot is the backstop
    return seam(e, s, r);
  }).map(e => e.tagName + '.' + String(e.className).split(' ')[0]);
  const rules = {}; names.forEach(n => rules[n] = (rules[n]||0) + 1);
  // background TRANSITIONS in document order (not distinct colors)
  const bands = [...document.querySelectorAll('body > *, main > *, main section')]
    .filter(e => { const r = e.getBoundingClientRect(); return r.width >= vw*0.6 && r.height > 120 && !e.parentElement?.closest('.ss-stage'); })
    .sort((a,b) => a.getBoundingClientRect().top - b.getBoundingClientRect().top)
    .map(e => getComputedStyle(e).backgroundColor);
  let transitions = 0;
  for (let i = 1; i < bands.length; i++) if (bands[i] !== bands[i-1]) transitions++;
  return { rules, transitions };
})()
