# README

競馬予想ツイート可視化システム


## herokuでvimを使う方法
```
mkdir ~/vim
cd ~/vim

# Staically linked vim version compiled from https://github.com/ericpruitt/static-vim
# Compiled on Jul 20 2017
curl 'https://s3.amazonaws.com/bengoa/vim-static.tar.gz' | tar -xz

export VIMRUNTIME="$HOME/vim/runtime"
export PATH="$HOME/vim:$PATH"
cd -
```

## rails c がうまくいかない時

```
export DISABLE_SPRING=true
```

## herokuに接続

```
heroku run bash
```

## Twitter Search APIのクエリ

https://developer.twitter.com/en/docs/tweets/search/guides/standard-operators

## netkeibaのDOMが変わった時

```
File.open('test.txt', 'w') do |text|
  text.puts(html.force_encoding("UTF-8"))
end
```
