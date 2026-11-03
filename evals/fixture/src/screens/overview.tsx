import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { shipments } from '@/data/shipments'

export function OverviewScreen() {
  const received = shipments.filter((s) => s.status === 'received').length
  const delayed = shipments.filter((s) => s.status === 'delayed').length
  const pallets = shipments.reduce((sum, s) => sum + s.pallets, 0)
  const stats = [
    { label: 'Inbound today', value: shipments.length },
    { label: 'Received', value: received },
    { label: 'Delayed', value: delayed },
    { label: 'Pallets expected', value: pallets },
  ]

  return (
    <div className="flex flex-col gap-6 p-6">
      <h1 className="text-2xl font-semibold">Overview</h1>
      <div className="grid grid-cols-4 gap-4">
        {stats.map((stat) => (
          <Card key={stat.label}>
            <CardHeader>
              <CardTitle className="text-sm text-muted-foreground">{stat.label}</CardTitle>
            </CardHeader>
            <CardContent className="text-3xl font-semibold">{stat.value}</CardContent>
          </Card>
        ))}
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Next arrivals</CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-2 text-sm">
          {shipments
            .filter((s) => s.status === 'scheduled')
            .map((s) => (
              <div key={s.id} className="flex justify-between">
                <span>
                  {s.id} · {s.carrier}
                </span>
                <span className="text-muted-foreground">{s.eta.slice(11)}</span>
              </div>
            ))}
        </CardContent>
      </Card>
    </div>
  )
}
