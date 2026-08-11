# Docker + ESP-IDF (Configuración Automatizada)

El proyecto usa **Docker** para ejecutar ESP-IDF. Asume que Docker está instalado.

## Configuración

`docker-compose.yml` define un contenedor con:
- **Imagen**: `espressif/idf:v5.2` (oficial de Espressif)
- **Volumen**: Código compartido en `/workspace`
- **Dispositivos**: Acceso a `/dev/ttyUSB0` para carga

## Uso (con Makefile)

```bash
# Compilar Fase 0
make compilef00

# Detectar puertos USB
make ports

# Cargar firmware
make uploadf00 PORT=/dev/ttyUSB0

# Monitor serial en tiempo real
make monitorf00
```

## Comandos Docker Directos

Si necesitas más control o debugging:

```bash
# Compilar Fase 0 directamente
docker-compose run --rm esp-idf bash -c "cd esp32/00_led && idf.py build"

# Cargar firmware
docker-compose run --rm esp-idf esptool.py \
  -p /dev/ttyUSB0 \
  -b 921600 \
  flash

# Shell interactivo en el contenedor
docker-compose run --rm esp-idf bash

# Ver logs del contenedor
docker-compose logs -f esp-idf
```

## Troubleshooting

| Error | Causa | Solución |
|-------|-------|----------|
| "Cannot connect to port /dev/ttyUSB0" | Permiso denegado | `sudo usermod -a -G dialout $USER` (Linux) |
| "docker: command not found" | Docker no instalado | Instala Docker y docker-compose |
| "Descarga lenta de imagen" | Primera ejecución (~1.2GB) | Conexión normal es de 5-10 min |
| "idf.py: command not found" | Fallo del contenedor | Revisa `docker-compose logs` |

## Permisos USB (Linux)

Si tienes problemas de acceso a USB:

```bash
# Agregar usuario al grupo dialout
sudo usermod -a -G dialout $USER

# Agregar usuario al grupo docker (opcional)
sudo usermod -a -G docker $USER

# Aplicar cambios (reinicia sesión o ejecuta):
newgrp dialout
```

## Limpiar

```bash
# Detener y remover contenedores
docker-compose down

# Eliminar imagen (descargará de nuevo si se usa)
docker rmi espressif/idf:v5.2

# Limpiar compilaciones locales
make clean
```

## Estructura del docker-compose.yml

```yaml
services:
  esp-idf:
    image: espressif/idf:v5.2        # Imagen oficial
    working_dir: /workspace          # Directorio de trabajo
    volumes:
      - .:/workspace                 # Código compartido (host → contenedor)
      - /dev:/dev                    # Acceso a dispositivos USB
    devices:
      - /dev/ttyUSB0:/dev/ttyUSB0   # Puerto USB específico
    privileged: true                 # Acceso total a puertos
```

## Referencias

- [Imagen ESP-IDF en Docker Hub](https://hub.docker.com/r/espressif/idf)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
