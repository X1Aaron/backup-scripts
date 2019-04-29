#!/bin/bash

backup_dir=/opt/backup
remote_service=wasabi
remote_bucket=studersolutions
remote_path=backups/ee/

date=`date +"%Y-%m-%d"`

for site in $(ls /opt/easyengine/sites/);
do
echo
echo Backing up $site
echo
mkdir -p $backup_dir/$site/$date > /dev/null 2>&1
ee shell $site --command='wp db export'
mv /opt/easyengine/sites/$site/app/htdocs/*.sql /opt/backup/$site/$date/$site.sql
tar -czvf $backup_dir/$site/$date/wp-content.tar.gz /opt/easyengine/sites/$site/app/htdocs/wp-content/
echo
ls $backup_dir/$site/$date
done
echo
echo Copying Backups to Remote Storage...
echo
rclone copy -v $backup_dir $remote_service:$remote_bucket/$remote_path
rm -r $backup_dir/*
