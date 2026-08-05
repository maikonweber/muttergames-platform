import Link from "next/link";

export function Footer() {
  return <footer className="site-footer"><div className="container footer-row"><div>© 2026 MutterGames</div><nav className="footer-links" aria-label="Rodapé"><Link href="/ecosystem">Segurança</Link><Link href="/ecosystem">Transparência</Link><Link href="/">Privacidade</Link><Link href="/">Status</Link></nav></div></footer>;
}
