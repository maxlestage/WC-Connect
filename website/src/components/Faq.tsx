import { useT } from "../i18n";
import { Reveal } from "./Reveal";

export function Faq() {
  const t = useT();

  return (
    <section className="section section--alt" id="faq">
      <div className="wrap narrow">
        <Reveal as="h2">{t.faq.title}</Reveal>

        {t.faq.questions.map((item) => (
          <Reveal as="details" className="faq" key={item.question}>
            <summary>{item.question}</summary>
            <p>{item.answer}</p>
          </Reveal>
        ))}
      </div>
    </section>
  );
}
