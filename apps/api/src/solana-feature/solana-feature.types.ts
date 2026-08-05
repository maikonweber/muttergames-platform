export const SOLANA_FEATURE_MODES = ['off', 'tester', 'v2'] as const;

export type SolanaFeatureMode = (typeof SOLANA_FEATURE_MODES)[number];

export type SolanaFeatureCapabilities = {
  walletLink: boolean;
  chainIntents: boolean;
  marketplaceSettlement: boolean;
  inventorySync: boolean;
};

export type SolanaFeatureStatus = {
  mode: SolanaFeatureMode;
  capabilities: SolanaFeatureCapabilities;
  description: string;
};

export function parseSolanaFeatureMode(raw: string | undefined): SolanaFeatureMode {
  const value = (raw ?? 'tester').trim().toLowerCase();
  if (value === 'off' || value === 'tester' || value === 'v2') return value;
  return 'tester';
}

export function capabilitiesForMode(mode: SolanaFeatureMode): SolanaFeatureCapabilities {
  switch (mode) {
    case 'off':
      return {
        walletLink: false,
        chainIntents: false,
        marketplaceSettlement: false,
        inventorySync: false,
      };
    case 'tester':
      return {
        walletLink: true,
        chainIntents: false,
        marketplaceSettlement: false,
        inventorySync: false,
      };
    case 'v2':
      return {
        walletLink: true,
        chainIntents: true,
        marketplaceSettlement: true,
        inventorySync: true,
      };
  }
}

export function descriptionForMode(mode: SolanaFeatureMode): string {
  switch (mode) {
    case 'off':
      return 'Solana desabilitado.';
    case 'tester':
      return 'Modo tester: vincula e salva wallets/users. Chain intents, marketplace e equipamentos ficam bloqueados.';
    case 'v2':
      return 'Solana 2.0 integrado: wallets, intents, settlement e inventário liberados.';
  }
}
