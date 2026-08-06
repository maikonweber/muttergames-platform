#!/usr/bin/env node
// MCP stdio mínimo e seguro: argumentos são passados como array, nunca como shell livre.
import { createInterface } from 'node:readline';
import { spawn } from 'node:child_process';
import path from 'node:path';

const root = process.env.MUTTER_FORGE_ROOT || process.cwd();
const forge = path.join(root, 'scripts', 'mutter-forge.sh');
const tools = [
  { name: 'forge_2d', description: 'Executa uma operação 2D do Mutter Forge.', inputSchema: { type: 'object', properties: { args: { type: 'array', items: { type: 'string' }, description: 'Ex.: ["vfx","forge","assets/vfx/forge","256","12"]' } }, required: ['args'] } },
  { name: 'forge_game', description: 'Cria schema, localização, componente ou release template.', inputSchema: { type: 'object', properties: { args: { type: 'array', items: { type: 'string' } } }, required: ['args'] } },
  { name: 'forge_3d', description: 'Cria primitive 3D ou renderiza um .blend pelo Blender.', inputSchema: { type: 'object', properties: { args: { type: 'array', items: { type: 'string' } } }, required: ['args'] } },
  { name: 'forge_ai', description: 'Chama OpenRouter para imagem, texto, brief ou voz; requer OPEN_ROUTER.', inputSchema: { type: 'object', properties: { group: { type: 'string', enum: ['ai-image', 'ai-game'] }, args: { type: 'array', items: { type: 'string' } } }, required: ['group', 'args'] } },
];

function reply(id, result) { process.stdout.write(`${JSON.stringify({ jsonrpc: '2.0', id, result })}\n`); }
function fail(id, message) { process.stdout.write(`${JSON.stringify({ jsonrpc: '2.0', id, error: { code: -32000, message } })}\n`); }
function invoke(args) {
  return new Promise((resolve) => {
    const child = spawn('bash', [forge, ...args], { cwd: root, env: process.env, shell: false });
    let stdout = '', stderr = '';
    child.stdout.on('data', (chunk) => { stdout += chunk; });
    child.stderr.on('data', (chunk) => { stderr += chunk; });
    child.on('close', (code) => resolve({ code, stdout, stderr }));
    child.on('error', (error) => resolve({ code: 1, stdout, stderr: error.message }));
  });
}

const input = createInterface({ input: process.stdin, crlfDelay: Infinity });
input.on('line', async (line) => {
  let request;
  try { request = JSON.parse(line); } catch { return; }
  if (!request.id) return;
  if (request.method === 'initialize') return reply(request.id, { protocolVersion: '2025-06-18', capabilities: { tools: {} }, serverInfo: { name: 'mutter-forge', version: '1.0.0' } });
  if (request.method === 'tools/list') return reply(request.id, { tools });
  if (request.method !== 'tools/call') return fail(request.id, 'Método não suportado');
  const { name, arguments: inputArgs = {} } = request.params ?? {};
  let args;
  if (name === 'forge_2d') args = ['2d', ...(inputArgs.args ?? [])];
  else if (name === 'forge_game') args = ['game', ...(inputArgs.args ?? [])];
  else if (name === 'forge_3d') args = ['3d', ...(inputArgs.args ?? [])];
  else if (name === 'forge_ai') args = [inputArgs.group, ...(inputArgs.args ?? [])];
  else return fail(request.id, 'Ferramenta não encontrada');
  if (!args.every((value) => typeof value === 'string')) return fail(request.id, 'Todos os argumentos devem ser strings');
  const result = await invoke(args);
  reply(request.id, { content: [{ type: 'text', text: `${result.stdout}${result.stderr}`.trim() || 'Concluído.' }], isError: result.code !== 0 });
});
