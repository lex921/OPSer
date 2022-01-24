# ArgoCD
开源社区在复杂应用发布管理方面逐渐开始发力，其中2种针对上层应用发布管理的方案：     
 
它们就是Intuit的ArgoCD和ArgoRollouts结合的方案以及Weaveworks的Flux和Flagger结合的方案。                   

ArgoCD和Flux（或者Flux CD）的主要职责都是监听Git Repository源中的应用编排变化，并与当前环境中应用运行状态进行对比，自动化同步拉取应用变更并部署到进群中。         

ArgoRollouts和Flagger的主要职责都是执行更复杂的应用发布策略，比如蓝绿发布、金丝雀发布、AB Testing等。                

## K8s Install ArgoCD
https://argo-cd.readthedocs.io/en/stable/getting_started/


## GitHub
https://github.com/argoproj/argo-cd/


## ArgoCD包括3个主要组件：

* API Server             
ArgoCD API server是一个gRPC/REST风格的server，提供API给Web UI，CLI以及其他CI/CD做系统调用或集成.             
包括以下职责：         
1、应用管理和状态上报       
2、执行应用变更，如同步、回滚等        
3、Git Repository和集群凭证的管理（存储为k8s secret）        
4、对外部身份提供者进行身份验证（添加外部集群）        
5、RBAC增强      
6、监听和转发Git webhook事件          

* Repository Server        
repossitory server是一个内部服务，维护一个Git Repo中应用编排文件的本地缓存。
支持以下参数设置：       
1、repository URL     
2、revision (commit, tag, branch)       
3、application path，Git Repo中的subpath          
4、模板化的参数设置，如parameters, ksonnet environments, helm values.yaml          

* Application Controller           
Application Controller是一个Kubernetes Controller，主要工作是持续监听应用当前运行状态与期望状态（Git Repo中描述的状态）的不同。       
自动检测应用OutOfSync状态并根据Sync测试执行下一步动作。
