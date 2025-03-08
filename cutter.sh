#!/bin/bash

# Variables por defecto
INPUT="./input"  # Archivo predeterminado en modo automático
OUTPUT="./archivo_recortado"  # Nombre base del archivo de salida
EXT="png"  # Formato de salida por defecto
CLEAN=false
RESIZE_FACTOR=1  # Factor por defecto (1: 512px)
ASPECT="1:1"  # Relación de aspecto predeterminada
SHAPE="squircle"  # Forma predeterminada (squircle)

# Función para mostrar ayuda
function show_help() {
    echo "Uso: $0 [--input <archivo>] [--output <archivo>] [--ext <formato>] [--clean]"
    echo "          [--factor <multiplicador>] [--aspect <relación>] [--shape <forma>]"
    echo ""
    echo "Opciones:"
    echo "  --input    Especifica el archivo de entrada. (Por defecto: './input' si no se indica)"
    echo "  --output   Nombre base del archivo de salida. (Por defecto: './archivo_recortado')"
    echo "  --ext      Formato de salida. (Por defecto: png)"
    echo "  --clean    Elimina archivos temporales o intermedios creados."
    echo "  --factor   Multiplicador para el tamaño de salida (e.g., 0.5 para 256px, 2 para 1024px)."
    echo "  --aspect   Relación de aspecto (e.g., 1:1, 3:4, 16:9, etc.)."
    echo "  --shape    Forma del path (circle, square, rectangle, squircle)."
    echo ""
    echo "Si se ejecuta sin argumentos, usa el archivo './input' como entrada predeterminada."
    exit 1
}

# Procesar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            INPUT="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --ext)
            EXT="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --factor)
            RESIZE_FACTOR="$2"
            shift 2
            ;;
        --aspect)
            ASPECT="$2"
            shift 2
            ;;
        --shape)
            SHAPE="$2"
            shift 2
            ;;
        *)
            echo "❌ Opción desconocida: $1"
            show_help
            ;;
    esac
done

# Verificar entrada predeterminada si no se especifica input
if [[ -z "$INPUT" && -f "./input" ]]; then
    echo "ℹ️ No se proporcionó --input. Usando archivo predeterminado './input'."
    INPUT="./input"
fi

# Validar la existencia del archivo de entrada
if [[ ! -f "$INPUT" ]]; then
    echo "❌ El archivo de entrada '$INPUT' no existe."
    exit 1
fi

# Calcular dimensiones según la relación de aspecto
IFS=":" read -r ASPECT_WIDTH ASPECT_HEIGHT <<< "$ASPECT"
ASPECT_RATIO=$(echo "$ASPECT_WIDTH / $ASPECT_HEIGHT" | bc -l)

# Calcular dimensiones finales ajustadas al factor y relación de aspecto
BASE_SIZE=$(echo "512 * $RESIZE_FACTOR" | bc)
WIDTH=$(echo "$BASE_SIZE" | bc)
HEIGHT=$(echo "$WIDTH / $ASPECT_RATIO" | bc)
WIDTH=${WIDTH%.*}  # Convertir a entero
HEIGHT=${HEIGHT%.*}  # Convertir a entero
echo "📏 Dimensiones ajustadas: ${WIDTH}x${HEIGHT}px (Aspecto: $ASPECT, Factor: $RESIZE_FACTOR)"

# Crear un archivo SVG con dimensiones ajustadas
SVG_PATH="./clip.svg"
FINAL_OUTPUT="${OUTPUT}.${EXT}"
case $SHAPE in
    circle)
        PATH_DATA='<circle cx="'$(($WIDTH / 2))'" cy="'$(($HEIGHT / 2))'" r="'$(($WIDTH / 2))'"/>'
        ;;
    square)
        PATH_DATA='<rect x="0" y="0" width="'$WIDTH'" height="'$WIDTH'"/>'
        ;;
    rectangle)
        PATH_DATA='<rect x="0" y="0" width="'$WIDTH'" height="'$HEIGHT'"/>'
        ;;
    squircle)
        PATH_DATA='<path d="M31.47 31.47 q230.53-62.94 449.06 0 q62.94 230.53 0 449.06 q-230.53 62.94-449.06 0 q-62.94-230.53 0-449.06"/>'
        ;;
    *)
        echo "❌ Forma desconocida: $SHAPE"
        show_help
        ;;
esac

echo '<svg width="'$WIDTH'" height="'$HEIGHT'" viewBox="0 0 '$WIDTH' '$HEIGHT'" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <clipPath id="customShape">
            '"$PATH_DATA"'
        </clipPath>
    </defs>
    <image x="0" y="0" width="'$WIDTH'" height="'$HEIGHT'" xlink:href="'"$INPUT"'" clip-path="url(#customShape)"/>
</svg>' > "$SVG_PATH"

# Exportar el archivo con las dimensiones ajustadas
echo "✏️ Exportando $FINAL_OUTPUT usando Inkscape..."
inkscape "$SVG_PATH" --export-filename="$FINAL_OUTPUT" --export-type="$EXT" --export-width="$WIDTH" --export-height="$HEIGHT"

echo "✅ Imagen exportada: $FINAL_OUTPUT"

# Eliminar el archivo SVG temporal
rm -f "$SVG_PATH"
echo "🧹 Archivo temporal eliminado: $SVG_PATH"

# Eliminar el archivo de entrada convertido si CLEAN está habilitado
if $CLEAN && [[ "$INPUT" != "$FINAL_OUTPUT" ]]; then
    rm -f "$INPUT"
    echo "🧹 Archivo temporal eliminado: $INPUT"
fi

echo "✅ Proceso finalizado."

