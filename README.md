　　　ヘヘヘ    
　＜（・∀・）＞  
　　　ＶＶＶ  
Piyo-Piyo Fortress  
  
# Inga-Do Type IoT Raspi-Recorder  
ラズベリーパイにカメラユニットを取り付け、起動すると自動で録画してくれるレコーダーです  
インターネットに接続されている場合、録画ファイルに自動で録画日時をつけてくれます  
Gmailと連動して、録画開始や動作異常についてメール通知する機能も備えています  
  
This is Auto Recording Script Set for Raspberry PI Zero/Zero W.  
Send E-mail (via Gmail) when "Rec start", "DISK FULL" , "Find Faliure"  
Released @ ComicMarket 95(Winter 2019)  
  
Sample Video(motorcycle helmet mount)  
https://twitter.com/IngaSakimori/status/1076787382295261184  
  
# Dependency  
## H/W  
Raspberry PI Zero/Zero W and Camera Unit  
MicroSD Card (Recommend over 32GB)  
## S/W  
Raspbian Stretch Offical Image  
  
# Setup  
Raspbian StretchをクリーンインストールしたRaspberry PIで、raspi-configを実行し、「CAMERA」を有効にしてください。  
任意のディレクトリにこのレポジトリをクローンするか  
ZIPファイルでダウンロードして、/tmpなどに解凍して、セットアップスクリプトを実行してください。  
  
## Enable CAMERA
  
$ sudo raspi-config  
  
Enable CAMERA Unit.  

  
## Clone  
  
$ cd /tmp  
$ sudo git clone https://github.com/IngaSakimori/ingado-iot-Raspi-Recorder.git  
$ sudo cd ingado-iot-Raspi-Recorder  
  
次に以下のコマンドを実行してください  
## Run Initial Script  
  
$ sudo chmod 755 ./00_initial_copy.sh  
$ sudo ./00_initial_copy.sh  
  
*OS設定ファイルも含めて上書きしますので、他の用途に使用中のRaspberry PIではセットアップしないでください*  
*Caution! Setup script will overwrite OS Setting.*  
  
# Usage  
以下の資料を参照してください。これはコミケ95で頒布した際の資料です  
https://www.slideshare.net/IngaSakimori/c95raspberry-pi-zero-w  
  
基本的には起動するだけで勝手に録画が始まります  
初期設定では720p/3Mbpsで録画が行われます  
録画中はH264フォーマットで録画が行われ、数十分ごとにMP4ファイルへのコンバートプロセスが自動で走ります  
  
手動で録画ファイルを回収する場合は、/opt/ingado-iot-camera/rec にMP4が保存されています  
自動で転送する場合はボリュームラベルを「RASPI」（半角大文字）に設定した「FAT32」形式のUSBメモリを接続してください  
数十分ごとに自動転送プロセスが走ります。また起動開始時にも録画中ファイルをコンバートした上で、自動転送プロセスが走ります  
（「exFAT」にも対応していますが、「FAT32」がオススメです。なお、フォーマットはWindowsやMACのフォーマッターではなく、SD Associationよりフリーで配布されている「SD Card Formatter」でフォーマットしてください）  
  
## This is Auto Recorder. It's simple.  
1st, Power on.  
2nd, wait few minutes.  
3rd, Recording start automatically.  
  
## Move recorded files
Insert USB Memory(Formatted "FAT32" and Named Volume label "RASPI").  
Wait about 20 minutes.  
Automatically moved recording files.  
(cron job runs background)  
  
# Licence  
デュアルライセンスです。  
GPLバージョン3もしくはInga-Do Type IoT商用ライセンスを選択することができます。  
特別な事情がない限り、GPLバージョン3を強く推奨します。  
  
This software is a dual license.  
Please choose GPL version 3 license or Inga-Do Type IoT commercial license.  
Unless there are special circumstances, it is strongly recommended to use GPL version 3 license.  
  
# Authors  
copylight 2019 Inga-do Type IoT/IngaSakimori All Rights Reserved  
  
# Additional Info  
本ソフトウェアは無保証です。  
ABSOLUTELY NO WARRANTY  
  
画質設定を変えたい場合は、デスクトップのリンクをクリックするか、/opt/ingado-iot-camera/commom.confを編集してください  
  
$ sudo vi /opt/ingado-iot-camera/commom.conf  
You can change Video bit rate and FPS.  
  
開発模様はこちら  
Development tweets  
https://togetter.com/li/1291301  
  
開発元のWebSiteはこちら  
This is Authors Website  
https://iot.inga-do.com/  

