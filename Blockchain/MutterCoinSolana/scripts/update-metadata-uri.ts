import { PublicKey, Transaction, sendAndConfirmTransaction } from "@solana/web3.js";
import { TOKEN_2022_PROGRAM_ID } from "@solana/spl-token";
import { createUpdateFieldInstruction } from "@solana/spl-token-metadata";
import {
  getConnection,
  loadDeployed,
  loadOrCreateKeypair,
  PATHS,
  saveDeployed,
} from "./config.js";
import { uploadSandboxAssets } from "./upload-assets.js";

/** Re-upload logo/metadata and patch Token-2022 URI + image fields. */
async function main() {
  const connection = getConnection();
  const payer = loadOrCreateKeypair(PATHS.wallet);
  const deployed = loadDeployed();
  const mint = new PublicKey(deployed.mint);

  console.log("Uploading assets...");
  const { logoUri, metadataUri } = await uploadSandboxAssets();

  const tx = new Transaction().add(
    createUpdateFieldInstruction({
      programId: TOKEN_2022_PROGRAM_ID,
      metadata: mint,
      updateAuthority: payer.publicKey,
      field: "uri",
      value: metadataUri,
    }),
    createUpdateFieldInstruction({
      programId: TOKEN_2022_PROGRAM_ID,
      metadata: mint,
      updateAuthority: payer.publicKey,
      field: "image",
      value: logoUri,
    }),
    createUpdateFieldInstruction({
      programId: TOKEN_2022_PROGRAM_ID,
      metadata: mint,
      updateAuthority: payer.publicKey,
      field: "description",
      value: "MutterCoin ($MUTTER) — MutterCorp GameFi token (sandbox)",
    })
  );

  const sig = await sendAndConfirmTransaction(connection, tx, [payer], {
    commitment: "confirmed",
  });

  deployed.metadataUri = metadataUri;
  deployed.logoUri = logoUri;
  saveDeployed(deployed);

  console.log("✓ Metadata updated");
  console.log(`  URI:  ${metadataUri}`);
  console.log(`  Logo: ${logoUri}`);
  console.log(`  Tx:   ${sig}`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
