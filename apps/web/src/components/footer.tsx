import Link from "next/link";

export function Footer() {
  return <footer className="site-footer"><div className="container footer-row"><div>© 2026 MutterGames</div><nav className="footer-links" aria-label="Rodapé"><Link href="/blockchain">Blockchain</Link><Link href="/marketplace">Marketplace</Link><Link href="/ecosystem">Segurança</Link><Link href="/ecosystem">Transparência</Link></nav></div></footer>;
}
