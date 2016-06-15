#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./update_db.sh local_db_password remote_db_password"
else
    
    mysqladmin -uroot -p$1 -f drop trip
    mysqladmin -uroot -p$1 -f drop trip2

    mysqladmin -uroot -p$1 create trip
    mysqladmin -uroot -p$1 create trip2

    ssh root@46.101.120.198 "mysqldump -uroot -p$2 trip | gzip > /var/www/backup/trip.sql.gz"

    scp root@trip.ee:/var/www/backup/trip.sql.gz /var/www/backup/.
    scp root@trip.ee:/var/www/backup/trip2.sql.gz /var/www/backup/.

    gunzip -c /var/www/backup/trip.sql.gz | mysql -uroot -p$1 trip
    gunzip -c /var/www/backup/trip2.sql.gz | mysql -uroot -p$1 trip2
    
fi

