// design-qa machine probe: heading order. Output {startsAtH1, oneH1, noSkip}; every value true = pass.
(() => { const vis = e => e.checkVisibility ? e.checkVisibility({checkOpacity:true, visibilityProperty:true}) : e.offsetHeight > 0;
  const hs=[...document.querySelectorAll('h1,h2,h3,h4,h5,h6')].filter(vis).map(h=>+h.tagName[1]);
  return { startsAtH1: hs[0]===1, oneH1: hs.filter(l=>l===1).length===1,
           noSkip: hs.every((l,i)=>i===0||l<=hs[i-1]+1) }; })()
