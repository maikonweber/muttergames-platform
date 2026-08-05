"use client";

import { useState } from "react";

type WalletState = "idle" | "connecting" | "connected" | "challenge";
type InjectedSolana = { isPhantom?: boolean; connect(): Promise<{ publicKey: { toString(): string } }> };

declare global { interface Window { solana?: InjectedSolana } }

export function WalletConnect() {
  const [state, setState] = useState<WalletState>("idle");
  const [address, setAddress] = useState("");
  const [message, setMessage] = useState("Pronta para conexão segura em Solana Devnet.");

  async function connect() {
    if (!window.solana) { setMessage("Nenhuma wallet compatível foi encontrada. Instale uma carteira Solana para continuar."); return; }
    try {
      setState("connecting");
      const result = await window.solana.connect();
      const nextAddress = result.publicKey.toString();
      setAddress(nextAddress);
      setState("connected");
      setMessage("Wallet conectada. A próxima etapa é assinar uma mensagem gratuita de vínculo.");
    } catch { setState("idle"); setMessage("A conexão foi cancelada. Nenhum acesso foi concedido."); }
  }

  async function prepareChallenge() {
    setState("challenge");
    const response = await fetch("/api/wallet/challenge", { method:"POST", headers:{"content-type":"application/json"}, body:JSON.stringify({ address }) });
    if (!response.ok) { setMessage("Não foi possível preparar o vínculo. Tente novamente."); setState("connected"); return; }
    setMessage("Challenge preparado. A verificação criptográfica será implementada na próxima etapa.");
  }

  return <section className="wallet-panel" aria-live="polite">
    <span className="badge">Solana Devnet</span><h2>Conexão de wallet</h2>
    <div className="wallet-state"><span className={`status-dot ${state === "connected" || state === "challenge" ? "ready" : ""}`} />{message}</div>
    {address && <p className="address">{address}</p>}
    <div className="notice"><strong>Importante:</strong> a MutterGames nunca solicita sua frase-semente. Este protótipo não movimenta fundos.</div>
    {state === "idle" && <button className="button button-primary" onClick={connect}>Conectar carteira</button>}
    {state === "connecting" && <button className="button button-primary" disabled>Conectando…</button>}
    {state === "connected" && <button className="button button-outline" onClick={prepareChallenge}>Preparar vínculo</button>}
    {state === "challenge" && <button className="button button-secondary" disabled>Challenge preparado</button>}
  </section>;
}
