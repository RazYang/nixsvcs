Nixsvcs是一个采用了和nixpkgs相似结构的，用于构建“服务”的框架和仓库。深受sixos启发，希望使用更简单的方式在非nixos以及容器环境中部署使用nix构建的服务。
# 特性
1. 结构简单，（几乎）所有核心部分都是可以独立构建的Derivation，没有复杂的module系统；
3. 自动计算和构建服务闭包
4. 支持构建服务容器镜像
5. 交叉编译
# 立即体验魔法
## 构建单个服务
``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.bar'
```
## 构建服务闭包
``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcClosure.bar'
```
## 构建容器镜像
``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcImage.bar'
```
## 交叉编译
支持与[nixpkgs相似的交叉编译语法](https://nix.dev/tutorials/cross-compilation)
``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcsCross.musl64.bar'
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcsCross.musl64.svcClosure.bar'
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcsCross.musl64.svcImage.bar'
```
当使用musl交叉编译时，最小服务闭包约10M，容器镜像大小约3M。当使用glibc时，最小服务闭包约37M，容器镜像大小约12M。
