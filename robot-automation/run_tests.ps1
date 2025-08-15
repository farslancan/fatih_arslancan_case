# run_tests.ps1
$runId  = Get-Date -Format "yyyyMMdd-HHmmss"
$outDir = "results\$runId"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

robot -d $outDir --timestampoutputs .\Tests
