# Check if in vagrant directory
vagrantfile_exists=$(ls Vagrantfile)
if [[ ${#vagrantfile_exists} -eq "0" ]]; then
    echo 'Failed - please run this command in the directory of the Vagrantfile'
    exit 1
fi

# Copy wp-config to root if exists
wp_config_exists=$(ls public/wp-config.php)
if [[ ${#wp_config_exists} -ne "0" ]]; then
    echo 'Copying wp-config.php to root'
   $(cp public/wp-config.php wp-config.php)
fi

# Copy uploads to root if exists
uploads_folder_exists=$(ls public/wp-content/uploads)
if [[ ${#uploads_folder_exists} -ne "0" ]]; then
    echo 'Copying uploads folder to root'
   $(cp -r  public/wp-content/uploads uploads)
fi

# Copy uploads to root if exists
htaccess_exists=$(ls public/.htaccess)
if [[ ${#htaccess_exists} -ne "0" ]]; then
    echo 'Copying .htaccess to root'
   $(cp -r  public/.htaccess .htaccess)
fi

# Destroy vagrant environment and DB dump
# SSH into box and dump all databases
echo 'Dumping databases to root and destroying VM...'
$(vagrant up)
$(vagrant ssh -c "mysqldump -u root -proot --all-databases > /var/www/public/all_dbs.sql && exit")
$(vagrant destroy --f )
$(cp public/all_dbs.sql all_dbs.sql)

echo 'Compressing project folder...'

wd=$(pwd)

hostname=$(grep 'config.vm.hostname' Vagrantfile)

searchstring="\""
rest_of_hostname=${hostname#*$searchstring}
stripped_hostname=${rest_of_hostname//[\"]/''} 
echo $stripped_hostname

# Compress remaining project folder
# Copy compressed file to parent directory
# # Delete uncompressed folder
$(rm -rf public && tar -zcvf ${stripped_hostname}.tar.gz . && cp ${stripped_hostname}.tar.gz ../${stripped_hostname}.tar.gz)

$(cd .. && rm -rf ${wd})

