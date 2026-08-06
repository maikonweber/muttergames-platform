import Link from 'next/link';
import { MutterCoinsCard } from '../../components/mutter-coins-card';

export default function AccountPage() {
  return <div className="card-grid"><article className="card"><span className="badge">Mutter ID</span><h2>Bem-vindo</h2><p>Seu perfil está preparado para receber jogos e progressão.</p></article><MutterCoinsCard /><article className="card"><span className="badge">Wallet</span><h2>Não conectada</h2><p>Conecte uma wallet Solana para consultar ativos na Devnet.</p><Link className="button button-primary" href="/account/wallets">Conectar</Link></article></div>;
}
