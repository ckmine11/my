#! /bin/bash
cd /var/lib/jenkins/workspace/sample-project/
sudo su - jenkins -s/bin/bash
#docker logout   harbor.cluster.com/sample-project
  docker login -u admin --password root harbor.cluster.com
  docker image build -t  $JOB_NAME:v1.$BUILD_ID .
 docker image tag $JOB_NAME:v1.$BUILD_ID harbor.cluster.com/sample-project/$JOB_NAME:v1.$BUILD_ID
 docker image tag $JOB_NAME:v1.$BUILD_ID harbor.cluster.com/sample-project/$JOB_NAME:latest
 docker image push harbor.cluster.com/sample-project/$JOB_NAME:v1.$BUILD_ID
 docker  push harbor.cluster.com/sample-project/$JOB_NAME:latest
 #docker image rmi $JOB_NAME:v1.$BUILD_ID  harbor.cluster.com/sample-project/$JOB_NAME:v1.$BUILD_ID   harbor.cluster.com/sample-project/$JOB_NAME:latest 
