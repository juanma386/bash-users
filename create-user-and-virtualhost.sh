#!/bin/bash

# Pedimos el nombre del usuario
echo "Ingresa el nombre del usuario:"
read username

# Verificamos si el usuario existe
if id "$username" >/dev/null 2>&1; then
    echo "El usuario $username ya existe."
else
    # Creamos el usuario
    sudo adduser --disabled-password --gecos "" $username

    # Configuramos el shell "rbash" para el usuario
    sudo usermod -s /bin/rbash $username

    # Creamos un archivo de configuración para el shell "rbash"
    sudo touch /home/$username/.bashrc

    # Permitimos solo los comandos necesarios para gestionar sus propios archivos
    echo "PATH=$PATH:/bin:/usr/bin:/usr/local/bin" | sudo tee -a /home/$username/.bashrc
    echo "alias cp='cp -i'" | sudo tee -a /home/$username/.bashrc
    echo "alias mv='mv -i'" | sudo tee -a /home/$username/.bashrc
    echo "alias rm='rm -i'" | sudo tee -a /home/$username/.bashrc

    # Asignamos el grupo "www-data" al usuario
    sudo usermod -a -G www-data $username

    # Configuramos los permisos del directorio del usuario
    sudo chown -R $username:$username /home/$username
    sudo chmod -R 700 /home/$username
fi

# Pedimos el nombre del dominio
echo "Ingresa el nombre del dominio:"
read domain

# Creamos el directorio del sitio en el directorio del usuario
sudo mkdir -p /home/$username/www/$domain

# Creamos el archivo index.html
echo "<html><body><h1>Bienvenido a $domain</h1></body></html>" | sudo tee /home/$username/www/$domain/index.html

# Asignamos el grupo "www-data" al directorio y sus archivos
sudo chown -R $username:www-data /home/$username/www/$domain
sudo chmod -R 750 /home/$username/www/$domain

# Creamos el archivo de configuración del sitio
sudo touch /etc/apache2/sites-available/$domain.conf

# Configuramos el archivo de configuración del sitio
echo "<VirtualHost *:80>" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    ServerName $domain" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    ServerAlias www.$domain" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    DocumentRoot /home/$username/www/$domain" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    ErrorLog ${APACHE_LOG_DIR}/error.log" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "    CustomLog ${APACHE_LOG_DIR}/access.log combined" | sudo tee -a /etc/apache2/sites-available/$domain.conf
echo "</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/$domain.conf

# Habilitamos el sitio
sudo a2ensite $domain.conf

sudo semanage fcontext -a -t httpd_sys_content_t "/home/$username/www/$domain(/.*)?" ? echo "Success SELinux" : echo "Error SELinux"

# Reiniciamos Apache2
sudo systemctl restart apache2
