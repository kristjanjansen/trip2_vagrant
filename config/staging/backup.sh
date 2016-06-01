#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./backup.sh local_db_password remote_db_password"
else
    
    # Reset staging database

    mysqladmin -uroot -p$1 -f drop trip2
    mysqladmin -uroot -p$1 create trip2

    # Replicate production database to staging database

    ssh root@46.101.120.198 "mysqldump -uroot -p$2 trip2 | gzip > $BACKUP_DIR/trip2.sql.gz"
    scp root@46.101.120.198:/var/www/trip2.sql.gz /var/www/.
    gunzip -c /var/www/trip2.sql.gz | mysql -uroot -p$1 trip2
    
    # Move replicated database to a backup

    mv /var/www/trip2.sql.gz /var/www/trip2--$(date +%F--%R).sql.gz

    # Replicate production images to staging images

    rsync -azP --delete root@46.101.120.198:/var/www/trip2/storage/app/images/ /var/www/trip2/storage/app
    
    # Create image backup

    tar -zcvf /var/www/trip2--$(date +%F--%R).images.gz /var/www/trip2/storage/app/images/original/ > /dev/null

    # We delete db backups older than 2 days
    # We keep 2 * 24 hourly db backups

    find /var/www/*.sql.gz -type f -mtime +2 -delete

    # We delete image backups older than one hour
    # We keep 1 hourly image backup (due to its size)

    find /var/www/*.images.gz -type f -mmin +60 -delete

fi

