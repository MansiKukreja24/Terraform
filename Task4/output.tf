output "lb_ip" {
  value = kubernetes_service.lb.load_balancer_ingress.0.ip
}
output "dns" {
  value = aws_db_instance.default.address
}
output "name" {
  value = aws_db_instance.default.name
}
output "username" {
  value = aws_db_instance.default.username
}
output "password" {
  value = aws_db_instance.default.password
}