variable "hostnames_no_disk" {
  type = "list"
  default = [
    # {
    #   hostname = "db1",
    #   tags = "patroni",
    #   cpu = "2",
    #   mem = "4",
    #   frac = "100",
    # },
    # {
    #   hostname = "db2",
    #   tags = "patroni",
    #   cpu = "2",
    #   mem = "4",
    #   frac = "100",
    # },
    # {
    #   hostname = "db3",
    #   tags = "patroni",
    #   cpu = "2",
    #   mem = "4",
    #   frac = "100",
    # },
    # {
    #   hostname = "web",
    #   tags = "master",
    #   cpu = "1",
    #   mem = "1",
    #   frac = "5",
    # },
    # {
    #   hostname = "web1",
    #   tags = "backend",
    #   cpu = "1",
    #   mem = "1",
    #   frac = "5",
    # },
    # {
    #   hostname = "web2",
    #   tags = "backend",
    #   cpu = "1",
    #   mem = "1",
    #   frac = "5",
    # },
    {
      hostname = "mfsmaster1",
      tags = "mfsmaster",
      cpu = "1",
      mem = "1",
      frac = "100",
      sdd = "0"
    },
    {
      hostname = "mfsmaster2",
      tags = "mfsmaster",
      cpu = "1",
      mem = "1",
      frac = "100",
      sdd = "0"

    }
  ]
}
variable "hostnames_with_disk" {
  type = "list"
  default = [
    {
      hostname = "nfs",
      tags = "nfs",
      cpu = "1",
      mem = "1",
      frac = "5",
      sdd = "1"
    },
    {
      hostname = "mfsdisk01",
      tags = "mfsdisk",
      cpu = "1",
      mem = "1",
      frac = "5",
      sdd = "1"
    },
    {
      hostname = "mfsdisk02",
      tags = "mfsdisk",
      cpu = "1",
      mem = "1",
      frac = "5",
      sdd = "1"
    },
    {
      hostname = "mfsdisk03",
      tags = "mfsdisk",
      cpu = "1",
      mem = "1",
      frac = "5",
      sdd = "1"
    }
  ]
}
