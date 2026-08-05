import Image from "next/image";
import Link from "next/link";

export function Header() {
  return <header className="site-header"><div className="container nav">
    <Link className="brand" href="/"><Image src="/logo.png" alt="" width={40} height={40} priority />Mutter<span>Games</span></Link>
    <nav className="nav-links" aria-label="Principal"><Link href="/games">Jogos</Link><Link href="/blockchain">Blockchain</Link><Link href="/marketplace">Marketplace</Link><Link href="/ecosystem">Ecossistema</Link></nav>
    <div className="nav-actions"><Link className="button button-secondary" href="/account">Entrar</Link><Link className="button button-primary" href="/account/wallets">Conectar wallet</Link></div>
  </div></header>;
}
