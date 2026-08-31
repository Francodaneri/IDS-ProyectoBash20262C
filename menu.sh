#!/bin/bash
if [ -n "$1" ]; then
    export FILENAME="$1"
elif [ -z "$FILENAME" ]; then
    export FILENAME="archivoSalida.txt"
fi


#PRE: -
#POST: SI NO EXISTE -> consolidar.sh creara uno nuevo.
function crear_consolidar_sh {
    ruta_script="$HOME/EPNro1/consolidar.sh"
    #Existe consolidar.sh?
    if [ -f "$ruta_script" ]; then
        return 0
    else 
        echo "-------------------------------------------------------------"
        echo " Detectando falta de consolidar.sh..."
        echo " Generando script de fondo..."
    
    #                              consolidar.sh                                  #
    #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/#
    cat << 'EOF' > "$ruta_script"
#!/bin/bash
        
# Creo el archivo de log
LOG="$HOME/EPNro1/procesado.log"

        while true; do
            # Buscar el archivo de salida dinámico creado por el menú
            archivo_salida=$(ls "$HOME/EPNro1/Salida/$FILENAME" 2>/dev/null)

            # Solo procesamos la entrada si el archivo de salida ya existe
            if [[ -f "$archivo_salida" ]]; then
                for archivo_txt_entrada in "$HOME/EPNro1/Entrada"/*.txt; do
                # Verificamos que sea un archivo real (por si la carpeta está vacía)
                    if [[ -f "$archivo_txt_entrada" ]]; then
                        if [[ -s "$archivo_salida" ]]; then
                            ultimo_char=$(tail -c 1 "$archivo_salida")
                            if [[ "$ultimo_char" != $'\n' ]]; then
                                echo "" >> "$archivo_salida"
                            fi
                        fi
                        cat "$archivo_txt_entrada" >> "$archivo_salida"
                        ultimo_char_entrada=$(tail -c 1 "$archivo_salida")
                        if [[ "$ultimo_char_entrada" != $'\n' ]]; then
                            echo "" >> "$archivo_salida"
                        fi
                        grep -v '^$' "$archivo_salida" > "$archivo_salida.tmp"
                        mv "$archivo_salida.tmp" "$archivo_salida"
                        # Registro el procesamiento en el log
                        echo "$(date '+%d/%m/%Y %H:%M:%S') - Fue procesado el archivo $(basename "$archivo_txt_entrada")" >> "$LOG"
                
                        mv "$archivo_txt_entrada" "$HOME/EPNro1/Procesando"
                    fi 
                done
            fi
            sleep 3
        done
EOF
    #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/#
    chmod +x "$ruta_script"
    echo " Script consolidar.sh creado correctamente."
    echo "-------------------------------------------------------------"
    fi
}

#PRE: -
#POST: Chequeara todos los diretorios, si estan faltantes los crea.
function directorio_funcional {
    # Si falta EPNro1 lo creara y todos los sub-directorios (Entrada, Procesando, Salida)
    if [ ! -d "$HOME/EPNro1" ]; then
        echo "Todos los directorios estan faltantes:"
        echo " Directorio principal:"
        echo "  home/EPNro1"
        echo " Directorios secundarios:"
        echo "  home/EPNro1/Procesando"
        echo "  home/EPNro1/Entrada"
        echo "  home/EPNro1/Salida"
        echo " Creando directorio..."
        mkdir "$HOME/EPNro1"
        mkdir "$HOME/EPNro1/Entrada"
        mkdir "$HOME/EPNro1/Procesando"
        mkdir "$HOME/EPNro1/Salida"
        touch "$HOME/EPNro1/Salida/$FILENAME"
        echo " Directorio creado correctamente."
        echo "-------------------------------------------------------------"
    fi
    # Si falta Entrada lo crea
    if [ ! -d "$HOME/EPNro1/Entrada" ]; then
        echo "Directorio faltante detectado:"
        echo " home/EPNro1/Entrada"
        echo " Creando directorio..."
        mkdir "$HOME/EPNro1/Entrada"
        echo " Directorio creado correctamente."
        echo "-------------------------------------------------------------"
    fi
    # Si falta Procesando lo crea
    if [ ! -d "$HOME/EPNro1/Procesando" ]; then
        echo "Directorio faltante detectado:"
        echo " home/EPNro1/Procesando"
        echo " Creando directorio..."
        mkdir "$HOME/EPNro1/Procesando"
        echo " Directorio creado correctamente."
        echo "-------------------------------------------------------------"
    fi
    # Si falta Salida lo crea
    if [ ! -d "$HOME/EPNro1/Salida" ]; then
        echo "Directorio faltante detectado:"
        echo " home/EPNro1/Salida"
        echo " Creando directorio..."
        mkdir "$HOME/EPNro1/Salida"
        echo " Directorio creado correctamente."
        echo "-------------------------------------------------------------"
        touch "$HOME/EPNro1/Salida/$FILENAME"
    fi
        return 0
}

#PRE: -
#POST: Chequea el archivo de salida, (EXISTE o ESTA VACIO?) y arregla los posibles casos.
function salida_funcional {
    archivo_salida=$(ls "$HOME/EPNro1/Salida/$FILENAME" 2>/dev/null)
    # Si no existe el archivo de salida lo creara.
    if [[ ! -f "$archivo_salida" ]]; then
        echo "No existe ningun archivo en la salida"
        read -r -p "¿Como quiere llamar al archivo de salida (sin el .txt)? " FILENAME
        echo "Creando archivo en la salida..."
        touch "$HOME/EPNro1/Salida/$FILENAME"
        archivo_salida=$(ls "$HOME/EPNro1/Salida/$FILENAME" 2>/dev/null)
        echo "-------------------------------------------------------------"
        return 1 
    fi
    #Da tiempo al consolidar.sh para procesar, esto evita casos falsos de archivo vacio.
        echo "Espere porfavor..."
        sleep 2
    # si el archivo de salida esta vacio entraremos al SUBMENU
    if [[ -s "$archivo_salida" ]]; then
        return 0
    else
        submenuOpen=true;
        status=0;
        #                                  SUBMENU                                    #
        #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/#
        while $submenuOpen; do
            clear
            #                        SUBMENU INTERFAS                          #
            #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-#
            echo "============================================================="
            echo " ATENCIÓN: El archivo de salida está vacío."
            echo "============================================================="
            echo " 1) No subí los archivos necesarios a la Entrada"
            echo " 2) No estoy corriendo el procesador (consolidar.sh)"
            echo " 3) Volver al menú principal"
            echo "============================================================="
            read -r -p "Seleccione una opción [1-3]: " sub_entrada
            #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-#

            #Procesamiento de la entrada
            case $sub_entrada in
                # CASO: 1) No subio los archivos necesarios a la Entrada
                1)
                    echo " SIGA LAS INSTRUCCIONES:"
                    echo "  1- Vuelva al menu"
                    echo "  2- Asegurese de tener el directorio creado"
                    echo "  3- Ponga sus archivos para leer en:"
                    echo "     $HOME/EPNro1/Entrada"
                    echo "-------------------------------------------------------------"
                    read -p "Presione [Enter] cuando haya terminado de subirlos..."
                    ;;
                #CASO: 2) No esta corriendo el procesador (consolidar.sh)
                2)
                    echo " solucionaremos su problema en breve..."
                    crear_consolidar_sh
                    echo " Iniciando consolidar.sh en segundo plano..."
                    nohup "$HOME/EPNro1/consolidar.sh" > /dev/null 2>&1 &
                    echo " Proceso iniciado correctamente."
                    echo "-------------------------------------------------------------"
                    read -p "Presione [Enter] para continuar..."
                    ;;
                #Vuelve al menu principal
                3)
                    submenuOpen=false
                    status=1
                    ;;
                #CASO: invalido
                *)
                    echo "Opción inválida."
                    sleep 1
                    ;;
            esac
        done
        #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/#
    fi
    return $status
}

function consolidar_status {
    # Busca el PID de consolidar.sh
    PID=$(pgrep -f "consolidar.sh")
    if [ -n "$PID" ]; then
        echo "-------------------------------------------------------------"
        echo "  STATUS PROCESO: [ EJECUTÁNDOSE ]"
        echo "  PID(s) asignado(s): $PID"
        echo "-------------------------------------------------------------"
        return 0
    else
        echo "-------------------------------------------------------------"
        echo "  STATUS PROCESO: [ DETENIDO / APAGADO ]"
        echo "-------------------------------------------------------------"
        return 1
    fi
}
archivo_salida="$HOME/EPNro1/Salida/$FILENAME";
menuOpen=true;
sortChar=";";
#                                     MENU                                    #
#/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/#
while $menuOpen; do
    clear
        #                          MENU INTERFAZ                           #
        #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-#
        echo "============================================================="
        echo "                       MENÚ DE CONTROL                       "
        echo "============================================================="
        echo " 1) Crear/Chequear entornos"
        echo " 2) Correr/Chequear el proceso consolidar.sh"
        echo " 3) Mostrar alumnos"
        echo " 4) Mostrar 10 notas más altas"
        echo " 5) Buscar alumno por padrón"
        echo " 6) Visualizar log"
        echo " 7) Salir del menú (agrege -d para borrar entorno)"
        echo " 8) Detener proceso de escucha"
        echo " 9) Verificar TODO el estado del sistema"
        echo "==================================================="
        read -r -p "Seleccione una opción [1-9]: " entrada
        #/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-#

    # Separar la opción y el parámetro (si existe)
    opcion=$(echo "$entrada" | awk '{print $1}')
    parametro=$(echo "$entrada" | awk '{print $2}')

    #Procesamiento de la entrada
    case $opcion in
        # CASO: 1) Crea/Chequea entornos
        1)
            clear
                if directorio_funcional; then
                    echo "Entorno creado con éxito."
                    read -p "Presione [Enter] para continuar..."
                fi
            ;;
        # CASO: 2) Corre/Chequea el proceso consolidar.sh
        2)
            clear
                    echo "Verificando el estado actual del proceso..."
                    crear_consolidar_sh
                    if consolidar_status; then
                        echo " No es necesario iniciar. ¡El proceso ya se encuentra en ejecución!"
                    else
                        echo " Iniciando proceso en segundo plano..."
                        nohup "$HOME/EPNro1/consolidar.sh" > /dev/null 2>&1 &
                        echo " Proceso iniciado con éxito."
                    fi
            read -p "Presione [Enter] para continuar..."
            ;;
        # CASO: 3) Muestra alumnos en la salida
        3)
            clear
                if salida_funcional; then
                    echo "Mostrando alumnos..."
                    echo ""
                    sort -t "$sortChar" -k1 -nr "$archivo_salida"
                    echo ""
                fi
                read -p "Presione [Enter] para continuar..."
            ;;
        # CASO: 4) Muestra las 10 notas mas altas en la salida
        4)
            clear
                if salida_funcional; then
                    echo "Mostrando los 10 mejores alumnos..."
                    echo ""
                    (sort -t "$sortChar" -k5 -nr "$archivo_salida") | (head -n 10)
                    echo ""
                fi
                read -p "Presione [Enter] para continuar..."
            ;;
        # CASO: 5) Busca alumno por padrón en la salida
        5)
            clear
                if salida_funcional; then
                    read -p "Ingrese el padrón del alumno a buscar: " padron
                    echo ""
                    grep $padron "$archivo_salida"
                    e=$?
                    if [[ $e -eq 1 ]]; then
                        echo "No existe alumno con ese padron"
                    fi
                    echo ""
                fi
                read -p "Presione [Enter] para continuar..."
            ;;
        # CASO: 6) Visualizar log
        6)
            clear 
                echo "============================================================="
                echo "			  LOG DE PROCESAMIENTO"
                echo "============================================================="
                if [[ -f "$HOME/EPNro1/procesado.log" ]]; then
                	cat "$HOME/EPNro1/procesado.log"
                else
                	echo "Todavia no hay archivos procesados."
                fi
                
                echo "============================================================="
                read -p "Presione [Enter] para continuar..."  
            ;;

        # CASO: 7) Sale del menú Y con -d borra todos los entornos
        7)
            clear
                if [[ "$parametro" == "-d" ]]; then
                    echo "Parámetro '-d' detectado: Borrando el entorno..."
                    pkill -f "consolidar.sh"
                    rm -rf "$HOME/EPNro1"
                    echo "Entorno borrado con éxito."
                fi
                echo "Saliendo del menú. Los procesos en background seguirán activos."
                read -p "Presione [Enter] para salir..."
                menuOpen=false
            ;;
        # CASO: 8) Detiene el proceso de escucha (consolidar.sh)
        8)
            clear
                echo "Verificando el estado actual del proceso..."
                crear_consolidar_sh
                if consolidar_status; then
                    echo " Deteniendo el proceso de escucha..."
                    pkill -f "consolidar.sh"
                    echo " Proceso detenido con éxito."
                else
                    echo " No se requiere acción. No hay ningún proceso en ejecución."
                fi
                read -p "Presione [Enter] para continuar..."
            ;;
        # CASO: 9) Verifica TODO el estado del sistema
        9)
            clear
                echo "Verificando el estado del sistema..."
                echo "============================================================="
                echo " Verificando el directorio..."
                    if directorio_funcional; then
                        echo "  Directorio funcional"
                    fi
                echo "-------------------------------------------------------------"
                echo " Verificando la salida..."
                    if salida_funcional; then
                        echo "  Salida funcional"
                    else
                        echo "  ATENCIÓN!!!!!!: el archivo de salida esta vacio."
                    fi
                echo "-------------------------------------------------------------"
                echo " Verificando proceso en segundo plano..."
                    crear_consolidar_sh
                    if ! consolidar_status; then
                        echo " Arrancando consolidar.sh automáticamente..."
                        nohup "$HOME/EPNro1/consolidar.sh" > /dev/null 2>&1 &
                        echo "  Proceso funcional"
                    fi
                echo "-------------------------------------------------------------"
                echo " Todo funciona correctamente"
                read -p "  Presione [Enter] para continuar..."
            ;;
        *)
            echo "Opción inválida."
            sleep 1
            ;;
    esac
done
exit 0
