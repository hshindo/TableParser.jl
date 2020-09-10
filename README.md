# TableParser.jl
# 表の抽出サンプル

## Detectronのインストール
Condaを使った例です．  
Ubuntu16.0.4で動作確認しています．  

Condaで仮想環境を構築します．
名前は`tabledetect`にしていますが，自由です．

```
conda create -n tabledetect python=2.7
conda activate tabledetect
(tabledetect) conda install pip
```

以降，`(tabledetect)`は省略します．

次に，[Detectron Install](https://github.com/facebookresearch/Detectron/blob/master/INSTALL.md)の手順に沿って，
[Caffe2](https://caffe2.ai/docs/getting-started.html?platform=ubuntu&configuration=prebuilt)をインストールします．リンク先ページを参考にGPU版をインストールします．  
事前にCUDA, cuDNN, NCCLのインストールが必要です．（CUDA 10, cuDNN 7.5で検証しています）

```
conda install pytorch-nightly -c pytorch
```

Caffe2が正しく動作するか確認します．
```
python -c 'from caffe2.python import core' 2>/dev/null && echo "Success" || echo "Failure"
python -c 'from caffe2.python import workspace; print(workspace.NumCudaDevices())'
```

次に，COCOAPIをインストールします．
```
git clone https://github.com/cocodataset/cocoapi
cd cocoapi/PythonAPI
make install
```

インストールが完了したら，ルートディレクトリへ戻ります．

次に，Detectronをインストールして動作テストを行います．

```
git clone https://github.com/facebookresearch/detectron
cd detectron
pip install pyyaml==3.12
pip install -r requirements.txt
make
python detectron/tests/test_spatial_narrow_as_op.py
```

Detectronのインストールが成功したら，ルートディレクトリへ戻ります．


## 表領域の認識モデル

以下の表領域の認識のモデルファイルと設定ファイルをダウンロードして，ルートディレクトリへ置きます．
* [model_final.pkl](https://conversationhub.blob.core.windows.net/tablebank/model_zoo/Without_copyright/X101/model_final.pkl)
* [config_X101.yaml](https://conversationhub.blob.core.windows.net/tablebank/model_zoo/Without_copyright/X101/config_X101.yaml)

次に，入力データを用意します．（サンプルとして，`data`ディレクトリ内のpdfファイルを使います）  

以下のコマンドでJavaを実行すると，ディレクトリ内にある全てのPDFが画像化されます．
```
java -classpath pdfextractor.jar PDF2Image input=data
```

ディレクトリ内に画像ファイルが生成されていることを確認します．

次に，表認識モデルを実行します．  
共有ファイルの`infer_simple.py`を`detectron/tools/infer_simple.py`に上書きします．新しい`infer_simple.py`は，オリジナルから出力フォーマットなどを変更したパッチです．  
そして，以下のコマンドをルートディレクトリで実行すると，`data`ディレクトリ内の画像から，表の領域認識された結果（jsonファイル）が`data`ディレクトリ内に作成されます．
```
python detectron/tools/infer_simple.py --cfg config_X101.yaml --image-ext jpg --wts model_final.pkl data
```

`data`ディレクトリ内にjsonファイルが出力されていることを確認します．
ただし，表が含まれないと予測されたpdfはjsonファイルが出力されません．


## 表の中身の解析

まずはじめに，[Julia](https://julialang.org/downloads/)をインストールします．  
次に，`CodecZlib`と`JSON`パッケージをインストールします．
パッケージをインストールするには，コンソールで`julia`を実行して，`]`を入力すると`pkg>`と表示されます．
この状態で，以下のように`add`コマンドでパッケージをインストールします．

```julia
$ julia↵

julia> ]

pkg> add CodecZlib JSON
# インストールが始まる
```


表の解析を実行するには，以下のコマンドを実効します．

```julia
julia main.jl ../data
```

`../data`は，好きなディレクトリに変更可能です．  
pdfファイルごとにhtmlファイルが出力されていることを確認します．
