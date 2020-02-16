#!/bin/bash
#製作者: みぐりー

#使用するサーバーを固定したい場合は、例のようにフルパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) SERVER="/home/$USER/git/rcrs-server"
#SERVER="/home/$USER/git/rcrs-server-master"
SERVER="/home/$USER/git/rcrs-server"

#使用するエージェントを固定したい場合は、例のようにフルパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) AGENT="/home/migly/git/sample"
AGENT="/home/$USER/git/rcrs-adf-sample"

#使用するマップを固定したい場合は、例のようにmapsディレクトリからのパスを指定してください。
#固定したくない場合は空白で大丈夫です。
##例) MAP="maps/gml/Kobe2013/map"
MAP="maps/gml/test/map"

#瓦礫の有無。固定する場合はtrue(瓦礫あり)もしくはfalse(瓦礫なし)を指定してください。
#固定したくない場合は空白で大丈夫です。
#brockade=false
brockade=true

#ループ数。何回同じ条件で実行するかを1以上の数字で指定してください。
#固定したくない場合は空白で大丈夫です。
##例) LOOP=10
LOOP=2

#/////////////////////////////////////////////////////////////
#ここから先は改変しないでくだせぇ動作が止まっても知らないゾ？↓

CurrentVer=7.00
os=`uname`
LOCATION=$(cd $(dirname $0); pwd)
phase=0
master_url="https://raw.githubusercontent.com/Rione/rionelauncher/develop/RioneLauncher.sh"

if [[ ! -f $LOCATION/$(echo "$0") ]]; then
    echo 'スクリプトと同じディレクトリで実行してください。'
    exit 0
fi

#[C+ctrl]検知
trap 'last' {1,2,3,15}
rm $LOCATION/.signal &>/dev/null

killcommand(){

    if [[ $phase -eq 1 ]]; then

        if [[ $defalutblockade = "false" ]]; then

            sed -i -e 's/true/false/g' $CONFIG

        else

            sed -i -e 's/false/true/g' $CONFIG

        fi

    fi

    if [[ -f $SERVER/boot/"backup-$START_LAUNCH" ]]; then

        rm $SERVER/boot/$START_LAUNCH
        cat $SERVER/boot/backup-$START_LAUNCH > $SERVER/boot/$START_LAUNCH
        rm $SERVER/boot/"backup-$START_LAUNCH"

    fi

    kill $(ps aux | grep "start.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "start-comprun.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "start-precompute.sh" | grep -v "gnome-terminal" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "collapse.jar" | awk '{print $2}') &>/dev/null
    sleep 0.5
    kill $(ps aux | grep "compile.sh" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "start.sh -1 -1 -1 -1 -1 -1 localhost" | awk '{print $2}') &>/dev/null
    kill $(ps aux | grep "$SERVER" | awk '{print $2}') &>/dev/null

    rm $LOCATION/.history_date &>/dev/null
    rm $LOCATION/.signal &>/dev/null

    #updateスレッドが落ちるまで待機
    while :
    do
        if [[ `jobs | grep 'update' | awk '{print $2}'` = '実行中' ]]; then
            continue
        fi
        break
    done

}

