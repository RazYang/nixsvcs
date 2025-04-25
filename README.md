

Nixsvcs is a service-oriented framework and repository with a structure similar to nixpkgs. Inspired by sixos, it aims to simplify service deployment using Nix in non-NixOS and container environments.

# Features
1. Simple structure - (almost) all core components are independently buildable Derivations, free from complex module systems
2. Automatic computation and building of service closures
3. Container image building support
4. Cross-compilation support
# Feel The Magic
## Build Individual Service
```bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.bar'
```
## Build Service Closure
``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcClosure.bar'
```
## Build Container Image
``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcImage.bar'
```
## Cross-compilation
Supports nixpkgs-style cross-compilation syntax

``` bash
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcsCross.musl64.bar'
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcsCross.musl64.svcClosure.bar'
nix build 'github:razyang/nixsvcs#services.x86_64-linux.svcsCross.musl64.svcImage.bar'
```
When cross-compiling with musl:
* Minimal service closure: ~10M
* Container image size: ~3M
When using glibc:
* Minimal service closure: ~37M
* Container image size: ~12M

This difference stems from nixpkgs' glibc implementation (31M total), which includes 13M `locales` and 8M `gconv` modules.

# nixsvcs demo
For advanced usage examples, see the nixsvcs-demo project. It demonstrates:
* Adding new packages/services while maintaining cross-compilation support
* Modifying container images using infuse
* Extending both nixpkgs and nixsvcs ecosystems
