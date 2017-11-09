#!/bin/bash
EMAIL_MESSAGE="<h3>Daily Server Report</h3>"

EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE <div>Get the hard drive useage</div>"
DF=$(df -h | grep /dev/xvda1) 
EMAIL_MESSAGE="$EMAIL_MESSAGE $DF"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"


EMAIL_MESSAGE="$EMAIL_MESSAGE MyMagentoSite modules"
MAGEENABLED=$(php /var/www/html/somemagentosite/bin/magento module:status)
EMAIL_MESSAGE="$EMAIL_MESSAGE $MAGEENABLED"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"
EMAIL_MESSAGE="$EMAIL_MESSAGE AnotherMagentoSite modules"
ANOTHERMAGEENABLED=$(php /var/www/html/anothermagentosite/bin/magento module:status)
EMAIL_MESSAGE="$EMAIL_MESSAGE $ANOTHERMAGEENABLED"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"
TOTAL_IMAGES_ONE=$(find /var/www/html/somepathtomagento/pub/media/catalog/product -type f | wc -l)
EMAIL_MESSAGE="$EMAIL_MESSAGE $TOTAL_IMAGES_ONE total Images in somepathtomagento/pub/media/catalog/product"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

TOTAL_IMAGES_TWO=$(find /var/www/html/anotherpath/pub/media/catalog/product -type f | wc -l)
EMAIL_MESSAGE="$EMAIL_MESSAGE $TOTAL_IMAGES_TWO total Images in anotherpath/pub/media/catalog/product"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE Checking for files larger than 50MB"
# Any files larger than 50MB
LARGE_FILES=$(sudo find / -xdev -type f -path /var/lib/mysql -prune -size +50M -exec du -sh {} ';' | sort -rh | head -n50 >> LARGE_FILES)

EMAIL_MESSAGE="$EMAIL_MESSAGE $LARGE_FILES"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE Checking for some folders larger than 1GB<br>"
SOME_LARGE_FOLDERS=$(du -h --max-depth=6 /var/www/html/somepathtomagento/ | grep '[0-9]G\>')
EMAIL_MESSAGE="$EMAIL_MESSAGE $SOME_LARGE_FOLDERS"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"

EMAIL_MESSAGE="$EMAIL_MESSAGE Checking for yet another folders larger than 1GB<br>"
ANOTHER_LARGE_FOLDERS=$(du -h --max-depth=6 /var/www/html/anotherpath/ | grep '[0-9]G\>')
EMAIL_MESSAGE="$EMAIL_MESSAGE $ANOTHER_LARGE_FOLDERS"
EMAIL_MESSAGE="$EMAIL_MESSAGE <hr>"


EMAIL_MESSAGE="$EMAIL_MESSAGE <P>Errors</P>"
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
