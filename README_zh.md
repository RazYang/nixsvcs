- [特性](#特性)
- [立即体验魔法](#立即体验魔法)
  * [构建单个服务](#构建单个服务)
  * [构建服务闭包](#构建服务闭包)
  * [构建容器镜像](#构建容器镜像)
  * [交叉编译](#交叉编译)
- [nixsvcs demo](#nixsvcs-demo)

Nixsvcs是一个采用了和nixpkgs相似结构的，用于构建“服务”的框架和仓库。深受sixos启发，希望使用更简单的方式在非nixos以及容器环境中部署使用nix构建的服务。
# 特性
1. 结构简单，（几乎）所有核心部分都是可以独立构建的Derivation，没有复杂的module系统；
3. 自动计算和构建服务闭包
4. 支持构建服务容器镜像
5. 交叉编译支持
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
当使用musl交叉编译时，最小服务闭包约10M，容器镜像大小约3M。当使用glibc时，最小服务闭包约37M，容器镜像大小约12M。<br></br>
由于nixpkgs中的glibc大小有31M，其中包含了13M的locales以及8M的gconv，所以使用了glibc的软件或者服务闭包会比较大。
# nixsvcs demo
进一步使用方式可以参考[nixpkgs-demo](https://github.com/RazYang/nixsvcs-demo)项目，其中包含了如何在保证交叉编译的情况下，为nixpkgs以及nixsvcs增加新的pkg以及svc，以及如何使用infuse来改变构建的容器镜像。
