#!/bin/bash
EMAIL_MESSAGE="<h3>Daily Server Report</h3>"

EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE <div>Get the hard drive useage</div>"
DF=$(df -h | grep /dev/xvda1) 
EMAIL_MESSAGE="$EMAIL_MESSAGE $DF"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE Checking for files larger than 50MB"
# Any files larger than 50MB
LARGE_FILES=$(sudo find / -xdev -type f -path /var/lib/mysql -prune -size +50M -exec du -sh {} ';' | sort -rh | head -n50 >> LARGE_FILES)

EMAIL_MESSAGE="$EMAIL_MESSAGE $LARGE_FILES"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE <P>Chinavasion Errors</P>"
# TODO get the user and password from configuration rather than hard code it here
MYSQL_COUNT=`mysql -u yourdbuser -p'yourpassword' yourdbname -e "SELECT  (SELECT COUNT(*) FROM catalog_product_entity ) as catalogTotal,  (SELECT COUNT(*) FROM chinavasion_products ) as importProducts,  (SELECT COUNT(*) FROM chinavasion_errors ) as totalErrors,  (SELECT COUNT(*) FROM url_rewrite ) as URLRewrites;"`

EMAIL_MESSAGE="$EMAIL_MESSAGE $MYSQL_COUNT"

EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"
EMAIL_MESSAGE="$EMAIL_MESSAGE <P>SSL Cert Expirations</P>"
SSL_CERT_1=$(sudo ssl-cert-check -c /etc/letsencrypt/live/www.someurl.com/fullchain.pem)

EMAIL_MESSAGE="$EMAIL_MESSAGE <div>First Cert</div> $SSL_CERT_1"
SSL_CERT_2=$(sudo ssl-cert-check -c /etc/letsencrypt/live/www.anotherurl.com/fullchain.pem)

EMAIL_MESSAGE="$EMAIL_MESSAGE <div>Another Cert</div> $SSL_CERT_2"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"
EMAIL_MESSAGE="$EMAIL_MESSAGE <h3>End of report</h3>"
# Send the email
echo $EMAIL_MESSAGE | mail -a "Content-type: text/html" -s "Daily server report" info@someemail.com
