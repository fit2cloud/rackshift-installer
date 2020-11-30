#!/bin/bash

installLog="/tmp/rackshift-install.log"

red=31
green=32
yellow=33
blue=34
validationPassed=1

function printTitle() {
  echo -e "\n\n**********\t ${1} \t**********\n"
}

function printSubTitle() {
  echo -e "------\t \033[${blue}m ${1} \033[0m \t------\n"
}

function colorMsg() {
  echo -e "\033[$1m $2 \033[0m"
}

function checkPort() {
  record=$(lsof -i:$1 | grep LISTEN | wc -l)
  echo -ne "$1 端口 \t\t........................ "
  if [ "$record" -eq "0" ]; then
    colorMsg $green "[OK]"
  else
    validationPassed=0
    colorMsg $red "[被占用]"
  fi
}

echo "" >$installLog

systemName=" RackShift 服务"
versionInfo=$(cat ../rackhd/conf/version)

colorMsg $yellow "\n\n开始安装 $systemName，版本 - $versionInfo"

printTitle "${systemName} 安装环境检测"

#root用户检测
echo -ne "root 用户检测 \t\t........................ "
isRoot=$(id -u -n | grep root | wc -l)
if [ "x$isRoot" == "x1" ]; then
  colorMsg $green "[OK]"
else
  colorMsg $red "[ERROR] 请用 root 用户执行安装脚本"
  validationPassed=0
fi

#操作系统检测
echo -ne "操作系统检测 \t\t........................ "
if [ -f /etc/redhat-release ]; then
  majorVersion=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+' | awk -F. '{print $1}')
  if [ "x$majorVersion" == "x" ]; then
    colorMsg $red "[ERROR] 操作系统类型版本不符合要求，请使用 CentOS 7.x, RHEL 7.x 版本 64 位"
    validationPassed=0
  else
    if [ "x$majorVersion" == "x7" ]; then
      is64bitArch=$(uname -m)
      if [ "x$is64bitArch" == "xx86_64" ]; then
        colorMsg $green "[OK]"
      else
        colorMsg $red "[ERROR] 操作系统必须是 64 位的，32 位的不支持"
        validationPassed=0
      fi
    else
      colorMsg $red "[ERROR] 操作系统类型版本不符合要求，请使用 CentOS 7.x, RHEL 7.x 版本 64 位"
      validationPassed=0
    fi
  fi
else
  colorMsg $red "[ERROR] 操作系统类型版本不符合要求，请使用 CentOS 7.x, RHEL 7.x版本 64 位"
  validationPassed=0
fi

#磁盘剩余空间检测
echo -ne "磁盘剩余空间检测 \t........................ "
path="/opt/rackshift"

