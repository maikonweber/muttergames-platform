import type { Metadata } from 'next';
import { centralApi, type BlockchainNetwork } from '@/lib/api';

export const metadata: Metadata = { title: 'Blockchain' };

const fallback: BlockchainNetwork[] = [
  { id: 'preview', key: 'solana-devnet', name: 'Solana Devnet', cluster: 'devnet', enabled: true },
];

export default async function BlockchainPage() {
  const networks = await centralApi.networks().catch(() => fallback);

  return (
    <>
      <section className="page-hero chain-hero">
        <div className="container">
          <div className="eyebrow">Infraestrutura blockchain</div>
          <h1>Propriedade verificavel.<br />Gameplay sem bloqueio.</h1>
          <p>A MutterGames utiliza Solana como camada de propriedade e liquidacao. Partidas, progressao e anti-cheat permanecem em servidores autoritativos.</p>
        </div>
      </section>
      <section className="section section-muted">
        <div className="container">
          <div className="chain-flow">
            <article><span>01</span><strong>Servidor do jogo</strong><p>Valida partidas e eventos.</p></article>
            <i aria-hidden="true">→</i>
            <article><span>02</span><strong>API central</strong><p>Aplica policy, ledger e risco.</p></article>
            <i aria-hidden="true">→</i>
            <article><span>03</span><strong>Solana</strong><p>Liquida ativos elegiveis.</p></article>
          </div>
        </div>
      </section>
      <section className="section">
        <div className="container">
          <div className="section-head">
            <div><div className="eyebrow">Redes</div><h2>Integracoes configuradas</h2></div>
          </div>
          <div className="card-grid">
            {networks.map((network) => (
              <article className="card" key={network.key}>
                <span className="badge">{network.cluster}</span>
                <h3>{network.name}</h3>
                <p>Estado: {network.enabled ? 'configurada' : 'desativada'}. Operacoes financeiras permanecem bloqueadas no MVP.</p>
                <code className="chain-key">{network.key}</code>
              </article>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
