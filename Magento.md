## Magento 1

$ php -r "require 'app/Mage.php'; echo Mage::getVersion(); "

Find where sessions are kept

> $ grep 'session' app/etc/local.xml

### DB info

    grep 'host' app/etc/local.xml 
    grep 'dbname' app/etc/local.xml 
    grep 'username' app/etc/local.xml 
    grep 'password' app/etc/local.xml

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

## Magento 2

Magento 2.2 and above

### Get the secure and unsecure URL for the site

     bin/magento config:show web/secure/base_url
     bin/magento config:show web/unsecure/base_url]

### Create an admin user via cli

> php bin/magento admin:user:create --admin-firstname=Joe --admin-lastname=Testperson --admin-email=whomever@someemail.com --admin-user=ausernamegoeshere --admin-password=somep@$$w0rd!! 

### setup new store via CLI

> php bin/magento setup:install --base-url=http://local.someurl.com/ --db-host=localhost --db-name=magento2 --db-user=magento2 --db-password=magento2 --admin-firstname="Russell" --admin-lastname="Albin" --admin-email="some@emailaddres.com" --admin-user="userNameGoeshere" --admin-password="MyHardToGuessPass!" --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1

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
#### Cloud
    php -r 'print_r(json_decode(base64_decode($_ENV["MAGENTO_CLOUD_RELATIONSHIPS"]))->database);'
#### Self Hosted    
    cat app/etc/env.php | grep host && cat app/etc/env.php | grep 'username' && cat app/etc/env.php | grep 'dbname' && cat app/etc/env.php | grep 'password'

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

## Fastly check
> http://magento-tester.global.ssl.fastly.net/magento-tester/

## Magento 2 cloud
     git branch -r
     git pull magento master
     git commit --allow-empty -m "Redeploy"
     git push magento master
     git push production master
     git commit -am'removing weltpixle cleanup'
     git push staging master
     git commit --allow-empty -m "Redeploy"
     git push magento master
     git commit --allow-empty -m "Redeploy to master"
     git push magento master
     git push production master

## Magento Cloud SSH
     Please make sure that when you ssh into the staging environment that you are 
     passing the -A flag so that your SSH agent is forwarded. 
     You will also need to make sure you have an agent started and your key added to it before you connect.

     You can start the agent with eval $(ssh-agent) and then ssh-add. 
     You can then verify the key has been added with ssh-add -l. 
     Once done, use ssh -A to connect to the staging environment and confirm the agent was forwarded by checking
     $ echo $SSH_AUTH_SOCK 
     which should show something. If you see some output, try the rsync again.
     
     Right. In that case, it seems like you SSH agent forwarding isn't enabled on those connections. You'd have to start ssh-agent on your local machine, load the environment variables that it returns, load your SSH key into the agent, and start all of the SSH sessions with the -A switch.

     You can continue to transfer to and from your local machine though, so you don't necessarily have to go through all that. It's the only way to do direct environment-to-environment transfers though

     The guide here might be useful: https://developer.github.com/v3/guides/using-ssh-agent-forwarding/
     
     
## Fastly for Enterprise Cloud
     2 Things required.  You need a custom TXT record that Magento provides.  This is to prove we own the domain.  A CNAME with the URL for the source and the fastly URL is prod.magentocloud.map.fastly.net
     
     Sample TXT record
     _globalsign-domain-verification=abcd_omRJzUn0R1IUv3sAavXrnJrsHnnaIcZabcd

     
## Disable all NON magento modules

    php bin/magento module:status | command grep -v 'Magento' | command grep -v 'List' | xargs php bin/magento module:disable --clear-static-content  
    
    ** If you get Unknown module(s): 'None' then try the next command it should work just fine **
    
    php bin/magento module:status | command grep -v 'Magento' | command grep -v 'List' | command grep -v 'None' | xargs php bin/magento module:disable --clear-static-content
   
