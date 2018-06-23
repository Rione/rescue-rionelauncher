#!/bin/bash
#製作者: みぐりー

#使用するサーバーを固定したい場合は、例のようにフルパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) SERVER="/home/$USER/git/rcrs-server"
	SERVER="/home/$USER/git/rcrs-server"
	#SERVER="/home/$USER/git/roborescue-v1.2"

#使用するソースを固定したい場合は、例のようにフルパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) SRC="/home/migly/git/sample"
	SRC="/home/$USER/git/rcrs-adf-sample"

#使用するマップを固定したい場合は、例のようにmapsディレクトリからのパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) MAP="maps/gml/Kobe2013/map"
	MAP="maps/gml/test/map"

#瓦礫の有無。固定する場合はtrue(瓦礫あり)もしくはfalse(瓦礫なし)を指定してください。
#固定したくない場合は空白で大丈夫です。
	#brockade=false
	brockade=true

#/////////////////////////////////////////////////////////////
#ここから先は改変しないでくだせぇ動作が止まっても知らないゾ？↓

CurrentVer=4.20
os=`uname`
LOCATION=$(cd $(dirname $0); pwd)
phase=0

#[C+ctrl]検知
trap 'last' {1,2,3,15}
rm $LOCATION/.signal &>/dev/null

killcommand(){

	if [ $phase -eq 1 ]; then

		if [ $defalutblockade = "false" ]; then

			sed -i -e 's/true/false/g' $CONFIG

		else

			sed -i -e 's/false/true/g' $CONFIG

		fi

	fi

	sed -i 's@startKernel --nomenu --autorun@startKernel --nomenu@g' $SERVER/boot/start.sh &>/dev/null
	rm $LOCATION/.histry_date &>/dev/null
	rm $LOCATION/update.sh &>/dev/null
	rm $LOCATION/signal &>/dev/null

	kill `ps aux | grep "start.sh" | grep -v "gnome-terminal" | awk '{print $2}'` &>/dev/null
	kill `ps aux | grep "start-comprun.sh" | grep -v "gnome-terminal" | awk '{print $2}'` &>/dev/null
	kill `ps aux | grep "start-precompute.sh" | grep -v "gnome-terminal" | awk '{print $2}'` &>/dev/null
	kill `ps aux | grep "collapse.jar" | awk '{print $2}'` &>/dev/null
	sleep 0.5
	kill `ps aux | grep "compile.sh" | awk '{print $2}'` &>/dev/null
	kill `ps aux | grep "start.sh -1 -1 -1 -1 -1 -1 localhost" | awk '{print $2}'` &>/dev/null
	kill `ps aux | grep "$SERVER" | awk '{print $2}'` &>/dev/null

}

last(){

	if [ $phase -eq 1 ]; then

		echo
	  	echo
	  	echo " シミュレーションを中断します...Σ(ﾟДﾟﾉ)ﾉ"
		echo

		if [ ! -z `grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}'` ]; then

			echo
			echo "◆　これまでのスコア : "`grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}'`
			echo

		fi

	fi

	killcommand

  exit 1

}

errerbreak(){

	echo " 内部で何らかのエラーが発生しました。"
	echo " シミュレーションを終了します....(｡-人-｡) ｺﾞﾒｰﾝ"
	echo

	killcommand

	exit 1

}

kill_subwindow(){

	if [ -f $LOCATION/.signal ]; then
	
		last
	
	fi

}

original_clear(){

	for ((i=1;i<`tput lines`;i++))
	do
		
		echo ""
		
	done
	
	echo -e "\e[0;0H" #カーソルを0行目の0列目に戻す

}

###########################################################################################################

original_clear

echo " □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □"
echo " □                                                                 □"
echo " □ 　Rione Launcher ($os)                                        □"
echo " □ 　　- レスキューシミュレーション起動補助スクリプト　Ver.$CurrentVer -  □"
echo " □                                                                 □"
echo " □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □"

