#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./backup.sh local_db_password remote_db_password"
else
    
    mysqladmin -uroot -p$1 -f drop trip2
    mysqladmin -uroot -p$1 create trip2

    ssh root@trip.ee "mysqldump -uroot -p$2 trip2 | gzip > /var/www/backup/trip2.sql.gz"
    scp root@trip.ee:/var/www/backup/trip2.sql.gz /var/www/backup/.
    gunzip -c /var/www/backup/trip2.sql.gz | mysql -uroot -p$1 trip2
    rm /var/www/backup/trip2.sql.gz

fi