last(){
    if [[ $phase -eq 1 ]]; then
        echo
        echo
        echo " シミュレーションを中断します...Σ(ﾟДﾟﾉ)ﾉ"
        echo
        if [[ -f $SERVER/boot/logs/kernel.log ]] && [[ ! -z `grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}'` ]]; then
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
    if [[ -f $LOCATION/.signal ]]; then
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

update(){
    #自動アップデート
    echo
    echo " ▶ ▶ アップデート確認中..."
    echo

    FILENAME=$LOCATION/$(echo "$0")
    master_script=$(curl -s $master_url)

    if [[ ! -z $(diff <(cat $FILENAME | tail -n +$(grep -n '？↓' $FILENAME | sed 's/:/ /g' | sed -n 1P | awk '{print $1}')) <(echo "$master_script" | tail -n +$(echo "$master_script" | grep -n '？↓' | sed 's/:/ /g' | sed -n 1P | awk '{print $1}'))) ]]; then
        
        echo
        echo ' ▶ ▶ アップデートします。'
        echo

        killcommand

        echo "$master_script" > $FILENAME
        partition_line=$(grep -n '？↓' $FILENAME | sed 's/:/ /g' | sed -n 1P | awk '{print $1}')

        sed -i -e "/#/!s@$(cat $FILENAME | head -$partition_line | grep 'SERVER=' | grep -v '#')@SERVER=\"$SERVER\"@g" $FILENAME
        sed -i -e "/#/!s@$(cat $FILENAME | head -$partition_line | grep 'AGENT=' | grep -v '#')@AGENT=\"$AGENT\"@g" $FILENAME
        sed -i -e "/#/!s@$(cat $FILENAME | head -$partition_line | grep 'MAP=' | grep -v '#')@MAP=\"$MAP\"@g" $FILENAME
        sed -i -e "/#/!s@$(cat $FILENAME | head -$partition_line | grep 'brockade=' | grep -v '#')@brockade=$brockade@g" $FILENAME
        sed -i -e "/#/!s@$(cat $FILENAME | head -$partition_line | grep 'LOOP=' | grep -v '#')@LOOP=$LOOP@g" $FILENAME

        echo
        echo " ▶ ▶ Version "$(cat $FILENAME | grep 'CurrentVer=' | sed 's@=@ @g' | awk '{print $2}')" にアップデート完了しました。"
        echo " ▶ ▶ 再起動をお願いします。"
        echo

        sleep 1

        kill `ps | grep bash | awk '{print $1}'` >& /dev/null

    fi
    exit 1
}

###########################################################################################################

original_clear

echo " □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □"
echo " □                                                                 □"
echo " □ 　Rione Launcher ($os)                                        □"
echo " □ 　　- レスキューシミュレーション起動補助スクリプト　Ver.$CurrentVer -  □"
echo " □                                                                 □"
echo " □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □ □"

#条件変更シグナル
ChangeConditions=0
DEBUG_FLAG=false

if [[ ! -z $1 ]]; then
    if [[ $1 == 'debug' ]]; then
        DEBUG_FLAG='true'
        if [[ -z $2 ]]; then
            ChangeConditions=0
        else
            ChangeConditions=1
        fi
    else
        ChangeConditions=1
    fi
fi

if [[ $DEBUG_FLAG == 'false' ]]; then
    update &
fi

echo
echo 
echo "  ● ディレクトリ検索中..."

#環境変数変更
IFS=$'\n'

#サーバーディレクトリの登録
if [[ -z $SERVER ]] || [[ $ChangeConditions -eq 1 ]] || [[ ! -f $SERVER/boot/start-comprun.sh ]]; then

    serverdirinfo=($(find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep jars/rescuecore2.jar | sed 's@/jars/rescuecore2.jar@@g')) &>/dev/null
    
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
        
            mapname=$(echo $i | sed 's@/@ @g' | awk '{print $NF}')

            serverdirinfo[$count]=$mapname"+@+"$i"+@+"${#mapname}

            count=$(($count+1))

        done
        
        #文字数最大値取得
        maxservername=$(echo "${serverdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}')

        #ソート
        serverdirinfo=($(echo "${serverdirinfo[*]}" | sort -f))

        #エージェントリスト表示
        line=0

        echo
        echo "▼ サーバーリスト"
        echo

        for i in ${serverdirinfo[@]}
        do  
        
            servername=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $1}')
            serverdir=$(echo ${i} | sed 's/+@+/ /g' | awk '{print $2}')
        
            printf "%3d  %s" $((++line)) $servername
            
            for ((space=$(($maxservername-${#servername}+5)); space>0; space--))
            do

                printf " "

            done
            
            printf "%s\n" $(echo $serverdir | sed "s@/home/$USER/@@g" | sed "s@$servername@@g")

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

#エージェントディレクトリの登録
if [ -z $AGENT ] || [ $ChangeConditions -eq 1 ] || [ ! -f $AGENT/library/rescue/adf/adf-core.jar ]; then

    agentdirinfo=(`find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'`) &>/dev/null
    
    original_clear

    if [ ${#agentdirinfo[@]} -eq 0 ]; then

        echo
        echo "エージェントが見つかりません…ｷｮﾛ^(･д･｡)(｡･д･)^ｷｮﾛ"
        echo
        exit 1

    fi

    if [ ! ${#agentdirinfo[@]} -eq 1 ]; then

        #エージェント名+ディレクトリ+文字数
        count=0
        for i in ${agentdirinfo[@]}; do
        
            agentname=`echo $i | sed 's@/@ @g' | awk '{print $NF}'`

            agentdirinfo[$count]=$agentname"+@+"$i"+@+"${#agentname}

            count=$(($count+1))

        done
        
        #文字数最大値取得
        maxagentname=`echo "${agentdirinfo[*]}" | sed 's/+@+/ /g' | awk '{if(m<$3) m=$3} END{print m}'`

        #ソート
        agentdirinfo=(`echo "${agentdirinfo[*]}" | sort -f`)

        #エージェントリスト表示
        line=0

        echo
        echo "▼ エージェントリスト"
        echo

        for i in ${agentdirinfo[@]};do

            agentname=`echo ${i} | sed 's/+@+/ /g' | awk '{print $1}'`
            agentdir=`echo ${i} | sed 's/+@+/ /g' | awk '{print $2}'`
        
            printf "%3d  %s" $((++line)) $agentname
            
            for ((space=$(($maxagentname-${#agentname}+5)); space>0; space--))
            do

                printf " "

            done
            
            printf "%s\n" `echo $agentdir | sed "s@/home/$USER/@@g" | sed "s@$agentname@@g"`

        done

        echo
        echo "上のリストからエージェントコードを選択してください。"
        echo "(※ 0を入力するとデフォルトになります)"

        while true
        do

            read agentnumber

            #入力エラーチェック
            if [ ! -z `expr "$agentnumber" : '\([0-9][0-9]*\)'` ] && [ 0 -lt $agentnumber ] && [ $agentnumber -le $line ]; then

                #アドレス代入
                AGENT=`echo ${agentdirinfo[$(($agentnumber-1))]} | sed 's/+@+/ /g' | awk '{print $2}'`
                break

            elif [ ! -z `expr "$agentnumber" : '\([0-9][0-9]*\)'` ] && [ $agentnumber -eq 0 ]; then

                if [ -f $AGENT/library/rescue/adf/adf-core.jar ]; then

                    break

                else

                    echo "デフォルトの設定が不正確です。0以外を入力してください。"

                fi

            else

                echo "もう一度入力してください。"

            fi

        done


    else

        AGENT=${agentdirinfo[0]}

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
#コメントアウトをとってもいいけど処理がめちゃくちゃ重くなりますぞ...

#maplist=(`cat $MAP/map.gml`)

#line_count=1
#before_comment=0
#after_comment=0

#echo ${#maplist[@]}

#for line in ${maplist[@]}; do

#   if [ `echo $line | grep '*'` ] && [ $before_comment = 0 ]; then

#       before_comment=$line_count

#   fi


#   if [ `echo $line | grep '*'` ] && [ $after_comment = 0 ]; then

#       after_comment=$line_count

#   fi


#   if [ `echo $line | grep '//'` ] && [ $before_comment = 0 ]; then

#       before_comment=$line_count
#       after_comment=$line_count

#   fi


#   if [ ! $before_comment = 0 ] && [ ! $after_comment = 0 ]; then

#       for ((i=before_comment; i <= $after_comment; i++)); do

#           unset maplist[$(($i-1))]

#       done

#       before_comment=0
#       after_comment=0

#   fi

#   line_count=$(($line_count+1))
#echo $line_count
#done

#echo

#echo text
#for n in ${maplist[@]}; do

#   echo $n>>tempfile

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
rm agent.log &>/dev/null

touch agent.log
touch server.log

#////////////////////////////////////////////////////////////////////////////////////////////////////

phase=1

cd $SERVER/boot/

if [ `grep -c "trap" start.sh` -eq 1 ]; then

    START_LAUNCH="start.sh"

else

    START_LAUNCH="start-comprun.sh"

fi

cp $START_LAUNCH "backup-$START_LAUNCH"

sed -i "s/$(cat $START_LAUNCH | grep 'startKernel')/startKernel --nomenu --autorun/g" $START_LAUNCH
sed -i "s/$(cat $START_LAUNCH | grep 'startSims')/startSims --nogui/g" $START_LAUNCH

#サーバー起動
if [ $os = "Linux" ]; then

    gnome-terminal --tab -x bash -c  "

        #[C+ctrl]検知
        trap 'last2' {1,2,3}
        last2(){
            echo -en "\x01" > $LOCATION/.signal
            exit 1
        }

        bash $START_LAUNCH -m ../$MAP/ -c ../`echo $CONFIG | sed "s@$SERVER/@@g" | sed 's@collapse.cfg@@g'` 2>&1 | tee $LOCATION/server.log

        read waitserver

    " &

else

    bash $START_LAUNCH -m ../$MAP/ -c ../`echo $CONFIG | sed "s@$SERVER/@@g" | sed 's@collapse.cfg@@g'` > $LOCATION/server.log &

fi

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
echo "  エージェントコード ："`echo $AGENT | sed 's@/@ @g' | awk '{print $NF}'`
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

#エージェント起動
cd $AGENT

echo
echo -n "  コンパイル中..."

bash compile.sh > $LOCATION/agent.log 2>&1

if [[ -f 'start.sh' ]]; then

    bash start.sh -1 -1 -1 -1 -1 -1 localhost >> $LOCATION/agent.log 2>&1 &

else

    bash ./launch.sh -all -local >> $LOCATION/agent.log 2>&1 &

fi

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

#エラーチェック
if [ -f agent.log ]; then

    #errer
    if [ `grep -c "Failed." agent.log` -eq 1 ]; then

        echo " エラー"
        echo
        echo
        echo " ＜エラー内容＞"
        echo
        cat agent.log
        echo
        echo " コンパイルエラー...開始できませんでした...ｻｰｾﾝ( ・ω ・)ゞ"
        echo

        killcommand

        exit 1

    fi

    #sucsess
    if [ `grep -c "Done." agent.log` -ge 1 ]; then

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

    ambulanceteam_read=`grep -c "PlatoonAmbulance@" agent.log`
    firebrigade_read=`grep -c "PlatoonFire@" agent.log`
    policeforce_read=`grep -c "PlatoonPolice@" agent.log`
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


    if [ `grep -c "Loader is not found." agent.log` -eq 1 ]; then

        errerbreak

    fi

    if [ ! `grep -c "Done connecting to server" agent.log` -eq 0 ]; then

        if [ `cat agent.log | grep "Done connecting to server" | awk '{print $6}' | sed -e 's/(//g'` -eq 0 ]; then

            errerbreak

        fi

        if [ `cat agent.log | grep "Done connecting to server" | awk '{print $6}' | sed -e 's/(//g'` -gt 0 ]; then

            if [[ $START_LAUNCH = "start.sh" ]]; then
            
                [ ! `grep -c "failed: No more agents" server.log` -eq 1 ] && continue

            fi

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

#agent.logの読み込み
lastline=`grep -e "FINISH" -n agent.log | sed -e 's/:.*//g' | awk '{if (max<$1) max=$1} END {print max}'`

#コンフィグのサイクル数読み込み
config_cycle=$(cat $(echo $CONFIG | sed s@collapse.cfg@kernel.cfg@g) | grep "timesteps:" | awk '{print $2}')

next_cycle=0

while true
do

    kill_subwindow

    cycle=$(cat $SERVER/boot/logs/traffic.log | grep -a "Timestep" | grep -a "took" | awk '{print $5}' | tail -n 1)

    expr $cycle + 1 > /dev/null 2>&1

    [ $? -eq 2 ] && continue

    [ -z $cycle ] && cycle=0

    if [[ $next_cycle -eq $cycle ]]; then

        echo '**** Time:' $cycle '*************************'
        echo 

        next_cycle=$(($cycle + 1))

    fi

    tail -n $((`wc -l agent.log | awk '{print $1}'` - $lastline)) agent.log

    lastline=$(wc -l agent.log | awk '{print $1}')

    if [ $cycle -ge $config_cycle ]; then

        echo
        echo "● シミュレーション終了！！"
        echo
        echo "◆ 最終スコアは"$(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}')"でした。"
        
        [ ! -f score.csv ] && echo 'Date, Score, Server, Agent, Map, Blockade' > score.csv
        [ $brockademenu = 'あり' ] && brockademenu=yes
        [ $brockademenu = 'なし' ] && brockademenu=no

        echo "$(date +%Y/%m/%d_%H:%M), $(grep -a -C 0 'Score:' $SERVER/boot/logs/kernel.log | tail -n 1 | awk '{print $5}'), $(echo $SERVER | sed "s@/home/$USER/@@g"), $(echo $AGENT | sed "s@/home/$USER/@@g"), $(echo $MAP | sed 's@/map/@@g' | sed 's@/map@@g' | sed 's@/maps@maps@g'), $brockademenu" >> score.csv
        echo
        echo "スコアは'score.csv'に記録しました。"
        echo

        killcommand

        exit 1

    fi

    sleep 1

done
