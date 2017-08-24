# QiniuUpload

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/QiniuUpload.svg)](https://img.shields.io/cocoapods/v/QiniuUpload.svg)
[![Platform](https://img.shields.io/cocoapods/p/QiniuUpload.svg?style=flat)](http://cocoadocs.org/docsets/QiniuUpload)

qiniu_upload 是一款支持七牛云存储的 iOS/macOS sdk。

qiniu_upload 除了文件上传等基本功能完，还实现了多文件队列上传。

qiniu_upload 转入了维护，想去写个 UploadKit。

## Done

- [x] 减小内存占用，清除内存泄露
- [x] 支持多种数据来源，包括 ALAsset, NSData，NSFileManager
- [x] 支持 NSInputStream 方式上传
- [x] 支持并发上传
- [x] 支持版本更新在开发环境中提示 
- [x] Remove all warnings 
- [x] Remove AFNetWorking support

## 如何开始

---

### CocoaPods

#### Podfile

```shell
    pod "QiniuUpload"
```

### 手动安装

复制Classes目录下的类到工程项目中就行了。

### 开始编码

#### QiniuToken

首先要初始化一个 QiniuToken。scope, secretKey, accessKey 注册七牛后官方都会给出

```Objective-C
    [QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"];
```

这样初始化，一个 Token 的默认有效生命周期是5分钟，如果你想自定义生命周期的话，可以这样初始化

```Objective-C
    [QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey" TimeToLive:60]
```

生成一个上传凭证

```Objective-C
    NSString *uploadToken = [[QiniuToken sharedQiniuToken] uploadToken]
```

不推荐在生产环境的代码中直接填写 accesskey 和 secretKey 来使用。

#### QiniuFile

初始化要上传的七牛文件，图片，音频都可以。

以图片为例「NSData 方式」

```Objective-C
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(your_image, 1.0f)];
```

或者一段音频「路径方式」

```Objective-C
    NSString *path = [NSString stringWithFormat:@"%@/%@",[NSBundle mainBundle].resourcePath,@"your_mp3"];
    QiniuFile *file = [[QiniuFile alloc] initWithPath:path];
```

或者 ALAsset

```Objective-C
    QiniuFile *file = [[QiniuFile alloc] initWithAsset: your_asset]];
```

#### QiniuUploader

#### 添加文件

```Objective-C
    uploader.files = @[file, file, file];
```

这里的 QinniuFile 可以部分是图片，部分是视频、音频，不会对上传有任何影响。

### 设置并发上限

```Objective-C
    [[QiniuUploader sharedUploader] setMaxConcurrentNumber:3];
```

建议不要设置过大，因为 iOS 的连接数是有限的。

#### 开始上传

上面乱七八糟的设置完了后，就调用这个开始上传。

```Objective-C
    [uploader startUpload:uploadToken uploadOneFileSucceededHandler:^(NSInteger index, NSDictionary * _Nonnull info) {
            NSLog(@"index: %ld info: %@",(long)index, info);
        } uploadOneFileFailedHandler:^(NSInteger index, NSError * _Nullable error) {
            NSLog(@"error: %@", error);
        } uploadOneFileProgressHandler:^(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
             NSLog(@"index:%ld percent:%f",(long)index, totalBytesSent * 1.0 / totalBytesExpectedToSend);
        } uploadAllFilesComplete:^{
            NSLog(@"complete");
        }];
```

再次提醒，不要在 App 内直接写入 key。

#### 取消全部上传任务

当你希望取消掉所有上传任务时

```Objective-C
    [uploader cancelAllUploadTask]
```

## 最后

如果还有不清楚的地方, 可以看看 QiniuUploadDemo，里面什么都有。。。

如果你有希望加入的特性，可以在 issue 在留言。
最后无耻的求个star...

## Thanks

Thanks for [@pavelosipov](https://github.com/pavelosipov)

[POSInputStreamLibrary](https://github.com/pavelosipov/POSInputStreamLibrary
) 帮我节省了很多时间去做用文件流形式读取 ALAsset 的工作

## 更新记录

[CHANGELOG.md](https://github.com/huhuanming/qiniu_upload/blob/master/CHANGELOG.md)