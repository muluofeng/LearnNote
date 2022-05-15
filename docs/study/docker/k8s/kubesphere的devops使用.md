### ![image-20220515104713611](/Users/muluofeng/Library/Application Support/typora-user-images/image-20220515104713611.png)devops  devops 使用



### devops 功能开启

- 使用admin账号登录kubesphere平台  ---》自定义资源 (CRD) --》clusterconfigurations --》ks-installer

- 编辑 ks-installer 将  enabled =true 打开，然后点击保存更新 

   ```yml
     devops:
       enabled: true
       jenkinsJavaOpts_MaxRAM: 2g
       jenkinsJavaOpts_Xms: 512m
       jenkinsJavaOpts_Xmx: 512m
       jenkinsMemoryLim: 2Gi
       jenkinsMemoryReq: 1500Mi
       jenkinsVolumeSize: 8Gi
   ```

- 等待安装 使用命令行查看 如果  kubesphere-devops-system  命名空间下的 pod全都 running 了就是安装好了

  ```shell
   kubectl get pod -A  
  ```

  ![image-20220514170858039](https://qiniu.muluofeng.com//uPic/%202022%2005%20/image-20220514170858039.png)



   查看安装进度

```shell
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```



   遇到了 一直安装 mino的问题

 由于我这里安装了 nfs ,但是本地还有  local  ，  解决方案  删除 local 的storage 

```shell
kubectl  get sc
```

最终只有一个 sc

![image-20220514172202707](https://qiniu.muluofeng.com//uPic/202205/image-20220514172202707.png)

### devops 使用 



- 找到devops  工程  ，先创建一个devops功能
- 创建好了 点进去创建对应的流水线

![image-20220514172458531](https://qiniu.muluofeng.com//uPic/202205/image-20220514172458531.png)

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514172839983.png" alt="image-20220514172839983" style="zoom: 50%;" />

 我们可以使用第一种构建生成 jenkinsfile 然后把 jenkinsfile 放在项目，让他自动构建

生成 jenkinsfile

- 拉取代码, 添加git仓库地址，分支，以及凭证(git 的账号密码)

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514174346006.png" alt="image-20220514174346006" style="zoom: 50%;" />

- 编译打包，这里要指定  maven容器，执行 mvn clean package -Dmaven.test.skip=true  

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514174514776.png" alt="image-20220514174514776" style="zoom:50%;" />

  需要添加 maven 配置镜像加速或者私有仓库

  admin账号   --》配置中心 --》ks-devops-agent  --》 修改配置 --》 mavensetting 编辑

  在 mirrors节点添加 阿里云镜像仓库, 更新文件

  ```xml
  <mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>        
  </mirror>
  ```

  

- 推送镜像

   构建镜像

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514175522810.png" alt="image-20220514175522810" style="zoom:50%;" />

  推送镜像

  <img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514175623077.png" alt="image-20220514175623077" style="zoom:50%;" />

- 部署到 k8s ，指定部署k8s的yml位置 和  kubeconfig 凭证，这里需要新建一个凭证，到时候会使用 $KUBECONFIG_CREDENTIAL_ID 找到指定的对应的凭证，我们可以新建一个凭证，选择 kubeconfig 类型，ID 为一个字符串，我们这里是 xing-kubeconfig  ，也就是我们在jenkinsfile里面的environment 的 KUBECONFIG_CREDENTIAL_ID = 'xing-kubeconfig'

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514175720411.png" alt="image-20220514175720411" style="zoom:50%;" />

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514193017336.png" alt="image-20220514193017336" style="zoom:33%;" />

  

保存所有的配置，可以看到生成 了jenkinsfile  pipline

```yaml
pipeline {
  agent {
    node {
      label 'maven'
    }

  }
  stages {
    stage('拉取代码') {
      agent none
      steps {
        container('base') {
          git(url: 'https://gitee.com/muluofeng/springbootdemo.git', credentialsId: 'gitee', branch: 'master', changelog: true, poll: false)
        }

      }
    }

    stage('编译打包') {
      agent none
      steps {
        container('maven') {
          sh 'mvn clean package -Dmaven.test.skip=true '
        }

      }
    }

    stage('构建镜像') {
      agent none
      steps {
        container('maven') {
          sh 'docker image build -t  springbootdemo:$BUILD_NUMBER -f Dockerfile  .'
        }

      }
    }

    stage('推送镜像') {
      agent none
      steps {
        container('maven') {
          ##  这里新建一个  yunlun-image-account  凭证，指定账号变量名称，密码变量名称
          withCredentials([usernamePassword(credentialsId : 'yunlun-image-account' ,passwordVariable : 'DOCKER_PWD_VAR' ,usernameVariable : 'DOCKER_USER_VAR' ,)]) {
            sh 'docker tag  springbootdemo:$BUILD_NUMBER   $REGISTRY/$DOCKERHUB_NAMESPACE/springbootdemo:$BUILD_NUMBER '
            ## 这里引用 登录私有仓库 的账号密码 
            sh 'echo $DOCKER_PWD_VAR| docker login $REGISTRY -u "$DOCKER_USER_VAR" --password-stdin'
            sh 'docker push  $REGISTRY/$DOCKERHUB_NAMESPACE/springbootdemo:$BUILD_NUMBER '
          }

        }

      }
    }

    stage('deploy to dev') {
      agent none
      steps {
        kubernetesDeploy(configs: 'deploy/**', enableConfigSubstitution: true, kubeconfigId: "$KUBECONFIG_CREDENTIAL_ID")
      }
    }

  }
  environment {
    DOCKER_CREDENTIAL_ID = 'dockerhub-id'
    GITHUB_CREDENTIAL_ID = 'github-id'
    KUBECONFIG_CREDENTIAL_ID = 'xing-kubeconfig'
    REGISTRY = 'ip'
    DOCKERHUB_NAMESPACE = 'xing'
    GITHUB_ACCOUNT = 'kubesphere'
    APP_NAME = 'devops-java-sample'
  }
  parameters {
    string(name: 'TAG_NAME', defaultValue: '', description: '')
  }
}
```

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514185533491.png" alt="image-20220514185533491" style="zoom:50%;" />

-  点击运行 ，所有的都成功标识成功了 

![image-20220514185938135](https://qiniu.muluofeng.com//uPic/202205/image-20220514185938135.png)



- 复制上面生成的jenkinsfile放到项目里面， 新建一个deploy.yml文件，然后新建一个 流水线指定webhook

  

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514190132307.png" alt="image-20220514190132307" style="zoom:50%;" />

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: springbootdemo
  name: springbootdemo
  namespace: mall-app   #一定要写名称空间
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  selector:
    matchLabels:
      app: springbootdemo
  strategy:
    rollingUpdate:
      maxSurge: 50%
      maxUnavailable: 50%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: springbootdemo
    spec:
      imagePullSecrets:
        - name: yunlu-docker-hub  #提前在项目下配置访问阿里云的账号密码
      containers:
        - image: $REGISTRY/$DOCKERHUB_NAMESPACE/springbootdemo:$BUILD_NUMBER
          #         readinessProbe:
          #           httpGet:
          #             path: /actuator/health
          #             port: 8080
          #           timeoutSeconds: 10
          #           failureThreshold: 30
          #           periodSeconds: 5
          imagePullPolicy: Always
          name: app
          ports:
            - containerPort: 8888
              protocol: TCP
          resources:
            limits:
              cpu: 300m
              memory: 600Mi
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: springbootdemo
  name: springbootdemo
  namespace: mall-app
spec:
  ports:
    - name: http
      port: 8888
      protocol: TCP
      targetPort: 8888
  selector:
    app: springbootdemo
  sessionAffinity: None
  type: NodePort
```



<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514190215653.png" alt="image-20220514190215653" style="zoom:50%;" />

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514190250078.png" alt="image-20220514190250078" style="zoom:50%;" />



<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514190404598.png" alt="image-20220514190404598" style="zoom: 33%;" />

- 复制新建之后获得的webhook地址放在  gitee的webhook的位置

<img src="https://qiniu.muluofeng.com//uPic/202205/image-20220514190631222.png" alt="image-20220514190631222" style="zoom:33%;" />

- 测试 git 提交之后是否能正常 发布









遇到的问题



-  私有仓库需要在docker 添加私有仓库, 重启docker，需要等一下  k8s 整个服务启动

  

```json
{
    "insecure-registries": [
    "ip:port"
  ],
}
```

