@echo off
REM Cutter.cmd - Recortar y exportar imágenes con formas personalizadas
REM ---------------------------------------------------------------

REM Variables por defecto
set INPUT=.\input
set OUTPUT=.\archivo_recortado
set EXT=png
set CLEAN=false
set RESIZE_FACTOR=1
set ASPECT=1:1
set SHAPE=squircle

REM Mostrar ayuda
:show_help
if "%1"=="/?" (
    echo Uso: cutter.cmd [--input <archivo>] [--output <archivo>] [--ext <formato>] [--clean] ^
                         [--factor <multiplicador>] [--aspect <relacion>] [--shape <forma>]
    echo Opciones:
    echo   --input    Especifica el archivo de entrada. (Por defecto: .\input)
    echo   --output   Nombre base del archivo de salida. (Por defecto: .\archivo_recortado)
    echo   --ext      Formato de salida. (Por defecto: png)
    echo   --clean    Elimina archivos temporales creados.
    echo   --factor   Multiplicador para el tamaño de salida (e.g., 0.5 para 256px, 2 para 1024px).
    echo   --aspect   Relacion de aspecto (e.g., 1:1, 3:4, 16:9).
    echo   --shape    Forma para recortar (circle, square, rectangle, squircle).
    exit /b 0
)

REM Procesar argumentos
:args
:next_arg
if "%~1"=="" goto validate_input
if "%~1"=="--input" set INPUT=%2 & shift & shift & goto next_arg
if "%~1"=="--output" set OUTPUT=%2 & shift & shift & goto next_arg
if "%~1"=="--ext" set EXT=%2 & shift & shift & goto next_arg
if "%~1"=="--clean" set CLEAN=true & shift & goto next_arg
if "%~1"=="--factor" set RESIZE_FACTOR=%2 & shift & shift & goto next_arg
if "%~1"=="--aspect" set ASPECT=%2 & shift & shift & goto next_arg
if "%~1"=="--shape" set SHAPE=%2 & shift & shift & goto next_arg
echo ❌ Opcion desconocida: %1
goto show_help

REM Validar archivo de entrada
:validate_input
if not exist "%INPUT%" (
    echo ❌ El archivo de entrada "%INPUT%" no existe.
    exit /b 1
)

REM Calcular dimensiones segun relacion de aspecto
for /f "tokens=1,2 delims=:" %%a in ("%ASPECT%") do (
    set /a ASPECT_WIDTH=%%a
    set /a ASPECT_HEIGHT=%%b
)
set /a BASE_SIZE=512 * RESIZE_FACTOR
set /a WIDTH=%BASE_SIZE%
set /a HEIGHT=%WIDTH% * %ASPECT_HEIGHT% / %ASPECT_WIDTH%

REM Crear archivo SVG temporal
set SVG_PATH=clip.svg
set FINAL_OUTPUT=%OUTPUT%.%EXT%
(
    echo ^<svg width="%WIDTH%" height="%HEIGHT%" xmlns="http://www.w3.org/2000/svg"^>
    echo     ^<defs^>^<clipPath id="customShape"^>
    if "%SHAPE%"=="circle" (
        echo         ^<circle cx="^%WIDTH%/2^" cy="^%HEIGHT%/2^" r="^%WIDTH%/2^" /^>
    ) else if "%SHAPE%"=="square" (
        echo         ^<rect x="0" y="0" width="%WIDTH%" height="%WIDTH%" /^>
    ) else if "%SHAPE%"=="rectangle" (
        echo         ^<rect x="0" y="0" width="%WIDTH%" height="%HEIGHT%" /^>
    ) else if "%SHAPE%"=="squircle" (
        echo         ^<path d="M31.47 31.47 q230.53-62.94 449.06 0 q62.94 230.53 0 449.06 q-230.53 62.94-449.06 0 q-62.94-230.53 0-449.06" /^>
    ) else (
        echo ❌ Forma desconocida: %SHAPE%
        goto show_help
    )
    echo     ^</clipPath^>^</defs^>
    echo ^</svg^>
) > "%SVG_PATH%"

REM Exportar archivo usando Inkscape
echo ✏️ Exportando %FINAL_OUTPUT% usando Inkscape...
inkscape "%SVG_PATH%" --export-filename="%FINAL_OUTPUT%" --export-type="%EXT%" ^
    --export-width=%WIDTH% --export-height=%HEIGHT%

REM Eliminar SVG temporal
del /f "%SVG_PATH%"
if "%CLEAN%"=="true" del /f "%INPUT%"

echo ✅ Proceso finalizado. Archivo generado: %FINAL_OUTPUT%
exit /b 0

