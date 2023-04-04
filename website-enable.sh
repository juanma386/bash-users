#!/bin/bash

# Pedimos el nombre del dominio
echo "Ingresa el nombre del dominio:"
read domain

# Creamos el directorio del sitio
sudo mkdir /var/www/$domain

# Creamos el archivo index.html
echo "<html><body><h1>Bienvenido a $domain</h1></body></html>" | sudo tee /var/www/$domain/index.html

# Asignamos el grupo "www-data" al directorio y sus archivos
sudo chown -R $USER:www-data /var/www/$domain
sudo chmod -R 750 /var/www/$domain

# Creamos el archivo de configuración del sitio
sudo touch /etc/apache2/sites-available/$domain.conf

# Configuramos el archivo de configuración del sitio
echo "<VirtualHost *:80>" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    ServerName $domain" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    ServerAlias www.$domain" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    DocumentRoot /var/www/$domain" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/$domain.conf

# Habilitamos el sitio
sudo a2ensite $domain.conf

# Reiniciamos Apache2
sudo systemctl restart apache2
