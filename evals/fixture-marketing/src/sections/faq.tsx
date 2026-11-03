import { Separator } from '@/components/ui/separator'
import { faqs } from '@/data/landing'

export function Faq() {
  return (
    <section id="faq" className="mx-auto max-w-3xl px-6 py-24">
      <h2 className="mb-12 text-center text-3xl font-semibold">Frequently asked questions</h2>
      <div className="flex flex-col">
        {faqs.map((faq, i) => (
          <div key={faq.question}>
            {i > 0 && <Separator />}
            <details className="py-4">
              <summary className="cursor-pointer font-medium">{faq.question}</summary>
              <p className="mt-2 text-muted-foreground">{faq.answer}</p>
            </details>
          </div>
        ))}
      </div>
    </section>
  )
}
