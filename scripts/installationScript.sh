#! /bin/bash

#### Docker installtion
yum update -y
yum install epel-release -y
yum install git ansible wget dejavu-sans-fonts fontconfig xorg-x11-server-Xvfb -y
curl -fsSL https://get.docker.com/ | sh
service docker start
yum install vim zip ruby rubygems -y
cat << EOF >/etc/docker/daemon.json
{
 "insecure-registries": [
 "172.30.0.0/16"
 ]
}
EOF
service docker restart

#### jenkins installation
yum install java-1.8.0-openjdk.x86_64 -y
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install jenkins -y
sed -i -e "s/8080/8083/g" /etc/sysconfig/jenkins 
usermod -aG wheel jenkins
service jenkins start

### clone git repo 
git clone https://ram_kannan@bitbucket.org/ram_kannan/devops_app_e2e_workflow.git
cd devops_app_e2e_workflow/scripts/
./jenkins_plugin_install.sh job-dsl,envinject,envinject-api,maven-plugin,javadoc,pipeline-maven,config-file-provider,docker-java-api,rebuild,saferestart,docker-plugin,docker-build-step,docker-custom-build-environment,findbugs,blueocean,blueocean-github-pipeline,blueocean-jwt,blueocean-rest,blueocean-commons,blueocean-dashboard,blueocean-pipeline-editor,blueocean-personalization,jenkins-design-language,blueocean-web,blueocean-autofavorite,blueocean-jira,blueocean-events,blueocean-git-pipeline,blueocean-i18n,blueocean-core-js,blueocean-bitbucket-pipeline,blueocean-config,blueocean-pipeline-api-impl,blueocean-display-url,blueocean-rest-impl,slack
service jenkins restart

#### installing maven
rm -rf /usr/local/src/apache-maven
cd /usr/local/src
wget http://www-us.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar -xf apache-maven-3.6.3-bin.tar.gz
mv apache-maven-3.6.3/ apache-maven/ 
cd /etc/profile.d/

echo "# Apache Maven Environment Variables" > maven.sh
echo "# MAVEN_HOME for Maven 1 - M2_HOME for Maven 2" >> maven.sh
echo "export M2_HOME=/usr/local/src/apache-maven" >> maven.sh
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> maven.sh

chmod +x maven.sh
source /etc/profile.d/maven.sh
mvn --version
mkdir -p /home/jenkins/.m2/repository
chown jenkins:jenkins /home/jenkins/.m2/repository

#### tomcat installation - port 8088
rm -rf /tomcat_app
mkdir /tomcat_app && cd /tomcat_app
wget https://www.apache.org/dist/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz
tar -xf apache-tomcat-*.tar.gz
rm -rf /opt/tomcat
mkdir -p /opt/tomcat
mv apache-tomcat-*/* /opt/tomcat
sed -i -e 's/8005/9006/g' /opt/tomcat/conf/server.xml 
sed -i -e 's/Catalina/Catalina1/g' /opt/tomcat/conf/server.xml 
sed -i -e 's/8080/8088/g' /opt/tomcat/conf/server.xml
chown -R jenkins:jenkins /opt/tomcat
/opt/tomcat/bin/startup.sh

#### tomcat installation - port 8089
rm -rf /tomcat_app
mkdir /tomcat_app && cd /tomcat_app
wget https://www.apache.org/dist/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz
tar -xf apache-tomcat-*.tar.gz
rm -rf /usr/local/tomcat
mkdir -p /usr/local/tomcat
mv apache-tomcat-*/* /usr/local/tomcat
sed -i -e 's/8005/9007/g' /usr/local/tomcat/conf/server.xml 
sed -i -e 's/Catalina/Catalina2/g' /usr/local/tomcat/conf/server.xml 
sed -i -e 's/8443/8444/g' /usr/local/tomcat/conf/server.xml 
sed -i -e 's/8009/8010/g' /usr/local/tomcat/conf/server.xml 
sed -i -e 's/8080/8089/g' /usr/local/tomcat/conf/server.xml
chown -R jenkins:jenkins /usr/local/tomcat
/usr/local/tomcat/bin/startup.sh

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
aws --version

#### installing nexus
rm -rf /nexus_app
mkdir /nexus_app && cd /nexus_app
wget https://sonatype-download.global.ssl.fastly.net/nexus/3/latest-unix.tar.gz 
tar -xvf latest-unix.tar.gz
mv nexus-* nexus
adduser nexus
chown -R nexus:nexus /nexus_app
sed -i -e 's/.*run_as_user.*/run_as_user="nexus"/' /nexus_app/nexus/bin/nexus.rc
ln -s /nexus_app/nexus/bin/nexus /etc/init.d/nexus
chkconfig --add nexus
chkconfig --levels 345 nexus on
usermod -aG wheel nexus
service nexus start

usermod -aG wheel centos
curl icanhazip.com
