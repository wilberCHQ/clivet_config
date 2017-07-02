#!/bin/bash
echo "Iniciando $NAME como `whoami`"
#================================================================================
PROJECT='CloudSYSbilioteca'
GIT_REP='https://gitlab.com/beth.ramos/CloudSYSbilioteca.git'
USER='BibliotecaUser'
#================================================================================
apt update
apt upgrade
apt-get install zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>Users"
groupadd --system webapps
useradd --system --gid webapps --shell /bin/bash --home /var/www/$PROJECT $USER
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>Virtual env"
apt install python-virtualenv
mkdir -p /var/www/
cd /var/www/
git clone $GIT_REP $PROJECT
chown $USER /var/www/$PROJECT/

su - $USER
cd /var/www/$PROJECT/
virtualenv .
source bin/activate
pip install -r requirements.txt
pip install gunicorn
su - root
chown -R $USER:users /var/www/$PROJECT
chmod -R g+w /var/www/$PROJECT
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>Gunicorn"
cd /var/www/$PROJECT
wget https://raw.githubusercontent.com/wilberCHQ/clivet_config/master/gunicorn_start -P /var/www/$PROJECT/bin/
chmod u+x bin/gunicorn_start
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>supervisor"
apt install supervisor
wget https://raw.githubusercontent.com/wilberCHQ/clivet_config/master/CloudSYSbilioteca.conf -P /etc/supervisor/conf.d/
mkdir -p /var/www/$PROJECT/logs/
touch /var/www/$PROJECT/logs/gunicorn_supervisor.log 
supervisorctl reread
supervisorctl update
supervisorctl status $PROJECT
#supervisorctl restart $PROJECT 
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>nginx"
apt install nginx
service nginx start
wget https://raw.githubusercontent.com/wilberCHQ/clivet_config/master/CloudSYSbilioteca -P /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/$PROJECT /etc/nginx/sites-enabled/$PROJECT
service nginx restart
