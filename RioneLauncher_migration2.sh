#!/bin/bash
#製作者: みぐりー
#バージョン移行専用

echo
echo "バージョンを4.10に移行します..."
rm $0
wget -N -O RioneLauncher.sh `curl https://raw.githubusercontent.com/MiglyA/bash-rescue/master/histry.txt | grep "RioneLauncher3-link" | awk '{print $2}'` &>/dev/null
echo
echo
echo "再起動をお願いします。"
exit 1
