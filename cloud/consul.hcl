client_addr = "127.0.0.1 100.64.0.4"

ui_config {
	enabled = true
}

server = true

bind_addr = "100.64.0.4"
bootstrap_expect=3

encrypt = "T9YIHnZEM9PZrMgwny7bTbJIkJzkU7S6mkrX7Pz9W+A="

retry_join = ["100.64.0.5"]
tls {
   defaults {
      ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"
      cert_file = "/etc/consul.d/certs/dc1-server-consul-0.pem"
      key_file = "/etc/consul.d/certs/dc1-server-consul-0-key.pem"

      verify_incoming = true
      verify_outgoing = true
   }
   internal_rpc {
      verify_server_hostname = true
   }
}

auto_encrypt {
  allow_tls = true
}

acl {
  enabled = true
  default_policy = "allow"
  enable_token_persistence = true
}

ports {
  grpc_tls = 8502
}

connect {
  enabled = true
}
