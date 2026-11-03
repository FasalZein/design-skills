// Page content for the Harbor landing page fixture. Prices are per warehouse site and month, in EUR.
export type Feature = { title: string; body: string }
export type Plan = {
  id: 'site' | 'network' | 'enterprise'
  name: string
  price: number | null
  unit: string
  summary: string
  includes: string[]
  cta: { label: string; href: string }
  featured: boolean
}
export type Faq = { question: string; answer: string }

export const features: Feature[] = [
  {
    title: 'One timetable for every dock',
    body: 'Inbound shipments sorted by arrival time, with carrier, pallets, value and status in one row.',
  },
  {
    title: 'Delays before the truck is late',
    body: 'Carrier updates mark a shipment as delayed and show the note your dispatcher needs to replan the dock.',
  },
  {
    title: 'Dock occupancy at a glance',
    body: 'See which of your docks are unloading, which are free, and which shipment comes next.',
  },
  {
    title: 'Values your accounts team trusts',
    body: 'Pallet counts and shipment values come from the purchase order, in euros with two decimals.',
  },
]

export const plans: Plan[] = [
  {
    id: 'site',
    name: 'Site',
    price: 290,
    unit: 'per warehouse, per month',
    summary: 'One warehouse with up to 8 docks.',
    includes: ['Arrival timetable', 'Delay notes from carriers', 'Dock occupancy', '5 dispatcher seats'],
    cta: { label: 'Start a 30-day trial', href: 'mailto:sales@harbor.example?subject=Site%20trial' },
    featured: false,
  },
  {
    id: 'network',
    name: 'Network',
    price: 790,
    unit: 'per month, up to 5 warehouses',
    summary: 'Several sites on one shared timetable.',
    includes: ['Everything in Site', 'Shared timetable across sites', 'Carrier API connections', '25 dispatcher seats'],
    cta: { label: 'Start a 30-day trial', href: 'mailto:sales@harbor.example?subject=Network%20trial' },
    featured: true,
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    price: null,
    unit: 'priced per contract',
    summary: 'More than 5 warehouses, SSO and an on-site rollout.',
    includes: ['Everything in Network', 'SAML single sign-on', 'On-site rollout support', 'Unlimited seats'],
    cta: { label: 'Talk to sales', href: 'mailto:sales@harbor.example?subject=Enterprise' },
    featured: false,
  },
]

export const faqs: Faq[] = [
  {
    question: 'Which carriers send updates to Harbor?',
    answer: 'Any carrier that sends EDI 214 status messages or uses our carrier API. Others are updated by your dispatchers in the timetable.',
  },
  {
    question: 'Does Harbor replace our warehouse management system?',
    answer: 'No. Harbor reads purchase orders from your WMS and covers the dock: arrivals, delays and unloading.',
  },
  {
    question: 'Where is our data stored?',
    answer: 'In data centers in Frankfurt, Germany. Shipment data is deleted 24 months after receipt.',
  },
  {
    question: 'Can we try it before we sign?',
    answer: 'Yes. Site and Network start with a 30-day trial on your own data, with no card required.',
  },
]
