## Magento 1

$ php -r "require 'app/Mage.php'; echo Mage::getVersion(); "

Find where sessions are kept

> $ grep 'session' app/etc/local.xml

### DB info

> grep 'host' app/etc/local.xml grep 'dbname' app/etc/local.xml grep 'username' app/etc/local.xml grep 'password' app/etc/local.xml

### Permissions

> http://devdocs.magento.com/guides/m1x/install/installer-privileges_after.html

     find . -type f -exec chmod 400 {} \;
     find . -type d -exec chmod 500 {} \; 
     find var/ -type f -exec chmod 600 {} \; 
     find media/ -type f -exec chmod 600 {} \;
     find var/ -type d -exec chmod 700 {} \; 
     find media/ -type d -exec chmod 700 {} \;
     chmod 700 includes
     chmod 600 includes/config.php

##Magento 2

Magento 2.2 and above

### Get the secure and unsecure URL for the site

     bin/magento config:show web/secure/base_url
     bin/magento config:show web/unsecure/base_url]

### Create an admin user via cli

> php bin/magento admin:user:create --admin-firstname=Joe --admin-lastname=Testperson --admin-email=whomever@someemail.com --admin-user=ausernamegoeshere --admin-password=somep@$$w0rd!! 

### Search for caching issues with xml

> grep -rnw /pat/to/folder/ -e 'no-cache'

### Production push shell script

     #!/bin/bash
     clear
     echo "Starting Production push"
     echo "----------"
     echo "Change to the correct directory"
     cd /path/to/magento/root
     echo "----------"
     echo "Turn on maintenance mode"
     echo "----------"
     php bin/magento maintenance:enable
     echo "Git PULL from master"
     git pull origin master
     echo "----------"
     echo "Clear the cahce"
     php bin/magento cache:flush
     echo "----------"
     echo "Setup Upgrade"
     php bin/magento setup:upgrade
     echo "Setup DI compile"
     echo "----------"
     php bin/magento setup:di:compile
     echo "Static Content Deploy"
     echo
     php bin/magento setup:static-content:deploy
     echo "Disable maintenance mode"
     php bin/magento maintenance:disable

### Get the dbname and password quickly from the env.php

> cat app/etc/env.php | grep password && cat app/etc/env.php | grep dbname

## composer install that skips the php version requirement
     A little backstory, I have a Magento 2.2 site, but my Puphet has issues with php 7.1 and xdebug.
     So, I am using php 7.0 instead.  However, when you try to do a CLI install with composer, you get an error
     
     $ composer install
       Loading composer repositories with package information
       Installing dependencies (including require-dev) from lock file
       Your requirements could not be resolved to an installable set of packages.

      Problem 1
       - Installation request for zendframework/zend-code 3.2.0 -> satisfiable by zendframework/zend-code[3.2.0].
       - zendframework/zend-code 3.2.0 requires php ^7.1 -> your PHP version (7.0.24) does not satisfy that requirement.
      Problem 2
       - Installation request for doctrine/instantiator 1.1.0 -> satisfiable by doctrine/instantiator[1.1.0].
       - doctrine/instantiator 1.1.0 requires php ^7.1 -> your PHP version (7.0.24) does not satisfy that requirement.
      Problem 3
       - zendframework/zend-code 3.2.0 requires php ^7.1 -> your PHP version (7.0.24) does not satisfy that requirement.
       - magento/product-community-edition 2.2.0 requires zendframework/zend-code ^3.1.0 -> satisfiable by zendframework/zend-code[3.2.0].
       - Installation request for magento/product-community-edition 2.2.0 -> satisfiable by magento/product-community-edition[2.2.0].


     To get past this use the flag --ignore-platfgorm-reqs     
     $ composer install --ignore-platform-reqs

## Magento location for saved user/password 
     Do you want to store credentials for repo.magento.com in /home/vagrant/.config/composer/auth.json
     Sometimes i need to edit that and I can never remember where its at, now I know for ever!

### Magento Cloud and SSH
     Please make sure that when you ssh into the staging environment that you are 
     passing the -A flag so that your SSH agent is forwarded. 
     You will also need to make sure you have an agent started and your key added to it before you connect.

     You can start the agent with eval $(ssh-agent) and then ssh-add. 
     You can then verify the key has been added with ssh-add -l. 
     Once done, use ssh -A to connect to the staging environment and confirm the agent was forwarded by checking
     $ echo $SSH_AUTH_SOCK 
     which should show something. If you see some output, try the rsync again.
     
## Disable all NON magento modules
     php bin/magento module:status | command grep -v 'Magento' | command grep -v 'List' | xargs php bin/magento module:disable --clear-static-content

## Check for duplicate products/categories
     SELECT t1.value, t1.store_id, COUNT() AS NumberOfDuplicates
    -> FROM catalog_product_entity_varchar AS t1
    -> JOIN eav_attribute a ON t1.attribute_id = a.attribute_id
    -> JOIN eav_entity_type e ON a.entity_type_id = e.entity_type_id
    -> WHERE e.entity_type_code = 'catalog_product'
    -> AND a.attribute_code = 'url_key'
    -> GROUP BY t1.value, t1.store_id
    -> HAVING COUNT() > 1
    -> ORDER BY COUNT(*) DESC;
