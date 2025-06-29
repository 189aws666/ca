#!/bin/bash

docker rm -f socks5-proxy
# 随机选择内网网段类型
SEGMENT=$((RANDOM % 6))
case $SEGMENT in
  0)
    SUBNET1=10
    SUBNET2=$((RANDOM % 256))
    SUBNET="$SUBNET1.$SUBNET2.0.0/16"
    GATEWAY="$SUBNET1.$SUBNET2.0.1"
    IP="$SUBNET1.$SUBNET2.$((RANDOM % 254 + 2)).$((RANDOM % 254 + 2))"
    ;;
  1)
    SUBNET1=172
    SUBNET2=$((RANDOM % 16 + 16))  # 172.16-31
    SUBNET="$SUBNET1.$SUBNET2.0.0/16"
    GATEWAY="$SUBNET1.$SUBNET2.0.1"
    IP="$SUBNET1.$SUBNET2.$((RANDOM % 254 + 2)).$((RANDOM % 254 + 2))"
    ;;
  2)
    SUBNET1=192
    SUBNET2=168
    SUBNET="$SUBNET1.$SUBNET2.0.0/16"
    GATEWAY="$SUBNET1.$SUBNET2.0.1"
    IP="$SUBNET1.$SUBNET2.$((RANDOM % 254 + 2)).$((RANDOM % 254 + 2))"
    ;;
  3)
    SUBNET1=100
    SUBNET2=$((RANDOM % 64 + 64))  # 100.64-127
    SUBNET="$SUBNET1.$SUBNET2.0.0/16"
    GATEWAY="$SUBNET1.$SUBNET2.0.1"
    IP="$SUBNET1.$SUBNET2.$((RANDOM % 254 + 2)).$((RANDOM % 254 + 2))"
    ;;
  4)
    SUBNET1=169
    SUBNET2=254
    SUBNET="$SUBNET1.$SUBNET2.0.0/16"
    GATEWAY="$SUBNET1.$SUBNET2.0.1"
    IP="$SUBNET1.$SUBNET2.$((RANDOM % 254 + 2)).$((RANDOM % 254 + 2))"
    ;;
  5)
    SUBNET1=198
    SUBNET2=$((RANDOM % 2 + 18))  # 198.18-19
    SUBNET="$SUBNET1.$SUBNET2.0.0/16"
    GATEWAY="$SUBNET1.$SUBNET2.0.1"
    IP="$SUBNET1.$SUBNET2.$((RANDOM % 254 + 2)).$((RANDOM % 254 + 2))"
    ;;
esac

# 创建随机网络
NETWORK_NAME="gost-net-$SUBNET1-$SUBNET2"
docker network rm $NETWORK_NAME 2>/dev/null
docker network create --driver bridge --subnet $SUBNET --gateway $GATEWAY $NETWORK_NAME

# 运行容器
docker run -d --restart=always \
  --name socks5-proxy \
  -p 43666:43666 \
  --network $NETWORK_NAME \
  --ip $IP \
  ginuerzh/gost \
  -L "socks5://:43666?udp=true&dns=https://1.1.1.2/dns-query,1.1.1.3"

echo "Container started with IP: $IP, Gateway: $GATEWAY, Network: $SUBNET"
