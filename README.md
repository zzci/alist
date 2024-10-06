# alist with wireguard

## docker compose

* `docker-compose.yml`
```yaml
services:
  alist:
    image: zzci/alist
    restart: always
    container_name: alist
    networks:
      - traefik
    volumes:
      - ./work:/work
    cap_add:
      - NET_ADMIN
      - NET_RAW
    dns:
      - 223.5.5.5
networks:
  traefik:
    external: true
    name: traefik
```

* `/work/.init/init.sh`
```
#!/bin/sh

sctl enable alist
sctl enable wireguard
```
### wireguard
* `/work/wireguard/route.txt`

```
mkdir -p /work/wireguard/
wget -O ./work/wireguard/route.txt https://github.com/fernvenue/chn-cidr-list/raw/refs/heads/master/ipv4.txt
```

* `/work/wireguard/post.sh`

```shell
#!/bin/sh
# post.sh
## we have to wait for the network to be ready
/build/bin/wait-for qq.com:80 -- echo "net is ready"

IP="192.168.0.2/32"
VPNHOST="wg.demo.io"
VPNIF="wg0"
VPNIP=$(ping -c 1 $VPNHOST | awk -F'[()]' '/PING/{print $2}')
ROUTE="/work/wireguard/route.txt"

## setup vpn server use default gateway
echo "$VPNIP $VPNHOST" >> /etc/hosts
DEFAULT_GATEWAY=$(ip route | awk '/default/ {print $3}')
ip addr add $IP dev $VPNIF
ip route add $VPNIP via $DEFAULT_GATEWAY

## setup route
if [ -f $ROUTE ]; then
  while IFS= read -r line; do
    ip route add $line dev $VPNIF
  done < $ROUTE
fi
```

* /work/wireguard/wg.conf

```conf
[Interface]
PrivateKey = SCrdiU+sttS0SG2kdtOnBn0A2XpiKkl0MX1+OzP5CVo=

[Peer]
PublicKey = UZV+QS844A+BuxRKcx8WWgwVysC2zKCajl5eBJiXc1k=
AllowedIPs = 0.0.0.0/0
Endpoint = wg.demo.io:443
PersistentKeepalive = 60
```

