'use client';

import { useEffect, useState } from 'react';

type LedgerEntry = { id: string; amountAtomic: string; description: string };
type CoinSummary = { symbol: string; decimals: number; balanceAtomic: string; transactions: LedgerEntry[] };
const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1';

function formatCoins(value: string, decimals: number) {
  const raw = BigInt(value);
  const unit = BigInt(10) ** BigInt(decimals);
  const whole = raw / unit;
  const fraction = (raw % unit).toString().padStart(decimals, '0').slice(0, 2).replace(/0+$/, '');
  return `${whole.toLocaleString('pt-BR')}${fraction ? `,${fraction}` : ''}`;
}

export function MutterCoinsCard() {
  const [summary, setSummary] = useState<CoinSummary | null>(null);
  const [state, setState] = useState<'loading' | 'signin' | 'error'>('loading');
  useEffect(() => {
    const token = window.localStorage.getItem('muttergames.accessToken');
    if (!token) { setState('signin'); return; }
    fetch(`${API_URL}/muttercoins/me`, { headers: { authorization: `Bearer ${token}` } })
      .then(async (response) => {
        if (response.status === 401) { setState('signin'); return; }
        if (!response.ok) throw new Error('coin summary failed');
        setSummary(await response.json() as CoinSummary);
      }).catch(() => setState('error'));
  }, []);
  if (state === 'signin') return <article className="card coin-card"><span className="badge">MutterCoins</span><h2>Saldo protegido</h2><p>Entre na sua conta para consultar o saldo e o histórico de transações.</p></article>;
  if (state === 'error') return <article className="card coin-card"><span className="badge">MutterCoins</span><h2>Saldo indisponível</h2><p>Não foi possível alcançar a API central agora.</p></article>;
  if (!summary) return <article className="card coin-card"><span className="badge">MutterCoins</span><p>Carregando saldo…</p></article>;
  return <article className="card coin-card"><span className="badge">MutterCoins</span><strong className="coin-balance">{formatCoins(summary.balanceAtomic, summary.decimals)} <small>{summary.symbol}</small></strong><p>Saldo off-chain disponível no ecossistema.</p>{summary.transactions.slice(0, 3).map((item) => <div className="coin-entry" key={item.id}><span>{item.description}</span><b className={item.amountAtomic.startsWith('-') ? 'coin-debit' : 'coin-credit'}>{item.amountAtomic.startsWith('-') ? '−' : '+'}{formatCoins(item.amountAtomic.replace('-', ''), summary.decimals)}</b></div>)}</article>;
}
