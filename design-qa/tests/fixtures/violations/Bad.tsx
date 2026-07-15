export function Bad() {
  return (
    <div className="bg-gradient-to-r from-violet-500 to-fuchsia-500 h-screen">
      <div className="bg-gradient-to-br from-slate-900
        to-slate-800 blur-3xl" />
      <h1 className="bg-clip-text text-transparent bg-gradient-to-r tracking-tighter">Big</h1>
      <div onClick={() => go()} tabIndex={2} className="p-[13px] text-[15px] w-[423px] z-[999]">
        <a href="#">Get started</a>
      </div>
      <span style={{ color: "#ff0000" }} className="bg-[#fefefe] transition-all">x</span>
      <input onPaste={(e) => e.preventDefault()} />
      <button onClick={() => console.log("hi")}>ok</button>
    </div>
  );
}
