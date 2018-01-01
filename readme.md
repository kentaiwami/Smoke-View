<img src="">

スモログ(仮)
=============
## 概要
喫煙にかける時間や頻度をセンサーで自動収集し、そのデータを提示して自分の喫煙を把握できるアプリです。
センサーを使用してデータを収集するため、わざわざアプリを操作して喫煙記録を残す手間はありません。
また、喫煙の頻度からペースを予測し目標本数と比較を行い、注意を促したりしてくれます。

## 注意事項
* 1つのWi-Fiおよびセンサーにつき1人までしか記録・管理できません。
そのため、同じセンサーを使用して複数人が喫煙を行った場合、特定の1人が複数回喫煙をしたと記録されます。

## システム構成図
<img src="system_image.png" align="center" />

## デモ
![demo]()
## サポート情報
* Xcode x.x
* iOS x.x
* iPhone 6,6s


## 注意事項
* Raspberry PiのIPアドレスを固定にした方が楽です

## 使い方
1. [Webサイト](http://osoyoo.com/ja/2017/03/30/co检测器/)を参考にしてラズパイとセンサーを繋げる
2. ラズパイを設置・起動
3. ラズパイをWi-Fiに接続
4. ラズパイ上で[Raspberry Pi API](raspberry-pi/api/api.py)と[Raspberry Pi Sensor](raspberry-pi/mq-7.py)をサービスとして起動する
5. アプリを起動し設定を行う
    * 給与日
    * 吸っているタバコ1箱の値段
    * 1日の目標本数
    * Raspberry PiのIPアドレス
    * Raspberry Piとのリンク
6. いつも通りタバコを吸う

## API
#### Create User
```
method：POST
endpoint：user
request：
{
    "uuid": "hogehoge",
    "payday": 30,
    "price": 100,
    "target_number": 10,
    "address": "192.168.0.0"
}
response：
{
    "uuid": "hogehoge",
    "id": 1
}
```

#### Update User Profile
```
method：PUT
endpoint：user/{id}
request：
{
    "uuid": "hogehoge",
    "payday": 25,
    "price": 420,
    "target_number": 20,
    "address": "192.168.0.0"
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "is_active": 1,
    "payday": 25,
    "price": 420,
    "target_number": 20
}
```

#### Update User Active Status
```
method：PATCH
endpoint：user/{id}
request：
{
    "uuid": "hogehoge"
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "is_active": 1,
    "payday": 25,
    "price": 420,
    "target_number": 20
}
```

#### Get User Data
```
method：GET
endpoint：user/{id}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "payday": 25,
    "price": 420,
    "target_number": 20,
    "address": "192.168.0.0"
}
```

#### Create Smoke
```
method：POST
endpoint：smoke
request：
{
    "uuid": "hogehoge"
}
response：
{
    "uuid": "hogehoge",
    "smoke_id": 10
}
```

#### Update End Smoke Time
```
method：PUT
endpoint：smoke/{id}
request：
{
    "uuid": "hogehoge"
}
response：
{
    "smoke_id": 10,
    "started_at": "2017-11-03 23:48:56",
    "ended_at": "2017-11-03 23:52:32"
}
```

#### Update Smoke Data
```
method：PATCH
endpoint：smoke/{id}
request：
{
    "smoke_id": 10,
    "started_at": "2017-11-11 23:23:23",
    "ended_at": "2017-11-11 23:52:52"
}
response：
{
    "smoke_id": 10,
    "started_at": "2017-11-11 23:23:23",
    "ended_at": "2017-11-11 23:52:52"
}
```

#### Delete Smoke Data
```
method：DELETE
endpoint：smoke/{smoke_id}/user/{user_id}
response：
{
    "msg": "Success delete"
}
```

#### Get User's Smoke Overview Data
```
method：GET
endpoint：smoke/overview/user/{id}
response：
{
    "count": 28,
    "min": 41,
    "hour": [1,3,1,2,2,2,2,1,1,1,2,1,3,1,1,2,1,1],
    "over": 13
}
```

#### Get User's Smoke Detail Data
```
method：GET
endpoint：smoke/detail/user/{id}
response：
{
    "coefficients": [0.0087776806526799998,-0.25967204092200002,2.11355137918,-3.7402793965300001,14.304487179500001],
    "price": 420,
    "ave": 3.6000000000000001
}

```
