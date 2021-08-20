data_dir = "/tmp/data-nomad"

bind_addr = "0.0.0.0"

log_level = "trace"

advertise {
    http = "{{ GetInterfaceIP \"eth1\" }}"
    rpc  = "{{ GetInterfaceIP \"eth1\" }}"
    serf = "{{ GetInterfaceIP \"eth1\" }}"
}

server {
    enabled = false

    license_path = "/vagrant/nomad.lic"
}

client {
    enabled = true

    # This is required for a Vagrant environment because
    # clients default to using the interface attached to
    # the default route, which is eth0. That interface is
    # a NAT setup that isn't really routable and is used
    # by Vagrant for `vagrant ssh`.
    network_interface = "eth1"
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}
