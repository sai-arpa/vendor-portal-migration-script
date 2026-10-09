sudo apt update

sudo apt install \
    git \
    build-essential \
    make \
    gcc \
    postgresql-server-dev-18 \
    freetds-dev
    
    
cd /tmp
git clone https://github.com/tds-fdw/tds_fdw.git
cd tds_fdw
make
sudo make install