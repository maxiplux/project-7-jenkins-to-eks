#!/bin/bash
eksctl create  cluster -f cluster.yaml
#aws eks update-kubeconfig   --region us-east-1 --name weclouddata
#eksctl get iamidentitymapping --cluster weclouddata --region us-east-1

