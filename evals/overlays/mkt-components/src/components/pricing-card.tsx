// The decided PricingCard of evals/fixture-marketing/DESIGN.md. new-run.sh adds it to the marketing
// page run, so that page builds on a component that already passed.
import { Check } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import type { Plan } from '@/data/landing'
import { cn } from '@/lib/utils'

export function PricingCard({ plan }: { plan: Plan }) {
  return (
    <article
      className={cn(
        'flex h-full flex-col gap-4 rounded-lg border bg-card p-6 text-card-foreground',
        plan.featured ? 'border-primary' : 'border-border',
      )}
    >
      <div className="flex flex-col gap-1">
        <h3 className="flex flex-wrap items-center gap-2 text-lg font-semibold">
          {plan.name}
          {plan.featured && <Badge className="rounded-sm">Most popular</Badge>}
        </h3>
        <p className="text-muted-foreground">{plan.summary}</p>
      </div>
      <div className="flex flex-col">
        <span className="font-mono text-[40px] leading-[44px] font-medium tabular-nums">
          {plan.price === null ? 'Custom' : `€${plan.price}`}
        </span>
        <span className="text-sm text-muted-foreground">{plan.unit}</span>
      </div>
      <ul className="flex flex-col gap-2">
        {plan.includes.map((item) => (
          <li key={item} className="flex items-start gap-2">
            <Check className="mt-1 size-4 shrink-0 text-primary" aria-hidden />
            {item}
          </li>
        ))}
      </ul>
      <Button asChild className="mt-auto w-full" variant={plan.featured ? 'default' : 'outline'}>
        <a href={plan.cta.href}>{plan.cta.label}</a>
      </Button>
    </article>
  )
}
