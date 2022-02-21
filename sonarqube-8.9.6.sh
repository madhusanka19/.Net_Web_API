#!/bin/bash

echo "========================================================================"
echo "----------Installing Sonarqube 2022 PaperTrl@Inc------------------------"
echo "========================================================================"


SONARQUBE_VERSION=8.9.6.50800
SONARQUBE_DOWNLOAD_FILE_VERSION=sonarqube-$SONARQUBE_VERSION
SONARQUBE_INSTALL_LOCATION=/papertrl/installs
SONARQUBE_FOLDER_NAME=sonarqube
SONARQUBE_DATA_DIR_FOLDER=sonarqubefiles
SONARQUBE_DATA_DIR_LOCATION=/papertrl/data/
SONARQUBE_TEMP_FOLDER=temp
SONARQUBE_SERVICE_FILE_NAME=papertrl-sonarqube
SONARQUBE_USERNAME=sonar
SONARQUBE_WEB_ADDRESS=192.168.8.117
SONARQUBE_WEB_PORT=9000
SONARQUBE_DB_ADDRESS=localhost
SONARQUBE_DB_PASSWORD=test123
SONARUBE_DB_ADDRESS=jdbc:postgresql://$SONARQUBE_DB_ADDRESS/$SONARQUBE_USERNAME
JAVA_LOCATION=/usr/bin/java



installation_status=1

install(){
        status
        if [ $installation_status -eq 0 ];then

	        groupadd $SONARQUBE_USERNAME

                useradd -r -g $SONARQUBE_USERNAME $SONARQUBE_USERNAME
		

		mkdir -p $SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME
		
		mkdir -p $SONARQUBE_DATA_DIR_LOCATION/$SONARQUBE_DATA_DIR_FOLDER

		mkdir -p $SONARQUBE_DATA_DIR_LOCATION/$SONARQUBE_DATA_DIR_FOLDER/$SONARQUBE_TEMP_FOLDER

		cd $SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME

		wget https://binaries.sonarsource.com/Distribution/sonarqube/$SONARQUBE_DOWNLOAD_FILE_VERSION.zip

		sudo unzip $SONARQUBE_DOWNLOAD_FILE_VERSION.zip

		sudo sh -c 'echo "#Sonar Properties

sonar.jdbc.username='$SONARQUBE_USERNAME'
sonar.jdbc.password='$SONARQUBE_DB_PASSWORD'
sonar.jdbc.url='$SONARUBE_DB_ADDRESS'
sonar.web.host='$SONARQUBE_WEB_ADDRESS'
sonar.web.port='$SONARQUBE_WEB_PORT'
sonar.path.data='$SONARQUBE_DATA_DIR_LOCATION/$SONARQUBE_DATA_DIR_FOLDER'
sonar.path.temp='$SONARQUBE_DATA_DIR_LOCATION/$SONARQUBE_DATA_DIR_FOLDER/$SONARQUBE_TEMP_FOLDER'
sonar.web.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.search.javaOpts=-server -Xms512m -Xmx512m -XX:+HeapDumpOnOutOfMemoryError
sonar.search.javaAdditionalOpts=-Dbootstrap.system_call_filter=false" >> '$SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME/$SONARQUBE_DOWNLOAD_FILE_VERSION'/conf/sonar.properties'
		
		sudo sh -c 'echo "[Unit]
Description=papertrl-sonarqube service
#After=syslog.target network.target

[Service]
Type=simple
User='$SONARQUBE_USERNAME'
Group='$SONARQUBE_USERNAME'
PermissionsStartOnly=true
ExecStart=/bin/nohup '$JAVA_LOCATION' -Xms32m -Xmx32m -Djava.net.preferIPv4Stack=true -jar '$SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME/$SONARQUBE_DOWNLOAD_FILE_VERSION'/lib/sonar-application-'$SONARQUBE_VERSION'.jar
LimitNOFILE=131072
LimitNPROC=8192
Restart=always
RestartSec=12
SuccessExitStatus=143
StartLimitInterval=120
StartLimitBurst=5
RemainAfterExit=no
#TimeoutStartSec=10s
#TimeoutStopSec=60s

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/'$SONARQUBE_SERVICE_FILE_NAME'.service'


		sudo chown -R $SONARQUBE_USERNAME:$SONARQUBE_USERNAME $SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME
		sudo chown -R $SONARQUBE_USERNAME:$SONARQUBE_USERNAME $SONARQUBE_DATA_DIR_LOCATION/$SONARQUBE_DATA_DIR_FOLDER 	


		sudo firewall-cmd --permanent --add-port=$SONARQUBE_WEB_PORT/tcp && sudo firewall-cmd --reload

	        sudo systemctl start $SONARQUBE_SERVICE_FILE_NAME

                sudo systemctl enable $SONARQUBE_SERVICE_FILE_NAME

		sudo systemctl status $SONARQUBE_SERVICE_FILE_NAME

		rm -rf $SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME/$SONARQUBE_DOWNLOAD_FILE_VERSION.zip   

           
        sleep 3s

        else
                echo "SonarQube is allready installed on this server"
        fi
}

remove(){
        status
        if [ $installation_status -ne 0 ]; then

                read -p "Are you sure? " -n 1 -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        rm -rf $SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME
                        rm -rf $SONARQUBE_DATA_DIR_LOCATION/$SONARQUBE_DATA_DIR_FOLDER

                        sleep 3s
                fi
        else
                echo "openvpn not exist in this server"
        fi
}

status(){

        if [ -d "$SONARQUBE_INSTALL_LOCATION/$SONARQUBE_FOLDER_NAME" ]; then
                installation_status=1
        else
                installation_status=0
        fi
}

case $1 in
        install)
                install
                exit 0
                ;;

        remove)
                remove
                exit 0
                ;;

        *)
                echo "Usage ./$INIT_SCRIPT_NAME install|remove|status"
esac

exit

