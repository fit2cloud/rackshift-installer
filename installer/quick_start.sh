#Install Latest Stable RackShift Release
os=$(uname -a)

if [[ $os =~ 'Darwin' ]]; then
  echo 暂时不支持 MacOS 安装
else
  VERSION=$(curl -s https://github.com/rackshift/rackshift/releases/latest/download 2>&1 | grep -Po '[0-9]+\.[0-9]+\.[0-9]+.*(?=")')
fi

if [[ $VERSION =~ "" ]]; then
  echo Please check your network,github is unreachable!
  exit
fi

if [ ! -f ./rackshiftV${VERSION}.tar.gz ]; then
      wget --no-check-certificate https://github.com/rackshift/rackshift/releases/latest/download/rackshiftV${VERSION}.tar.gz
fi

if [ ! -f ./rackshiftV${VERSION}/installer ]; then
      tar zxvf rackshiftV${VERSION}.tar.gz
fi
cd rackshiftV${VERSION}/installer

/bin/bash install.sh
