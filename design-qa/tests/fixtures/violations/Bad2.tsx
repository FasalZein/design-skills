export function Bad2() {
  return (
    <section className="bg-gradient-to-r from-purple-500 to-blue-500">
      <h2 className="bg-clip-text
        text-transparent">Multiline gradient text</h2>
      <p className="text-[1.125rem] w-[50px]">decimal rem</p>
      <div className="transition-[height]">tailwind layout anim</div>
      <button onClick={() => {}}>Empty handler</button>
      <a href="">empty destination</a>
    </section>
  );
}
export const Stripe = () => <div className="border-l-4 border-amber-500 bg-amber-50">striped card</div>;
