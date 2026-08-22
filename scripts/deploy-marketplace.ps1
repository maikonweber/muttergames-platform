param(
  [string]$DatabaseUrl = $env:DATABASE_URL
)

if ([string]::IsNullOrWhiteSpace($DatabaseUrl)) { throw 'Defina DATABASE_URL antes de publicar o marketplace.' }
$env:DATABASE_URL = $DatabaseUrl
pnpm --filter @muttergames/api db:migrate
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
pnpm --filter @muttergames/api db:seed
exit $LASTEXITCODE
