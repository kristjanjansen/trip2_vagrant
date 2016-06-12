#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./backup.sh local_db_password remote_db_password"
else
    
    echo "Starting backup"

    # Reset staging database

    mysqladmin -uroot -p$1 -f drop trip2
    mysqladmin -uroot -p$1 create trip2

    # Replicate production database to staging database

    ssh root@46.101.120.198 "mysqldump -uroot -p$2 trip2 | gzip > /var/www/backup/trip2.sql.gz"
    scp root@46.101.120.198:/var/www/backup/trip2.sql.gz /var/www/backup/.
    gunzip -c /var/www/backup/trip2.sql.gz | mysql -uroot -p$1 trip2
    
    # Move replicated database to a backup

    mv /var/www/backup/trip2.sql.gz /var/www/backup/trip2--$(date +"%Y-%m-%d--%H-%M").sql.gz

    # We delete db backups older than 2 days
    # We keep 2 * 24 hourly db backups

    find /var/www/backup/*.sql.gz -type f -mtime +2 -delete

    # Replicate production images to staging images

    # rsync -azP root@46.101.120.198:/var/www/trip2/storage/app/images /var/www/trip2/storage/app
    
    # Create image backup

    # tar -zcvf /var/www/trip2--$(date +%F--%R).images.gz /var/www/trip2/storage/app/images/original/ > /dev/null
    # find /var/www/*.images.gz -type f -mmin +60 -delete

    echo "Finishing backup"

fi

