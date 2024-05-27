## INSTALAR SYMMETRIC  

### DESCARGAR E INSTALAR SYMMETRICDS
    https://symmetricds.org/

### COPY THE ZIP FILE INTO THE SERVER AND UNZIP
    unzip symmetric.zip

### MOVE THE UNZIP FOLDER INTO /opt/symmetricds
    sudo mv symmetric-server-3.9.15 /opt/symmetricds

### AT THIS POINT ALL THE NECCESARY FILES ARE IN THE SERVER 

### install java 
    sudo apt install openjdk-11-jdk

### CHECK THE JAVA INSTALATION
    java -version

### INSTAL SYMMTRIC AS A DAEMON
    ./sym_service install

### PREPARE THE ENVIROMENT FOR REPLICATION - FOR POSTGRES
    sudo psql -U postgres -w -h 127.0.0.1


## CONFIGURE AND ADD MASTER NODE - WE CONFIGURE THE MASTER AND OTHER REQUIRED NODES/ENGINES
    cd /opt/symmetricds/engines

### CREATE MASTER NODE - NODES HAVE THE .properties extension
    touch master.properties 

### CONFIGURE THE MASTER NODE ENGINE
    engine.name=publicador
    external.id=publicador
    group.id=publicador -- como es el primer nodo crea un grupo llamado publicador al crear el servicio
    syn.url=  --utiliza el ip debido a que no tiene dom - symetric utiliza por defecto el puerto 31415
    syn.url=http://192.160.0.15:31415/sync/$(engineName) --utiliza una variable de entorno
    registration-url=  --vacio indicando que se trata del maestro

    db.url=jdbc:postgresql://localhost:5232/replicacion
    db.driver=org.postgresql.Driver
    db.user=symmetric_user
    db.password=123456

    auto.reload=true - para la recarga de info - no es neceario en todos los maestros





    

