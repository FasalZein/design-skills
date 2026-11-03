export type ShipmentStatus = 'scheduled' | 'at-gate' | 'unloading' | 'received' | 'delayed'

export interface Shipment {
  id: string
  carrier: string
  origin: string
  dock: number | null
  eta: string // ISO 8601, local warehouse time
  pallets: number
  valueEur: number
  status: ShipmentStatus
  note?: string
}

// Inbound shipments for the Harbor warehouse in Duisburg, Tuesday 3 November 2026.
export const shipments: Shipment[] = [
  { id: 'IN-20431', carrier: 'Rhein Cargo', origin: 'Rotterdam, NL', dock: 2, eta: '2026-11-03T06:30', pallets: 26, valueEur: 48210.5, status: 'received' },
  { id: 'IN-20432', carrier: 'Kessler Logistik', origin: 'Nürnberg, DE', dock: 4, eta: '2026-11-03T07:15', pallets: 18, valueEur: 21940, status: 'unloading' },
  { id: 'IN-20433', carrier: 'Baltic Line Spedition', origin: 'Gdańsk, PL', dock: null, eta: '2026-11-03T08:00', pallets: 33, valueEur: 67325.8, status: 'delayed', note: 'Border queue at Świecko, new ETA 10:40' },
  { id: 'IN-20434', carrier: 'Nordwest Freight', origin: 'Hamburg, DE', dock: 1, eta: '2026-11-03T08:45', pallets: 12, valueEur: 9875.25, status: 'at-gate' },
  { id: 'IN-20435', carrier: 'Transportes Ibéricos del Norte S.L.', origin: 'Bilbao, ES', dock: null, eta: '2026-11-03T10:30', pallets: 30, valueEur: 112480, status: 'scheduled' },
  { id: 'IN-20436', carrier: 'Rhein Cargo', origin: 'Antwerpen, BE', dock: null, eta: '2026-11-03T11:15', pallets: 8, valueEur: 4120.9, status: 'scheduled' },
  { id: 'IN-20437', carrier: 'Kessler Logistik', origin: 'Linz, AT', dock: null, eta: '2026-11-03T13:00', pallets: 21, valueEur: 30755, status: 'scheduled' },
  { id: 'IN-20438', carrier: 'Alpentrans', origin: 'Verona, IT', dock: null, eta: '2026-11-03T14:30', pallets: 16, valueEur: 25600.4, status: 'scheduled' },
]
