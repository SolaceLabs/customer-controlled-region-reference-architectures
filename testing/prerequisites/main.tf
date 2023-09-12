data "http" "ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}