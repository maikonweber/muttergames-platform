import { PublicKey } from "@solana/web3.js";
import {
  TOKEN_2022_PROGRAM_ID,
  getMint,
  getTokenMetadata,
} from "@solana/spl-token";
import { explorerMintUrl, getConnection, loadDeployed } from "./config.js";

async function main() {
  const connection = getConnection();
  const deployed = loadDeployed();
  const mint = new PublicKey(deployed.mint);

  const mintInfo = await getMint(connection, mint, "confirmed", TOKEN_2022_PROGRAM_ID);
  const metadata = await getTokenMetadata(connection, mint);

  console.log("=== MutterCoin mint info ===");
  console.log(JSON.stringify({ deployed, mintInfo: {
    address: mint.toBase58(),
    decimals: mintInfo.decimals,
    supply: mintInfo.supply.toString(),
    mintAuthority: mintInfo.mintAuthority?.toBase58() ?? null,
    freezeAuthority: mintInfo.freezeAuthority?.toBase58() ?? null,
    isInitialized: mintInfo.isInitialized,
  }, metadata }, null, 2));
  console.log(`Explorer: ${explorerMintUrl(mint, deployed.cluster as "devnet" | "localnet")}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
