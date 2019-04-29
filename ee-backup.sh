
#!/bin/bash

BACKUP_LOCATION=/opt/backup
RCLONE_REMOTE_NAME=wasabi
RCLONE_REMOTE_BUCKET=studersolutions
RCLONE_REMOTE_PATH=backups/ee/
RCLONE_TO_REMOTE_STORAGE=true
DELETE_LOCAL_BACKUPS=true

DATE=`date +"%Y-%m-%d"`

for SITE in $(ls /opt/easyengine/sites/);
do
echo
echo Backing up $SITE
echo
mkdir -p $BACKUP_LOCATION/$SITE/$DATE
ee shell $SITE --command='wp db export'
mv /opt/easyengine/sites/$SITE/app/htdocs/*.sql /opt/backup/$SITE/$DATE/$SITE.sql
tar -czvf $BACKUP_LOCATION/$SITE/$DATE/wp-content.tar.gz /opt/easyengine/sites/$SITE/app/htdocs/wp-content/
echo
ls $BACKUP_LOCATION/$SITE/$DATE
done
echo
if [ "$RCLONE_TO_REMOTE_STORAGE" == "true" ]
then
echo
echo Sending Backup to Remote Storage - $RCLONE_REMOTE_NAME
rclone copy -v $BACKUP_LOCATION $RCLONE_REMOTE_NAME:$RCLONE_REMOTE_BUCKET/$RCLONE_REMOTE_PATH
echo
fi
if [ "$DELETE_LOCAL_BACKUPS" == "true" ]
then
echo "Removing Local Backups.."
rm -r $BACKUP_LOCATION/*
fi
echo
echo "Backup Complete!"
echo
