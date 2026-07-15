export function Good() {
  return (
    <main className="h-dvh bg-background text-foreground p-4">
      <h1 className="text-5xl tracking-[-0.02em] text-balance">Real product</h1>
      <span className="text-xs uppercase tracking-wider text-muted-foreground">SKU 4821</span>
      <div className="animate-pulse rounded-md bg-muted h-4 w-32" aria-hidden="true" />
      <button
        onClick={submit}
        className="whitespace-nowrap rounded-md bg-primary text-primary-foreground hover:bg-primary/90 focus-visible:ring-2 focus-visible:ring-ring active:scale-[0.97] disabled:opacity-50 transition-colors max-w-[65ch]"
      >
        Save changes
      </button>
      <a href="/pricing">Pricing</a>
    </main>
  );
}
