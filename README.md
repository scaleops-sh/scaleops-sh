# scaleops-sh
ScaleOps the best cost optimization framework for K8s


## Installation Manual

1. [Pre-requisits](#pre-requisits)
2. [Setup our CLI](#setup-cli)
4. Save coasts :D


### Pre Requisits

1. Make use you have proper credentials set to access k8s
2. (Optional) make sure to install helm[^1]
3. (Optional) make sure to install kubectl[^1]

[^1]: If they would not be installed, the instalation step will take care to install the missing dependancies.

### Setup CLI

** This section is valid only during the closed triels

```sh
export GITHUB_USERNAME=******
export GITHUB_TOKEN=******
export HOMEBREW_GITHUB_API_TOKEN=$GITHUB_TOKEN

brew tap scaleops-sh/scaleops https://github.com/scaleops-sh/scaleops-sh
brew install scaleops
scaleops install
```
