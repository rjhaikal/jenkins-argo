pipeline {
    agent {
        node {
            label 'master'
        }
    }
    
    stages {       
        stage('Prepare') {
            steps {
                checkout([$class: 'GitSCM',
                branches: [[name: "origin/master"]],
                doGenerateSubmoduleConfigurations: false,
                submoduleCfg: [],
                userRemoteConfigs: [[
                    url: 'https://github.com/rjhaikal/jenkins-argo.git']]
                ])
            }
        }
        stage ('Docker_Build') {

            steps {

                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub') {
                }

                // Build the docker image
                sh'''
                    IMAGE="k8s-debian-test"

                    # Build the image
                    docker build . -t k8s-debian-test

                    # Deploy image to Dockerhub
                    docker tag $IMAGE:latest rjhaikal/$IMAGE:latest
                    docker push rjhaikal/$IMAGE:latest
                '''
            }
        }
        
        stage ('Deploy_K8S') {
             steps {
                     withCredentials([string(credentialsId: "argocd-deploy-role", variable: 'ARGOCD_AUTH_TOKEN')]) {
                        sh '''
                        ARGOCD_SERVER="argocd.bignetlab.com"
                        APP_NAME="debian-test-k8s"
                        IMAGE="k8s-debian-test"

                        IMAGE_DIGEST=$(docker image inspect rjhaikal/$IMAGE:latest -f '{{join .RepoDigests ","}}')
                        # Customize image 
                        ARGOCD_SERVER=$ARGOCD_SERVER argocd --grpc-web app set $APP_NAME --kustomize-image $IMAGE_DIGEST
                        
                        # Deploy to ArgoCD
                        ARGOCD_SERVER=$ARGOCD_SERVER argocd --grpc-web app sync $APP_NAME --force
                        ARGOCD_SERVER=$ARGOCD_SERVER argocd --grpc-web app wait $APP_NAME --timeout 600
                        '''
               }
            }
        }
    }
}