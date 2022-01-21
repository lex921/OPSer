

# Longhorn



## Docs
https://longhorn.io/docs/1.2.3/deploy/install/install-with-kubectl/


## GitHub

https://github.com/longhorn/longhorn


## Release Status

| Release | Version | Type           |    
| --------|---------|----------------|
| 1.2     | 1.2.3   | Stable, Latest |
| 1.1     | 1.1.3   | Stable, Latest |

## Source code

Longhorn is 100% open source software. Project source code is spread across a number of repos:

| Component                      | What it does                                                           | GitHub repo                                                                                 |
| :----------------------------- | :--------------------------------------------------------------------- | :------------------------------------------------------------------------------------------ |
| Longhorn Backing Image Manager | Backing image download, sync, and deletion in a disk                   | [longhorn/backing-image-manager](https://github.com/longhorn/backing-image-manager)         |
| Longhorn Engine                | Core controller/replica logic                                          | [longhorn/longhorn-engine](https://github.com/longhorn/longhorn-engine)                     |
| Longhorn Instance Manager      | Controller/replica instance lifecycle management                       | [longhorn/longhorn-instance-manager](https://github.com/longhorn/longhorn-instance-manager) |
| Longhorn Manager               | Longhorn orchestration, includes CSI driver for Kubernetes             | [longhorn/longhorn-manager](https://github.com/longhorn/longhorn-manager)                   |
| Longhorn Share Manager         | NFS provisioner that exposes Longhorn volumes as ReadWriteMany volumes | [longhorn/longhorn-share-manager](https://github.com/longhorn/longhorn-share-manager)       |
| Longhorn UI                    | The Longhorn dashboard                                                 | [longhorn/longhorn-ui](https://github.com/longhorn/longhorn-ui)                             |

![Longhorn UI](https://github.com/lex921/longhorn/blob/master/longhorn-ui.png)
