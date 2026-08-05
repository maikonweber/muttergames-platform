'use client';

import { useEffect, useState } from 'react';
import type { LauncherCatalog } from '@/lib/api';
import { featuredGames } from '@/lib/games';

const apiUrl = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1';
const bytes = (value: number | null) => value ? `${(value / 1024 / 1024).toFixed(0)} MB` : null;

const staticCatalog: LauncherCatalog = {
  schemaVersion: 1,
  launcher: { latestVersion: '0.1.0', downloadUrl: null },
  games: featuredGames.map((game) => ({
    id: game.id,
    name: game.name,
    description: game.description,
    status: 'coming_soon' as const,
    release: { version: '0.1.0', downloadUrl: null, sizeBytes: null, notes: '' },
  })),
};

export function GameLibrary() {
  const [catalog, setCatalog] = useState<LauncherCatalog>();
  const [usingFallback, setUsingFallback] = useState(false);

  useEffect(() => {
    fetch(`${apiUrl}/launcher/catalog?platform=windows`, { headers: { accept: 'application/json' } })
      .then((r) => (r.ok ? (r.json() as Promise<LauncherCatalog>) : Promise.reject()))
      .then((data) => {
        setCatalog(data.games?.length ? data : staticCatalog);
        setUsingFallback(!data.games?.length);
      })
      .catch(() => {
        setCatalog(staticCatalog);
        setUsingFallback(true);
      });
  }, []);

  if (!catalog) return <p className="library-loading" aria-live="polite">Carregando biblioteca…</p>;

  return (
    <div className="library-grid">
      {catalog.games.map((game) => {
        const available = game.status === 'available';
        const accent = featuredGames.find((g) => g.id === game.id)?.accent;
        return (
          <article className={`card game-card${accent === 'red' ? ' red' : ''}`} key={game.id}>
            <span className="badge">{available ? `Versão ${game.release.version}` : 'Em desenvolvimento'}</span>
            <strong>{game.name}</strong>
            <p>{game.description}</p>
            <small>
              {available
                ? `${game.release.notes}${bytes(game.release.sizeBytes) ? ` · ${bytes(game.release.sizeBytes)}` : ''}`
                : 'Disponível pelo launcher assim que a release for publicada.'}
            </small>
            {available ? (
              <a className="button button-primary" href={`muttergames://install/${game.id}`}>
                Instalar ou abrir
              </a>
            ) : (
              <button className="button button-secondary" disabled>
                Em breve
              </button>
            )}
          </article>
        );
      })}
      <p className="launcher-help">
        {usingFallback
          ? 'Catálogo local enquanto a API não responde. '
          : null}
        O botão abre o MutterGames Launcher instalado no Windows.{' '}
        {catalog.launcher.downloadUrl ? (
          <a href={catalog.launcher.downloadUrl}>Baixar launcher v{catalog.launcher.latestVersion}</a>
        ) : (
          'A publicação do instalador será configurada com a primeira release.'
        )}
      </p>
    </div>
  );
}