## Check for duplicate products/categories
### Products

     SELECT t1.value, t1.store_id, COUNT(*) AS NumberOfDuplicates
     FROM catalog_product_entity_varchar AS t1
     JOIN eav_attribute a ON t1.attribute_id = a.attribute_id
     JOIN eav_entity_type e ON a.entity_type_id = e.entity_type_id
     WHERE e.entity_type_code = 'catalog_product'
     AND a.attribute_code = 'url_key'
     GROUP BY t1.value, t1.store_id
     HAVING COUNT(*) > 1
     ORDER BY COUNT(*) DESC;
     
     SELECT DISTINCT cpe.entity_id, cpe.sku, cpev.store_id, cpev.value AS url_key
     FROM catalog_product_entity_varchar AS cpev
     INNER JOIN
     (
         SELECT cpev.value, cpev.store_id, COUNT(*) AS NumberOfDuplicates, cpev.row_id AS `row_id`
         FROM catalog_product_entity_varchar AS cpev
         INNER JOIN eav_attribute ea ON cpev.attribute_id = ea.attribute_id AND ea.attribute_code='url_key'
         JOIN eav_entity_type eet ON ea.entity_type_id = eet.entity_type_id AND eet.entity_type_code = 'catalog_product'
         GROUP BY cpev.value, cpev.store_id
         HAVING NumberOfDuplicates > 1
     ) AS d ON cpev.store_id=d.store_id AND cpev.value=d.value AND cpev.row_id=d.row_id
     INNER JOIN catalog_product_entity AS cpe ON cpev.row_id = cpe.row_id
     ORDER BY cpev.value, cpev.store_id, cpe.entity_id;

### Category

    SELECT t1.value, t1.store_id, COUNT(*) AS NumberOfDuplicates
    FROM catalog_category_entity_varchar AS t1
    JOIN eav_attribute a ON t1.attribute_id = a.attribute_id
    JOIN eav_entity_type e ON a.entity_type_id = e.entity_type_id
    WHERE e.entity_type_code = 'catalog_category'
    AND a.attribute_code = 'url_key'
    GROUP BY t1.value, t1.store_id
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC;
    
    SELECT DISTINCT cce.entity_id, ccev.store_id, ccev.value AS url_key
    FROM catalog_category_entity_varchar AS ccev
    INNER JOIN
    (
        SELECT ccev.value, ccev.store_id, COUNT(*) AS NumberOfDuplicates
        FROM catalog_category_entity_varchar AS ccev
        INNER JOIN eav_attribute ea ON ccev.attribute_id = ea.attribute_id AND ea.attribute_code='url_key'
        JOIN eav_entity_type eet ON ea.entity_type_id = eet.entity_type_id AND eet.entity_type_code = 'catalog_category'
        GROUP BY ccev.value, ccev.store_id
        HAVING NumberOfDuplicates > 1
    ) AS d ON ccev.store_id=d.store_id AND ccev.value=d.value
    INNER JOIN catalog_category_entity AS cce ON ccev.row_id = cce.row_id
    ORDER BY ccev.value, ccev.store_id, cce.entity_id;
     
## Magento Cloud Access Denied Super privilege needed
    ERROR 1277 (42000) at line <number>: Access denied; you need (at least one of) the SUPER privilege(s) for this operation

    http://devdocs.magento.com/guides/v2.2/cloud/live/stage-prod-migrate.html
    // Staging
    mysqldump -h 127.0.0.1 --user=root --password=root --single-transaction KR_STG  | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | gzip > stg1-database_no-definer.sql.gz
``` zcat vortex-integration-release-3.sql.gz | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | mysql -h database.internal -u user -p  main ```

    

