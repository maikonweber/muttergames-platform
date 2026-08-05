import Image from "next/image";
import Link from "next/link";

const steps = [
  ["01", "Crie sua identidade", "Um Mutter ID conecta seu perfil, progresso e segurança entre jogos."],
  ["02", "Jogue primeiro", "A experiência central funciona sem exigir conhecimento de blockchain."],
  ["03", "Conecte quando quiser", "Vincule uma wallet para consultar ativos e provar propriedade."],
];

export default function Home() {
  return <>
    <section className="hero"><div className="container hero-grid"><div><div className="eyebrow">Ecossistema MutterGames</div><h1>Mundos diferentes.<br/><span>Uma identidade.</span></h1><p className="lead">Descubra jogos conectados, leve suas conquistas e use ativos compatíveis entre experiências — com segurança e controle.</p><div className="hero-actions"><Link className="button button-primary" href="/games">Explorar jogos</Link><Link className="button button-outline" href="/account/wallets">Conectar wallet</Link></div></div><div className="cube-stage"><div className="logo-card"><Image src="/logo.png" alt="Símbolo modular MutterGames" width={520} height={520} priority sizes="(max-width: 850px) 330px, 420px" /></div></div></div></section>
    <section className="section section-muted"><div className="container"><div className="section-head"><div><div className="eyebrow">Comece sem atrito</div><h2>Jogar vem antes da tecnologia.</h2></div><p className="section-copy">Blockchain aparece somente quando melhora propriedade, transparência e interoperabilidade.</p></div><div className="card-grid">{steps.map(([index,title,copy])=><article className="card" key={index}><span className="card-index">{index}</span><strong>{title}</strong><p>{copy}</p></article>)}</div></div></section>
    <section className="section"><div className="container"><div className="section-head"><div><div className="eyebrow">Primeiros mundos</div><h2>Jogos em construção</h2></div><Link className="button button-ghost" href="/games">Ver todos →</Link></div><div className="card-grid"><article className="card game-card"><span className="badge">Estratégia</span><strong>Fallen Tactics</strong><p>Decisões táticas, progressão e colecionáveis compatíveis.</p></article><article className="card game-card red"><span className="badge">Ação</span><strong>Beat Up</strong><p>Combate baseado em habilidade, temporadas e identidade visual.</p></article><article className="card game-card"><span className="badge">Launchpad</span><strong>Próximo jogo</strong><p>Uma plataforma aberta para novas experiências conectadas.</p></article></div></div></section>
  </>;
}
