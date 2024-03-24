#!/bin/bash
eksctl delete cluster --region=us-east-1 --name=weclouddata --disable-nodegroup-eviction
