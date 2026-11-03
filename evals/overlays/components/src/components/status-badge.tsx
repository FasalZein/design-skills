// The decided StatusBadge of evals/fixture/DESIGN.md. new-run.sh adds it to the screen run,
// so that screen builds on a component that already passed.
import type { ShipmentStatus } from '@/data/shipments'
import { cn } from '@/lib/utils'

const looks: Record<ShipmentStatus, { label: string; className: string }> = {
  scheduled: { label: 'Scheduled', className: 'bg-status-scheduled-tint text-status-scheduled' },
  'at-gate': { label: 'At gate', className: 'bg-status-at-gate-tint text-status-at-gate' },
  unloading: { label: 'Unloading', className: 'bg-status-unloading-tint text-status-unloading' },
  received: { label: 'Received', className: 'bg-status-received-tint text-status-received' },
  delayed: { label: 'Delayed', className: 'bg-status-delayed-tint text-status-delayed' },
}

export function StatusBadge({ status }: { status: ShipmentStatus }) {
  const look = looks[status]
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 whitespace-nowrap rounded-sm px-1.5 py-0.5 text-xs font-medium',
        look.className,
      )}
    >
      <span aria-hidden className="size-1.5 rounded-full bg-current" />
      {look.label}
    </span>
  )
}
