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
  2.  Comments removed - removed comments relating to versions of nginx below 1.4.
  3.  Comments added - Added comments to each file, where necessary to reflect choices about the configuration and steps needed for implementation.

###Specific
  1. PHP5-FPM uses unix sockets only.  Removed configuration file for use of tcp. Changed pool names.
  2. Drupal Boost module configuration files were removed (may be added back in at a later date).
  3. Drupal Escaped configuration files were removed.
  4. Added comments to include files to reference the calling file. (TO DO)
  5. Added comments relating to implementation and installation.
  6. Expanded user agents blocked in `blacklist.conf`.

## Nginx Configuration Concepts
### The Include Directive
Nginx provides a realtively easy way of managing complex configurations through the **[include directive](http://wiki.nginx.org/CoreModule#include)**.  In brief, by using the include directive, you can read another file into the configuration.  This allows you to reuse parts of the configuration where needed without having to retype the configuration directives again, lets you make changes in one file rather than changing the same thing in multiple places, reducing the chance of error, and keeps file size manageable. 

For example, `apps/drupal/drupal.conf` contains four include statements in various blocks for `fastcgi.conf` which includes 13 lines of directives and comments.  You can see that it is more efficient to save these repeated directives to a file and use an include directive rather than adding an additional 52 lines of comments and directives to the `apps/drupal/drupal.conf`.  Any changes only need to be made in one place.

An example of an include directive found in `nginx.conf`:

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
  4. sites-available/example.com.conf

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

In this instance, for the URI www.example.com/favicon.ico, nginx will first look for the favicon.ico file at the site root level and serve it.  If not found, it will then proceed to the named location, @empty, below.  The configuration directives in @empty return an empty gif. A named location is one with an '@' sign. Note the above location uses a named location with its configuration directives.

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

The documentation provided here is documentation relating to this version of perusio's configuration.  See perusio's [README.md](https://github.com/perusio/drupal-with-nginx/blob/D7/README.md) for more detailed documentation regarding the configuration itself. You should consider mandatory a reading perusio's [README.md](https://github.com/perusio/drupal-with-nginx/blob/D7/README.md).

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
1. Change your PHP5-FPM pool configuration to match the pool configuration in `upstream_phpcgi_unix.conf` which uses three pools, www1, www2 and www3 and unix sockets.  Alternatively, change `upstream_phpcgi_unix.conf` to match your existing PHP5-FPM configuration. 

####`/sites-available/example.com.conf`
1. Replace example.com with your domain name.
2. Replace IPv6 address with your IPv6 address or disable.
3. Check root path. Change as necessary.
4. Check log paths.  Change as necessary.
5. Check SSL paths. Change as necessary.

Note that there are four server blocks - two for http and two for https. The first server block for each redirects www.example.com to example.com.  

#### `blacklist.conf`
1.  Review list of user agents to be blocked. Change as necessary.
2.  Review list of referrers to be blocked.  Change as necessary.
3.  Review list of hosts exempt from referrer checking.  Change as necessary.

#### `map_block_http_methods.conf`
1.  Review and change as necessary.


##Options

###Options - Disabled by Default
These options are disabled by default.
####`/sites-available/example.com.conf`

1. **New Druapl Installation:**  If installing a new Drupal site, enable include directive for drupal_install.conf. 
	a. If you want to enable auth_basic for installation, see `apps/drupal/drupal_install.conf` and `.htpasswd-users` to enable  authentication if desired). Default is disabled.
2. **PHP5-FPM Status and Ping Pages:** Enable include directive for PHP5-FPM status and ping pages.  Disabled by default. (http & https - one include directive in each so two changes needed if you want to enable it in both).  **Note:** The status pages correspond to this configuration. If you opted to change this configuration and not your PHP5-FPM configuration, you'll need to make those changes here.) 
    a.  `php_fpm_status_allowed_hosts.conf` - review and change hosts as necessary.
3. **Nginx Status Pages:** Enable include directive for nginx status page.  Disabled by default. (http & https - one include directive in each so two changes needed if you want to enable it in both)
    a.  `nginx_status_allowed_hosts.conf` - review and change hosts as necessary.

####`/apps/drupal/drupal.conf`
1. **Hotlinking Protection:** Enable the include directive for hotlinking protection.
	a.    `apps/drupal/hotlinking_protection.conf` - change the directive valid_referers to include your domain name.
2. **FastCGI Microcache** - microcaching for anonymous users is enabled by default.  You can switch to microcahing for authenticated users by disabling the include directive for anonymous microcaching and enabling the other. Enable only one!
3. **AIO File System Support** - XFS or ext3 or similar - ext3 is enabled by default (differs from perusio's config where XFS enabled by default).  Switch to XFS by disabling ext3 and enabling XFS in the MP3 and Ogg/Vorbis section.  There are two entries so be sure to change it in both places.

####`/apps/drupal/microcache_fcgi.conf` & `/apps/drupal/microcache_fcgi_auth.conf`
1. **Clickjacking Protection:** - Choose only one of the add-header lines.
   One is for sites not using frames and the other is for sites using frames.
2. **Strict Transport Security:** If using HTTPS, uncomment add_header for
   Strict Transport Security and adjust time if necessary.
   Disabled by default.

####`nginx.conf`
1. **Clickjacking Protection:** - Choose only one of the add-header lines.
   One is for sites not using frames and the other is for sites using frames.