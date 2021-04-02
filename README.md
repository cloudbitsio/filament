<p align="center">
  <a href="https://github.com/cloudbitsio/filament"><img width="240" src="filament.svg" /></a>
</p>
<p align="center">Drop-in replacement for /etc/nginx</p>
<p align="center">
  <a href="#nginx-configurations">About</a> |
  <a href="#installation">Installation</a> |
  <a href="#usage">Usage</a> |
  <a href="#whats-inside">What's Inside</a> |
  <a href="#credits">Credits</a>
</p>

---

# NGINX Configurations

The goal of this project is to maintain a compilation of best practices of NGINX server configurations and some opinionated patterns for ease of configurability.

Licensed under [MIT](./LICENSE).

Features: 
- HTTP for local development, HTTPS with/without FastCGI Cache;
- HTTP/2, IPv6;
- Certbot, HSTS, security headers, SSL profiles, OCSP resolvers;
- FastCGI caching, gzip, fallback routing, www/non-www redirect; 
- Comprehensive WordPress support

## Installation

Assuming you have NGINX installed, 

1. Backup your `/etc/nginx` folder.

```bash
tar -czvf /etc/nginx_$(date +'%F_%H-%M-%S').tar.gz /etc/nginx
```
2. Filament is a drop-in replacement for NGINX configs. Download Filament into `/etc/nginx`.

```bash
git clone https://github.com/cloudbitsio/filament /etc/nginx
```

## Usage

You have three templates in the `templates` folder.

- `no-ssl.conf` is a simple http with no-www configs. Great for development
- `ssl.conf` is the one you should be using (provided you have an SSL certificate)
- `ssl-fastcgi.conf` is configured with NGINX fastcgi cache

Start by copying a template file to `sites-available`

```bash
cp /etc/nginx/templates/ssl.conf /etc/nginx/sites-available/http.conf
```

Replace `example.com` with your hostname

```bash
sed -i 's|example.com|myawesomewebsite.com|g' /etc/nginx/sites-available/http.conf
```

- Open the file and check the path to document root
- Enable the Wordpress server rules if you are using Wordpress. Otherwise discard/ignore.
- If you want site-specific logs, uncomment the `access_log` and `error_log` configs (make sure your log files exist)
- Provide path to your SSL certificates

`default.conf` is the default_server that returns 444 to all requests. Create symlinks of both the `default` server and your custom server into `sites-enabled`.

```bash
ln -s /etc/nginx/templates/default.conf /etc/nginx/sites-enabled/default.conf
ln -s /etc/nginx/sites-available/http.conf /etc/nginx/sites-enabled/http.conf
```

Finally, test your nginx configuration before you (re)start your service.

```bash
nginx -t
```

## What's Inside

The configurations have the following structure: 

```text
./
├── conf.d/
│   ├── performance/
│   │   ├── cache.conf
│   │   ├── cache-expires.conf
│   │   ├── cache-fastcgi.conf
│   │   ├── fastcgi-params.conf
│   ├── security/
│   │   ├── exclusions.conf
│   │   ├── policies.conf
│   └── ssl/
│   │   ├── ocsp-stapling.conf
│   │   ├── policy-deprecated.conf
│   │   ├── policy-intermediate.conf
│   │   ├── policy-modern.conf
│   │   ├── ssl-engine.conf
│   ├── wordpress/
│   │   ├── wordpress-cache.conf
│   │   ├── wordpress-security.conf
│   │   ├── wordpress-yoast.conf
│   ├── gzip.conf
│   ├── http.conf
│   ├── php-fpm.conf
├── sites-available/
├── sites-enabled/
├── templates/
│   ├── default.conf
│   ├── no-ssl.conf
│   ├── ssl.conf
│   ├── ssl-fastcgi.conf
├── mime.types
└── nginx.conf

```

* **`sites-available/` folder** should contain your working server blocks and drafts. Edit your server block files here because some test editors create temp files. 

* **`sites-enabled/` folder** should only contain symlinks to server blocks that are live.

* **`conf.d/` folder**

  Contains all the config snippets and are loaded automatically. Do not change anything inside unless you know what you are doing.

  If you need to change the PHP version, edit `php-fpm.conf`. 
  
  `http.conf` and `gzip.conf` are global HTTP and GZip rules that are applied to the http block in our `nginx.conf` main configuration file.

  * **`performance/` subfolder** contains files that improve performance of the web server blocks.

  * **`security/` subfolder** headers for cross-origin requests and security policies. Check out [securityheaders.com](https://securityheaders.com) for details.

    If you are using a no-ssl config with a `.test` domain for local development, disable HSTS in `policies.conf`

  * **`ssl/` subfolder** contains SSL rules: 

    - `ssl-engine.conf` contains the generic SSL rules

    - You have a choice between three SSL profiles: 
    
      `policy-deprecated.conf` supports TLS v1, v1.1 and 1.2. It is not recommended.

      `policy-intermediate.conf` supports only TLS v1.2

      `policy-modern.conf` supports TLS v1.2 and v1.3. This is the default in the provided templates.

    - `ocsp-stapling.conf` contains resolvers for CloudFlare, Google and OpenDNS.

  * **`wordpress/` subfolder** contains rules that are for performance and security for Wordpress.


* **`mime-types.conf` file** is responsible for mapping file extensions to mime types.

* **`nginx.conf` file** is the main configuration file.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## TODO

- Brotli support
- mod_pagespeed support

## Support

NGINX 1.8.0+

## Credits

This project would not have been possible without the following. In fact, much of the code snippets are borrowed from these projects.

- [H5BP server configs](https://github.com/h5bp/server-configs-nginx) boilerplate
- DigitalOcean [nginx config generator](https://do.co/nginxconfig)
- Many others


## License
[MIT](https://choosealicense.com/licenses/mit/)