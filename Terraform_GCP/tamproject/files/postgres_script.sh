#! /bin/bash
#sudo -i
sudo wget https://ftp.postgresql.org/pub/source/v12.0/postgresql-12.0.tar.gz
sudo apt-get update -y
sudo gunzip postgresql-12.0.tar.gz
sudo tar xf postgresql-12.0.tar
cd postgresql-12.0
sudo apt install build-essential -y
sudo apt-get install zlib1g-dev -y
sudo ./configure --without-readline
sudo make
sudo make install
sudo useradd -s /bin/bash -m -p $(openssl passwd -1 postgres) postgres
sudo mkdir /usr/local/pgsql/data
sudo chown postgres /usr/local/pgsql/data
sudo su - postgres <<!
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start
/usr/local/pgsql/bin/createdb test2
/usr/local/pgsql/bin/psql test2
!
