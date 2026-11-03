import { Faq } from '@/sections/faq'
import { Features } from '@/sections/features'
import { FooterCta } from '@/sections/footer-cta'
import { Hero } from '@/sections/hero'
import { Pricing } from '@/sections/pricing'
import { ProductDemo } from '@/sections/product-demo'

export default function App() {
  return (
    <div className="min-h-dvh bg-background text-foreground">
      <header className="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
        <a href="#top" className="font-semibold">Harbor</a>
        <nav className="flex gap-6 text-sm">
          <a href="#features">Features</a>
          <a href="#pricing">Pricing</a>
          <a href="#faq">FAQ</a>
        </nav>
      </header>
      <main id="top">
        <Hero />
        <ProductDemo />
        <Features />
        <Pricing />
        <Faq />
      </main>
      <FooterCta />
    </div>
  )
}
