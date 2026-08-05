const API_URL =
  process.env.API_INTERNAL_URL ??
  process.env.NEXT_PUBLIC_API_URL ??
  'http://localhost:3001/api/v1';

export type MarketplaceItem = {
  id: string;
  slug: string;
  name: string;
  description: string;
  gameId: string;
  assetType: string;
  priceAtomic: string;
  currencySymbol: string;
  supply: number;
  sold: number;
  status: string;
};

export type BlockchainNetwork = {
  id: string;
  key: string;
  name: string;
  cluster: string;
  enabled: boolean;
};

export type GameReleaseId =
  | 'fallen-tactics'
  | 'forge-of-champions'
  | 'taskbar-planets-forger'
  | 'beat-up'
  | (string & {});

export type GameRelease = {
  id: GameReleaseId;
  name: string;
  description: string;
  status: 'available' | 'coming_soon';
  release: { version: string; downloadUrl: string | null; sizeBytes: number | null; notes: string };
};
export type LauncherCatalog = { schemaVersion: number; launcher: { latestVersion: string; downloadUrl: string | null }; games: GameRelease[] };

async function apiGet<T>(path: string): Promise<T> {
  const response = await fetch(`${API_URL}${path}`, {
    next: { revalidate: 30 },
    headers: { accept: 'application/json' },
  });

  if (!response.ok) throw new Error(`Central API request failed: ${response.status}`);
  return response.json() as Promise<T>;
}

export const centralApi = {
  marketplace: () => apiGet<MarketplaceItem[]>('/marketplace/items'),
  networks: () => apiGet<BlockchainNetwork[]>('/blockchain/networks'),
  launcherCatalog: () => apiGet<LauncherCatalog>('/launcher/catalog?platform=windows'),
};
