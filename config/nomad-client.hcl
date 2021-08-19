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
}

client {
    enabled = true
    network_interface = "eth1"
}
