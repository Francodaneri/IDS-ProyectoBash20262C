echo "Corriendo------"
if [ ! -f "$HOME/EPNro1/Salida/$FILENAME.txt" ]; then
    echo "Archivo $FILENAME.txt no encontrado. Creando archivo..."
    touch "$HOME/EPNro1/Salida/$FILENAME.txt"
    echo "Archivo $FILENAME.txt creado con éxito."
fi
while true; do
    echo "El proceso de consolidación está activo."
    sleep 5 #Simula un trabajo que se ejecuta cada 5 segundos 
done