### Remove Orders pre-launch
     SET FOREIGN_KEY_CHECKS = 0;
    TRUNCATE TABLE `gift_message`;
    TRUNCATE TABLE `quote`;
    TRUNCATE TABLE `quote_address`;
    TRUNCATE TABLE `quote_address_item`;
    TRUNCATE TABLE `quote_id_mask`;
    TRUNCATE TABLE `quote_item`;
    TRUNCATE TABLE `quote_item_option`;
    TRUNCATE TABLE `quote_payment`;
    TRUNCATE TABLE `quote_shipping_rate`;
    TRUNCATE TABLE `reporting_orders`;
    TRUNCATE TABLE `sales_bestsellers_aggregated_daily`;
    TRUNCATE TABLE `sales_bestsellers_aggregated_monthly`;
    TRUNCATE TABLE `sales_bestsellers_aggregated_yearly`;
    TRUNCATE TABLE `sales_creditmemo`;
    TRUNCATE TABLE `sales_creditmemo_comment`;
    TRUNCATE TABLE `sales_creditmemo_grid`;
    TRUNCATE TABLE `sales_creditmemo_item`;
    TRUNCATE TABLE `sales_invoice`;
    TRUNCATE TABLE `sales_invoiced_aggregated`;
    TRUNCATE TABLE `sales_invoiced_aggregated_order`;
    TRUNCATE TABLE `sales_invoice_comment`;
    TRUNCATE TABLE `sales_invoice_grid`;
    TRUNCATE TABLE `sales_invoice_item`;
    TRUNCATE TABLE `sales_order`;
    TRUNCATE TABLE `sales_order_address`;
    TRUNCATE TABLE `sales_order_aggregated_created`;
    TRUNCATE TABLE `sales_order_aggregated_updated`;
    TRUNCATE TABLE `sales_order_grid`;
    TRUNCATE TABLE `sales_order_item`;
    TRUNCATE TABLE `sales_order_payment`;
    TRUNCATE TABLE `sales_order_status_history`;
    TRUNCATE TABLE `sales_order_tax`;
    TRUNCATE TABLE `sales_order_tax_item`;
    TRUNCATE TABLE `sales_payment_transaction`;
    TRUNCATE TABLE `sales_refunded_aggregated`;
    TRUNCATE TABLE `sales_refunded_aggregated_order`;
    TRUNCATE TABLE `sales_shipment`;
    TRUNCATE TABLE `sales_shipment_comment`;
    TRUNCATE TABLE `sales_shipment_grid`;
    TRUNCATE TABLE `sales_shipment_item`;
    TRUNCATE TABLE `sales_shipment_track`;
    TRUNCATE TABLE `sales_shipping_aggregated`;
    TRUNCATE TABLE `sales_shipping_aggregated_order`;
    TRUNCATE TABLE `tax_order_aggregated_created`;
    TRUNCATE TABLE `tax_order_aggregated_updated`;
    TRUNCATE TABLE `magento_rma`;
    TRUNCATE TABLE `magento_rma_grid`;
    TRUNCATE TABLE `magento_rma_status_history`;
    TRUNCATE TABLE `magento_sales_creditmemo_grid_archive`;
    TRUNCATE TABLE `magento_sales_invoice_grid_archive`;
    TRUNCATE TABLE `magento_sales_order_grid_archive`;
    TRUNCATE TABLE `magento_sales_shipment_grid_archive`;
    TRUNCATE TABLE `sequence_creditmemo_0`;
    TRUNCATE TABLE `sequence_creditmemo_1`;
    TRUNCATE TABLE `sequence_creditmemo_2`;
    TRUNCATE TABLE `sequence_creditmemo_7`;
    TRUNCATE TABLE `sequence_invoice_0`;
    TRUNCATE TABLE `sequence_invoice_1`;
    TRUNCATE TABLE `sequence_invoice_2`;
    TRUNCATE TABLE `sequence_invoice_7`;
    TRUNCATE TABLE `sequence_order_0`;
    TRUNCATE TABLE `sequence_order_1`;
    TRUNCATE TABLE `sequence_order_2`;
    TRUNCATE TABLE `sequence_order_7`;
    TRUNCATE TABLE `sequence_rma_item_0`;
    TRUNCATE TABLE `sequence_rma_item_1`;
    TRUNCATE TABLE `sequence_rma_item_2`;
    TRUNCATE TABLE `sequence_rma_item_7`;
    TRUNCATE TABLE `sequence_shipment_0`;
    TRUNCATE TABLE `sequence_shipment_1`;
    TRUNCATE TABLE `sequence_shipment_2`;
    TRUNCATE TABLE `sequence_shipment_7`;
    SET FOREIGN_KEY_CHECKS = 1;
    ALTER TABLE sequence_creditmemo_0 AUTO_INCREMENT=1;
    ALTER TABLE sequence_creditmemo_1 AUTO_INCREMENT=1;
    ALTER TABLE sequence_creditmemo_2 AUTO_INCREMENT=1;
    ALTER TABLE sequence_creditmemo_7 AUTO_INCREMENT=1;
    ALTER TABLE sequence_invoice_0 AUTO_INCREMENT=1;
    ALTER TABLE sequence_invoice_1 AUTO_INCREMENT=1;
    ALTER TABLE sequence_invoice_2 AUTO_INCREMENT=1;
    ALTER TABLE sequence_invoice_7 AUTO_INCREMENT=1;
    ALTER TABLE sequence_order_0 AUTO_INCREMENT=1;
    ALTER TABLE sequence_order_1 AUTO_INCREMENT=1;
    ALTER TABLE sequence_order_2 AUTO_INCREMENT=1;
    ALTER TABLE sequence_order_7 AUTO_INCREMENT=1;
    ALTER TABLE sequence_rma_item_0 AUTO_INCREMENT=1;
    ALTER TABLE sequence_rma_item_1 AUTO_INCREMENT=1;
    ALTER TABLE sequence_rma_item_2 AUTO_INCREMENT=1;
    ALTER TABLE sequence_rma_item_7 AUTO_INCREMENT=1;
    ALTER TABLE sequence_shipment_0 AUTO_INCREMENT=1;
    ALTER TABLE sequence_shipment_1 AUTO_INCREMENT=1;
    ALTER TABLE sequence_shipment_2 AUTO_INCREMENT=1;
    ALTER TABLE sequence_shipment_7 AUTO_INCREMENT=1;

