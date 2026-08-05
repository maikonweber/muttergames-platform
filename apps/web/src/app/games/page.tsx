import type { Metadata } from 'next';
import { GameLibrary } from '@/components/game-library';

export const metadata: Metadata = { title: 'Jogos' };

export default function GamesPage() {
  return <>
    <section className="page-hero"><div className="container">
      <div className="eyebrow">Mundos MutterGames</div>
      <h1>Escolha sua próxima experiência.</h1>
      <p>Instale, atualize e abra seus jogos pelo MutterGames Launcher. O mesmo catálogo também mantém a biblioteca do portal atualizada.</p>
    </div></section>
    <section className="section"><div className="container"><GameLibrary /></div></section>
  </>;
}
