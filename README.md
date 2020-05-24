# 编译
```
docker build -t unnamed:latest .
```

# 运行
```
docker run -p 1935:1935 -p 8080:80 --rm unnamed
```
* `1935`为rtmp协议端口，`8080`为http协议端口

# 推流
地址: `rtmp://<server ip>:1935/stream/<stream name>`<br/><br/>
可以使用OBS推流，配置示例: <br/>
  * 服务: `自定义`
  * 服务器: `rtmp://localhost:1935/stream`
  * 串流密钥: `hello`
  * 如果需要hls协议播放，注意查看问题[2]

# 观看
rtmp地址: `rtmp://<server ip>:1935/stream/<stream name>`<br/>
hls地址: `http://<server ip>:8080/live/<stream name>.m3u8`<br/><br/>
播放示例: 
  * ffplay: `ffplay -fflags nobuffer rtmp://localhost:1935/stream/hello`
  * hls.js: 在该[网页](https://hls-js.netlify.app/demo/)中输入`http://localhost:8080/live/hello.m3u8`

# 问题
1. 基于ubuntu:18.04构建（产出的镜像比较大），本来计划在Alpine上构建，但编译失败。

2. 使用OBS推流时，rtmp协议可以观看，hls协议获取不到视频，修改OBS的配置可以正常。具体原因待查。[参考链接](https://github.com/alfg/docker-nginx-rtmp/issues/64)。
