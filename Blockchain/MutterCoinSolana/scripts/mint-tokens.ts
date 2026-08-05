import { PublicKey } from "@solana/web3.js";
import {
  TOKEN_2022_PROGRAM_ID,
  createAssociatedTokenAccountIdempotent,
  getAccount,
  mintTo,
} from "@solana/spl-token";
import {
  TOKEN,
  explorerMintUrl,
  getConnection,
  loadDeployed,
  loadOrCreateKeypair,
  PATHS,
  saveDeployed,
  wholeToBase,
} from "./config.js";

async function main() {
  const connection = getConnection();
  const payer = loadOrCreateKeypair(PATHS.wallet);
  const deployed = loadDeployed();
  const mint = new PublicKey(deployed.mint);

  const amountArg = process.argv[2];
  const amountWhole = amountArg ? BigInt(amountArg) : TOKEN.sandboxMintWhole;
  const amountBase = wholeToBase(amountWhole);

  console.log("=== MutterCoin sandbox mint ===");
  console.log(`Mint:   ${mint.toBase58()}`);
  console.log(`Amount: ${amountWhole.toString()} MUTTER (${amountBase.toString()} base units)`);

  const ata = await createAssociatedTokenAccountIdempotent(
    connection,
    payer,
    mint,
    payer.publicKey,
    { commitment: "confirmed" },
    TOKEN_2022_PROGRAM_ID
  );

  const mintTx = await mintTo(
    connection,
    payer,
    mint,
    ata,
    payer,
    amountBase,
    [],
    { commitment: "confirmed" },
    TOKEN_2022_PROGRAM_ID
  );

  const account = await getAccount(connection, ata, "confirmed", TOKEN_2022_PROGRAM_ID);

  deployed.mintedAmountWhole = amountWhole.toString();
  deployed.mintTx = mintTx;
  deployed.tokenAccount = ata.toBase58();
  saveDeployed(deployed);

  console.log("\n✓ Minted");
  console.log(`  ATA:      ${ata.toBase58()}`);
  console.log(`  Balance:  ${account.amount.toString()} base units`);
  console.log(`  Tx:       ${mintTx}`);
  console.log(`  Explorer: ${explorerMintUrl(mint, deployed.cluster as "devnet" | "localnet")}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
