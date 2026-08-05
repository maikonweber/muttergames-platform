import { spawnSync } from "node:child_process";
import { resolve } from "node:path";
import { ROOT } from "./config.js";

function run(script: string) {
  console.log(`\n>>>>>> npm run ${script}\n`);
  const r = spawnSync("npm", ["run", script], {
    cwd: ROOT,
    stdio: "inherit",
    shell: true,
  });
  if (r.status !== 0) process.exit(r.status ?? 1);
}

run("sandbox:setup");
run("sandbox:create-mint");
run("sandbox:mint");
run("sandbox:info");
