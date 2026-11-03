import { Button } from '@/components/ui/button'

export function Hero() {
  return (
    <section className="mx-auto flex max-w-3xl flex-col items-center gap-6 px-6 py-24 text-center">
      <h1 className="text-5xl font-semibold tracking-tight">Every inbound shipment on one timetable</h1>
      <p className="text-lg text-muted-foreground">
        Harbor shows warehouse dispatchers what arrives next, what is late and which dock is free.
      </p>
      <div className="flex gap-3">
        <Button asChild size="lg">
          <a href="#pricing">See pricing</a>
        </Button>
        <Button asChild size="lg" variant="outline">
          <a href="#demo">Watch the demo</a>
        </Button>
      </div>
    </section>
  )
}
