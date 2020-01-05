# README

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