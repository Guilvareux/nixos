bind_addr = "100.64.0.4"

server = {
	enabled = true
	bootstrap_expect = 3
	encrypt = "1jYVDOkxTmFGPJS5gg7R6Q=="
	#server_join {
	#	retry_join = ["100.64.0.5:4648"]
	#}
}
client = {
	enabled = true
	#servers = ["127.0.0.1"]
	host_network "ts" {
		cidr = "100.64.0.0/24"
	}
	#host_network "public" {
	#	cidr = "10.0.0.0/16"
	#}
	node_class = "admin"
}

plugin "raw_exec" {
	config {
		enabled = true
	}
}
