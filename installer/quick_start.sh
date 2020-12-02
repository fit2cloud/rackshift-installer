#Install Latest Stable RackShift Release
os=$(uname -a)
# 支持MacOS
if [[ $os =~ 'Darwin' ]]; then
  echo 暂时不支持 MacOS 安装
  #VERSION=$(curl -s https://github.com/rackshift/rackshift/releases/latest |grep -Eo 'v[0-9]+.[0-9]+.[0-9]+')
else
  VERSION=$(curl -s https://github.com/rackshift/rackshift/releases/latest/download 2>&1 | grep -Po '[0-9]+\.[0-9]+\.[0-9]+.*(?=")')
fi

wget --no-check-certificate https://github.com/rackshift/rackshift/releases/latest/download/rackshiftV${VERSION}.tar.gz
#curl -s https://api.github.com/repos/rackshift/rackshift/releases/latest | grep browser_download_url | grep online | cut -d '"' -f 4 | wget -qi -
tar zxvf rackshiftV${VERSION}.tar.gz
cd rackshiftV${VERSION}/installer

/bin/bash install.sh
