# Jinja2

## map('combine')

```yml
servers_pa3:
  - name: server1
    state: present
  - name: server2
    state: present

app_shared_config_pa3:
  boot_volume:
    name: boot
    size: 20
    storage: pa3
  data_volumes:
    - name: data
      size: 30
      storage: pa3

app_shared_config_cdc:
  boot_volume:
    name: boot
    size: 20
    storage: cdc
  data_volumes:
    - name: data
      size: 30
      storage: cdc

shared_config_pa3:
  instance_auth: "hyperviser1"

shared_config_cdc:
  instance_auth: "hyperviser2"

shared_config:
  cores: 2
  memory: 2048

servers: >-
  {{
    (
      (
        servers_pa3 | map('combine',
          app_shared_config_pa3, shared_config_pa3
        )
      )
      +
      (
        servers_cdc | map('combine',
          app_shared_config_cdc, shared_config_cdc
        )
      )
    )
    | map('combine', shared_config)
  }}
```

# Multipath

## Flush

```sh
$ multipath -f <multipath device>
$ blockdev --flushbufs /dev/<block devices>
$ echo 1 > /sys/block/<block device>/device/delete
```
