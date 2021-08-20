job "example" {
  datacenters = ["dc1"]

  group "cache" {
    network {
      port "db" {
        to = 6379
      }
    }

    scaling {
      enabled = true
      min = 1
      max = 3
      policy {
        cooldown = "1m"
        evaluation_interval = "1m"

        check "95pct" {
          strategy "app-sizing-percentile" {
            percentile = "95"
          }
        }

        check "max" {
          strategy "app-sizing-max" {}
        }
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:3.2"

        ports = ["db"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
