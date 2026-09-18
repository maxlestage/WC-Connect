import { questions } from "../content";
import { Reveal } from "./Reveal";

export function Faq() {
  return (
    <section className="section section--alt" id="faq">
      <div className="wrap narrow">
        <Reveal as="h2">Questions fréquentes</Reveal>

        {questions.map((item) => (
          <Reveal as="details" className="faq" key={item.question}>
            <summary>{item.question}</summary>
            <p>{item.answer}</p>
          </Reveal>
        ))}
      </div>
    </section>
  );
}
