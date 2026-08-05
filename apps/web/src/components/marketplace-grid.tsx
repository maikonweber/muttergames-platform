import type { MarketplaceItem } from '@/lib/api';

const formatter = new Intl.NumberFormat('pt-BR', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

export function MarketplaceGrid({ items }: { items: MarketplaceItem[] }) {
  return (
    <div className="market-grid">
      {items.map((item) => {
        const remaining = Math.max(0, item.supply - item.sold);
        const price = Number(item.priceAtomic) / 1_000_000;

        return (
          <article className="market-card" key={item.id}>
            <div className={`asset-visual ${item.gameId === 'beat-up' ? 'asset-red' : ''}`}>
              <span>{item.assetType}</span>
            </div>
            <div className="market-card-body">
              <div className="market-meta">
                <span className="badge">{item.gameId}</span>
                <span>{remaining} disponiveis</span>
              </div>
              <h2>{item.name}</h2>
              <p>{item.description}</p>
              <div className="market-price">
                <div>
                  <small>Preco</small>
                  <strong>{formatter.format(price)} {item.currencySymbol}</strong>
                </div>
                <button className="button button-primary" disabled>Devnet em breve</button>
              </div>
            </div>
          </article>
        );
      })}
    </div>
  );
}
