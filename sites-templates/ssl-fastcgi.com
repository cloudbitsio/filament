# Define path to cache and memory zone. The memory zone should be unique.
# keys_zone=ssl-fastcgi-cache.com:100m creates the memory zone and sets the maximum size in MBs.
# inactive=60m will remove cached items that haven't been accessed for 60 minutes or more.
fastcgi_cache_path /var/www/cache/ssl-fastcgi.com levels=1:2 keys_zone=ssl-fastcgi.com:100m inactive=60m;

server {
	# Ports to listen on, uncomment one.
	listen 443 ssl http2;
	listen [::]:443 ssl http2;

	# Server name to listen for
	server_name ssl-fastcgi.com;

	# Path to document root
	root /var/www/html/ssl-fastcgi.com/web;

	# File to be used as index
	index index.php;

	# Server Block Rules
	include conf.d/server/fastcgi-cache.conf;
	include conf.d/server/cache-expires.conf;
	include conf.d/server/exclusions.conf;
	include conf.d/server/wordpress-security.conf;
	include conf.d/server/wordpress-cache.conf;
	#include conf.d/server/wordpress-yoast.conf;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /var/www/logs/ssl-fastcgi.com/access.log;
	error_log /var/www/logs/ssl-fastcgi.com/error.log;
	
	# Customize what Nginx returns to the client in case of an error.
	# https://nginx.org/en/docs/http/ngx_http_core_module.html#error_page
	error_page 404 /404.html;
	error_page 500 /500.html;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include conf.d/fastcgi-params.conf;

		# Use the php pool defined in the upstream variable.
		# See conf.d/php-fpm.conf for definition.
		fastcgi_pass $upstream;

		# Skip cache based on rules in conf.d/server/fastcgi-cache.conf.
		fastcgi_cache_bypass $skip_cache;
		fastcgi_no_cache $skip_cache;

		# Define memory zone for caching. 
		# Should match key_zone in fastcgi_cache_path above.
		fastcgi_cache ssl-fastcgi.com;
		fastcgi_cache_valid 60m;
	}

	# Rewrite robots.txt
	rewrite ^/robots.txt$ /index.php last;


	# Paths to SSL Certificate files.
	#
	ssl_certificate /path/to/certificate.crt;
	ssl_certificate_key /path/to/key.key;
	#ssl_trusted_certificate /path/to/ca.crt;
	#ssl_client_certificate /etc/nginx/default_ssl.crt;

	# SSL Policies
	#
	include conf.d/ssl/ssl-engine.conf; # DISABLE if using LetsEncrypt Certbot
	include conf.d/ssl/policy-modern.conf; # DISABLE if using LetsEncrypt Certbot
	#include conf.d/ssl/ocsp-stapling.conf; # Use ONLY if ssl_trusted_certificate present
	#ssl_dhparam /etc/ssl/ssl-dhparams.pem; # DISABLE if using LetsEncrypt Certbot. Generate before use.

}

# Redirect http to https
server {
	listen 80;
	listen [::]:80;
	server_name ssl-fastcgi.com www.ssl-fastcgi.com;

	return 301 https://ssl-fastcgi.com$request_uri;
}

# Redirect www to non-www
server {
	listen 443;
	listen [::]:443;
	server_name www.ssl-fastcgi.com;

	return 301 https://ssl-fastcgi.com$request_uri;
}
