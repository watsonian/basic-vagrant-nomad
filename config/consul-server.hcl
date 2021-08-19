data_dir = "/tmp/data-consul"
log_level = "trace"

ui = true
server = true
bootstrap_expect = 1

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"

ports {
  https = -1
  grpc  = 8502
}

encrypt = "Bz6jxAkOeAW2ADxzHfax5TL4Tvl4Qb0P3oaONibmFgY="

enable_central_service_config = true

connect {
  enabled = true
}