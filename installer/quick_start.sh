function printTitle() {
  echo -e "\n\n**********\t ${1} \t**********\n"
}
#Install Latest Stable RackShift Release
os=$(uname -a)

if [ ! "$serverIp" ]; then
  printTitle "配置 RackShift 服务 IP 地址:"
  echo "请输入 RackShift 当前 IP 地址(与物理机 PXE 口属于同一个 VLAN )："
  read ip
  export serverIp=`echo $ip`
else
  printTitle "RackShift 服务 IP 地址: $serverIp"
fi

if [[ $os =~ 'Darwin' ]]; then
  echo 暂时不支持 MacOS 安装
else
  VERSION=$(curl -s https://github.com/rackshift/rackshift/releases/latest/download 2>&1 | grep -Po '[0-9]+\.[0-9]+\.[0-9]+.*(?=")')
fi

if [ -z "$VERSION" ]; then
  echo Please check your network,github is unreachable!
  exit
fi

if [ ! -f ./rackshift-online-installer-v${VERSION}.tar.gz ]; then
      wget --no-check-certificate https://github.com/rackshift/rackshift/releases/latest/download/rackshift-online-installer-v${VERSION}.tar.gz
fi

if [ ! -f ./rackshift-online-installer-v${VERSION}/installer ]; then
      tar zxvf rackshift-online-installer-v${VERSION}.tar.gz
fi
cd rackshift-online-installer-v${VERSION}/installer

/bin/bash install.sh online
