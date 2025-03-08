# cutter.sh

**Recortar y Exportar Imágenes con Formas Personalizadas**

Este script en Bash permite recortar imágenes en formas personalizables (círculo, cuadrado, rectángulo o squircle), ajustando tamaño y relación de aspecto según parámetros proporcionados. Utiliza **Inkscape** para exportar en varios formatos y permite limpieza automática de archivos temporales. Ideal para automatizar tareas de edición.

---

## Características principales

- Configuración flexible de entrada y salida de archivos.
- Soporte para múltiples formatos de imagen (predeterminado: PNG).
- Ajuste de tamaño mediante un factor de escala.
- Relación de aspecto personalizable (e.g., 1:1, 16:9, 3:4, etc.).
- Selección de formas geométricas para el recorte (`circle`, `square`, `rectangle`, `squircle`).
- Opción de limpiar archivos temporales tras la exportación (`--clean`).

---

## Uso

```bash
./script.sh [--input <archivo>] [--output <archivo>] [--ext <formato>] [--clean] \
            [--factor <multiplicador>] [--aspect <relación>] [--shape <forma>]
```

Ejemplo:

```bash
./script.sh --input "imagen.png" --output "resultado" --ext "jpg" \
            --factor 1.5 --aspect 16:9 --shape "circle"
```

---

## Requisitos previos

1. Inkscape: Instalado y accesible desde la línea de comandos.

2. Un archivo de entrada válido especificado con --input o ubicado en la ruta predeterminada (./input).

## Opciones disponibles

| Opción   | Descripción                                                                    |
| -------- | ------------------------------------------------------------------------------ |
| --input  | Ruta del archivo de entrada. Por defecto, utiliza ./input.                     |
| --output | Nombre base del archivo de salida (sin extensión).                             |
| --ext    | Formato del archivo de salida (predeterminado: png).                           |
| --clean  | Limpia archivos temporales tras la exportación.                                |
| --factor | Multiplicador para el tamaño de salida, basado en un tamaño inicial de 512 px. |
| --aspect | Relación de aspecto de la imagen exportada (e.g., 1:1, 3:4, 16:9).             |
| --shape  | Forma geométrica para el recorte (circle, square, rectangle, squircle).        |

## Notas

- Si no se proporcionan argumentos, el script utiliza el archivo ./input y valores predeterminados.

- Asegúrate de que Inkscape esté instalado correctamente para evitar errores durante la exportación.
