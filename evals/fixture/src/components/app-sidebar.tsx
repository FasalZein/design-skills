import { LayoutDashboard, Truck } from 'lucide-react'
import { cn } from '@/lib/utils'

export type ScreenId = 'overview' | 'shipments'

const items: { id: ScreenId; label: string; href: string; icon: typeof Truck }[] = [
  { id: 'overview', label: 'Overview', href: '#/overview', icon: LayoutDashboard },
  { id: 'shipments', label: 'Shipments', href: '#/shipments', icon: Truck },
]

export function AppSidebar({ active }: { active: ScreenId }) {
  return (
    <aside className="flex flex-col border-r bg-sidebar text-sidebar-foreground">
      <div className="flex h-14 items-center px-4 font-semibold">Harbor</div>
      <nav className="flex flex-col gap-1 px-2">
        {items.map((item) => (
          <a
            key={item.id}
            href={item.href}
            aria-current={active === item.id ? 'page' : undefined}
            className={cn(
              'flex h-9 items-center gap-2 rounded-md px-2 text-sm',
              active === item.id ? 'bg-sidebar-accent font-medium' : 'text-muted-foreground hover:bg-sidebar-accent',
            )}
          >
            <item.icon className="size-4" />
            {item.label}
          </a>
        ))}
      </nav>
      <div className="mt-auto px-4 py-3 text-xs text-muted-foreground">Duisburg warehouse</div>
    </aside>
  )
}