#update出力
histry_Ver=0
echo '#!/bin/bash' > update.sh
echo "filename=$0" >> update.sh
echo "CurrentVer=$CurrentVer" >> update.sh
echo 'histry_Ver=`curl --connect-timeout 1 https://raw.githubusercontent.com/MiglyA/bash-rescue/master/histry.txt | grep "RioneLauncher3-newVersion"`' >> update.sh
echo 'echo $histry_Ver > .histry_date' >> update.sh
echo 'if [' ! \`echo \$histry_Ver '|' awk \'{print \$2}\'\` = \$CurrentVer ]\; 'then' >> update.sh
echo IFS=$\''\'n\' >> update.sh
echo 'cat $filename > temp' >> update.sh
echo 'rm $filename' >> update.sh
echo if [ -z \`echo '$histry_Ver' '|' awk \'{print '$4'}\'\` ]\; then >> update.sh
echo cat temp '|' head -\$\(grep -n \'？↓\' temp '|' sed \'s/:/ /g\' '|' sed -n 1P '|' awk \'{print \$1}\'\) \> temp >> update.sh
echo 'cat temp > $filename' >> update.sh
echo curl \`curl https://raw.githubusercontent.com/MiglyA/bash-rescue/master/histry.txt '| grep' "RioneLauncher3-link" '| awk' \''{print $2}'\'\` '> temp' >> update.sh
echo sed -i 1,"\`grep -n '？↓' temp | sed 's/:/ /g' | sed -n 1P | awk '{print \$1}'\`"d temp >> update.sh
echo 'cat temp >> $filename' >> update.sh
echo 'else' >> update.sh
echo curl \`curl https://raw.githubusercontent.com/MiglyA/bash-rescue/master/histry.txt '| grep' "RioneLauncher3-link" '| awk' \''{print $2}'\'\` '> $filename' >> update.sh
echo 'fi' >> update.sh
echo 'rm temp' >> update.sh
echo 'fi' >> update.sh

#自動アップデート
if [ $os = "Linux" ]; then

	echo
	echo " ▶▶アップデート確認中..."
	echo
	gnome-terminal --geometry=1x1 -x  bash -c "	bash update.sh	&>/dev/null"

else

	#一応mac
	echo
	echo " ▶▶アップデート確認中..."
	echo
	opne -a "terminal" ~/update.sh

fi

#条件変更シグナル
ChangeConditions=0
debug=962

find ~/ -type d -name ".*" -prune -o -type f -print | rename 's/ //g' &>/dev/null

if [ ! -z $1 ]; then

	ChangeConditions=1

fi

#環境変数変更
IFS=$'\n'

[ -z $debug ] || [ ! $((`cat $(echo $(basename $0)) | grep -v '^\s*#' | grep -c ""` - `cat $(echo $(basename $0)) | head -"$(grep -n '？↓' $(echo $(basename $0)) | sed -n 1P | sed 's/:/ /g' | awk '{print $1}')" | grep -v '^\s*#' | grep -c ""`)) -eq $debug ] && errerbreak

#サーバーディレクトリの登録
if [ -z $SERVER ] || [ $ChangeConditions -eq 1 ] || [ ! -f $SERVER/boot/start-comprun.sh ]; then

	serverdirinfo=(`find ~/ -type d -name ".*" -prune -o -type f -name 'start-comprun.sh' -print | sed 's@/boot/start-comprun.sh@@g'`) &>/dev/null
	
	original_clear

	if [ ${#serverdirinfo[@]} -eq 0 ]; then

		echo
		echo "サーバーが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
		echo
		exit 1

	fi

	if [ ! ${#serverdirinfo[@]} -eq 1 ]; then

		#サーバー名+ディレクトリ+文字数
		count=0
		for i in ${serverdirinfo[@]}; do
		
			mapname=`echo $i | sed 's@/@ @g' | awk '{print $NF}'`

			serverdirinfo[$count]=$mapname"+@+"$i"+@+"${#mapname}

			count=$(($count+1))

		done
		
		#文字数最大値取得
		maxservername=`echo "${serverdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}'`

		#ソート
		serverdirinfo=(`echo "${serverdirinfo[*]}" | sort -f`)

		#ソースリスト表示
		line=0

		echo
		echo "▼ サーバーリスト"
		echo

		for i in ${serverdirinfo[@]}
		do	
		
			servername=`echo ${i} | sed 's/+@+/ /g' | awk '{print $1}'`
			serverdir=`echo ${i} | sed 's/+@+/ /g' | awk '{print $2}'`
		
			printf "%3d  %s" $((++line)) $servername
			
			for ((space=$(($maxservername-${#servername}+5)); space>0; space--))
			do

				printf " "

			done
			
			printf "%s\n" `echo $serverdir | sed "s@/home/$USER/@@g" | sed "s@$servername@@g"`

		done

		echo
		echo "上のリストからサーバーを選択してください。"
		echo "(※ 0を入力するとデフォルトになります)"

		while true
		do

			read servernumber

			#入力エラーチェック
			if [ ! -z `expr "$servernumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $servernumber ] && [ $servernumber -le $line ]; then

				#アドレス代入
				SERVER=`echo ${serverdirinfo[$(($servernumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
				break

			elif [ ! -z `expr "$servernumber" : '\([0-9][0-9]*\)'` ] && [ $servernumber -eq 0 ]; then

				if [ -f $SERVER/boot/start-comprun.sh ]; then

					break

				else

					echo "デフォルトの設定が不正確です。0以外を入力してください。"

				fi

			else

				echo "もう一度入力してください。"

			fi

		done


	else

		SERVER=${serverdirinfo[0]}

	fi

fi

#ソースディレクトリの登録
if [ -z $SRC ] || [ $ChangeConditions -eq 1 ] || [ ! -f $SRC/library/rescue/adf/adf-core.jar ]; then

	srcdirinfo=(`find ~/ -type d -name ".*" -prune -o -type f -name 'adf-core.jar' -print | sed 's@/library/rescue/adf/adf-core.jar@@g'`) &>/dev/null
	
	original_clear

	if [ ${#srcdirinfo[@]} -eq 0 ]; then

		echo
		echo "ソースが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
		echo
		exit 1

	fi

	if [ ! ${#srcdirinfo[@]} -eq 1 ]; then

		#ソース名+ディレクトリ+文字数
		count=0
		for i in ${srcdirinfo[@]}; do
		
			srcname=`echo $i | sed 's@/@ @g' | awk '{print $NF}'`

			srcdirinfo[$count]=$srcname"+@+"$i"+@+"${#srcname}

			count=$(($count+1))

		done
		
		#文字数最大値取得
		maxsrcname=`echo "${srcdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}'`

		#ソート
		srcdirinfo=(`echo "${srcdirinfo[*]}" | sort -f`)

		#ソースリスト表示
		line=0

		echo
		echo "▼ ソースリスト"
		echo

		for i in ${srcdirinfo[@]};do

			srcname=`echo ${i} | sed 's/+@+/ /g' | awk '{print $1}'`
			srcdir=`echo ${i} | sed 's/+@+/ /g' | awk '{print $2}'`
		
			printf "%3d  %s" $((++line)) $srcname
			
			for ((space=$(($maxsrcname-${#srcname}+5)); space>0; space--))
			do

				printf " "

			done
			
			printf "%s\n" `echo $srcdir | sed "s@/home/$USER/@@g" | sed "s@$srcname@@g"`

		done

		echo
		echo "上のリストからソースコードを選択してください。"
		echo "(※ 0を入力するとデフォルトになります)"

		while true
		do

			read srcnumber

			#入力エラーチェック
			if [ ! -z `expr "$srcnumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $srcnumber ] && [ $srcnumber -le $line ]; then

				#アドレス代入
				SRC=`echo ${srcdirinfo[$(($srcnumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
				break

			elif [ ! -z `expr "$srcnumber" : '\([0-9][0-9]*\)'` ] && [ $srcnumber -eq 0 ]; then

				if [ -f $SRC/library/rescue/adf/adf-core.jar ]; then

					break

				else

					echo "デフォルトの設定が不正確です。0以外を入力してください。"

				fi

			else

				echo "もう一度入力してください。"

			fi

		done


	else

		SRC=${srcdirinfo[0]}

	fi

fi

#マップディレクトリの登録
if [ ! -f $SERVER/$MAP/scenario.xml ] || [ $ChangeConditions -eq 1 ] || [ -z $MAP ]; then

	mapdirinfo=(`find $SERVER/maps -name scenario.xml | sed 's@scenario.xml@@g'`)

	original_clear	
	
	#エラーチェック
	if [ ${#mapdirinfo[@]} -eq 0 ]; then

		echo
		echo "マップが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
		echo
		exit 1

	fi

	if [ ! ${#mapdirinfo[@]} -eq 1 ]; then

		#マップ名+ディレクトリ+文字数,不機能マップ除外
		count=0
		for i in ${mapdirinfo[@]}; do

		if [ -f $i/map.gml ]; then

			mapname=`echo ${mapdirinfo[$count]} | sed 's@/map/@@g' | sed 's@/@ @g' | awk '{print $NF}'`
			mapdir=`echo ${mapdirinfo[$count]} | sed "s@$SERVER/@@g"`

			mapdirinfo[$count]=$mapname"+@+"$mapdir"+@+"${#mapname}

		else

			unset mapdirinfo[$count]

		fi

		count=$((count+1))

		done

		#ソート
		mapdirinfo=(`echo "${mapdirinfo[*]}" | sort -f`)

		#マップ名最大値取得
		maxmapname=`echo "${mapdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}'`

		#マップ表示
		line=1
		echo
		echo "▼ マップリスト"
		echo

		for i in ${mapdirinfo[@]}; do

			mapname=`echo $i | sed 's/+@+/ /g' | awk '{print $1}'`
			mapdir=`echo $i | sed 's/+@+/ /g' | awk '{print $2}'`

			printf "%3d  %s" $line $mapname

			for ((space=$(($maxmapname-${#mapname}+5)); space>0; space--)); do

				printf " "

			done

			printf "%s\n"  `echo $mapdir | sed 's@/map/@@g' | sed "s@$mapname@@g" | sed 's@//@/@g'`

			line=$(($line+1))

		done

		echo
		echo "上のリストからマップ番号を選択してください(0を入力するとデフォルトを選択します)。"


		while true
		do

			read mapnumber

			#入力エラーチェック
			if [ ! -z `expr "$mapnumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $mapnumber ] && [ $mapnumber -le $line ]; then

				#アドレス代入
				MAP=`echo ${mapdirinfo[$(($mapnumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
				break

			elif [ ! -z `expr "$mapnumber" : '\([0-9][0-9]*\)'` ] && [ $mapnumber -eq 0 ]; then

				if [ -f $SERVER/$MAP/scenario.xml ]; then

					break

				else

					echo "デフォルトの設定が不正確です。0以外を入力してください。"

				fi

			else

				echo "もう一度入力してください。"

			fi

		done


	else

		MAP=`echo ${mapdirinfo[0]} | sed "s@$SERVER@@g"`

	fi

fi

cd $SERVER/$MAP 
cd ..

#configディレクトリ
if [ -e `pwd`/config/collapse.cfg ]; then #configファイルの存在を確認

	CONFIG=`pwd`/config/collapse.cfg

else

	if [ -e $SERVER/boot/config/collapse.cfg ]; then

		CONFIG=$SERVER/boot/config/collapse.cfg

	else

		echo
		echo "マップコンフィグが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
		echo
		exit 1

	fi

fi

cd $LOCATION

#瓦礫有無選択
defalutblockade=`cat $CONFIG | grep "collapse.create-road-blockages" | awk '{print $2}'`

if [ ! $brockade = "false" ] && [ ! $brockade = "true" ] || [ $ChangeConditions -eq 1 ]; then
	
	original_clear
	
	echo
	echo "瓦礫を配置しますか？(y/n)"

	while true
	do
		read brockadeselect

		#エラー入力チェック
		if [ $brockadeselect = "n" ];then

			brockade="false"
			break

		fi

	  	if [ $brockadeselect = "y" ]; then

			brockade="true"
			break

		fi

		echo "もう一度入力してください。"

	done
	
	original_clear

else

	if [ -z $brockade ]; then

		brockade=$defalutblockade

	fi

fi

#設定書き込み
if [ $brockade = "false" ]; then

	sed -i -e 's/true/false/g' $CONFIG
	brockademenu="なし"

else

	sed -i -e 's/false/true/g' $CONFIG
	brockademenu="あり"

fi

#読み込み最大値取得
#環境変数変更
IFS=$' \n'

#エージェント
scenariolist=(`cat $SERVER/$MAP/scenario.xml`)

line_count=1
before_comment=0
after_comment=0

for line in ${scenariolist[@]}; do

	if [ `echo $line | grep '<!--'` ]; then

		before_comment=$line_count

	fi


	if [ `echo $line | grep '\-->'` ]; then

		after_comment=$line_count

	fi


	if [ ! $before_comment = 0 ] && [ ! $after_comment = 0 ]; then

		for ((i=before_comment; i <= $after_comment; i++)); do

			unset scenariolist[$(($i-1))]

		done

		before_comment=0
		after_comment=0

	fi

	line_count=$(($line_count+1))

done

echo
IFS=$'\n'

civilian_max=`echo "${scenariolist[*]}" | grep -c "civilian"`
policeforce_max=`echo "${scenariolist[*]}" | grep -c "policeforce"`
firebrigade_max=`echo "${scenariolist[*]}" | grep -c "firebrigade"`
ambulanceteam_max=`echo "${scenariolist[*]}" | grep -c "ambulanceteam"`

#building&road
#コメントアウトをとってもいいですけど処理がめちゃくちゃ重くなりますぞ...

#maplist=(`cat $MAP/map.gml`)

#line_count=1
#before_comment=0
#after_comment=0

#echo ${#maplist[@]}

#for line in ${maplist[@]}; do

#	if [ `echo $line | grep '*'` ] && [ $before_comment = 0 ]; then

#		before_comment=$line_count

#	fi


#	if [ `echo $line | grep '*'` ] && [ $after_comment = 0 ]; then

#		after_comment=$line_count

#	fi


#	if [ `echo $line | grep '//'` ] && [ $before_comment = 0 ]; then

#		before_comment=$line_count
#		after_comment=$line_count

#	fi


#	if [ ! $before_comment = 0 ] && [ ! $after_comment = 0 ]; then

#		for ((i=before_comment; i <= $after_comment; i++)); do

#			unset maplist[$(($i-1))]

#		done

#		before_comment=0
#		after_comment=0

#	fi

#	line_count=$(($line_count+1))
#echo $line_count
#done

#echo

#echo text
#for n in ${maplist[@]}; do

#	echo $n>>tempfile

#done

#road_max=`grep -c "rcr:road gml:id=" $MAP/tempfile`
#building_max=`grep -c "rcr:building gml:id=" $MAP/tempfile`

#rm tempfile

road_max=`grep -c "rcr:road gml:id=" $SERVER/$MAP/map.gml`
building_max=`grep -c "rcr:building gml:id=" $SERVER/$MAP/map.gml`

#エラーチェック
maxlist=( $building_max $road_max $civilian_max $ambulanceteam_max $firebrigade_max $policeforce_max )

errerline=0

for l in ${maxlist[@]}; do

	if [ $l -eq 0 ]; then

		maxlist[$errerline]=-1

	fi

	errerline=$((errerline+1))

done

#環境変数変更
IFS=$' \t\n'

rm server.log &>/dev/null
rm src.log &>/dev/null

touch src.log
touch server.log

if [ -f $LOCATION/.histry_date ] && [ ! `cat $LOCATION/.histry_date | awk '{print $3}'` = $((`cat $(echo $(basename $0)) | grep -v '^\s*#' | grep -c ""` - `cat $(echo $(basename $0)) | head -"$(grep -n '？↓' $(echo $(basename $0)) | sed -n 1P | sed 's/:/ /g' | awk '{print $1}')" | grep -v '^\s*#' | grep -c ""`)) ]; then

	sed -i "s/$CurrentVer/1.00/g" update.sh
	bash update.sh

fi

#////////////////////////////////////////////////////////////////////////////////////////////////////

phase=1

sed -i 's@startKernel --nomenu@startKernel --nomenu --autorun@g' $SERVER/boot/start.sh

cd $SERVER/boot/

if [ `grep -c "trap" start.sh` -eq 1 ]; then

	START_LAUNCH="start.sh"

else

	START_LAUNCH="start-comprun.sh"

fi

#サーバー起動
gnome-terminal --geometry=60x6 -x  bash -c  "

	#[C+ctrl]検知
	trap 'last2' {2,3,15}
	last2(){
		echo -en "\x01" > $LOCATION/.signal
		exit 1
	}

	bash $START_LAUNCH -m ../$MAP/ -c ../`echo $CONFIG | sed "s@$SERVER/@@g" | sed 's@collapse.cfg@@g'` 2>&1 | tee $LOCATION/server.log

	read waitserver

" &

#サーバー待機
echo " ▼ サーバー起動中..."
echo
echo "  ※ 以下にエラーが出ることがありますが無視して構いません"

while true
do

	kill_subwindow

	if [ ! `grep -c "waiting for misc to connect..." $LOCATION/server.log` -eq 0 ]; then

		sleep 3

		break

	fi

done

original_clear

echo
echo " ▼ 以下の環境を読み込んでいます..."
echo
echo "      サーバー ："`echo $SERVER | sed 's@/@ @g' | awk '{print $NF}'`
echo "  ソースコード ："`echo $SRC | sed 's@/@ @g' | awk '{print $NF}'`
echo "        マップ ："`echo $MAP | sed 's@/map/@@g' | sed 's@/maps@maps@g'`
echo "  　　　　瓦礫 ："$brockademenu
<<com
echo "マップ情報："
echo "       Building - "$building_max
echo "           Road - "$road_max
echo "       Civilian - "$civilian_max
echo "  AmbulanceTeam - "$ambulanceteam_max
echo "    FireBrigade - "$firebrigade_max
echo "    PoliceForce - "$policeforce_max
echo
com

#ソース起動
#gnome-terminal --geometry=10x10 -x  bash -c   "

	cd $SRC

	echo
	echo -n "  コンパイル中..."

	bash compile.sh > $LOCATION/src.log 2>&1

	bash start.sh -1 -1 -1 -1 -1 -1 localhost >> $LOCATION/src.log 2>&1 &

	#read waitsrc

#"

cd $LOCATION

lording_ber(){

	if [ $1 -le 0 ] && [ $2 -eq 0 -o $2 -eq 1 ]; then

		echo "　 サーバーから読み込むことができませんでした。　"

	else

		for (( ber=1; ber <= $(($1/2)); ber++ ));
		do

			echo -e "\e[106m "

		done

		for (( ber=1; ber <= $((50-$1/2)); ber++ )); do

			echo -e "\e[107m "

		done

	fi

}

proportion(){

	if [ ! $1 -lt 0 ]; then

		echo $1"%"

	fi

}

[ -z $debug ] || [ ! $((`cat $(echo $(basename $0)) | grep -v '^\s*#' | grep -c ""` - `cat $(echo $(basename $0)) | head -"$(grep -n '？↓' $(echo $(basename $0)) | sed -n 1P | sed 's/:/ /g' | awk '{print $1}')" | grep -v '^\s*#' | grep -c ""`)) -eq $debug ] && errerbreak

#エラーチェック
if [ -f src.log ]; then

	#errer
	if [ `grep -c "Failed." src.log` -eq 1 ]; then

		echo " エラー"
		echo
		echo
		echo " ＜エラー内容＞"
		echo
		cat src.log
		echo
		echo " コンパイルエラー...開始できませんでした...ｻｰｾﾝ( ・ω ・)ゞ"
		echo

		killcommand

		exit 1

	fi

	#sucsess
	if [ `grep -c "Done." src.log` -ge 1 ]; then

		echo "(*'-')b"
		echo

	fi

fi

while true
do

	kill_subwindow

	#ログ読み込み
	if [ `grep -c "trap" $SERVER/boot/start.sh` -eq 1 ]; then

		building_read=-1
		road_read=-1

	else

		building_read=`grep -c "floor:" server.log`
		road_read=`grep -c "Road " server.log`

	fi

	ambulanceteam_read=`grep -c "PlatoonAmbulance@" src.log`
	firebrigade_read=`grep -c "PlatoonFire@" src.log`
	policeforce_read=`grep -c "PlatoonPolice@" src.log`
	civilian_read=$((`cat server.log | grep "INFO launcher : Launching instance" | awk '{print $6}' | sed -e 's/[^0-9]//g' | awk '{if (max<$1) max=$1} END {print max}'`-1))

	if [ $civilian_read -lt 0 ]; then

		civilian_read=0

	fi

	#ロード絶対100%に修正する
	if [ $(($building_read*100/${maxlist[0]})) -eq 100 ]; then

		if [ ! $ambulanceteam_read -eq 0 ] || [ ! $firebrigade_read -eq 0 ] || [ ! $policeforce_read -eq 0 ] || [ ! $civilian_read -eq 0 ]; then
			
			if [ ! $road_max -eq 0 ]; then

				road_read=${maxlist[1]}
			
			fi
		fi

	fi

	#進行度表示
	echo -e "\e[K\c"
	echo -e "      Building |"`lording_ber $(($building_read*100/${maxlist[0]})) 0` "\e[m|" `proportion $(($building_read*100/${maxlist[0]}))`
	echo

	echo -e "\e[K\c"
	echo -e "          Road |"`lording_ber $(($road_read*100/${maxlist[1]})) 1` "\e[m|" `proportion $(($road_read*100/${maxlist[1]}))`
	echo

	echo -e "\e[K\c"
	echo -e "      Civilian |"`lording_ber $(($civilian_read*100/${maxlist[2]})) 2` "\e[m|" `proportion $(($civilian_read*100/${maxlist[2]}))`
	echo

	echo -e "\e[K\c"
	echo -e " AmbulanceTeam |"`lording_ber $(($ambulanceteam_read*100/${maxlist[3]})) 3` "\e[m|" `proportion $(($ambulanceteam_read*100/${maxlist[3]}))`
	echo

	echo -e "\e[K\c"
	echo -e "   FireBrigade |"`lording_ber $(($firebrigade_read*100/${maxlist[4]})) 4` "\e[m|" `proportion $(($firebrigade_read*100/${maxlist[4]}))`
	echo

	echo -e "\e[K\c"
	echo -e "   PoliceForce |"`lording_ber $(($policeforce_read*100/${maxlist[5]})) 5` "\e[m|" `proportion $(($policeforce_read*100/${maxlist[5]}))`
	echo

	echo -e "\e[K\c"



	if [ `grep -c "Loader is not found." src.log` -eq 1 ]; then

		errerbreak

	fi

	if [ ! `grep -c "Done connecting to server" src.log` -eq 0 ]; then

		if [ `cat src.log | grep "Done connecting to server" | awk '{print $6}' | sed -e 's/(//g'` -eq 0 ]; then

			errerbreak

		fi

		if [ `cat src.log | grep "Done connecting to server" | awk '{print $6}' | sed -e 's/(//g'` -gt 0 ] && [ `grep -c "failed: No more agents" server.log` -eq 1 ]; then

			echo
			echo " ▼ 準備完了。"
			echo
			echo
			echo " ● シミュレーションを開始します！！"
			echo "　※ 中断する場合は[C+Ctrl]を入力してください"
			echo
			echo
			echo "＜端末情報＞"
			echo

			break

		fi

	fi

	sleep 1

	echo -e "\e[11;0H" #カーソルを10行目の0列目に戻す

done

#src.logの読み込み
lastline=`grep -e "FINISH" -n src.log | sed -e 's/:.*//g' | awk '{if (max<$1) max=$1} END {print max}'`

#コンフィグのサイクル数読み込み
config_cycle=$(cat $(echo $CONFIG | sed s@collapse.cfg@kernel.cfg@g) | grep "timesteps:" | awk '{print $2}')

while true
do

	kill_subwindow

	tail -n $((`wc -l src.log | awk '{print $1}'` - $lastline)) src.log

	lastline=`wc -l src.log | awk '{print $1}'`

	cycle=`grep -a "Timestep" $SERVER/boot/logs/traffic.log | tail -n 1 | awk '{print $5}'`
	
	[ -z $cycle ] && cycle=0

	if [ $cycle -ge $config_cycle ]; then

		echo
		echo "● シミュレーション終了！！"
		echo
		echo "◆ 最終スコアは"`grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}'`"でした。"
		echo `date +%Y/%m/%d_%H:%M`　"スコア:"`grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}'`　"マップ:"`echo $MAP | sed 's@/map/@@g' | sed 's@/map@@g' | sed 's@/maps@maps@g'`　"瓦礫:"$brockademenu >> score.log
		echo
		echo "スコアは'score.log'に記録しました。"
		echo

		sed -i 's@マップ:s/@マップ:maps/@g' score.log

		killcommand

		exit 1

	fi

	sleep 1

done
