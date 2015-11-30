job "nomad-example" {
        region = "vagrant"
        datacenters = ["vagrant1"]
        constraint {
                attribute = "$attr.kernel.name"
                value = "linux"
        }

        update {
                stagger = "20s"
                max_parallel = 1
        }

        # Create a 'cache' group. Each task in the group will be
        # scheduled onto the same machine.
        group "poc" {
                task "poc" {
                        driver = "docker"
                        config {
                                image = "maguec/golang-pocapp"
                                #command = "/usr/local/bin/supervisord"
                                #args = "-c /etc/supervisord.conf -n"
                        }
                        env {
                                APP_LOG_DIR = "/alloc/logs/"
                                CONSUL_SERVER = "localhost"
                                CONSUL_CLUSTER = "vagrant"
                        }
                        resources {
                                cpu = 1000 # 1 Ghz
                                memory = 100 # 1Mb - we are low in resources in vagrant
                                network {
                                        mbits = 10
                                        dynamic_ports = ["3000"]
                                }
                        }
                }
        }
}
