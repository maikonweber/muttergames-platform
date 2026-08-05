import { clusterApiUrl, Connection, Keypair, PublicKey } from "@solana/web3.js";
import bs58 from "bs58";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import "dotenv/config";

const __dirname = dirname(fileURLToPath(import.meta.url));
export const ROOT = resolve(__dirname, "..");

/** Tokenomics: 10B max, 9 decimals */
export const TOKEN = {
  name: "MutterCoin",
  symbol: "MUTTER",
  decimals: 9,
  maxSupplyWhole: 10_000_000_000n,
  /** Sandbox TGE-style mint: 1% of max (~100M MUTTER) */
  sandboxMintWhole: 100_000_000n,
} as const;

export const PATHS = {
  wallet: resolve(ROOT, "keys/sandbox-wallet.json"),
  mintKeypair: resolve(ROOT, "keys/mutter-mint.json"),
  logo: resolve(ROOT, "token/assets/logo.png"),
  offchainDir: resolve(ROOT, "token/offchain"),
  metadata: resolve(ROOT, "token/offchain/metadata.json"),
  deployed: resolve(ROOT, "token/offchain/deployed.json"),
} as const;

export type DeployedState = {
  cluster: string;
  rpcUrl: string;
  mint: string;
  mintAuthority: string;
  updateAuthority: string;
  metadataUri: string;
  logoUri: string;
  decimals: number;
  maxSupplyWhole: string;
  createTx: string;
  mintedAmountWhole?: string;
  mintTx?: string;
  tokenAccount?: string;
  createdAt: string;
};

export function getCluster(): "devnet" | "localnet" {
  const c = (process.env.SOLANA_CLUSTER ?? "devnet").toLowerCase();
  return c === "localnet" ? "localnet" : "devnet";
}

export function getRpcUrl(): string {
  if (process.env.SOLANA_RPC_URL) return process.env.SOLANA_RPC_URL;
  return getCluster() === "localnet"
    ? "http://127.0.0.1:8899"
    : clusterApiUrl("devnet");
}

export function getConnection(): Connection {
  return new Connection(getRpcUrl(), "confirmed");
}

export function ensureDir(filePath: string): void {
  mkdirSync(dirname(filePath), { recursive: true });
}

export function loadOrCreateKeypair(path: string): Keypair {
  ensureDir(path);
  if (existsSync(path)) {
    const raw = JSON.parse(readFileSync(path, "utf8")) as number[] | { secretKey: string };
    if (Array.isArray(raw)) {
      return Keypair.fromSecretKey(Uint8Array.from(raw));
    }
    return Keypair.fromSecretKey(bs58.decode(raw.secretKey));
  }
  const kp = Keypair.generate();
  writeFileSync(path, JSON.stringify(Array.from(kp.secretKey)));
  console.log(`Created keypair → ${path}`);
  console.log(`  pubkey: ${kp.publicKey.toBase58()}`);
  return kp;
}

export function loadDeployed(): DeployedState {
  if (!existsSync(PATHS.deployed)) {
    throw new Error(`Missing ${PATHS.deployed}. Run: npm run sandbox:create-mint`);
  }
  return JSON.parse(readFileSync(PATHS.deployed, "utf8")) as DeployedState;
}

export function saveDeployed(state: DeployedState): void {
  ensureDir(PATHS.deployed);
  writeFileSync(PATHS.deployed, JSON.stringify(state, null, 2));
  console.log(`Saved deploy state → ${PATHS.deployed}`);
}

export function wholeToBase(amountWhole: bigint, decimals = TOKEN.decimals): bigint {
  return amountWhole * 10n ** BigInt(decimals);
}

export function explorerMintUrl(mint: PublicKey | string, cluster = getCluster()): string {
  const m = typeof mint === "string" ? mint : mint.toBase58();
  const clusterQs = cluster === "devnet" ? "?cluster=devnet" : "?cluster=custom&customUrl=http%3A%2F%2F127.0.0.1%3A8899";
  return `https://explorer.solana.com/address/${m}${clusterQs}`;
}
