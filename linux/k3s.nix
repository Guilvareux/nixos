{ pkgs, ... }:
{
	virtualisation = {
		containerd = {
			enable = true;
			settings = {
				version = 2;
				plugins."io.containerd.grpc.v1.cri" = {
					cni.conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
					cni.bin_dir = "${pkgs.runCommand "cni-bin-dir" {} ''
						mkdir -p $out
						ln -sf ${pkgs.cni-plugins}/bin/* ${pkgs.cni-plugin-flannel}/bin/* $out
					''}";
				};
			};
		};
	};

	systemd = {
		services.k3s = {
			wants = ["containerd.service"];			
			after = ["containerd.service"];			
		};
	};

	#k3s = {
	#	enable = true;
	#	role = "server";
	#	#role = "agent";
	#	token = "K10bd92e02e7e55c483cf7b910c5a38a3cdfc36d026335cb574b5046fd5c720cdea::server:fcdc1726f942930c9431105ce1bc9c59";
	#	extraFlags = toString [
	#		"--node-ip 37.205.13.132"
	#		"--node-name klaus"
	#		"--disable traefik"
	#		"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
	#		"--cluster-init"
	#	];

	#};
}
