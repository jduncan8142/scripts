# This script installs the latest MeshCentral on Ubuntu 20.04
# Username must set to "fcadmin"
# TCP ports 22, 80, 443, 3389 should be open.

# Set some variables 
my_cert='"cert": "mesh.fosschurch.com",'
my_sessionKey='"sessionKey": "00wFXBTCizXiusL7MgD7",'
my_letencrypt='"letsencrypt": {'
my_email='jason.duncan@fosschurch.com'
my_names='mesh.fosschurch.com'
my_production='"production": false'
my_dbEncryptKey='"dbEncryptKey": "OnRrUL8U2Q8VVP6ojA2I",'
my_dbRecordsEncryptKey='"dbRecordsEncryptKey": "OnRrUL8U2Q8VVP6ojA2I",'
my_dbRecordsDecryptKey='"dbRecordsDecryptKey": "OnRrUL8U2Q8VVP6ojA2I",'

# Refresh repos & update OS to make sure we are current
sudo apt-get update && sudo apt-get upgrade -y

# Make sure we have some dependent packages for later in the script
sudo apt-get install neovim gnupg -y

# Install & start MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update
sudo apt-get install mongodb-org -y
sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl start mongod
sudo systemctl status mongod

# Start from the home folder
cd ~

# Install NodeJS
sudo apt-get install npm -y
sudo apt-get install nodejs -y

# Set NodeJS port permissions
sudo setcap cap_net_bind_service=+ep /usr/bin/node

# Install MeshCentral
npm install meshcentral

# Set production mode
export NODE_ENV=production

# Create a MeshCentral config.json from the sample
mkdir ~/meshcentral-data
cp ~/node_modules/meshcentral/sample-config-advanced.json ~/meshcentral-data/config.json

# Set WANonly, MPS port, MongoDB and other options in config.json
sed -i -e 's/"_MongoDb":/"MongoDb":/g' ~/meshcentral-data/config.json
sed -i -e "s/\"_cert\": \"myserver.mydomain.com\",/$my_cert/g" ~/meshcentral-data/config.json
sed -i -e "s/\"_sessionKey\": \"MyReallySecretPassword1\",/$my_sessionKey/g" ~/meshcentral-data/config.json
sed -i -e "s/\"_letsencrypt\": {/$my_letencrypt/g" ~/meshcentral-data/config.json
sed -i -e "s/myemail@mydomain.com/$my_email/g" ~/meshcentral-data/config.json
sed -i -e "s/myserver.mydomain.com/$my_names/g" ~/meshcentral-data/config.json
sed -i -e "s/\"production\": false/$my_production/g" ~/meshcentral-data/config.json
sed -i -e "s/\"_dbEncryptKey\": \"MyReallySecretPassword2\",/$my_dbEncryptKey/g" ~/meshcentral-data/config.json
sed -i -e "s/\"dbRecordsEncryptKey\": \"MyReallySecretPassword\",/$my_dbRecordsEncryptKey/g" ~/meshcentral-data/config.json
sed -i -e "s/\"_dbRecordsDecryptKey\": \"MyReallySecretPassword\",/$my_dbRecordsDecryptKey/g" ~/meshcentral-data/config.json

# Generate short server commands
echo "sudo systemctl start meshcentral.service" > start
chmod 755 start
echo "sudo systemctl stop meshcentral.service" > stop
chmod 755 stop
echo "sudo systemctl restart meshcentral.service" > restart
chmod 755 restart
echo -e "sudo systemctl stop meshcentral.service\nnpm install meshcentral\nsudo systemctl start meshcentral.service\n" > update
chmod 755 update
echo -e "mongodump --archive=backup.archive" > dbbackup
chmod 755 dbbackup

# Setup Systemd to launch MeshCentral
echo -e "\n[Unit]\nDescription=MeshCentral Server\n\n[Service]\nType=simple\nLimitNOFILE=1000000\nExecStart=/usr/bin/node /home/default/node_modules/meshcentral\nWorkingDirectory=/home/default\nUser=default\nGroup=default\nRestart=always\n# Restart service after 10 seconds if node service crashes\nRestartSec=10\n\n[Install]\nWantedBy=multi-user.target\n" > meshcentral.service
sudo cp meshcentral.service /etc/systemd/system/meshcentral.service
rm meshcentral.service
sudo systemctl enable meshcentral.service
sudo systemctl start meshcentral.service
echo "Done. Wait two minutes and use a browser to access this server..."
echo "WARNING: First user account to be created is site administrator."



