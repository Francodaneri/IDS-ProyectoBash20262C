#!/bin/bash
if [ -n "$1" ]; then
    export FILENAME="$1"
elif [ -z "$FILENAME" ]; then
    export FILENAME="archivoSalida.txt"
fi

menuOpen=true;

while $menuOpen; do
    clear
    echo "========================================="
    echo "             MENÚ DE CONTROL             "
    echo "========================================="
    echo " 1) Crear entornos"
    echo " 2) Correr proceso"
    echo " 3) Mostrar alumnos"
    echo " 4) Mostrar 10 notas más altas"
    echo " 5) Buscar alumno por padrón"
    echo " 6) Visualizar log"
    echo " 7) Salir del menú (-d para borrar entorno)"
    echo " 8) Detener proceso de escucha"
    echo " 9) Verificar estado del proceso"
    echo "========================================="
    read -r -p "Seleccione una opción [1-9]: " entrada

    # Separar la opción y el parámetro (si existe)
    opcion=$(echo "$entrada" | awk '{print $1}')
    parametro=$(echo "$entrada" | awk '{print $2}')

    case $opcion in
        1)
            clear
            if [ -d "$HOME/EPNro1" ]; then
                echo "El entorno ya existe. No se puede crear nuevamente."
            else
                echo "Creando entorno..."
                mkdir "$HOME/EPNro1"
                mkdir "$HOME/EPNro1/Salida"
                mkdir "$HOME/EPNro1/Entrada"
                mkdir "$HOME/EPNro1/Procesando"
                echo "Entorno creado con éxito."
            fi
            read -p "Presione [Enter] para continuar..."
            ;;
        2)
            clear
            if [ ! -d "$HOME/EPNro1" ]; then
                echo "El entorno no existe."
            else
                if pgrep -f "consolidar.sh" > /dev/null; then
                    echo "¡El proceso ya se encuentra ejecutándose!"
                else
                    echo "Iniciando proceso en segundo plano..."
                    nohup ./consolidar.sh > /dev/null 2>&1 &
                    echo "Proceso iniciado con éxito."
                fi
            fi
            read -p "Presione [Enter] para continuar..."
            ;;
        3)
            clear
            echo "Mostrando alumnos... <IMPLEMENTAR>"
            read -p "Presione [Enter] para continuar..."
            ;;
        4)
            clear
            echo "Mostrando 10 notas más altas... <IMPLEMENTAR>"
            read -p "Presione [Enter] para continuar..."
            ;;
        5)
            clear
            read -p "Ingrese el padrón del alumno a buscar: " padron
            echo "Mostrando información del alumno con padrón $padron... <IMPLEMENTAR>"
            read -p "Presione [Enter] para continuar..."
            ;;
        6)
            clear 
            echo "Visualizando log... <IMPLEMENTAR>"
            read -p "Presione [Enter] para continuar..."  
            ;;
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
        8)
            clear
            if pgrep -f "consolidar.sh" > /dev/null; then
                echo "Deteniendo el proceso..."
                pkill -f "consolidar.sh"
                echo "Proceso detenido."
            else
                echo "No hay ningún proceso de escucha en ejecución."
            fi
            read -p "Presione [Enter] para continuar..."
            ;;
        9)
            clear
            echo "Verificando el estado del sistema..."
            # pgrep -f busca el script por su nombre y -l muestra también el PID
            PID=$(pgrep -f "consolidar.sh")
            
            if [ -n "$PID" ]; then
                echo "-----------------------------------------"
                echo " STATUS: [ EJECUTÁNDOSE ]"
                echo " PID(s) asignado(s): $PID"
                echo "-----------------------------------------"
            else
                echo "-----------------------------------------"
                echo " STATUS: [ DETENIDO / APAGADO ]"
                echo "-----------------------------------------"
            fi
            read -p "Presione [Enter] para continuar..."
            ;;
        
        *)
            echo "Opción inválida."
            sleep 1
            ;;
    esac
done
exit 0
