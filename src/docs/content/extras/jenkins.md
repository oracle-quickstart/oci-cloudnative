---
title: "Jenkins"
date: 2020-06-24T16:48:49-07:00
draft: true
weight: 95
tags:
  - CI/CD
  - Automation
  - Jenkins
  - Patching
---

## Introduction

In this section we will demonstrate how to run leverage your kubernetes cluster for CI/CD tasks 
using [Jenkins](https://www.jenkins.io/).

{{% alert style="danger" icon="warning" %}}
Note that Jenkins is **OPTIONAL** and disabled by default. To enable it, see [setup]({{< ref "cloud/setup.md" >}}) section. 
{{% /alert %}}

When enabled, a Jenkins server is installed on the kubernetes cluster and is setup to utilize the [Jenkins Kubernetes plugin](https://plugins.jenkins.io/kubernetes).
The plugin enables Jenkins to create worker nodes on demand as pods on the kubernetes cluster to run jobs, 
then terminates the pods when the job is completed. This also lets the system run any arbitrary job since all
job related dependencies (say, building an application that requires a specific version of `java`) are contained
within the definition of a docker container that executes the step.

More information on the kubernetes plugin and the extensions it provides for the Jenkins pipeline are described [here](https://github.com/jenkinsci/kubernetes-plugin#pipeline-support)

## Accessing Jenkins

Once installation is completed, you can access the Jenkins server using the ingress controller (if one was configured), or using a port forward.

To use the ingress, first find the external IP for the Load Balancer that was created :

```shell
kubectl get svc mushop-utils-ingress-nginx-controller \
  --namespace mushop-utilities
```
Ensure that Jenkins is up and ready

```shell
kubectl get deployment -n mushop-utilities mushop-utils-jenkins
```

Once Jenkins is ready, navigate to http://<external-ip>/jenkins

The default username is `admin`. The default password is generated and stored as a kubernetes secret.

```shell
kubectl get secret -n mushop-utilities mushop-utils-jenkins \
-o jsonpath="{.data.jenkins-admin-password}" | base64 --decode ; echo
```

## A simple build job

Once logged in, we can test a simple pipeline by creating a multi-branch pipeline based on the repository 

https://github.com/jeevanjoseph/jenkins-k8s-pipeline.git

The repository contains a `Jenkinsfile` that describes how it should be built and this is the only information 
that Jenkins requires in order to run the build. In this example, the build defines its execution environment to
include a terraform container to run terraform code, and a docker container to build docker images.




