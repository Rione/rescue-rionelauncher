# RioneLauncher
## 概要
&nbsp;　RobocupRescueシミュレーションに必要なrcrs-serverとエージェントの起動をラクに実行できるようなスクリプトです。

## 確認環境
※Macでは動作しません。  
- Ubuntu18.04  
- Bash Ver.4.4.20  

## 導入
&nbsp;　以下のコマンドでダウンロードできます。場所はどこでも構いません。  

```
wget https://raw.githubusercontent.com/Rione/rionelauncher/master/RioneLauncher.sh
```

## 実行方法
&nbsp;　ホームディレクトリから自動的にサーバーとエージェントを検索するので、実行場所は基本的にどこでも大丈夫です。  

```
bash RioneLauncher.sh
```  

## オプション
### 実行条件指定
&nbsp;　RioneLauncher.shをエディタで開くと上にディレクトリ等指定ができる箇所がある。もしここが空であれば、実行時に自動でサーバーやエージェントなどのファイルを検索しリストアップする。

### 引数
&nbsp;　以下のように何か引数をしてすれば、スクリプトで直接ディレクトリ等指定している・していないにかかわらず、サーバーやエージェントなどのファイルを検索しリストアップする。  

```
bash RioneLauncher.sh 0
```

例では”0”としているが、本当に何でも良い（ただし、”debug”という文字列はデバッグ用に使用するため非推奨）。

### 自動アップデート機能