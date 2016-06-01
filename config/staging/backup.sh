#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./backup.sh local_db_password remote_db_password"
else
    
    mysqladmin -uroot -p$1 -f drop trip2
    mysqladmin -uroot -p$1 create trip2

    ssh root@46.101.120.198 "mysqldump -uroot -p$2 trip2 | gzip > $BACKUP_DIR/trip2.sql.gz"
    scp root@46.101.120.198:/var/www/trip2.sql.gz /var/www/.
    gunzip -c /var/www/trip2.sql.gz | mysql -uroot -p$1 trip2
    mv /var/www/trip2.sql.gz /var/www/trip2--$(date +%F--%R).sql.gz

    rsync -azP --delete root@46.101.120.198:/var/www/trip2/storage/app/images/ /var/www/trip2/storage/app
    # tar -zcvf /var/www/trip2--$(date +%F--%R).images.gz /var/www/trip2/storage/app/images/original/ > /dev/null

    find /var/www/*.sql.gz -type f -mtime +1 -delete

fi

