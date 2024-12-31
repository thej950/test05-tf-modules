/*
output "ec2_public_ip" {
  value = module.ec2_jenkins.public_ip
}
*/

output "vpc_id" {
  value = module.networking.vpc_id
}
