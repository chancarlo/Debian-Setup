server {   
    listen 80;
    #listen 80 reuseport fastopen=256;
    server_name default.com www.default.com;
    return 301 https://www.default.com$request_uri;
}

server {
    listen 443 ssl http2;
    #listen 443 ssl http2 backlog=2048 reuseport fastopen=256;
    server_name default.com www.default.com;

    if ($host = 'default.com') {
    return 301 https://www.default.com$request_uri;
    }

    ssl_certificate   /etc/letsencrypt/live/default.com/fullchain.pem;
    ssl_certificate_key   /etc/letsencrypt/live/default.com/privkey.pem;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    include /etc/nginx/siteconf/ssl.conf;
    #add_header Strict-Transport-Security max-age=15768000;
    
    access_log /var/log/www/default.com/access.log;
    error_log /var/log/www/default.com/error.log;

    root /var/www/default.com/public;
    
    include /etc/nginx/siteconf/locations.conf;
    #include /etc/nginx/siteconf/errorpage.conf;

    #Xenforo specific
    include /etc/nginx/siteconf/phpxf.conf;
    include /etc/nginx/siteconf/xenforo.conf;

    # Xenforo root location
    location / {
    limit_req zone=xfone burst=5;
    include /etc/nginx/siteconf/security.conf;
    try_files $uri $uri/ /index.php?$uri&$args;
    }
}