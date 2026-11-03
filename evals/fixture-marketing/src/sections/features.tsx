import { CalendarClock, Clock, Euro, Warehouse } from 'lucide-react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { features } from '@/data/landing'

const icons = [CalendarClock, Clock, Warehouse, Euro]

export function Features() {
  return (
    <section id="features" className="mx-auto max-w-6xl px-6 py-24">
      <h2 className="mb-12 text-center text-3xl font-semibold">Built for the dock office</h2>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {features.map((f, i) => {
          const Icon = icons[i]
          return (
            <Card key={f.title}>
              <CardHeader>
                <Icon className="size-6" aria-hidden />
                <CardTitle>{f.title}</CardTitle>
              </CardHeader>
              <CardContent className="text-sm text-muted-foreground">{f.body}</CardContent>
            </Card>
          )
        })}
      </div>
    </section>
  )
}
