import { useEffect, useState } from 'react'
import { AppSidebar, type ScreenId } from '@/components/app-sidebar'
import { OverviewScreen } from '@/screens/overview'
import { ShipmentsScreen } from '@/screens/shipments'

function screenFromHash(): ScreenId {
  return window.location.hash === '#/shipments' ? 'shipments' : 'overview'
}

export default function App() {
  const [screen, setScreen] = useState<ScreenId>(screenFromHash)

  useEffect(() => {
    const onHash = () => setScreen(screenFromHash())
    window.addEventListener('hashchange', onHash)
    return () => window.removeEventListener('hashchange', onHash)
  }, [])

  return (
    <div className="grid h-dvh grid-cols-[240px_minmax(0,1fr)] bg-background text-foreground">
      <AppSidebar active={screen} />
      <main className="min-w-0 overflow-y-auto">
        {screen === 'overview' ? <OverviewScreen /> : <ShipmentsScreen />}
      </main>
    </div>
  )
}
