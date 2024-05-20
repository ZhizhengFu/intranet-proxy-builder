# Define versions
NGINX_VERSION=1.19.9
OPENSSL_VERSION=3.0.13
PCRE_VERSION=8.35
ZLIB_VERSION=1.3.1
NGINX_PREFIX=/usr/local/nginx
NGINX_CONF=$NGINX_PREFIX/conf/nginx.conf

# Install required packages
# sudo apt-get update
# sudo apt-get install -y build-essential libssl-dev zlib1g-dev libpcre3 libpcre3-dev wget git

# Download and extract nginx
wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
tar -xzf nginx-$NGINX_VERSION.tar.gz

# Download and extract dependencies
wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
tar -xzf openssl-$OPENSSL_VERSION.tar.gz

wget https://sourceforge.net/projects/pcre/files/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz
tar -xzf pcre-$PCRE_VERSION.tar.gz

wget https://zlib.net/zlib-$ZLIB_VERSION.tar.gz
tar -xzf zlib-$ZLIB_VERSION.tar.gz

# Clone ngx_http_proxy_connect_module repository
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git

# Apply patch to nginx
cd nginx-$NGINX_VERSION
patch -p1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_1018.patch

# Configure nginx with modules and dependencies
sudo ./configure \
  --with-openssl=../openssl-$OPENSSL_VERSION \
  --with-pcre=../pcre-$PCRE_VERSION \
  --with-zlib=../zlib-$ZLIB_VERSION \
  --add-module=../ngx_http_proxy_connect_module \
  --prefix=$NGINX_PREFIX \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-threads

# Compile and install nginx
sudo make
sudo make install

# Verify nginx installation
$NGINX_PREFIX/sbin/nginx -V

# Configure nginx
if [ -f $NGINX_CONF ]; then
  sudo mv $NGINX_CONF ${NGINX_CONF}.old
fi

# Configure nginx
cat <<EOL | sudo tee $NGINX_CONF
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server{
      listen 8000;
      resolver 114.114.114.114;
      proxy_connect;
      proxy_connect_allow 443 563;
      proxy_connect_connect_timeout 10s;
      proxy_connect_read_timeout 10s;
      proxy_connect_send_timeout 10s;
      location / {
          proxy_pass http://\$host;
          proxy_set_header Host \$host;
      }
    }
}
EOL

# Test nginx configuration
sudo $NGINX_PREFIX/sbin/nginx -t

# Start nginx with new configuration
sudo $NGINX_PREFIX/sbin/nginx -c $NGINX_CONF
sudo $NGINX_PREFIX/sbin/nginx -s reload

echo "nginx installation and configuration completed."
