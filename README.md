
qiniu_upload 是一款支持七牛云存储的ios/mac sdk。它基于AFNetworking 2.x版本和七牛官方API构建。

（ _(:3」∠)_上面的话太严肃了写得我好难受）

qiniu_upload 除了文件上传等基本功能完，还实现了多文件队列上传。

UP 主开始填坑了。。增加了视频和音频上传的功能，删除了大量不好用的东西。。
几乎重写了


###如何开始
---
####从CocoaPods安装

#####Podfile
	platform :ios, '6.0'
	pod "QiniuUpload"


####手动安装

复制Classes目录下的类到工程项目中就行了，请确保您的项目已有AFNetworking 2.x。

####开始编码

###UploadToken

首先要初始化一个QiniuToken。scope, secretKey, accessKey注册七牛后官方都会给出

	[QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"];

这样初始化，一个 Token 的默认有效生命周期是5分钟，如果你想自定义生命周期的话，可以这样初始化

    [QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"TimeToLive:60]

QiniuToken 只需要初始化一次，建议在 AppDelegate 中使用

###QiniuFile
初始化要上传的七牛文件，图片，音频，都可以。以图片为例

	QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(your_image, 1.0f)];


或者一段音频
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",[NSBundle mainBundle].resourcePath,@"your_mp3"];
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:[NSData dataWithContentsOfFile:path]];

在或者你希望使用 AlAsset, 暂时 0.2 版 QiniuUpload 仅支持图片使用 AlAsset

    QiniuFile *file = [[QiniuFile alloc] initWithALAsset:your_image_alasset];


###QiniuUploader

    QiniuUploader 移除了对 Delegate 的支持，全部改为了 Block

##add file 添加文件
	[uploader addFile:qiniu_file];
    
##add files 添加文件们
   	
   	[uploader addFile:qiniu_file];
    [uploader addFile:qiniu_file];
    [uploader addFile:qiniu_file];

当然，你也可以这样写
   	
   	[uploader addFiles:the_qiniu_files];

这里的 QinniuFile 可以部分是图片，部分是视频、音频，不会对上传有任何影响。
    
## 上传一个文件成功时

    [uploader setUploadOneFileSucceeded:^(AFHTTPRequestOperation *operation, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index,key);
    }];

    这个 key 就是文件在七牛的唯一标识，七牛的 CDN 地址 + key 就可以访问该文件了
## 上传一个文件失败时
    
    [uploader setUploadOneFileFailed:^(AFHTTPRequestOperation *operation, NSInteger index, NSDictionary *error){
        NSLog(@"%@",error);
    }];
## 当前上传文件的进度

    [uploader setUploadOneFileProgress:^(AFHTTPRequestOperation *operation, NSInteger index, double percent){
        NSLog(@"index:%ld percent:%lf",(long)index,percent);
    }];
## 全部上传完成
    

    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
    }];

## 开始上传

上面乱七八糟的设置完了后，就调用这个开始上传

    [uploader startUpload];


## 取消全部上传任务
	
当你希望取消掉所有上传任务时
	
	[uploader cancelAllUploadTask]
	
## 最后

如果你有希望加入的特性，可以在 issue 在留言。
最后无耻的求个star...

#####更新记录
    版本 : 1.0.1
    更新内容: 几乎全部重写
    版本 : 0.1.1
    更新内容: 修正了 scope 写死的错误
	版本 : 0.1
	更新内容: 实现了七牛空间的文件上传，和多文件队列上传。