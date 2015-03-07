worker_processes  2;
daemon off;
error_log logs/error.log warn;
user $$NGINX_USER $$NGINX_USER;

events {
    worker_connections 1024;
}


http {
    access_log off;
    resolver 8.8.8.8 8.8.4.4;
    server {
        listen 80;

        # allow larger uploads
        client_body_buffer_size 10M;
        
        # To enable SSL on nginx uncomment and configure the following lines
        # We enable TLS, but not SSLv2/SSLv3 which is weak and should no longer be used and disable all weak ciphers.
        # Provide full path to certificate bundle (ssl-bundle.crt) and private key (juliabox.key). Rename as appropriate.
        # All HTTP traffic is redirected to HTTPS
        
        #listen 443 default_server ssl;

        #ssl_certificate        ssl-bundle.crt;
        #ssl_certificate_key    juliabox.key;
        
        #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        #ssl_ciphers ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM;

        #if ($http_x_forwarded_proto = 'http') {
        #    return 302 https://$host$request_uri;
        #}

        #if ($scheme = http) {
        #    return 302 https://$host$request_uri;
        #}

        root www;

        set $SESSKEY '$$SESSKEY';
        client_max_body_size 20M;
        
        location /favicon.ico {
            include    mime.types;
        }

        location /assets/ {
            include    mime.types;
        }
        
        location /timedout.html {
        	internal;
        }
        
        error_page 502 /timedout.html;

# On the host, all locations will be specified explictly, i.e, with an "="
# Everything else will be proxied to the appropriate container....
# Cookie data will be used to identify the container for a session
        
        location = / {
            proxy_pass          http://localhost:8888;
            proxy_set_header    Host            $host;
            proxy_set_header    X-Real-IP       $remote_addr;
            proxy_set_header    X-Forwarded-for $remote_addr;        
        }        

        location ~ \/(hostlaunchipnb|hostadmin|ping|cors|hw|jbapi)+\/  {
            proxy_pass          http://localhost:8888;
            proxy_set_header    Host            $host;
            proxy_set_header    X-Real-IP       $remote_addr;
            proxy_set_header    X-Forwarded-for $remote_addr;
        }        
        

# container locations

# file upload and listing....
        location /hostupload/ {
            # wait for n seconds for the container's upl listener to be ready...
            access_by_lua '
                dofile(ngx.config.prefix() .. "lua/validate.lua")
                
                local http  = require "resty.http.simple"
                local n = 20
                local hostuplport = ngx.var.cookie_hostupload
                local opts = {}
                opts.path = "/ping"

                while (n > 0) do
                    local res, err = http.request("127.0.0.1", hostuplport, opts)
                    if not res then
                        ngx.sleep(1.0)
                    else
                        return
                    end
                    n = n - 1
                end
                return
            ';
        
            rewrite /hostupload/(.+) /$1 break;
            
            proxy_pass http://127.0.0.1:$cookie_hostupload/$1$is_args$query_string;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_read_timeout  600;
        }

# shell....
        location /hostshell/ {
            access_by_lua '
                dofile(ngx.config.prefix() .. "lua/validate.lua")
                
                local http  = require "resty.http.simple"
                local n = 20
                local hostshellport = ngx.var.cookie_hostshell
                local opts = {}
                opts.path = "/"

                while (n > 0) do
                    local res, err = http.request("127.0.0.1", hostshellport, opts)
                    if not res then
                        ngx.sleep(1.0)
                    else
                        return
                    end
                    n = n - 1
                end
                return
            ';
        
            rewrite /hostshell/(.+) /$1 break;
            
            proxy_pass http://127.0.0.1:$cookie_hostshell/$1$is_args$query_string;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }


# landing page
        location = /hostipnbsession/ {
            # wait for n seconds for the container's ipnb listener to be ready...
            access_by_lua '
                dofile(ngx.config.prefix() .. "lua/validate.lua")
                
                local http  = require "resty.http.simple"
                local n = 20
                local hostipnbport = ngx.var.cookie_hostipnb
                local opts = {}
                opts.path = "/"

                while (n > 0) do
                    local res, err = http.request("127.0.0.1", hostipnbport, opts)
                    if not res then
                        ngx.sleep(1.0)
                    else
                        return
                    end
                    n = n - 1
                end
                return
            ';
        
            proxy_pass http://127.0.0.1:$cookie_hostipnb/;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

# everything else        
        location / {
            access_by_lua_file 'lua/validate.lua';
            
            proxy_pass http://127.0.0.1:$cookie_hostipnb;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # WebSocket support (nginx 1.4)
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout  600;            
        }
        
    }
}

