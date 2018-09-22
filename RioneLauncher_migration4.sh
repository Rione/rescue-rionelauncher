#!/bin/bash
#製作者: みぐりー
#バージョン移行専用

if [[ -f RioneLauncher.sh ]]; then
	
	echo
	echo "バージョンを6.00に移行します..."
	wget -N -O RioneLauncher.sh `curl https://raw.githubusercontent.com/MiglyA/bash-rescue/master/histry.txt | grep "RioneLauncher5-link" | awk '{print $2}'` &>/dev/null
	rm score.log &>/dev/null
	rm src.log &>/dev/null
	rm server.log &>/dev/null
	echo
	echo
	echo "再起動をお願いします。"
	rm $0

else

	echo
	echo 'このスクリプトをRioneLauncher.shと同じディレクトリに置いてください。'
	echo

fi

exit 1

