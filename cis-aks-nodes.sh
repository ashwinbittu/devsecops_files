#!/bin/bash
#cis-aks.sh for workder nodes

echo 'Starting K8S CIS Benchmark for Kubelet For Worker Nodes'
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod a+x /usr/local/bin/yq
git clone https://github.com/aquasecurity/kube-bench.git

kubectl delete job kube-bench

for nodeName in $(kubectl get no -o=jsonpath='{.items[*].metadata.name}')
do

  export nodeName=$nodeName
  #cp kube-bench/job-node.yaml kubebench-aks-$nodeName.yaml
  cp kube-bench/job-aks.yaml kubebench-aks-$nodeName.yaml
  yq -i '.spec.template.spec.nodeName = env(nodeName)' kubebench-aks-$nodeName.yaml
  kubectl create -f kubebench-aks-$nodeName.yaml
  sleep 30s
  #kubectl logs $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep kube-bench-node) > $nodeName-kube-sebenchc.log
  kubectl logs $(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep kube-bench) > $nodeName-kube-bench.log
  echo "#################################################"
  echo "AKS Worker Node - $nodeName --- Kube-Bench Output"
  echo "#################################################"
  cat $nodeName-kube-bench.log
  echo "#################################################"
  kubectl delete job kube-bench

done

