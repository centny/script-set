#!/bin/bash
domain=$1
pemfile=/etc/letsencrypt/live/$domain/fullchain.pem
if [ -f "$pemfile" ];
then
    if openssl x509 -checkend 864000 -noout -in $pemfile 
    then
        echo "Cert $domain is valid"
    else
        echo "Cert $domain is not valid, will renew it"
        certbot certonly --nginx -d $domain --staple-ocsp -m centny@qq.com --agree-tos
    fi
else
    echo "Cert $domain is not exist, will create it"
    certbot certonly --nginx -d $domain --staple-ocsp -m centny@qq.com --agree-tos
fi

sed -e 's/sxbastudio/'$domain'/g' $2 > /etc/nginx/conf.d/$domain.conf

if nginx -t
then
    systemctl reload nginx
else
    echo "nginx configure file is fail by "
    cat /etc/nginx/conf.d/$domain.conf
    rm -f /etc/nginx/conf.d/$domain.conf
fi