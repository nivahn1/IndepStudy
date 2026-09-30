#!/bin/bash
set -e
case "$1" in
  cluster)
    aws eks create-cluster --name lab-cluster \
      --role-arn arn:aws:iam::000000000000:role/eks-role \
      --resources-vpc-config subnetIds=subnet-default-us-east-1-a >/dev/null
    printf "Waiting for the cluster"
    until [ "$(aws eks describe-cluster --name lab-cluster --query cluster.status --output text)" = "ACTIVE" ]; do
      printf "."; sleep 5
    done
    echo
    docker exec floci-eks-lab-cluster cat /etc/rancher/k3s/k3s.yaml \
      | sed 's/127.0.0.1:6443/127.0.0.1:6500/' > ~/.kube/floci-lab.yaml
    echo "Cluster ready. Run: export KUBECONFIG=~/.kube/floci-lab.yaml"
    ;;
  load)
    docker save "task-tracker:$2" | docker exec -i floci-eks-lab-cluster \
      ctr -a /run/k3s/containerd/containerd.sock -n k8s.io images import - >/dev/null
    echo "Loaded task-tracker:$2 into the cluster"
    ;;
  *)
    echo "usage: ./lab.sh cluster | ./lab.sh load <tag>"
    ;;
esac