IFSOld=$IFS
IFS=$'\n'
lines=$(df)
for line in ${lines}; do
  linePath=$(echo ${line} | awk -F' ' '{print $6}')
  lineAvail=$(echo ${line} | awk -F' ' '{print $4}')
  if [ "${linePath:0:1}" != "/" ]; then
    continue
  fi

  if [ "${linePath}" == "/" ]; then
    rootAvail=${lineAvail}
    continue
  fi

  pathLength=${#path}
  if [ "${linePath:0:${pathLength}}" == "${path}" ]; then
    pathAvail=${lineAvail}
    break
  fi
done
IFS=$IFSOld

if test -z "${pathAvail}"; then
  pathAvail=${rootAvail}
fi

if [ $pathAvail -lt 2097 ]; then
  colorMsg $red "[ERROR] 安装目录剩余空间小于 200G， 所在机器的安装目录可用空间需要至少 200G"
  validationPassed=0
else
  colorMsg $green "[OK]"
fi

#docker环境检测
echo -ne "Docker 检测 \t\t........................ "
hasDocker=$(which docker 2>&1)
if [[ "${hasDocker}" =~ "no docker" ]]; then
  colorMsg $green '[OK]'
else
  dockerVersion=$(docker info | grep 'Server Version' | awk -F: '{print $2}' | awk -F. '{print $1}')
  if [ "$dockerVersion" -lt "18" ]; then
    colorMsg $red "[ERROR] Docker 版本需要 18 以上"
    validationPassed=0
  else
    colorMsg $green "[OK]"

    echo -ne "docker-compose 检测 \t........................ "
    hasDockerCompose=$(which docker-compose 2>&1)
    if [[ "${hasDockerCompose}" =~ "no docker-compose" ]]; then
      colorMsg $red "[ERROR] 未安装 docker-compose"
      validationPassed=0
    else
      colorMsg $green '[OK]'
    fi
  fi
fi

rackshiftPorts=$(grep -A 1 "ports:$" ./docker-compose.yml | grep "\-.*:" | awk -F":" '{print $1}' | awk -F" " '{print $2}')
for rackshiftPort in ${rackshiftPorts}; do
  checkPort $rackshiftPort
done

if [ $validationPassed -eq 0 ]; then
  colorMsg $red "\n${systemName} 安装环境检测未通过，请查阅上述环境检测结果\n"
  exit 1
fi

printTitle "开始进行${systemName} 安装"

# step 1 - install docker & docker-compose
printSubTitle "安装 Docker 运行时环境"
if [[ "${hasDocker}" =~ "no docker" ]]; then
  if [ ! -d "../docker" ]; then
    curl -fsSL https://get.docker.com -o get-docker.sh 2>&1 | tee -a $installLog
    sudo sh get-docker.sh --mirror Aliyun 2>&1 | tee -a $installLog
    log "... 启动 docker"
    service docker start 2>&1 | tee -a $installLog
  else
    cp ../docker/bin/* /usr/bin/
    cp ../docker/service/docker.service /etc/systemd/system/
    chmod +x /usr/bin/docker*
    chmod 754 /etc/systemd/system/docker.service
    echo -ne "Docker \t\t\t........................ "
    colorMsg $green "[OK]"
  fi
else
  echo -ne "Docker \t\t\t........................ "
  colorMsg $green "[OK] 已存在 Docker 运行时环境，忽略安装"
fi
systemctl start docker >>$installLog 2>&1
systemctl enable docker >>$installLog 2>&1
echo -ne "启动 Docker 服务 \t........................ "
colorMsg $green "[OK]"

if [ $(grep "vm.max_map_count" /etc/sysctl.conf | wc -l) -eq 0 ]; then
  echo "vm.max_map_count=262144" >>/etc/sysctl.conf
  sysctl -p /etc/sysctl.conf >>$installLog
fi

# step 2 - load rackshift 2.0 docker images
#echo
printSubTitle "加载 Docker 镜像"
docker_images_folder="../docker-images"
if [ ! -d "$docker_images_folder" ]; then
  echo -ne "docker_images 目录检测 \t\t........................ "
  colorMsg $red "[不存在]"
  echo -ne "准备开始下载docker镜像 \t\t........................ "
  colorMsg $green "[OK]"
else
  for docker_image in ${docker_images_folder}/*; do
    temp_file=$(basename $docker_image)
    printf "加载镜像 %-45s ........................ " $temp_file
    docker load -q -i ${docker_images_folder}/$temp_file >>$installLog
    printf "\e[32m[OK]\e[0m \n"
  done
fi

# step 3 - config rackshift service & start rackshift
printTitle "配置  RackShift服务"
echo -ne "配置  RackShift服务 \t........................ "
mkdir -p /opt/rackshift/
cp -rp ../rackhd /opt/rackshift
cp rackshift.service /etc/init.d/rackshift
chmod a+x /etc/init.d/rackshift
mkdir -p /opt/rackshift/conf/mysql/sql
cp ./mysql.cnf /opt/rackshift/conf/mysql
cp ./rackshift.sql /opt/rackshift/conf/mysql/sql
cp ./rackshift.properties /opt/rackshift/conf
cp ./docker-compose.yml /opt/rackshift
cp ./.env /opt/rackshift
mkdir -p /opt/rackshift/plugins
cp ../plugins/* /opt/rackshift/plugins

cp ./rackshift.service ./rsctl 2 >>$installLog >>$installLog
cp rsctl /usr/local/bin &
chmod +x /usr/local/bin/rsctl
ln -s /usr/local/bin/rsctl /usr/bin/rsctl

# step 4 - 设置ip地址
printTitle "配置 RackShift 服务 ip 地址:"
echo "请输入 RackShift 当前IP地址(与物理机 PXE 口属于同一个 VLAN )："
read serverIp
cp /opt/rackshift/rackhd/monorail/config.json.bak /opt/rackshift/rackhd/monorail/config.json
sed -i "s/172.31.128.1/${serverIp}/g" /opt/rackshift/rackhd/monorail/config.json
sed -i "s/172.31.128.1/${serverIp}/g" /opt/rackshift/conf/mysql/sql/rackshift.sql

chkconfig rackshift on
rackshiftService=$(grep "service rackhshift start" /etc/rc.d/rc.local | wc -l)
if [ "$rackshiftService" -eq 0 ]; then
  echo "service rackshift start" >>/etc/rc.d/rc.local
fi
systemctl restart docker
colorMsg $green "[OK]"

printTitle "启动  RackShift 服务"
echo -ne "启动  RackShift 服务 \t........................ "
service rackshift start
colorMsg $green "[OK]"

printTitle "正在开放必要端口"
firewall-cmd --zone=public --add-port=80/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=8080/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=8083/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=8443/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=9080/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=9090/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=9030/tcp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=4011/udp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=67/udp --permanent >>$installLog 2>&1
firewall-cmd --zone=public --add-port=69/udp --permanent >>$installLog 2>&1
firewall-cmd --reload
firewall-cmd --zone=public --list-ports

echo
echo "*********************************************************************************************************************************"
echo -e "\t $systemName 安装完成，请在服务完全启动后(大概需要等待5分钟左右)访问 http://$serverIp:80 来访问  RackShift 控制台 默认账号密码 admin/123"
echo
echo "*********************************************************************************************************************************"
echo
rsctl
