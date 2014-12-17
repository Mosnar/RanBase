#!/usr/bin/env bash


# Determine if this machine has already been provisioned
# Basically, run everything after this command once, and only once
if [ -f "/var/vagrant_provision" ]; then
    exit 0
fi

function say {
    printf "\n--------------------------------------------------------\n"
    printf "\t$1"
    printf "\n--------------------------------------------------------\n"
}

db='hackharmony'

# Install Apache
say "Installing Apache and setting it up."
    # Update aptitude library
    apt-get update >/dev/null 2>&1
    # Install apache2
    apt-get install -y apache2 >/dev/null 2>&1
    # Remove /var/www path
    rm -rf /var/www
    # Symbolic link to /vagrant/site path
    ln -fs /vagrant/application /var/www
    # Enable mod_rewrite
    a2enmod rewrite

    sudo echo ServerName localhost >> /etc/apache2/httpd.conf

# Install mysql
say "Installing MySQL."
export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y mysql-server >/dev/null 2>&1
    sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
    restart mysql
    mysql -u root mysql <<< "GRANT ALL ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;"


say "Installing handy packages"
    apt-get install -y curl git-core ftp unzip imagemagick >/dev/null 2>&1

say "Creating the database '$db'"
    mysql -u root -e "create database $db"

#
# There is a shared 'sql' directory that contained a .sql (database dump) file.
# This directory is part of the project path, shared with vagrant under the /vagrant path.
# We are populating the msyql database with that file. In this example it's called databasename.sql
#
say "Populating Database"
#    mysql -u root -D $db < /vagrant/sql/$db.sql TODO: Migrations

say "Installing PHP Modules"
    # Install php5, libapache2-mod-php5, php5-mysql curl php5-curl
    apt-get install -y php5 php5-cli php5-common php5-dev php5-imagick php5-imap php5-gd libapache2-mod-php5 php5-mysql php5-curl >/dev/null 2>&1

# Restart Apache
say "Restarting Apache"
#    mkdir /var/www
    service apache2 restart

# Install Phalcon
say "Installing Zephir and Phalcon 2.0"
    # Clone repos
    git clone -b 2.0.0 https://github.com/phalcon/cphalcon.git
    git clone https://github.com/phalcon/zephir.git
    git clone https://github.com/phalcon/json-c.git
    # Install dependencies
    apt-get install -y php5-dev php5-mysql gcc make
    sudo apt-get -y install re2c libpcre3-dev
    # Compile json-c
    cd json-c
    sudo sh autogen.sh
    sudo ./configure
    sudo make
    sudo make install
    cd ..
    # Compile Zephir
    cd zephir
    sudo ./install
    cd ..
    cd cphalcon
    sudo ../zephir/bin/zephir build

#    sudo echo extension=phalcon.so >> /etc/php5/apache2/php.ini
#    sudo echo extension=phalcon.so >> /etc/php5/cli/php.ini
    sudo echo extension=phalcon.so >> /etc/php5/mods-available/phalcon.ini
    sudo php5enmod phalcon

say "Installing Phalcon Dev Tools"
    git clone git://github.com/phalcon/phalcon-devtools.git
    cd phalcon-devtools
    sudo ./phalcon.sh
    sudo ln -fs ~/phalcon-devtools/phalcon.php /usr/bin/phalcon
    sudo chmod ugo+x /usr/bin/phalcon
    cd ../

say "Installing Beanstalkd Queue"
    apt-get install -y beanstalkd
    echo START=yes >> /etc/default/beanstalkd

say "Installing Redis Cache"
    apt-get install -y tcl8.5
    wget http://download.redis.io/releases/redis-2.8.9.tar.gz
    tar xzf redis-2.8.9.tar.gz
    cd redis-2.8.9
    make
    make test
    sudo make install
    cd utils
    sudo ./install_server.sh
    sudo update-rc.d redis_6379 defaults

## Let this script know not to run again
touch /var/vagrant_provision