### rsync media from cloud to local with excludes cache
> rsync -arvP --exclude-from="pub/media/catalog/product/cache" -e ssh ent-abcxkd67o6aabc-staging-5em2abc@ssh.us.magentosite.cloud:~/pub/media var/

## New Puphpet var cache not writeable (Solved!)
     Zend_Cache_Exception cache_dir is not writeable 
     Centos 7, PHP 7.0
     
     edit /etc/php-fpm.d/www.conf
     Change user from www-user to vagrant
     restart php-fpm
     sudy systemctl restart php-fpm.service
     
     You may need to disable selinux
     edit /etc/selinux/config 
     SELINUX=disabled
     Restart server to take effect
     
## Local setup things to change if pulling DB from Production/Staging
     bin/magento config:set dev/static/sign 0;
     bin/magento config:set admin/security/use_form_key 0;
     bin/magento config:set system/full_page_cache/caching_application 1;
     bin/magento config:set catalog/search/engine mysql;
     bin/magento config:set web/seo/use_rewrites 1;
     bin/magento config:set admin/security/password_is_forced 0;
     bin/magento config:set web/secure/use_in_adminhtml 0;
     bin/magento config:set admin/security/session_lifetime 86400;
     bin/magento deploy:mode:set developer;
   
## Magento 2 Cloud deployment notes
    Things to note about these instructions:
    My Remotes for the 2 repositories are called magento and blueacorn
    The first stop is a develop/current or other feature branch inside magento.  This way we can test the code before merging it into master.  Once its in master, that is what will be deployed to integration, staging and production. So testing things thourougly is important in this first step.
    
    First checkout the Magento branch that is the first level for testing, sometimes called develop, or current

> $ git checkout magento develop

> $ git pull magento develop 

    Now update from the blueacorn repo.  In this example master is the branch that has the code that has been approved

> $ git pull blueacorn master

    We are ready to deploy our code to develop
> $ git push magento develop

    Time to move our code to master if the deployment to develop was successful and the inital QA has passed
> $ git checkout master

> $ git pull magento develop

> $ git push magento master
    
    We are now ready to deploy up the the production layers.  First stop is integration.  Remember to always pull from magento master
> $ git checkout integration

> $ git pull magento master

> $ git push magento integration
  
    Now we do staging
> $ git checkout staging

> $ git pull magento master

> $ git push magento staging

    Finally Production
> $ git checkout production

> $ git pull magento master

> $ git push magento production

### Doing a 301 redirect with the Magento cloud routes.yaml
    "https://{default}/":
    type: upstream
    upstream: "ponbikemagento:http"
    redirects:
        expires: 1d
        paths:
            "/123": { "to": "https://www.gazelle.nl/", "code": "301" }
            "/welkom": { "to": "https://www.gazelle.nl/", "code": "301" }

### To get the IP address for each node in the Magento Cloud cluster
    dig +short 1.<projectid>.ent.magento.cloud
    dig +short 2.<projectid>.ent.magento.cloud
    dig +short 3.<projectid>.ent.magento.cloud

### migrate production DB to staging
    ** I would fetch the current staging details for these values before unless its part of app/etc/env.php **
    Create backup of db, rsync it to local
    gunzip db.sql.gz
    Using vi search and replace www with staging or whatever
         :%s/www.nononsense.com/staging.nononsense.com/g
         :%s/www.hue.com/staging.hue.com/g
    Fastly needs to point to staging swap out those values
    
    Algolia prefix needs to be updated
    
    Payment gateway needs to be changed

### Magento DB dump using ece tools
    vendor/bin/ece-tools db-dump
    
### REST commands
> http://example.test/rest/V1/products?searchCriteria[filter_groups][0][filters][0][field]=sku&searchCriteria[filter_groups][0][filters][0][value]=%green%&searchCriteria[filter_groups][0][filters][0][condition_type]=like

