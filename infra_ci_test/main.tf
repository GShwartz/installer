data "kamatera_datacenter" "rosh_haayin" {
  country = "Israel"
  name    = "Rosh Haayin"
}

resource "kamatera_server" "my_server" {
  count         = length(var.image_id)
  name          = var.image_id[count.index].name
  password      = var.password
  datacenter_id = data.kamatera_datacenter.rosh_haayin.id
  cpu_type      = "B"
  cpu_cores     = 2
  ram_mb        = var.image_id[count.index].ram
  disk_sizes_gb = [10]
  image_id      = var.image_id[count.index].id
  network {
    name = "wan"
  }
  network {
    name = "lan-1-ci-test"
  }
}