#### Disk Usage

> df -h

### Folder size

> du -sh path/to/folder/

### Folder size multiple folders

> du -sh backups/ cache/

###Search for a string

> grep -rnw /pat/to/folder/ -e 'no-cache'

### How to rsync to an AWS server with a PEM

> rsync -rave "ssh -i /path/to/Some-EC2-Staging.pem" . centos@ec10-10-10-10-10.eu-central-1.compute.amazonaws.com:~

### Ubuntu rsync to aws with pem

> rsync -rave "ssh -i /path/to/some.pem" ~/Desktop/aws/* ubuntu@ec2-10-10-10-10.us-east2.compute.amazonaws.com:/path/to/remote/directory