## enable/disable template path hints cli
    php bin/magento config:set dev/debug/template_hints_storefront 0 [--lock]
    php bin/magento cache:clean full_page

## Stuck Magento Cloud deployments

    If a cron is holding up a deployment, ssh to the environment and run ps aux | grp cron.
    That will show you the cron tasks running. Go ahead and kill any of those using kill <process id> (you can get the bbn process ID from the left of the row from the ps aux output)

    You can also log in to the database and check if there is a backlog of crons, which will keep trying to execute if they're pending. 
    Use mysql -h database.internal then use main.
    From there select from cron_schedule where status = 'pending';
    If you get lots of rows, then delete them, which should prevent them new ones from running as soon as the previous ones finish.

    Of course, be very careful interacting with the database directly.

    Crons only affect deployments on cloud environments and the above methods are only suitable on non-production environments.

    For any production environments we strongly recommend creating a support ticket.

## Cache Warming magento cloud
    As discussed, here is a cheat sheet on Post_deploy hook:

    https://devdocs.magento.com/guides/v2.2/cloud/env/variables-post-deploy.html

    1.       Edit .magento.app.yaml

     post_deploy: |

        php ./vendor/bin/ece-tools post_deploy

    2.       Edit .magento.env.yaml
    stage:
     global:
       #     SCD_ON_DEMAND: true
       SKIP_HTML_MINIFICATION: true

    OPTIONAL
     edit .magento.env.yaml
     post-deploy:
      WARM_UP_PAGES:
        - "index.php"
        - "index.php/customer/account/create"

## Dreaded Vertex Tax shasum error on cloud deployments
     
    1. Run `composer clearcache` locally
    2. Clea `vendor` dir in ypur project's root
    3. Run `composer update vertex/..`
    4. Commit update `composer.lock` file

## Suspended indexer
    $ php bin/magento indexer:status
    +----------------------+------------+-----------+--------------------------+---------------------+
    | Title                | Status     | Update On | Schedule Status          | Schedule Updated    |
    +----------------------+------------+-----------+--------------------------+---------------------+
    | Catalog Product Rule | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Catalog Rule Product | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Catalog Search       | Processing | Schedule  | suspended (0 in backlog) | 2019-01-14 20:10:35 |
    | Category Flat Data   | Ready      | Save      |                          |                     |
    | Category Products    | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Customer Grid        | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Design Config Grid   | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Product Categories   | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Product EAV          | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Product Flat Data    | Ready      | Save      |                          |                     |
    | Product Price        | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Product/Target Rule  | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Sales Rule           | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Stock                | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Target Rule/Product  | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    | Warehouse            | Ready      | Schedule  | idle (0 in backlog)      | 2019-01-14 20:07:04 |
    +----------------------+------------+-----------+--------------------------+---------------------+
    $ php bin/magento indexer:reindex catalogsearch_fulltext
       * If you get
    Catalog Search index is locked by another reindex process. Skipping.
    $ php bin/magento indexer:reset
       * Then
    $ php bin/magento indexer:reindex

    Try lowering batch sizes?
    https://devdocs.magento.com/guides/v2.3/extension-dev-guide/indexer-batch.html

## For API calls you can use this to return a message and a code number
       throw new \Magento\Framework\Webapi\Exception(__('Some message why it failed and a code number'),'400');

## Magento APIs to affect all stores
    use the word all in the request for example
    https://www.example.cloud/rest/all/V1/categories/445
    
## Magento Cloud ssh forwarding to allow for rsync from environment to environment

Make sure you have the forwarding agent in ~/.ssh/config
     $ cat ~/.ssh/config 
    Host ssh.us.magentosite.cloud
      ForwardAgent yes
    Host ssh.us-3.magentosite.cloud
      ForwardAgent yes
      
Check to see if your private key is added to ssh-add
     $ ssh-add -L

If not add it
     $ ssh-add ~/.ssh/id_rsa
     
Try again
     $ ssh-add -L
     
Add make sure the agent is running
     $ echo  "$SSH_AUTH_SOCK"
     /private/tmp/com.apple.launchd.Y0KyrDbwj0/Listeners
     
     Now you can do your rsync from production to staging
     First ssh into production with the -A flag
     ssh -A 1.ent-abcdefg5yga-production-abcdefg3y@ssh.us-3.magento.cloud
     Now sync media from production to staging
      rsync -avz --exclude 'catalog/product/cache' ~/pub/media/ -e ssh 1.ent-abcdefg-staging-abcedfg@ssh.us-3.magento.cloud:~/pub/media/ -P
