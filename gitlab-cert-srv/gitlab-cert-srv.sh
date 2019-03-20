#!/bin/bash
cert_auto=/srv/certbot/certbot-auto
nginx_out=/etc/nginx/conf.d/gitlab.d
check_dir=/etc/letsencrypt/live/
cert_hosts=()

proc_gitlab(){
    branches=`node -e 'JSON.parse(process.argv[1]).forEach((n)=>console.log(n.title))' "$(curl -s curl --header 'Private-Token: '$1 https://$2/api/v4/projects/$3/milestones?state=active)"`
    for branch in $branches
    do
        branch=${branch//./}
        echo "start check cert by $branch$4"
        if [ -f /etc/letsencrypt/live/$branch$4/fullchain.pem ];then
                if openssl x509 -checkend $((24*3600*3)) -noout -in /etc/letsencrypt/live/$branch$4/fullchain.pem
                then
                        echo "cert by $branch$4 is valid"
                else
                        echo "start renew cert by $branch$4"
                        $cert_auto certonly --nginx -d $branch$4
                fi
        else
                echo "start create cert by $branch$4"
                $cert_auto certonly --nginx -d $branch$4

        fi
        if [ ! -f $nginx_out/$branch$4.conf ];then
                mkdir -p $nginx_out/
                cat gitlab-cert-tmpl.conf | sed -i "s/CERT_HOME/$branch$4/g" > $nginx_out/$branch$4.conf
        fi
    done
}

proc_certbot(){
    for host in $cert_hosts
    do
        if [ -f /etc/letsencrypt/live/$host/fullchain.pem ];then
                if openssl x509 -checkend $((24*3600*3)) -noout -in /etc/letsencrypt/live/$host/fullchain.pem
                then
                        echo "cert by $host is valid"
                else
                        echo "start renew cert by $host"
                        $cert_auto certonly --nginx -d $host
                fi
        fi
    done
}

while true
do
        proc_certbot
        proc_gitlab <token> <gitlab> <project> <host>
        sleep 3600
done