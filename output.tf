data "aws_lb" "demoalb" {
  arn = aws_lb.demoalb.arn
}

output "aws_lb" {
  value = aws_lb.demoalb.dns_name
}

/*
output "id" {
  value = try (
    aws_instance.demo_instance[0].id
  )
}
*/