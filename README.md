# scaleops-sh
ScaleOps the best cost optimization framework for K8s


## Installation Manual

1. [Pre Requisites](#pre-requisites)
2. [Setup CLI](#setup-cli)
4. Save coasts :D


### Pre Requisites

1. Make use you have proper credentials set to access k8s [^1]
2. Get scaleops `token` from your account manager [^2]

[^1]: In case you have not installed `helm 3` or `kubectl`, and you are using one of our package installations we would install them as dependencies.
[^2]: Currentry in private beta, later we would open registration

### Setup CLI

<details><summary>MacOS Via Homebrew</summary>

```shell
brew install scaleops-sh/scaleops/scaleops
scaleops system install --token *****
```

Or
```shell
brew tap scaleops-sh/scaleops
brew install scaleops
scaleops system install --token *****
```


</details>
