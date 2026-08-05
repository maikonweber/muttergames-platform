import { LAMPORTS_PER_SOL } from "@solana/web3.js";
import { getCluster, getConnection, loadOrCreateKeypair, PATHS } from "./config.js";

async function airdropWithRetry(
  connection: ReturnType<typeof getConnection>,
  pubkey: Parameters<typeof connection.requestAirdrop>[0],
  lamports: number,
  attempts = 5
) {
  let lastErr: unknown;
  for (let i = 1; i <= attempts; i++) {
    try {
      console.log(`Airdrop attempt ${i}/${attempts} (${lamports / LAMPORTS_PER_SOL} SOL)...`);
      const sig = await connection.requestAirdrop(pubkey, lamports);
      await connection.confirmTransaction(sig, "confirmed");
      return;
    } catch (err) {
      lastErr = err;
      console.warn(`Airdrop failed: ${err instanceof Error ? err.message : err}`);
      await new Promise((r) => setTimeout(r, 2000 * i));
    }
  }
  throw lastErr;
}

async function main() {
  const cluster = getCluster();
  const connection = getConnection();
  const wallet = loadOrCreateKeypair(PATHS.wallet);

  console.log(`Cluster: ${cluster}`);
  console.log(`RPC: ${connection.rpcEndpoint}`);
  console.log(`Wallet: ${wallet.publicKey.toBase58()}`);

  let balance = await connection.getBalance(wallet.publicKey);
  console.log(`Balance: ${balance / LAMPORTS_PER_SOL} SOL`);

  if (balance < 1 * LAMPORTS_PER_SOL) {
    // Devnet public faucet is flaky; localnet always works.
    await airdropWithRetry(connection, wallet.publicKey, 2 * LAMPORTS_PER_SOL);
    balance = await connection.getBalance(wallet.publicKey);
    console.log(`New balance: ${balance / LAMPORTS_PER_SOL} SOL`);
  }

  if (balance === 0) {
    throw new Error(
      "Wallet has 0 SOL. For Devnet, fund via https://faucet.solana.com or set SOLANA_CLUSTER=localnet."
    );
  }

  console.log("Sandbox wallet ready.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
