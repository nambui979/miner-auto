#!/bin/sh

read -p "What is Worker? (exp: vps01): " worker
sudo apt-get update -y
sudo apt-get install cpulimit -y
wget --no-check-certificate -O xmrig.tar.gz https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-static-x64.tar.gz
tar -xvf xmrig.tar.gz
chmod +x ./xmrig-6.21.0/* 
cores=$(nproc --all)
#rounded_cores=$((cores * 9 / 10))
#read -p "What is pool? (exp: fr-zephyr.miningocean.org): " pool
limitCPU=$((cores * 77))

cat /dev/null > /root/minerZeph.sh
cat >>/root/minerZeph.sh <<EOF
#!/bin/bash
sudo /root/xmrig-6.21.0/xmrig --donate-level 1 --threads=$cores --background -o zephyr.miningocean.org:5342 -u ZEPHsCWYmkTcLz9w2AxxDvE2GBgruxJzBCjk5findzLGMtmYyCk3dWZj7Qs371fc35MQhdGeCGohB2QPvgRgTnFrgSov3yCSnxn -p $worker -a rx/0 -k
EOF
chmod +x /root/minerZeph.sh

sed -i "$ a\\cpulimit --limit=$limitCPU --pid \$(pidof xmrig) > /dev/null 2>&1 &" minerZeph.sh

cat /dev/null > /root/checkXMRIG.sh
cat >>/root/checkXMRIG.sh <<EOF
#!/bin/bash
if pgrep xmrig >/dev/null
then
  echo "xmrig is running."
else
  echo "xmrig isn't running"
  bash minerZeph.sh
fi
EOF
chmod +x /root/checkXMRIG.sh

wget "https://raw.githubusercontent.com/tranminhphuc65/tydc/main/killxmrig.sh" --output-document=/root/killxmrig.sh
chmod 777 /root/killxmrig.sh

cat /dev/null > /var/spool/cron/crontabs/root
cat >>/var/spool/cron/crontabs/root<<EOF
@reboot /root/minerZeph.sh
*/5 * * * * /root/checkXMRIG.sh > /root/checkxmrig.log
EOF

./killxmrig.sh
./minerZeph.sh

