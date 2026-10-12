# Ejecuta el runner de pruebas de EL GOAT en Godot headless.
# Uso:
#   .\tests\run_tests.ps1 -GodotPath "C:\ruta\Godot_v4.7.2-stable_win64.exe"
#   $env:GODOT = "C:\ruta\Godot_v4.7.2-stable_win64.exe"; .\tests\run_tests.ps1
# Si no se pasa parámetro ni variable GODOT, se intenta "godot" desde el PATH.
# Códigos de salida: 0 = todo pasó, 1 = hubo fallas, 2 = no se encontró Godot.
# Ver docs/TESTING.md.

param(
    [string]$GodotPath = $env:GODOT
)

if (-not $GodotPath) {
    $godotCommand = Get-Command godot -ErrorAction SilentlyContinue
    if ($godotCommand) {
        $GodotPath = $godotCommand.Source
    }
}

if (-not $GodotPath -or -not (Test-Path $GodotPath)) {
    Write-Host "ERROR: no se encontro el ejecutable de Godot."
    Write-Host "Pasalo con -GodotPath o definí la variable de entorno GODOT."
    exit 2
}

$projectRoot = Split-Path -Parent $PSScriptRoot

# Start-Process -Wait asegura esperar al ejecutable (incluso si es de tipo
# GUI, como la versión estándar de Godot) y capturar su código de salida.
$process = Start-Process -FilePath $GodotPath `
    -ArgumentList @("--headless", "--path", $projectRoot, "-s", "res://tests/run_tests.gd") `
    -NoNewWindow -Wait -PassThru

exit $process.ExitCode
