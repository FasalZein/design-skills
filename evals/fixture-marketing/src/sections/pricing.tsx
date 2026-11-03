import { Check } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { plans } from '@/data/landing'

export function Pricing() {
  return (
    <section id="pricing" className="mx-auto max-w-6xl px-6 py-24">
      <h2 className="mb-12 text-center text-3xl font-semibold">Pricing</h2>
      <div className="grid gap-6 md:grid-cols-3">
        {plans.map((plan) => (
          <Card key={plan.id}>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                {plan.name}
                {plan.featured && <Badge>Most popular</Badge>}
              </CardTitle>
              <CardDescription>{plan.summary}</CardDescription>
            </CardHeader>
            <CardContent className="flex flex-col gap-4">
              <div>
                <span className="text-4xl font-semibold">{plan.price === null ? 'Custom' : `€${plan.price}`}</span>
                <span className="ml-2 text-sm text-muted-foreground">{plan.unit}</span>
              </div>
              <ul className="flex flex-col gap-2 text-sm">
                {plan.includes.map((item) => (
                  <li key={item} className="flex items-center gap-2">
                    <Check className="size-4" aria-hidden />
                    {item}
                  </li>
                ))}
              </ul>
            </CardContent>
            <CardFooter>
              <Button asChild className="w-full" variant={plan.featured ? 'default' : 'outline'}>
                <a href={plan.cta.href}>{plan.cta.label}</a>
              </Button>
            </CardFooter>
          </Card>
        ))}
      </div>
    </section>
  )
}
