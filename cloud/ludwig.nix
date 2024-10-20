{ config, lib, pkgs, ... }: {

	services.k3s = {
		enable = true;
		role = "server";
		token = "%";
		serverAddr = "https://10.0.20.182:6443";
		extraFlags = toString [
			"--node-ip 10.0.20.223"
			"--node-name ludwig"
			"--disable traefik"
			"--disable servicelb"
			"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
		];

	};
}
