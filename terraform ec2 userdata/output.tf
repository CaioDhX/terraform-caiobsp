output "public_ip" {
  value = aws_instance.webserver.public_ip
}

output "web_url" {
  value = "http://${aws_instance.webserver.public_ip}"
}
