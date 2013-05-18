drupal7-with-nginx
==================

Customized nginx configuration from [drupal-with-nginx](https://github.com/perusio/drupal-with-nginx) by [perusio](https://github.com/perusio).  

##Requirements
  * [nginx](http://nginx.org) 1.4 and above
  * [Drupal 7](http://drupal.org)
  * [PHP-FPM](http://php.net/manual/en/install.fpm.php)
 
##Changes

###General

  1.  No proxy/loadbalance configuration - all files and the stanzas relating to same in the remaining configuration files were removed.
  2.  Directory structure - organized files into a more logical structure (for me at least) and changed "include" references where necessary to reflect the directory structure changes.
  3.  Code comments - removed code comments relating to lower versions of nginx
  4.  "include" references changed to absolute path, ie added "/etc/nginx/" to all "include" paths.

###Specific

  1. PHP-FPM uses unix sockets only.  Removed configuration file for use of tcp.
  2. Drupal Boost module configuration files were removed (may be added back in at a later date).
  3. Drupal Escaped configuration files were removed.
  4. Added comments to include files to reference the calling file.

## Background
Perusio's configuration is masterful - a great learning tool, security conscious and adaptable to many situations.  I am very grateful for his work.  It has saved me a tremendous amount of time and provided me with a working knowledge of nginx, Drupal and PHP-FPM.  

When working with Perusio's configuration, I found that it took me quite a bit of time to tailor it specifically to my needs.  I started with one relatively small VPS and then had to repeat the process for another VPS I acquired.  What I needed was a stock configuration for my needs so I could save time.  This is the result.

