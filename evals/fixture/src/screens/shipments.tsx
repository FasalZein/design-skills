import { Badge } from '@/components/ui/badge'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { shipments } from '@/data/shipments'

export function ShipmentsScreen() {
  return (
    <div className="flex flex-col gap-6 p-6">
      <h1 className="text-2xl font-semibold">Shipments</h1>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>ID</TableHead>
            <TableHead>Carrier</TableHead>
            <TableHead>Origin</TableHead>
            <TableHead>ETA</TableHead>
            <TableHead>Dock</TableHead>
            <TableHead>Pallets</TableHead>
            <TableHead>Status</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {shipments.map((s) => (
            <TableRow key={s.id}>
              <TableCell>{s.id}</TableCell>
              <TableCell>{s.carrier}</TableCell>
              <TableCell>{s.origin}</TableCell>
              <TableCell>{s.eta.slice(11)}</TableCell>
              <TableCell>{s.dock ?? '-'}</TableCell>
              <TableCell>{s.pallets}</TableCell>
              <TableCell>
                <Badge variant="secondary">{s.status}</Badge>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}
