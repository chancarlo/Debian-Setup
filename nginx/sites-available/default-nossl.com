server {
    server_name default.com www.default.com;

    access_log /var/log/www/default.com/access.log;
    error_log /var/log/www/default.com/error.log;

    root /var/www/default.com/public;

	location / {
	try_files $uri $uri/ /index.php?$args;
	}
	
    include /etc/nginx/siteconf/locations.conf;
    include /etc/nginx/siteconf/phpwp.conf;
}
