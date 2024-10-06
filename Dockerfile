FROM alpine:3.20

ENV PATH=$PATH:/build/bin:/work/bin

COPY --from=zzci/init / /

RUN apk add --no-cache \
  curl wget ca-certificates jq bash unzip \
  wireguard-tools tcpdump iptables ipset iproute2 net-tools iputils-ping \
  python3 py3-qrcode

WORKDIR /work

RUN LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/alist-org/alist/releases/latest | jq -r '.assets[] | select(.name | endswith("alist-linux-musl-amd64.tar.gz")) | .browser_download_url') && \
  curl -L $LATEST_RELEASE_URL -o /tmp/alist.tar.gz; \
  mkdir -p /build/bin/; \
  tar -zxvf /tmp/alist.tar.gz -C /build/bin/; \
  curl https://rclone.org/install.sh | bash

COPY rootfs /

CMD ["/start.sh"]
