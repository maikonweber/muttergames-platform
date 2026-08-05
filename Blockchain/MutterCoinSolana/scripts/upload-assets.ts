import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import sharp from "sharp";
import { PATHS } from "./config.js";

/**
 * Compresses logo(4), uploads logo + metadata to catbox.moe for sandbox URIs.
 * Falls back to local file://-style markers only if upload is unavailable
 * (name/symbol still live on-chain either way).
 */
export async function uploadSandboxAssets(): Promise<{ logoUri: string; metadataUri: string }> {
  const compressedLogo = resolve(PATHS.offchainDir, "logo.png");
  await sharp(PATHS.logo)
    .resize(512, 512, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 1 } })
    .png({ compressionLevel: 9 })
    .toFile(compressedLogo);
  console.log(`Compressed logo → ${compressedLogo}`);

  let logoUri: string;
  let metadataUri: string;

  try {
    logoUri = await uploadFile(compressedLogo, "mutter-logo.png");
    console.log(`Logo URI: ${logoUri}`);

    const meta = buildMetadata(logoUri);
    const staged = resolve(PATHS.offchainDir, "metadata.hosted.json");
    writeFileSync(staged, JSON.stringify(meta, null, 2));

    metadataUri = await uploadFile(staged, "mutter-metadata.json");
    console.log(`Metadata URI: ${metadataUri}`);
  } catch (err) {
    console.warn(`Remote upload failed (${err instanceof Error ? err.message : err}).`);
    console.warn("Using on-chain name/symbol; metadata.uri set to local staged JSON path.");
    const staged = resolve(PATHS.offchainDir, "metadata.hosted.json");
    const meta = buildMetadata(`file://${compressedLogo.replace(/\\/g, "/")}`);
    writeFileSync(staged, JSON.stringify(meta, null, 2));
    logoUri = `file://${compressedLogo.replace(/\\/g, "/")}`;
    metadataUri = `file://${staged.replace(/\\/g, "/")}`;
  }

  writeFileSync(resolve(PATHS.offchainDir, "metadata.uri.txt"), metadataUri);
  return { logoUri, metadataUri };
}

function buildMetadata(logoUri: string): Record<string, unknown> {
  const meta = existsSync(PATHS.metadata)
    ? (JSON.parse(readFileSync(PATHS.metadata, "utf8")) as Record<string, unknown>)
    : {
        name: "MutterCoin",
        symbol: "MUTTER",
        description: "MutterCoin ($MUTTER) sandbox mint",
      };
  meta.image = logoUri;
  if (meta.properties && typeof meta.properties === "object") {
    const props = meta.properties as { files?: Array<{ uri: string; type: string }> };
    props.files = [{ uri: logoUri, type: "image/png" }];
  }
  return meta;
}

async function uploadFile(path: string, filename: string): Promise<string> {
  const errors: string[] = [];
  for (const uploader of [uploadCatbox, uploadLitterbox, upload0x0]) {
    try {
      return await uploader(path, filename);
    } catch (err) {
      errors.push(`${uploader.name}: ${err instanceof Error ? err.message : err}`);
    }
  }
  throw new Error(errors.join(" | "));
}

async function uploadCatbox(path: string, filename: string): Promise<string> {
  const form = new FormData();
  form.append("reqtype", "fileupload");
  form.append("fileToUpload", new Blob([readFileSync(path)]), filename);
  const res = await fetch("https://catbox.moe/user/api.php", { method: "POST", body: form });
  const text = (await res.text()).trim();
  if (!res.ok || !text.startsWith("https://")) {
    throw new Error(`HTTP ${res.status} — ${text}`);
  }
  return text;
}

async function uploadLitterbox(path: string, filename: string): Promise<string> {
  const form = new FormData();
  form.append("reqtype", "fileupload");
  form.append("time", "72h");
  form.append("fileToUpload", new Blob([readFileSync(path)]), filename);
  const res = await fetch("https://litterbox.catbox.moe/resources/internals/api.php", {
    method: "POST",
    body: form,
  });
  const text = (await res.text()).trim();
  if (!res.ok || !text.startsWith("https://")) {
    throw new Error(`HTTP ${res.status} — ${text}`);
  }
  return text;
}

async function upload0x0(path: string, filename: string): Promise<string> {
  const form = new FormData();
  form.append("file", new Blob([readFileSync(path)]), filename);
  const res = await fetch("https://0x0.st", { method: "POST", body: form });
  const text = (await res.text()).trim();
  if (!res.ok || !/^https?:\/\//.test(text)) {
    throw new Error(`HTTP ${res.status} — ${text}`);
  }
  return text;
}
