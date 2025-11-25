<#
Script: place_fastlines.ps1
Propósito: Copia o descarga `fast-lines-background.mp4` a la carpeta donde se ubica este script.
Ubicación recomendada: `C:\Users\consa\Downloads\JMG_SITIO\Imagenes\place_fastlines.ps1`

Uso:
  - Copiar desde una ruta local:
    .\place_fastlines.ps1 -SourcePath "C:\ruta\a\fast-lines-background.mp4"

  - Mover desde una ruta local (elimina el archivo origen):
    .\place_fastlines.ps1 -SourcePath "C:\ruta\a\fast-lines-background.mp4" -Move

  - Descargar desde URL pública:
    .\place_fastlines.ps1 -Url "https://example.com/fast-lines-background.mp4"

  - Forzar sobrescritura del destino existente:
    .\place_fastlines.ps1 -SourcePath "C:\ruta\a\fast-lines-background.mp4" -Force

Nota: Si la política de ejecución bloquea el script, ejecútalo así:
  powershell -ExecutionPolicy Bypass -File .\place_fastlines.ps1 -SourcePath "C:\...\file.mp4"
#>

param(
    [Parameter(Mandatory=$false)] [string]$SourcePath,
    [Parameter(Mandatory=$false)] [string]$Url,
    [switch]$Move,
    [switch]$Force
)

# Destino: nombre fijo dentro del directorio donde está el script
$destDir = $PSScriptRoot
if (-not $destDir) { $destDir = Split-Path -Parent $MyInvocation.MyCommand.Definition }
$destFile = Join-Path -Path $destDir -ChildPath "fast-lines-background.mp4"

function Abort([string]$msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

if (-not $SourcePath -and -not $Url) {
    Abort "Debe proporcionar -SourcePath o -Url. Vea la ayuda en el script."
}

# Asegurar carpeta destino
if (-not (Test-Path -Path $destDir)) {
    Write-Host "Creando carpeta destino: $destDir"
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Si existe destino y no forzar, preguntar/salir
if (Test-Path -Path $destFile) {
    if ($Force) {
        Write-Host "El archivo destino ya existe y se sobrescribirá (flag -Force)."
        Remove-Item -Path $destFile -Force
n    } else {
        Write-Host "El archivo ya existe en destino: $destFile" -ForegroundColor Yellow
        Write-Host "Use -Force para sobrescribir o renombre/elimine el archivo existente." -ForegroundColor Yellow
        exit 0
    }
}

try {
    if ($SourcePath) {
        if (-not (Test-Path -Path $SourcePath)) {
            Abort "No se encontró el archivo origen: $SourcePath"
        }

        if ($Move) {
            Write-Host "Moviendo archivo desde: $SourcePath -> $destFile"
            Move-Item -Path $SourcePath -Destination $destFile -ErrorAction Stop
        } else {
            Write-Host "Copiando archivo desde: $SourcePath -> $destFile"
            if ($Force) { Copy-Item -Path $SourcePath -Destination $destFile -Force -ErrorAction Stop }
            else { Copy-Item -Path $SourcePath -Destination $destFile -ErrorAction Stop }
        }

        Write-Host "Operación completada exitosamente." -ForegroundColor Green
        exit 0
    }

    if ($Url) {
        Write-Host "Descargando desde URL: $Url -> $destFile"
        # Invoke-WebRequest -UseBasicParsing para compatibilidad con PS 5.1
        Invoke-WebRequest -Uri $Url -OutFile $destFile -UseBasicParsing -ErrorAction Stop
        Write-Host "Descarga completada exitosamente." -ForegroundColor Green
        exit 0
    }
}
catch {
    Write-Host "Ocurrió un error: $_" -ForegroundColor Red
    exit 1
}
