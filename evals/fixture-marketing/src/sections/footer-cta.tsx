import { Button } from '@/components/ui/button'

export function FooterCta() {
  return (
    <footer className="bg-muted">
      <div className="mx-auto flex max-w-3xl flex-col items-center gap-6 px-6 py-24 text-center">
        <h2 className="text-3xl font-semibold">See tomorrow's arrivals on your own data</h2>
        <Button asChild size="lg">
          <a href="mailto:sales@harbor.example?subject=Demo">Book a demo</a>
        </Button>
        <p className="text-sm text-muted-foreground">Harbor GmbH · Duisburg, Germany</p>
      </div>
    </footer>
  )
}
