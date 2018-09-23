#!/bin/bash
#製作者: みぐりー
#バージョン移行専用

if [[ -f RioneLauncher.sh ]]; then

	echo "しばらくお待ちください。。。"

	rm $(find ~/ -type d -name ".*" -prune -o -type f -print | grep RioneLauncher.sh | grep boot)
	
	echo
	echo "バージョンを6.00に移行します..."
	wget -N -O RioneLauncher.sh `curl https://raw.githubusercontent.com/Ri--one/bash-rescue/master/histry.txt | grep "RioneLauncher5-link" | awk '{print $2}'` &>/dev/null
	rm score.log &>/dev/null
	rm src.log &>/dev/null
	rm server.log &>/dev/null
	echo
	echo
	echo "バージョン移行完了しました。"
	rm $0

else

	echo
	echo 'このスクリプトをRioneLauncher.shと同じディレクトリに置いてください。'
	echo

fi

exit 1

