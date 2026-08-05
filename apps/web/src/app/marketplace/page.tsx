import type { Metadata } from 'next';
import { MarketplaceGrid } from '@/components/marketplace-grid';
import { centralApi, type MarketplaceItem } from '@/lib/api';

export const metadata: Metadata = { title: 'Marketplace' };

const fallback: MarketplaceItem[] = [
  { id: 'preview-1', slug: 'genesis-tactician', name: 'Genesis Tactician', description: 'Skin de comandante da colecao Genesis.', gameId: 'fallen-tactics', assetType: 'skin', priceAtomic: '25000000', currencySymbol: 'USDC', supply: 500, sold: 72, status: 'active' },
  { id: 'preview-2', slug: 'forge-gloves', name: 'Forge Gloves', description: 'Luvas cosmeticas para Beat Up.', gameId: 'beat-up', assetType: 'equipment', priceAtomic: '18000000', currencySymbol: 'USDC', supply: 750, sold: 188, status: 'active' },
];

export default async function MarketplacePage() {
  const items = await centralApi.marketplace().catch(() => fallback);

  return (
    <>
      <section className="page-hero market-hero">
        <div className="container">
          <div className="eyebrow">Mercado verificado</div>
          <h1>Itens para jogar.<br />Nao para especular.</h1>
          <p>Explore cosmeticos e colecionaveis compativeis. Compras permanecem desativadas ate a integracao Devnet passar pelos gates de seguranca.</p>
        </div>
      </section>
      <section className="section">
        <div className="container">
          <div className="market-toolbar">
            <div><strong>{items.length} itens</strong><span>Catalogo inicial</span></div>
            <div className="badge">Solana Devnet</div>
          </div>
          <MarketplaceGrid items={items} />
        </div>
      </section>
    </>
  );
}
