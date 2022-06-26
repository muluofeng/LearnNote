### jenkins pipline 部署  java + harbor + docker 项目

jenkins  docker 部署

```shell
docker run -d --name jenkins         -u root         -p 8889:8080 -p 5001:5000  \
-v /data/jenkions/mydata:/var/jenkins_home        \
-v /data/docker/volumes/maven/_data:/usr/local/maven        \
-v /usr/bin/docker:/usr/bin/docker         \
-v /var/run/docker.sock:/var/run/docker.sock         jenkins/jenkins:lts  
```







```groovy
pipeline {
   // 环境变量
 environment {
        // 镜像仓库地址
        REGISTRY = '47.114.174.69:5000'
        // 镜像仓库用户名
        REGISTRY_USERNAME = '镜像仓库用户名'
   			// 镜像仓库密码
        REGISTRY_PWD = '镜像仓库密码'
        // 部署的容器名称
        CONTANINER_NAME="data-summary-api"
        // 当前部署的镜像名称  容器名称 + 本次jenkins构建的版本号
        IMAGE_NAME = "$REGISTRY/$CONTANINER_NAME:$BUILD_NUMBER"
        // 在服务器上的部署脚本
        COMMAND = """
                            echo "开始在服务器部署容器"
                            echo "$REGISTRY_PWD"| docker login $REGISTRY -u "$REGISTRY_USERNAME" --password-stdin
                            docker rm -f $CONTANINER_NAME
                            docker run -d  --name   $CONTANINER_NAME    -e "SPRING_PROFILES_ACTIVE=dev" -p 9192:9192  $IMAGE_NAME
                            echo "部署容器完成"
                    """
            
    }

   agent any
   stages {
    stage('checkout') {
        steps {
            sh  'git config --global credential.helper cache'
            git branch: 'dev', credentialsId: 'git-tfs', url: 'https://xxxx/data-summary-api'
            // Git 子模块 需要更新子模块的内容
            sh 'git submodule update --init --recursive'
        }
    }
    stage('mvnbuild') {
        steps {
            // maven 构建
            sh '/usr/local/maven/maven/bin/mvn clean package -Dmaven.test.skip=true '
        }
    }
    stage('docker build') {
        steps {
            // docker 构建
            sh "docker build -t ${IMAGE_NAME} ."
        }
    }
    stage('docker push') {
        steps {
            script {
                withCredentials([usernamePassword(credentialsId : '6e5de3f5-1a63-4011-8939-d7f3a06cd9a5' ,passwordVariable : 'DOCKER_PWD_VAR' ,usernameVariable : 'DOCKER_USER_VAR' ,)]) {
                    // 登录镜像仓库
                    sh 'echo "$DOCKER_PWD_VAR"| docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
                    // 推送当前构建的镜像
                    sh 'docker push  ${IMAGE_NAME} '
                }
            }
        }
    }
       stage('deploy ') {
        steps {
            script {
                withCredentials([usernamePassword(credentialsId : '6e5de3f5-1a63-4011-8939-d7f3a06cd9a5' ,passwordVariable : 'DOCKER_PWD_VAR' ,usernameVariable : 'DOCKER_USER_VAR' ,)]) {
                       
                       sshPublisher(publishers: [sshPublisherDesc(configName: '47.114.62.126阿里云', transfers: [
                        sshTransfer(cleanRemote: false, excludes: '', execCommand: "${COMMAND}", execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '/data/s.sh')
                  ], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
                    }
              
            }
        }
    }
   }
}

```