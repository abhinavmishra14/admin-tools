#!/bin/sh

# CUSTOM START

if [[ $APP_PROJECT ]]; then
  rm -rf /usr/share/nginx/html/*
  unzip /tmp/apps/${APP_PROJECT}.zip -d /usr/share/nginx/html -o
  rm -rf /usr/share/nginx/html/META-INF && rm -rf /usr/share/nginx/html/WEB-INF
  echo "Project '${APP_PROJECT}' started."
fi

if [[ $APP_ENV ]]; then
  lowercase=$(echo "$APP_ENV" | tr '[:upper:]' '[:lower:]')
  yes | cp -f /usr/share/nginx/html/app.config.${lowercase}.json /usr/share/nginx/html/app.config.json
fi

# CUSTOM END

cp ./app.config.json /tmp/app.config.json
cp ./index.html /tmp/index.html

if [ -n "${APP_CONFIG_AUTH_TYPE}" ];then
  sed -e "s/\"authType\": \".*\"/\"authType\": \"${APP_CONFIG_AUTH_TYPE}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

# CUSTOM START
if [ -n "${APP_CONFIG_PROVIDERS}" ];then
  sed -e "s/\"providers\": \".*\"/\"providers\": \"${APP_CONFIG_PROVIDERS}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi
# CUSTOM END

if [ -n "${APP_CONFIG_OAUTH2_HOST}" ];then
  replace="\/"
  encoded=${APP_CONFIG_OAUTH2_HOST//\//$replace}
  sed -e "s/\"host\": \".*\"/\"host\": \"${encoded}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [ -n "${APP_CONFIG_OAUTH2_CLIENTID}" ];then
  sed -e "s/\"clientId\": \".*\"/\"clientId\": \"${APP_CONFIG_OAUTH2_CLIENTID}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [ -n "${APP_CONFIG_OAUTH2_IMPLICIT_FLOW}" ];then
 sed "/implicitFlow/s/true/${APP_CONFIG_OAUTH2_IMPLICIT_FLOW}/" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [ -n "${APP_CONFIG_OAUTH2_SILENT_LOGIN}" ];then
 sed "/silentLogin/s/true/${APP_CONFIG_OAUTH2_SILENT_LOGIN}/" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [ -n "${APP_CONFIG_OAUTH2_REDIRECT_SILENT_IFRAME_URI}" ];then
  replace="\/"
  encoded=${APP_CONFIG_OAUTH2_REDIRECT_SILENT_IFRAME_URI//\//$replace}
  sed -e "s/\"redirectSilentIframeUri\": \".*\"/\"redirectSilentIframeUri\": \"${encoded}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [ -n "${APP_CONFIG_OAUTH2_REDIRECT_LOGIN}" ];then
  replace="\/"
  encoded=${APP_CONFIG_OAUTH2_REDIRECT_LOGIN//\//$replace}
  sed -e "s/\"redirectUri\": \".*\"/\"redirectUri\": \"${encoded}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [ -n "${APP_CONFIG_OAUTH2_REDIRECT_LOGOUT}" ];then
  replace="\/"
  encoded=${APP_CONFIG_OAUTH2_REDIRECT_LOGOUT//\//$replace}
  sed -e "s/\"redirectUriLogout\": \".*\"/\"redirectUriLogout\": \"${encoded}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [[ $ACSURL ]]; then
  replace="\/"
  encoded=${ACSURL//\//$replace}
  sed -i s%{protocol}//{hostname}{:port}%"$encoded"%g /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

if [[ $BASEPATH ]]; then
  replace="\/"
  encoded=${BASEPATH//\//$replace}
  sed -i s%href=\"/\"%href=\""$encoded"\"%g /tmp/index.html && \
  cat /tmp/index.html > ./index.html
fi

if [ -n "${APP_BASE_SHARE_URL}" ];then
  replace="\/"
  encoded=${APP_BASE_SHARE_URL//\//$replace}
  sed -e "s/\"baseShareUrl\": \".*\"/\"baseShareUrl\": \"${encoded}\"/g" \
    -i /tmp/app.config.json && \
  cat /tmp/app.config.json > ./app.config.json
fi

# CUSTOM

if [[ $APP_PROTOCOL ]]; then
  replace="\/"
  encoded=${APP_PROTOCOL//\//$replace}
  sed -e "s/\"host\": \"https/\"host\": \"${encoded}/g" -i /usr/share/nginx/html/app.config.json 
fi

if [[ $APP_AUTH_TYPE ]]; then
  replace="\/"
  encoded=${APP_AUTH_TYPE//\//$replace}  
  sed -e "s/\"authType\": \"BASIC/\"authType\": \"${encoded}/g" -i /usr/share/nginx/html/app.config.json 
fi

# CUSTOM NGINX

cp /etc/nginx/nginx.conf /tmp/nginx.conf
if [[ $ACS_PROXY_URL ]]; then
  replace="\/"
  encoded=${ACS_PROXY_URL//\//$replace}
  sed -i "s/PROXY_URL/$encoded/g" /tmp/nginx.conf && \
  cat /tmp/nginx.conf > /etc/nginx/nginx.conf
fi

cp /etc/nginx/nginx.conf /tmp/nginx.conf
if [[ $APS_PROXY_URL ]]; then
  replace="\/"
  encoded=${APS_PROXY_URL//\//$replace}
  sed -i "s/PROXY_APS_URL/$encoded/g" /tmp/nginx.conf && \
  cat /tmp/nginx.conf > /etc/nginx/nginx.conf
else
  replace="\/"
  encoded=${ACS_PROXY_URL//\//$replace}
  sed -i "s/PROXY_APS_URL/$encoded/g" /tmp/nginx.conf && \
  cat /tmp/nginx.conf > /etc/nginx/nginx.conf
fi

nginx -g "daemon off;"
