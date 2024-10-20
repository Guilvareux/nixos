{ lib, pkgs, ... }:
let
	nameservers = [
		"1.1.1.1"
		"1.0.0.1"
		"2606:4700:4700::1111"
	];
in {

	boot = {
		isContainer = true;
		enableContainers = lib.mkDefault true;
		loader.initScript.enable = true;
		specialFileSystems."/run/keys".fsType = lib.mkForce "tmpfs";
		systemdExecutable = lib.mkDefault "/run/current-system/systemd/lib/systemd/systemd systemd.unified_cgroup_hierarchy=0";

	};

	documentation = {
		enable = lib.mkOverride 500 true;
		nixos.enable = lib.mkOverride 500 true;
	};

	networking = {
		nameservers = lib.mkDefault nameservers;
		dhcpcd.extraConfig = "noipv4ll";
		useHostResolvConf = lib.mkOverride 500 false;
		firewall = {
			enable = true;
			allowedTCPPorts = [ 22 80 443 5080 ];
		};
	};

	environment.systemPackages = with pkgs; [
		headscale
	];

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

		podman.dockerCompat = lib.mkForce false;
	};


	services = {

		k3s = {
			enable = false;
			role = "server";
			token = "%";
			extraFlags = toString [
				"--node-ip 37.205.13.132"
				"--node-name brainiac"
				"--disable traefik"
				"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
				"--cluster-init"
			];
		};
		
		nomad = {
			enable = true;
			enableDocker = true;
			extraSettingsPaths = [./nomad.hcl];
		};

		consul = {
			enable = true;
			webUi = true;
			extraConfigFiles = [ "/etc/nixos/cloud/consul.hcl" ];
		};

		resolved = lib.mkDefault { fallbackDns = nameservers; };
		openssh.startWhenNeeded = lib.mkOverride 500 false;

		headscale = {
			enable = true;
			address = "37.205.13.132";
			port = 5080;
			user = "paul";
			group = "users";
			settings = {
				server_url = "http://37.205.13.132:5080";
				db_type = "sqlite3";
				dns_config = {
					nameservers = [
						"1.1.1.1"
						"1.0.0.1"
					];
				};
			};
		};
	};

	systemd = {
		services = {

			k3s = {
				wants = ["containerd.service"];			
				after = ["containerd.service"];			
			};

			systemd-sysctl.enable = false;
			systemd-oomd.enable = false;
			rpc-gssd.enable = false;
			systemd-udev-trigger.serviceConfig.ExecStart = [
				""
				"-udevadm trigger --subsystem-match=net --action=add"
			];

			networking-setup = {
				description = "Load network configuration provided by the vpsAdminOS host";
				before = [ "network.target" ];
				wantedBy = [ "network.target" ];
				after = [ "network-pre.target" ];
				path = [ pkgs.iproute2 ];
				serviceConfig = {
					Type = "oneshot";
					RemainAfterExit = true;
					ExecStart = "${pkgs.bash}/bin/bash /ifcfg.add";
					ExecStop = "${pkgs.bash}/bin/bash /ifcfg.del";
				};
				unitConfig.ConditionPathExists = "/ifcfg.add";
				restartIfChanged = false;
			};
		};
		sockets."systemd-journald-audit".enable = false;
		mounts = [ {where = "/sys/kernel/debug"; enable = false;} ];
		additionalUpstreamSystemUnits = [
			"systemd-udev-trigger.service"
		];
		extraConfig = ''
		DefaultTimeoutStartSec=900s
		'';
	};


	system.stateVersion = "22.11";
}
