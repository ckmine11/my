#! /bin/bash
cd /var/lib/jenkins/workspace/devsecops-pro/
sudo su - jenkins -s/bin/bash
#docker logout   master.dns.com
  docker login -u admin --password Harbor12345 master.dns.com
  docker image build -t  $JOB_NAME:v1.$BUILD_ID .
 docker image tag $JOB_NAME:v1.$BUILD_ID master.dns.com/devsecops/$JOB_NAME:v1.$BUILD_ID
 docker image tag $JOB_NAME:v1.$BUILD_ID master.dns.com/devsecops/$JOB_NAME:latest
 docker image push master.dns.com/devsecops/$JOB_NAME:v1.$BUILD_ID
 docker  push master.dns.com/devsecops/$JOB_NAME:latest
 docker image rmi $JOB_NAME:v1.$BUILD_ID  master.dns.com/devsecops/$JOB_NAME:v1.$BUILD_ID   master.dns.com/devsecops/$JOB_NAME:latest 
