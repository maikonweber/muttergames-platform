import { randomBytes, randomUUID } from "node:crypto";
import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const body: unknown = await request.json().catch(() => null);
  const address = typeof body === "object" && body !== null && "address" in body ? String(body.address) : "";
  if (address.length < 32 || address.length > 64) return NextResponse.json({ error: "invalid_address" }, { status: 400 });
  const issuedAt = new Date(); const expiresAt = new Date(issuedAt.getTime() + 5 * 60_000);
  const nonce = randomBytes(16).toString("base64url"); const challengeId = randomUUID();
  const message = ["MutterGames Wallet Link","Version: 1","Domain: localhost:3000","URI: http://localhost:3000/account/wallets","Chain: solana:devnet",`Address: ${address}`,`Nonce: ${nonce}`,`Issued At: ${issuedAt.toISOString()}`,`Expiration Time: ${expiresAt.toISOString()}`,`Request ID: ${challengeId}`,"Statement: Esta assinatura não movimenta fundos."].join("\n");
  return NextResponse.json({ challengeId, message, expiresAt: expiresAt.toISOString(), algorithm: "ed25519", prototype: true }, { headers: { "Cache-Control": "no-store" } });
}
