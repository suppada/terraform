#!/bin/bash

#-----------Install Docker and related packages:
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt-get install docker-ce

#-----------Enable sudo-less Docker:
sudo usermod -aG docker vagrant

#-----------Install Node.js and NPM:
sudo curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
sudo chmod +x nodesource_setup.sh
sudo ./nodesource_setup.sh
sudo apt-get install nodejs
sudo apt-get install build-essential
 
#-----------Add the forethought application to the home directory (or whatever directory you wish to work from):
sudo apt-get install git -y
git clone https://github.com/linuxacademy/content-devops-monitoring-app.git forethought
 
#-----------Create an image:
cd forethought
docker build -t forethought .
sudo docker run --name ft-app -p 80:8080 -d forethought


#------------------------------------------------------------Prometheus Installation:----------------------------------------#


#-----------Create a system user for Prometheus:
sudo useradd --no-create-home --shell /bin/false prometheus

#-----------Create the directories in which we'll be storing our configuration files and libraries:
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

#-----------Set the ownership of the /var/lib/prometheus directory:
sudo chown prometheus:prometheus /var/lib/prometheus

#-----------Pull down the tar.gz file from the Prometheus downloads page:
cd /tmp/
wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz

#-----------Extract the files:
tar -xvf prometheus-2.7.1.linux-amd64.tar.gz

#-----------Move the configuration file and set the owner to the prometheus user:
cd prometheus-2.7.1.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

#-----------Move the binaries and set the owner:
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
 
#-----------Create the service file:
sudo vim /etc/systemd/system/prometheus.service

#-----------Add:

[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target

Save and exit.

#-----------Reload systemd:
sudo systemctl daemon-reload

#-----------Start Prometheus, and make sure it automatically starts on boot:
sudo systemctl start prometheus
sudo systemctl enable prometheus

Visit Prometheus in your web browser at PUBLICIP:9090.

#------------------------------------------------------------Alertmanager:----------------------------------------#

#-----------Create the alertmanager system user:
sudo useradd --no-create-home --shell /bin/false alertmanager

#-----------Create the /etc/alertmanager directory:
sudo mkdir /etc/alertmanager

#-----------Download Alertmanager from the Prometheus downloads page:
cd /tmp/
wget https://github.com/prometheus/alertmanager/releases/download/v0.16.1/alertmanager-0.16.1.linux-amd64.tar.gz

#-----------Extract the files:
tar -xvf alertmanager-0.16.1.linux-amd64.tar.gz

#-----------Move the binaries:
cd alertmanager-0.16.1.linux-amd64
sudo mv alertmanager /usr/local/bin/
sudo mv amtool /usr/local/bin/

#-----------Set the ownership of the binaries:
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

#-----------Move the configuration file into the /etc/alertmanager directory:
sudo mv alertmanager.yml /etc/alertmanager/

#-----------Set the ownership of the /etc/alertmanager directory:
sudo chown -R alertmanager:alertmanager /etc/alertmanager/

#-----------Create the alertmanager.service file for systemd:
sudo vim /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml
[Install]
WantedBy=multi-user.target

Save and exit.

#-----------Stop Prometheus, and then update the Prometheus configuration file to use Alertmanager:
sudo systemctl stop prometheus
sudo vim /etc/prometheus/prometheus.yml

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093

#-----------Reload systemd, and then start the prometheus and alertmanager services:
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl start alertmanager

#-----------Make sure alertmanager starts on boot:
sudo systemctl enable alertmanager

Visit PUBLICIP:9093 in your browser to confirm Alertmanager is working.


#------------------------------------------------------------Grafana Setup:----------------------------------------#

While Prometheus provides us with a web UI to view our metrics and craft charts, the web UI alone is often not the best solution to visualizing our data. 
Grafana is a robust visualization platform that will allow us to better see trends in our metrics and give us insight into what's going on with our applications and servers. 
It also lets us use multiple data sources, not just Prometheus, which gives us a full view of what's happening.

#-----------Install the prerequisite package:
sudo apt-get install libfontconfig

#-----------Download and install Grafana using the .deb package provided on the Grafana download page:
wget https://dl.grafana.com/oss/release/grafana_5.4.3_amd64.deb
sudo dpkg -i grafana_5.4.3_amd64.deb

#-----------Ensure Grafana starts at boot:
sudo systemctl enable --now grafana-server

Access Grafana's web UI by going to IPADDRESS:3000

Log in with the username admin and the password admin. Reset the password when prompted.


#-----------Add a Data Source:
Click Add data source on the homepage.

Select Prometheus.

Set the URL to http://localhost:9090.

Click Save & Test.

#-----------Add a Dashboard
From the left menu, return Home.

Click New dashboard. The dashboard is automatically created.

Click on the gear icon to the upper right.

Set the Name of the dashboard to Forethought.

Save the changes.