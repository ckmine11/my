pipeline { 
         agent any
           environment {
        jenkins_server_url = "http://192.168.163.102:8080"
        notification_channel = 'devops'
        slack_url = 'https://hooks.slack.com/services/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'
        deploymentName = "web-server"
    containerName = "web-server"
    serviceName = "web-server"
    imageName = "master.dns.com/devsecops/$JOB_NAME:v1.$BUILD_ID"
     applicationURL="http://192.168.163.101"
    applicationURI="epps-smartERP/" 		   
		   
        
    }
         
    
    tools {
        maven 'maven3'
    }
    
    stages { 
        stage('Build Checkout') { 
            steps { 
              checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/ckmine11/my.git']]])
         }
        }
        stage('Build Now') { 
            steps { 
              
                  dir("/var/lib/jenkins/workspace/sample-project") {
                    sh 'mvn -version'
                    sh 'mvn clean install'
                      
                    echo "build succses"
                }

       
              }

            }
            
           
     
            
             
              stage ('Code Quality scan') {
              steps {
        withSonarQubeEnv('sonar') {
          
       sh "mvn clean verify sonar:sonar -Dsonar.projectKey=me-project -Dsonar.host.url=http://system-services.cluster.com:9000/ -Dsonar.login=0df7f38cd998f3f2b4efff6538e6c26d16a5e486"
        }
		//      timeout(time: 2, unit: 'HOURS') {
         //  script {
          //   waitForQualityGate abortPipeline: true
         //  }
        // }
   }
              }
              
              
        stage('Synk-Test') {
      steps {
	      snykSecurity failOnError: false, failOnIssues: false, projectName: 'sample-project-erp', snykInstallation: 'snyk', snykTokenId: 'snyk'
       // echo 'Testing...'
      //  snykSecurity(
       //  snykInstallation: 'snyk',
        // snykTokenId: 'bbe4c279-8455-48f7-aeaa-901144bd2a86'
          // place other parameters here
      //  )
      }
   }
              
              
              stage ('Vulnerability Scan - Docker ') {
              steps {
                  
                 parallel   (
       "Dependency Scan": {
       	     	sh "mvn dependency-check:check"
		},
	 	  "Trivy Scan":{
	 		    sh "bash trivy-docker-image-scan.sh"
		     	},
		   "OPA Conftest":{
			sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
		    }   	
		             	
   	                      )
                    
              }
               }
              
           
              stage(' Rename and move Build To Perticuler Folder '){
                steps {
                   sh 'mv /var/lib/jenkins/workspace/sample-project/target/jenkins-git-integration.war   /var/lib/jenkins/workspace/sample-project/epps-smartERP.war'
                  sh 'chmod -R 777 /var/lib/jenkins/workspace/sample-project/epps-smartERP.war'
                  
                  sh 'chmod -R 777 /var/lib/jenkins/workspace/sample-project/Dockerfile'
                  sh 'chmod -R 777 /var/lib/jenkins/workspace/sample-project/shell.sh'
                  sh 'chown jenkins:jenkins  /var/lib/jenkins/workspace/sample-project/trivy-docker-image-scan.sh'                
                 
                                     }
                       }
                       
                     //  stage ("Slack-Notify"){
                    //     steps {
                    //        slackSend channel: 'devops-pipeline', message: 'deployment successfully'
                   //      }
                   //    }

    stage ('Regitsry Approve') {
      steps {
      echo "Taking approval from DEV Manager forRegistry Push"
        timeout(time: 7, unit: 'DAYS') {
        input message: 'Do you want to deploy?', submitter: 'admin'
        }
      }
    }

 // Building Docker images
    stage('Building image | Upload to Harbor Repo') {
      steps{
            sh '/var/lib/jenkins/workspace/sample-project/shell.sh'  
    }
      
    }
    
    stage('Vulnerability Scan - Kubernetes') {
       steps {
         parallel(
           "OPA Scan": {
             sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego blue.yml'
         },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          },
           "Trivy Scan": {
             sh "bash trivy-k8s-scan.sh"
           }
        )
      }
    }
	stage('K8S Deployment - DEV') {
       steps {
         parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
	  
             }
           },
         "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
             sh "bash k8s-deployment-rollout-status.sh"
             }
           }
        )
       }
     }
	  
	    
	   stage('Integration Tests - DEV') {
         steps {
         script {
          try {
            withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "bash integration-test.sh"
             }
            } catch (e) {
             withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "kubectl -n default rollout undo deploy ${deploymentName}"
             }
             throw e
           }
         }
       }
     }  
	    
	// stage('OWASP ZAP - DAST') {
      // steps {
       //  withKubeConfig([credentialsId: 'kubeconfig']) {
        //   sh 'bash zap.sh'
       //  }
      // }
    // }  	
    
        stage('Jmeter-Test') {
       steps {
                sh "sh /var/lib/jenkins/workspace/apache-jmeter-5.6.3/bin/jmeter.sh  -Jjmeter.save.saveservice.output_format=xml -n -t /var/lib/jenkins/workspace/apache-jmeter-5.6.3/bin/jemeter-reg.jmx -l /var/lib/jenkins/workspace/apache-jmeter-5.6.3/bin/Jenkinsjmeter.jtl"
         }
       }

	    
	    stage('Prompte to PROD?') {
       steps {
         timeout(time: 2, unit: 'DAYS') {
           input 'Do you want to Approve the Deployment to Production Environment/Namespace?'
         }
       }
     }

     stage('K8S CIS Benchmark') {
       steps {
         script {

           parallel(
            "Master": {
               sh "bash cis-master.sh"
             },
             "Etcd": {
               sh "bash cis-etcd.sh"
             },
             "Kubelet": {
               sh "bash cis-kubelet.sh"
             }
           )

         }
       }
     }
	    
	  
	 stage('K8S Deployment - PROD') {
         steps {
          parallel(
            "Deployment": {
                withKubeConfig([credentialsId: 'kubeconfig']) {
                 sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
                 sh "kubectl -n prod apply -f k8s_PROD-deployment_service.yaml"
               }
             },
             "Rollout Status": {
               withKubeConfig([credentialsId: 'kubeconfig']) {
                 sh "bash k8s-PROD-deployment-rollout-status.sh"
               }
             }
           )
         }
       }   
	    
	
	    stage('Integration Tests - PROD') {
       steps {
         script {
          try {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash integration-test-PROD.sh"
             }
           } catch (e) {
             withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "kubectl -n prod rollout undo deploy ${deploymentName}"
             }
             throw e
           }
         }
       }
     }  
	    
     
}

			 post{
                      always{
              dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
              publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'HTML Report', reportTitles: 'OWASP ZAP HTPML REPORT', useWrapperFileDirectly: true])
              perfReport errorFailedThreshold: 0, errorUnstableThreshold: 0, filterRegex: '', persistConstraintLog: true, showTrendGraphs: true, sourceDataFiles: '/var/lib/jenkins/workspace/apache-jmeter-5.6.3/bin/Jenkinsjmeter.jtl'
       }
   }

    }
