output "public_ip"  { value = aws_instance.web.public_ip }
output "website"    { value = "http://${aws_instance.web.public_ip}" }
output "ssh"        { value = "ssh -i ${local_sensitive_file.pem.filename} ubuntu@${aws_instance.web.public_ip}" }
output "instance_id" { value = aws_instance.web.id }
