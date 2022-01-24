# ArgoCD

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
