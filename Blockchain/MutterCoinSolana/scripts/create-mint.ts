import { SystemProgram, Transaction, sendAndConfirmTransaction } from "@solana/web3.js";
import {
  ExtensionType,
  LENGTH_SIZE,
  TOKEN_2022_PROGRAM_ID,
  TYPE_SIZE,
  createInitializeMetadataPointerInstruction,
  createInitializeMintInstruction,
  getMintLen,
} from "@solana/spl-token";
import {
  createInitializeInstruction,
  createUpdateFieldInstruction,
  pack,
  type TokenMetadata,
} from "@solana/spl-token-metadata";
import {
  TOKEN,
  explorerMintUrl,
  getCluster,
  getConnection,
  loadOrCreateKeypair,
  PATHS,
  saveDeployed,
  type DeployedState,
} from "./config.js";
import { uploadSandboxAssets } from "./upload-assets.js";

async function main() {
  const cluster = getCluster();
  const connection = getConnection();
  const payer = loadOrCreateKeypair(PATHS.wallet);
  const mintKp = loadOrCreateKeypair(PATHS.mintKeypair);
  const mint = mintKp.publicKey;

  console.log("=== MutterCoin sandbox create-mint ===");
  console.log(`Cluster: ${cluster}`);
  console.log(`Payer:   ${payer.publicKey.toBase58()}`);
  console.log(`Mint:    ${mint.toBase58()}`);

  const existing = await connection.getAccountInfo(mint);
  if (existing) {
    throw new Error(
      `Mint account already exists on-chain: ${mint.toBase58()}. Delete keys/mutter-mint.json to generate a new mint, or use sandbox:mint.`
    );
  }

  console.log("\nUploading logo(4) + metadata for sandbox URI...");
  const { logoUri, metadataUri } = await uploadSandboxAssets();

  const metadata: TokenMetadata = {
    mint,
    name: TOKEN.name,
    symbol: TOKEN.symbol,
    uri: metadataUri,
    additionalMetadata: [
      ["description", "MutterCoin ($MUTTER) — MutterCorp GameFi token (sandbox)"],
      ["image", logoUri],
    ],
  };

  const metadataLen = TYPE_SIZE + LENGTH_SIZE + pack(metadata).length;
  const mintLen = getMintLen([ExtensionType.MetadataPointer]);
  const lamports = await connection.getMinimumBalanceForRentExemption(mintLen + metadataLen);

  const tx = new Transaction().add(
    SystemProgram.createAccount({
      fromPubkey: payer.publicKey,
      newAccountPubkey: mint,
      space: mintLen,
      lamports,
      programId: TOKEN_2022_PROGRAM_ID,
    }),
    createInitializeMetadataPointerInstruction(
      mint,
      payer.publicKey,
      mint,
      TOKEN_2022_PROGRAM_ID
    ),
    createInitializeMintInstruction(
      mint,
      TOKEN.decimals,
      payer.publicKey,
      payer.publicKey, // freeze authority (policy-ready for sandbox)
      TOKEN_2022_PROGRAM_ID
    ),
    createInitializeInstruction({
      programId: TOKEN_2022_PROGRAM_ID,
      mint,
      metadata: mint,
      name: metadata.name,
      symbol: metadata.symbol,
      uri: metadata.uri,
      mintAuthority: payer.publicKey,
      updateAuthority: payer.publicKey,
    }),
    createUpdateFieldInstruction({
      programId: TOKEN_2022_PROGRAM_ID,
      metadata: mint,
      updateAuthority: payer.publicKey,
      field: "description",
      value: "MutterCoin ($MUTTER) — MutterCorp GameFi token (sandbox)",
    }),
    createUpdateFieldInstruction({
      programId: TOKEN_2022_PROGRAM_ID,
      metadata: mint,
      updateAuthority: payer.publicKey,
      field: "image",
      value: logoUri,
    })
  );

  console.log("\nSending create-mint transaction...");
  const createTx = await sendAndConfirmTransaction(connection, tx, [payer, mintKp], {
    commitment: "confirmed",
  });

  const state: DeployedState = {
    cluster,
    rpcUrl: connection.rpcEndpoint,
    mint: mint.toBase58(),
    mintAuthority: payer.publicKey.toBase58(),
    updateAuthority: payer.publicKey.toBase58(),
    metadataUri,
    logoUri,
    decimals: TOKEN.decimals,
    maxSupplyWhole: TOKEN.maxSupplyWhole.toString(),
    createTx,
    createdAt: new Date().toISOString(),
  };
  saveDeployed(state);

  console.log("\n✓ MutterCoin mint created (Token-2022 + metadata)");
  console.log(`  Mint:      ${mint.toBase58()}`);
  console.log(`  Tx:        ${createTx}`);
  console.log(`  Explorer:  ${explorerMintUrl(mint, cluster)}`);
  console.log(`  Logo URI:  ${logoUri}`);
  console.log(`  Meta URI:  ${metadataUri}`);
  console.log("\nNext: npm run sandbox:mint");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
