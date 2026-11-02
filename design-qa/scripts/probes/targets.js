// design-qa machine probe: target size at 375px. Output {fail, judge44}; fail non-empty = probe failure.
(() => { const els=[...document.querySelectorAll('button,a,[role=button],[role=link],input,select,textarea,[onclick]')]
    .map(e=>{ // the real hit target: wrapping label, or the label[for] pointing at this control
      let t = e.closest('label');
      if (!t && e.id) t = document.querySelector(`label[for="${CSS.escape(e.id)}"]`);
      const own = e.getBoundingClientRect(), lab = t ? t.getBoundingClientRect() : own;
      return {e, r: (lab.width*lab.height > own.width*own.height) ? lab : own}; })
    .filter(x=>x.r.width>0&&x.r.height>0);
  const name = x => (x.e.textContent?.trim() || x.e.getAttribute('aria-label') || x.e.tagName).slice(0,20);
  return { fail: els.filter(x=>x.r.width<24||x.r.height<24).map(name),
           judge44: els.filter(x=>(x.r.width<44||x.r.height<44)&&x.r.width>=24&&x.r.height>=24).map(name) }; })()
