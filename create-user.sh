#!/bin/bash

# Pedimos el nombre del usuario
echo "Ingresa el nombre del usuario:"
read username

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

# Configuramos los permisos del directorio /var/www
sudo chown -R www-data:www-data /var/www
sudo chmod -R g+rwX /var/www

# Agregamos el usuario al grupo www-data para poder acceder a los archivos
sudo usermod -a -G www-data $username

# Configuramos los permisos de los archivos del usuario
sudo chown -R $username:$username /home/$username
sudo chmod -R 700 /home/$username
