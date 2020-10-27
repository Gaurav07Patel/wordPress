#!/user/bin/env bash

tarball="wordpress-5.1.1.tar.gz"

password="Password123"

Apache_Installation(){
  echo "Installation of Apache web-server is started..."
  cd "$HOME"
  sudo yum install httpd -y
  echo "Staring apache web-server..."
  sudo systemctl start httpd.service 
  sudo systemctl enable httpd.service
  echo "***    Apache web-server installed & started successfully!     ***" 
}

MySQL_Installation(){
  echo "Instalation of MariaDB-server is started..."
  cd "$HOME"
  sudo yum install mariadb-server mariadb -y
  echo "Starting mardiadb server..."
  echo "..."
  sudo systemctl start mariadb
  echo "mySQL_secure_installation..." 
  mysql -u root -p 'Password123' -e "UPDATE mysql.user SET Password=PASSWORD('$password') WHERE User='root'; "
  mysql -u root -p 'Password123' -e "DELETE FROM mysql.user WHERE User='root' AND Host not in ('localhost', '127.0.0.1' , '::1');"
  mysql -u root -p 'Password123' -e "DELETE FROM mysql.user WHERE User='root' AND Host not in ('localhost', '127.0.0.1' , '::1');"
  mysql -u root -p 'Password123' -e "DELETE FROM mysql.user WHERE User='';"
  mysql -u root -p 'Password123' -e "DROP DATABASE test;"
  mysql -u root -p 'Password123' -e "FLUSH PRIVILEGES;"
  sudo systemctl enable mariadb.service
  echo "*** mariadb-server securely Installed successfully! ***"
}

PHP_Installation(){
  echo "Installation of PHP started..."
  cd "$HOME"
  sudo yum install php libapache2-mod-php php-mysql -y
  sudo systemctl restart httpd.service
  echo "PHP installed successfully"
}

Create_SQL_User() {
    echo "Creating mysql user for wordpress..."
    cd $HOME
    mysql -u root -p$password -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    mysql -u root -p$password -e "CREATE USER IF NOT EXISTS wpuser@localhost IDENTIFIED BY 'user1pwd';"
    mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON wordpress.* TO wpuser@localhost IDENTIFIED BY 'user1pwd';"
    mysql -u root -p$password -e "FLUSH PRIVILEGES;"
    echo "User created for mySQL successfully..."
}

Wordpress_Installation() {
  echo " Installation of wordpress started..."
  cd $HOME
  sudo yum install php-gd -y
  sudo systemctl restart httpd.service
  wget https://wordpress.org/$tarball
  tar -xzf $tarball
  sudo rsync -avP ~/wordpress/ /var/www/html/
  mkdir /var/www/html/wp-content/uploads
  sudo chown -R apache:apache /var/www/html/*
  sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i s/database_name_here/wordpress/ /var/www/html/wp-config.php
  sed -i s/username_here/wordpressuser/ /var/www/html/wp-config.php
  sed -i s/password_here/password/ /var/www/html/wp-config.php
  echo "Wordpress Installed..."
}

echo "Running script to set up wordpress"
Apache_Installation
MySQL_Installation
PHP_Installation
Create_SQL_User
Wordpress_Installation
echo "All set..."