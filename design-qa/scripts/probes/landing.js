// design-qa machine probe: landing continuity (marketing, 1440px). Output {rules, transitions}.
(() => { const vw = innerWidth;
  const sectionLevel = e => { const p = e.parentElement;
    return e.matches('section,footer,header') || (p && (p === document.body || p.tagName === 'MAIN')); };
  const clear = c => /rgba\(0, 0, 0, 0\)|transparent/.test(c);
  const border = (s, side) => parseFloat(s['border' + side + 'Width']) > 0 && s['border' + side + 'Style'] !== 'none';
  const hrLike = (e, s, r) => e.tagName === 'HR' || (r.height <= 2 && !clear(s.backgroundColor));
  // Chrome computes each shadow color first ("rgb(204, 204, 204) 0px 1px 0px 0px inset"); drop colors and words, keep lengths
  const lineShadow = sh => { const [x, y, blur = 0] = sh.replace(/[a-z]+\([^)]*\)|#[0-9a-f]+|[a-z]+/gi, ' ').trim().split(/\s+/).map(parseFloat);
    return x === 0 && (Math.abs(y) === 1 || Math.abs(y) === 2) && blur === 0; };
  const shadowLine = s => s.boxShadow.split(/,(?![^(]*\))/).some(lineShadow);
  const pseudoLine = e => ['::before','::after'].some(which => { const ps = getComputedStyle(e, which);
    return ps.content !== 'none' && parseFloat(ps.height) <= 2 && parseFloat(ps.width) > vw*0.5 && !clear(ps.backgroundColor); });
  // a seam: a top or bottom border, an hr-like thin band, a 1-2px line shadow, or a thin wide pseudo-element line
  const seam = (e, s, r) => border(s, 'Top') || border(s, 'Bottom') || hrLike(e, s, r) || shadowLine(s) || pseudoLine(e);
  const names = [...document.querySelectorAll('*')].filter(e => {
    const r = e.getBoundingClientRect(); if (r.width < vw*0.6) return false;
    const s = getComputedStyle(e);
    return !/^(sticky|fixed)$/.test(s.position)
      && !e.closest('table,thead,tbody,ul,ol,.ss-stage')   // .ss-stage: stageshow stage content, film.mjs owns it
      && sectionLevel(e)   // component-internal seams are anatomy; screenshot is the backstop
      && seam(e, s, r);
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
