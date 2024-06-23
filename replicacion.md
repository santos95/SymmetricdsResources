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

#### 1 verificar que se encuentra instalado java 
java -version 

### CONFIGURAR EL AMBIENTE MAESTRO
### 2 ingresar a la consola de postgres para crear o utilizar la base de datos donde se va a crear el esquema para symmetric
sudo psql -U postgres -W -h 127.0.0.1

### 3 crear la base de datos - PARA N
CREATE DATABASE replicacion WITH OWNER = postgres ENCODING='UTF-8';

\l - para listar bases de datos
\c replicacion - usar la base de datos especificada

### 4 crear el esquema 
CREATE SCHEMA symmetricds 

### 5 crea el usuario para symmetric 
CREATE USER symmetric_user LOGIN SUPERUSER ENCRYPTED PASSWORD '123456'; 

### 6 alter para que el usuario por defecto use el esquema symmetric
ALTER USER symmetric_user SET search_path TO symmetricds;


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





    

