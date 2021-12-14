output "public_ip" {
  value       = google_compute_instance.example.network_interface
  description = "The public IP of the web server"
}
output "nlb_public_ip" {
  value       = "http://${google_compute_forwarding_rule.example.ip_address}/"
  description = "The IP address of the load balancer"
}
