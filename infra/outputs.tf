output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_node_group_name" {
  value = aws_eks_node_group.main.node_group_name
}

output "eks_kubeconfig_command" {
  value = "aws eks update-kubeconfig --region us-east-2 --name ${aws_eks_cluster.main.name}"
}

output "eks_manifest_apply_command" {
  value = "kubectl apply -f infra/k8s/showingflow-stack.yaml"
}
