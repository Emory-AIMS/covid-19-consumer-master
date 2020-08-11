FROM open-resty-base AS covid19

ARG _env
ARG mysql_dsn
ARG mysql_user
ARG mysql_password
ARG redis_dsn
ARG jwt_secret
ARG android_secret_captcha
ARG ios_secret_captcha
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

RUN mkdir /usr/local/openresty/lualib/lua_scripts

COPY ./root /

#Set aws Credentials
RUN mkdir -p /root/.aws/ && echo "[default]" > /root/.aws/credentials && \
    echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> /root/.aws/credentials && \
    echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> /root/.aws/credentials && \
# Set cron log file
    touch /var/log/cron.log && chmod 600 /var/spool/cron/crontabs/root && \
#Mysql
    sed -i -r "s/local mysql_dsn = \"mysql\"/local mysql_dsn = \""${mysql_dsn}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/database.lua && \
    sed -i -r "s/local mysql_user = \"root\"/local mysql_user = \""${mysql_user}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/database.lua && \
    sed -i -r "s/local mysql_password = \"example\"/local mysql_password = \""${mysql_password}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/database.lua && \
#Redis
    sed -i -r "s/local redis_dsn = \"redis\"/local redis_dsn = \""${redis_dsn}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/cache.lua && \
#JWT KEY
    sed -i -r "s/local jwt_secret = \"my_secret_key\"/local jwt_secret = \""${jwt_secret}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/jwt_handler.lua && \
#SET nginx configurations
    if [ "x$_env" = "x" ] ; then echo dev ; else cp /etc/nginx/conf.d/default.conf.prod /etc/nginx/conf.d/default.conf ; fi && \
#SET logrotate conf
    if [ "x$_env" = "x" ] ; then echo dev ; else cp /root/postrotate_prod.sh /root/postrotate.sh ; fi && \
#SET recaptcha secrets
    sed -i -r "s/local android_secret_captcha = \"android_secret_captcha\"/local android_secret_captcha = \""${android_secret_captcha}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/re-captcha.lua && \
    sed -i -r "s/local ios_secret_captcha = \"ios_secret_captcha\"/local ios_secret_captcha = \""${ios_secret_captcha}"\"/g" /usr/local/openresty/lualib/lua_scripts/covid19/re-captcha.lua && \
#SET nginx workers equals to the number of cores
    sed -i -r "s/worker_processes  1;/worker_processes `grep processor /proc/cpuinfo | wc -l`;/g" /usr/local/openresty/nginx/conf/nginx.conf

RUN mkdir -p /var/log/nginx/coronaviruscheck.org
RUN touch /var/log/nginx/coronaviruscheck.org/postdata.log
RUN touch /var/log/nginx/patientstatus.log
VOLUME [ "/var/log/nginx/", "/usr/local/openresty/lualib/lua_scripts/" ]

ENTRYPOINT [ "/init" ]