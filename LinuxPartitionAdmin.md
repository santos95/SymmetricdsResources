## PARTED 
### to open the parted shell - to write commands to manage hard drives partitions
    sudo parted 

### driver disk are named sequentaly 
    /dev/sda /dev/sdb

### help
    help

### print devices
    print devices

### out 
    quit

### to select a device to work to it
    sudo parted select /dev/sdb

### print partitions - to see info about the disk partitions.
    print partitions

### print devices
    print devices

### to delete a partition - delete the indicated partition of the disk 
    rm [number as name]

### to delete all the partitions - create a new partition table on the disk - all the data on that disk will be lost
    mklabel 
    gpt 
    confirm

### make a partition - on gpt all the partitions are primary types
    mkpart partition-type filesystem start end
    mkpart primary ext4 0 50000
    mkpart primary ext4 2048s 50000
    mkpart primary ext4 0% 70%

### give a partition with a name 
    name partition-number name
    name 1 backup 

### using parted from bash
    sudo parted /dev/sdb print partitions


### types of file system
    ext4 - the most common actually 

### TO partionate a disk
    select /dev/sdb
    print partitions
    mklabel - gpt - confirm
    mkpart primary ext4 2048s 50000
    name 1 backup 

