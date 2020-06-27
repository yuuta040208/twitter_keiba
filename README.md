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


## user_stats ビューをCREATEするSQL

マイグレーションファイルでビュー作る方法わからんかったので。
（マイグレーションにSQL直書きでいけるか？）


```
CREATE VIEW user_stats AS
select
    users.id as user_id,
  	count(forecasts.id) as forecasts_count,
 	(coalesce(users.tanshou, 0) / count(forecasts.id)) as return_rate_win,
  	(coalesce(users.fukushou, 0) / count(forecasts.id)) as return_rate_place,
  	(
  		select round(count(sub_f) * 1.0 / count(forecasts.id), 2) * 100 from forecasts sub_f
  		inner join hits h on h.forecast_id = sub_f.id
  		where h.honmei_fukushou is not null and sub_f.user_id = users.id
  	) as hit_rate_place,
  	(
  		select round(count(sub_f) * 1.0 / count(forecasts.id), 2) * 100 from forecasts sub_f
  		inner join hits h on h.forecast_id = sub_f.id
    	where h.honmei_tanshou is not null and sub_f.user_id = users.id
  	) as hit_rate_win
FROM users
inner join forecasts on forecasts.user_id = users.id
group by users.id;
```