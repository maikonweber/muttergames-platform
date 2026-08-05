'use client';

import { useEffect, useState } from 'react';

type WalletState = 'idle' | 'connecting' | 'connected' | 'challenge' | 'disabled';
type SolanaFeatureMode = 'off' | 'tester' | 'v2';
type SolanaFeatureStatus = {
  mode: SolanaFeatureMode;
  capabilities: { walletLink: boolean; chainIntents: boolean; marketplaceSettlement: boolean; inventorySync: boolean };
  description: string;
};
type InjectedSolana = {
  isPhantom?: boolean;
  connect(): Promise<{ publicKey: { toString(): string } }>;
};

declare global {
  interface Window {
    solana?: InjectedSolana;
  }
}

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1';
const FALLBACK_MODE = (process.env.NEXT_PUBLIC_SOLANA_FEATURE_MODE ?? 'tester') as SolanaFeatureMode;

function badgeLabel(mode: SolanaFeatureMode) {
  if (mode === 'v2') return 'Solana 2.0';
  if (mode === 'tester') return 'Solana Tester';
  return 'Solana Off';
}

export function WalletConnect() {
  const [state, setState] = useState<WalletState>('idle');
  const [address, setAddress] = useState('');
  const [mode, setMode] = useState<SolanaFeatureMode>(FALLBACK_MODE);
  const [message, setMessage] = useState('Carregando feature flag Solana...');

  useEffect(() => {
    let cancelled = false;
    async function loadFeature() {
      try {
        const response = await fetch(`${API_URL}/features/solana`);
        if (!response.ok) throw new Error('feature status failed');
        const data = (await response.json()) as SolanaFeatureStatus;
        if (cancelled) return;
        setMode(data.mode);
        if (!data.capabilities.walletLink) {
          setState('disabled');
          setMessage(data.description);
          return;
        }
        setMessage(
          data.mode === 'tester'
            ? 'Modo tester: conecte a wallet para vincular ao usuario. Equipamentos ficam para depois do reset.'
            : 'Pronta para conexao segura em Solana integrada (v2).',
        );
      } catch {
        if (cancelled) return;
        if (FALLBACK_MODE === 'off') {
          setState('disabled');
          setMessage('Solana desabilitado.');
          return;
        }
        setMode(FALLBACK_MODE);
        setMessage('Pronta para conexao segura em Solana Devnet.');
      }
    }
    void loadFeature();
    return () => {
      cancelled = true;
    };
  }, []);

  async function connect() {
    if (!window.solana) {
      setMessage('Nenhuma wallet Solana foi encontrada. Instale uma carteira para continuar.');
      return;
    }

    try {
      setState('connecting');
      const result = await window.solana.connect();
      setAddress(result.publicKey.toString());
      setState('connected');
      setMessage('Wallet conectada. Agora prepare a mensagem gratuita de vinculo.');
    } catch {
      setState('idle');
      setMessage('A conexao foi cancelada. Nenhum acesso foi concedido.');
    }
  }

  async function prepareChallenge() {
    setState('challenge');

    try {
      const response = await fetch(`${API_URL}/wallets/challenges`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ address, chain: 'solana:devnet' }),
      });
      if (!response.ok) throw new Error('Challenge request failed');
      setMessage('Challenge criado pela API central. A assinatura Ed25519 sera a proxima etapa.');
    } catch {
      setMessage('Nao foi possivel preparar o vinculo. Tente novamente.');
      setState('connected');
    }
  }

  return (
    <section className="wallet-panel" aria-live="polite">
      <span className="badge">{badgeLabel(mode)}</span>
      <h2>Conexao de wallet</h2>
      <div className="wallet-state">
        <span className={`status-dot ${state === 'connected' || state === 'challenge' ? 'ready' : ''}`} />
        {message}
      </div>
      {address && <p className="address">{address}</p>}
      <div className="notice">
        <strong>Importante:</strong> a MutterGames nunca solicita sua frase-semente.
        {mode === 'tester'
          ? ' No modo tester so salvamos o vinculo wallet + usuario.'
          : ' Este fluxo nao movimenta fundos sem confirmacao explicita.'}
      </div>
      {state === 'disabled' && <button className="button button-secondary" disabled>Solana indisponivel</button>}
      {state === 'idle' && <button className="button button-primary" onClick={connect}>Conectar carteira</button>}
      {state === 'connecting' && <button className="button button-primary" disabled>Conectando...</button>}
      {state === 'connected' && <button className="button button-outline" onClick={prepareChallenge}>Preparar vinculo</button>}
      {state === 'challenge' && <button className="button button-secondary" disabled>Challenge preparado</button>}
    </section>
  );
}
