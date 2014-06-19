drupal7-with-nginx
==================
Customized nginx configuration for running druapl from [drupal-with-nginx](https://github.com/perusio/drupal-with-nginx) by [perusio](https://github.com/perusio).  I use Debian 7.0 (Wheezy) with the nginx-extras and PHP5 packages from the [dotdeb](http://www.dotdeb.org/) repository.  **No guarantees that this will work with anything other than that.**

##Requirements
  * [nginx](http://nginx.org) 1.4 and above
  * [PHP-FPM](http://php.net/manual/en/install.fpm.php)
  * [Drupal 7](http://drupal.org)
  * [drush](http://drush.ws/)

## Background
Perusio's configuration is masterful - a great learning tool, security conscious and adaptable to many situations.  I am very grateful for his work.  It has saved me a tremendous amount of time and provided me with a working knowledge of nginx, Drupal and PHP-FPM.  

When working with Perusio's configuration, I found that it took me quite a bit of time to go through the files and tailor it specifically to my needs.  I started with one relatively small VPS and then had to repeat the process for another VPS I acquired a year later (by which time I had a murky recollection of what I had done the first time).  What I needed was a stock configuration for my needs with so I could save time.  This is the result.

##Changes from Perusio's Configuration

###General
  1.  No proxy/loadbalance configuration - all files and the stanzas relating to same in the remaining configuration files were removed.
  2.  Comments removed - removed some comments relating to versions of nginx below 1.4.
  3.  Comments added - Added comments to each file where necessary to reflect choices about the configuration and steps needed for implementation.

###Specific
  1. PHP5-FPM uses unix sockets only.  Removed configuration file for use of tcp. Changed pool names.
  2. Drupal Boost module configuration files were removed (may be added back in at a later date).
  3. Drupal Escaped configuration files were removed.
  4. Added comments to include files to reference the calling file. (TO DO)
  5. Added comments relating to implementation and installation.
  6. Expanded user agents blocked in `blacklist.conf`.
  7. Added variables_hash section in `nginx.conf`. 
  
  		## Uncomment to increase variables_hash_max_size if you start getting 
    	## [emerg] could not build the variables_hash, you should increase 
    	## either variables_hash_max_size: 512 or 
    	## variables_hash_bucket_size: 64
    	## You only need to uncomment one. I chose to increase
    	## variables_hash_max_size to 1024 as this was recommended
    	## in nginx forum by developers.
    	## See this forum topic and responses
    	## http://forum.nginx.org/read.php?2,192277,192286#msg-192286
    	## See http://wiki.nginx.org/HttpCoreModule#variables_hash_bucket_size
    	## variables_hash_bucket_size was added for completeness but not
    	## changed from default.
    	#variables_hash_max_size 1024; # default 512
    	#variables_hash_bucket_size 64; # default is 64
  
  8. Changed IPv6 listen directive in `000-default` from a specific address to a wildcard address.
  
    	listen [::]:80 ipv6only=on;

  
  9. Changed IPv6 listen directives in `example.domain.conf` from a specific address to a wildcard address and removed 'ipv6only=on;' because you can only specify socket options once on an IPv6 wildcard address and that's been done in `000-default`.

		listen [::]80;
		
	and
	
		listen [::]:443 ssl spdy;

	See [listen directive](http://nginx.org/en/docs/http/ngx_http_core_module.html#listen) and this [bug report](http://trac.nginx.org/nginx/ticket/364). 
	 
	
## Nginx Configuration Concepts
### The Include Directive
Nginx provides a realtively easy way of managing complex configurations through the **[include directive](http://wiki.nginx.org/CoreModule#include)**.  In brief, by using the include directive, you can read another file into the configuration.  This allows you to reuse parts of the configuration where needed without having to retype the configuration directives again, lets you make changes in one file rather than changing the same thing in multiple places, reducing the chance of error, and keeps file size manageable. 

For example, `apps/drupal/drupal.conf` contains four include statements in various blocks for `fastcgi.conf` which includes 13 lines of directives and comments.  You can see that it is more efficient to save these repeated directives to a file and use an include directive rather than adding an additional 52 lines of comments and directives to the `apps/drupal/drupal.conf`.  Any changes only need to be made in one place.

Examples of an include directive found in `nginx.conf`:

	## Microcache zone definition for FastCGI.
    include fastcgi_microcache_zone.conf;

    ## Include all vhosts.
    include sites-enabled/*;

The relative path for include directives is relative to the path
of nginx.conf, not the prefix path.  In Debian 7, nginx.conf is
located at /etc/nginx/ so all paths are relative to /etc/nginx. You may use an absolute path.  All files in this repository use a path relative to `nginx.conf`.  Please see the [notes](http://wiki.nginx.org/CoreModule#include) for further information regarding relative path.

For purposes of documentation, a configuration file that uses an
include directive is the **calling** file. The file contained in the include directive is the **include** file.  In the above example, `nginx.conf` would be the calling file and `fastcgi_microcache_zone.conf` would be the include file. 

You may have multiple include directives per calling file.  See example above.  

You may have multiple include directives using the same include file.  For example, `apps/drupal/drupal.conf` contains several include directives for `apps/drupal/fastcgi_drupal.conf`.  

An include file may also contain an include directive(s), in which case it becomes a calling file.  For example, `fastcgi.conf` is both an include file and a calling file.  It contains an include directive for `fastcgi_params` and in turn, `nginx.conf` contains an include directive for `fastcgi.conf`.

There are four calling files in this configuration:

  1. nginx.conf
  2. fastcgi.conf
  3. apps/drupal/drupal.conf
  4. sites-available/example.domain.conf

See the file `1_documentation/includes-list.txt` for a complete listing of the include directives for each calling file.  It also contains a reference to the line numbers of the calling file where those include directives appear.  

---
***Caveat - This list is automatically generated by a script (so are the others). Ifyou make any changes to your configuration files, the list may or may not be valid depending on the changes you made. I have included this script as well as the others in the `2_scripts' directory so you can regenerate the lists.  Read the scripts for further instructions.  It's not elegant but it works.***

---

### The Location Directive
A [location](http://wiki.nginx.org/HttpCoreModule#location) directive allow you to set specific configuration options based on the URI.  A full discussion of the location directive is beyond the scope of this document.  See the link above, read the nginx mailing list, the nginx forum and the configuration files themselves for further information.

An example of two locations from `apps/drupal/drupal.conf`:

	## Support for favicon. Return an 1x1 transparent GIF if it doesn't
	## exist.
	location = /favicon.ico {
	    expires 30d;
	    try_files /favicon.ico @empty;
	}

In this instance, for the URI www.example.domain/favicon.ico, nginx will first look for the favicon.ico file at the site root level and serve it.  If not found, it will then proceed to the named location, @empty, below.  The configuration directives in @empty return an empty gif. A named location is one with an '@' sign. Note the above location uses a named location with its configuration directives.

	## Return an in memory 1x1 transparent GIF.
	location @empty {
    	expires 30d;
    	empty_gif;
	}

The location directive has many "gotchas".  Read the documentation carefully. If modifying this configuration, remember that the order of the location directives matters.

## What This Repository Provides
### Documentation
Besides the `README.md` file, documentation is provided in the `1_documentation` directory and within each file. This directory contains text files documenting the following:

* `structure.txt` - a simple list of all the files
* `includes-list.txt` - a list of include directives
* `locations-list.txt` - a list of named locations
* `variables-list.txt` - a list of variables used

The documentation provided here relates to this version of perusio's configuration.  See perusio's [README.md](https://github.com/perusio/drupal-with-nginx/blob/D7/README.md) for more detailed documentation regarding the configuration itself. You should consider mandatory a reading of perusio's [README.md](https://github.com/perusio/drupal-with-nginx/blob/D7/README.md).

### Scripts
Several scripts that generate lists of include directives, locations and variables.  These scripts were used to generate the files in `1_docmentation`.  The scripts can be handy when trying to understand how perusio's configuration fits together and for troubleshooting. See caveat above.

### Configuration Files
#### Default Nginx
The configuration files provided by the dotdeb nginx-extras package are (followed by the status in this configuration):

* `fastcgi_params` - changed
* `koi-win` - unchanged
* `koi-utf` - unchanged
* `mime.types` - changed
* `naxsi.rules` - unused
* `naxsi_core.rules` - unused
* `nginx.conf` - changed
* `proxy_params` - unused (changed and renamed to `reverse_proxy.conf` in perusio's configuration)
* `scgi_params` - unused
* `uwsgi_params` - unused
* `win-utf` - unchanged
* `sites-available/default` - changed and renamed to `000-default`

#### This Configuration
Although `koi-utf`, `koi-win` and `win-utf` are unchanged from the default configuration files provided by the dotdeb nginx-extras package, they are included here for completeness.

The unused files have been removed from the configuration.  

`mime.types` has been expanded to include additional audio and vidoe types as well as adding support for Open Document Format. See [here](https://github.com/troubleshooter/documentation-drupal-with-nginx-D7-branch/raw/master/drupal-with-nginx-D7_Branch-MimeTypes.pdf) for a complete list of changes.  

A number of configuration files have been added, with most of the Drupal-specific files added to apps/drupal/.

Comments have been added near the top of each file where appropriate indicating what choices you have when implementing the configuration, whether there are values that must be changed and whether there are any external programs which are affected (PHP5-FPM).  See section of each file titled "IMPLEMENT".

***IMPORTANT NOTE:*** This configuration uses three pools for PHP5-FPM named www1, www2 and www3.  It is not necessary that you use this configuration but you **must** make sure that the configuration here (`upstream_phpcgi_unix.conf` and `apps/drupal/php_fpm_status_vhost.conf`)matches your PHP5-FPM, either by changing this configuration or your PHP5-FPM configuration.

#### Drupal Module-Specific Support
This configuration supports Drupal generally however some Drupal modules require specific configuration in nginx. This configuration supports:

* Advanced Aggregation
* File Force Download
* FileField Nginx Progress
* Pressflow
* XML Sitemap

See `apps/drupal/drupal.conf` and `apps/drupal/drupal_upload_progress.conf` for those configuration directives.  In addition, comments in the form of "###_ DRUPAL_MODULE - Module Name" have been added to the configuration files.

## Implementation & Installation
###Mandatory Changes/Review
The following configuration files **must** be changed for this configuration to work.  In addition, a review of certain settings is strongly suggested.

####PHP5-FPM & `upstream_phpcgi_unix.conf`
Change your PHP5-FPM pool configuration to match the pool configuration in `upstream_phpcgi_unix.conf` which uses three pools, www1, www2 and www3 and unix sockets.  Alternatively, change `upstream_phpcgi_unix.conf` to match your existing PHP5-FPM configuration. 

####Microcaching & `fastcgi_microcache_zone.conf`
Microcaching requires the presence of /var/cache/nginx/microcache.  This directory is not created by default.  You **must** create it and grant the appropriate permissions to the nginx user (in Debian 7 it's www-data).
  If you want the microcache in another location, be sure to change it in `fastcgi_microcache_zone.conf`.

####`/sites-available/example.domain.conf`
1. Replace example.domain with your domain name.
2. Replace IPv6 address with your IPv6 address if you want to listen on a specific interface or disable altogether if not using IPv6.
3. Check root path for web. Change as necessary.
4. Check log paths.  Change as necessary.
5. Check SSL paths. Change as necessary.

Note that there are four server blocks - two for http and two for https. The first server block for each redirects www.example.domain to example.domain.  

#### `blacklist.conf`
1.  Review list of user agents to be blocked. Change as necessary.
2.  Review list of referrers to be blocked.  Change as necessary.
3.  Review list of hosts exempt from referrer checking.  Change as necessary.
4.  NOTE 1: The list of user agents and list of referrers are based on MY preferences.  You might want to remove some of the user-agents I've blocked.  None of my sites are "business" sites so I've blocked some of the more aggressive SEO bots/spiders.
5.  NOTE 2:  curl is blocked by default.  If you are testing/debugging, you might want to remove curl temporarily.
6.  NOTE 3:  Added blocking of empty user-agent string.  I noted in my logs that every log line that had an empty user-agent string was a hacking attempt.  I turned it on for my sites and have been monitoring and haven't seen any legitimate requests with an empty user-agent string for a month now.  Not sure if this is for everyone so it is NOT enabled by default.  I will be monitoring and investigating further as it has come to my attention that, for example, some Android applications do not set a user-agent and one must be manually entered.

#### `map_block_http_methods.conf`
Review and change as necessary.

#### Symlinks to `sites-enabled/`
Just a reminder to make sure you add the necessary symlinks from `sites-available/` to `sites-enabled/`.  Note that the `sites-enabled/default` symlink is already linked to `sites-available/default` on a standard installation.

##Options

###Options - Disabled by Default
These options are disabled by default.
####`/sites-available/example.domain.conf`

1. **New Druapl Installation:**  If installing a new Drupal site, enable include directive for drupal_install.conf. 
	a. If you want to enable auth_basic for installation, see `apps/drupal/drupal_install.conf` and `.htpasswd-users` to enable  authentication if desired). Default is disabled.
2. **PHP5-FPM Status and Ping Pages:** Enable include directive for PHP5-FPM status and ping pages.  Disabled by default. (http & https - one include directive in each so two changes needed if you want to enable it in both).  **Note:** The status pages correspond to this configuration. If you opted to change this configuration and not your PHP5-FPM configuration, you'll need to make those changes here.) 
    a.  `php_fpm_status_allowed_hosts.conf` - review and change hosts as necessary.
3. **Nginx Status Pages:** Enable include directive for nginx status page.  Disabled by default. (http & https - one include directive in each so two changes needed if you want to enable it in both)
    a.  `nginx_status_allowed_hosts.conf` - review and change hosts as necessary.

####`/apps/drupal/drupal.conf`
1. **Hotlinking Protection:** Enable the include directive for hotlinking protection.
	a.    `apps/drupal/hotlinking_protection.conf` - change the directive valid_referers to include your domain name.
2. **FastCGI Microcache** - microcaching for anonymous users is enabled by default.  You can switch to microcahing for authenticated users by disabling the include directive for anonymous microcaching and enabling the other. Enable only one!  Make sure you've created the directory and given appropriate permissions to the nginx user.  See note on Microcaching above.
3. **AIO File System Support** - XFS or ext3 or similar - ext3 is enabled by default (differs from perusio's config where XFS enabled by default).  Switch to XFS by disabling ext3 and enabling XFS in the MP3 and Ogg/Vorbis section.  There are two entries so be sure to change it in both places.

####`/apps/drupal/microcache_fcgi.conf` & `/apps/drupal/microcache_fcgi_auth.conf`
1. **Clickjacking Protection:** - Choose only one of the add-header lines.
   One is for sites not using frames and the other is for sites using frames.
2. **Strict Transport Security:** If using HTTPS, uncomment add_header for
   Strict Transport Security and adjust time if necessary.
   Disabled by default.

####`nginx.conf`
**Clickjacking Protection:** - Choose **only one** of the add-header lines.
   One is for sites not using frames and the other is for sites using frames.