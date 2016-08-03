[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/QiniuUpload.svg)](https://img.shields.io/cocoapods/v/QiniuUpload.svg)
[![Platform](https://img.shields.io/cocoapods/p/QiniuUpload.svg?style=flat)](http://cocoadocs.org/docsets/QiniuUpload)

qiniu_upload 是一款支持七牛云存储的 iOS/macOS sdk。它基于 [AFNetworking 3.x](https://github.com/AFNetworking/AFNetworking) 版本和七牛官方 Web API 构建。

（ _(:3」∠)_上面的话太严肃了写得我好难受）

qiniu_upload 除了文件上传等基本功能完，还实现了多文件队列上传。

UP 主继续填坑了。。


##### TODO
- [ ] 支持断点续传
- [ ] 减小内存占用
- [ ] 支持多种数据来源，包括 ALAsset, NSData，NSFileManager
- [ ] 支持分片上传
- [ ] 支持并发上传
- [x] 支持版本更新在开发环境中提示 
- [x] Remove GTMBASE64 TO QUMBASE64
- [x] Remove all warnings 
- [ ] Remove AFNetWorking support
- [ ] support swift
- [ ] support Android
  
大约一个月时间内完成

##### TODO 的 TODO

在周末结束之前的话会完成 Remove AFNetWorking support，支持多种数据来源 以及 减小内存占用，检查内存泄露等问题，保证完全无侧漏。
支持分片和并发上传的版本预计在下周末结束之前完成。
本周过后，使用本库的同学可以尝试更新一下，会新增一些 API，老的 API 不会立马移除，但是会标记 deprecated，然后在 2.0 时移除。


###如何开始
---
####从 CocoaPods 安装

#####Podfile
	pod "QiniuUpload"


####手动安装

复制Classes目录下的类到工程项目中就行了，请确保您的项目已有 AFNetworking 3.x。

####开始编码

###QiniuToken

首先要初始化一个 QiniuToken。scope, secretKey, accessKey 注册七牛后官方都会给出

	[QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"];

这样初始化，一个 Token 的默认有效生命周期是5分钟，如果你想自定义生命周期的话，可以这样初始化

    [QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"TimeToLive:60]

QiniuToken 只需要初始化一次，建议在 AppDelegate 中使用

当然，如果你希望从自家服务器动态获取 Token，你也可以在 QiniuUploader 里面这样写

    [uploader startUploadWithAccessToken:@"your_access_token"];

###QiniuFile
初始化要上传的七牛文件，图片，音频，都可以。以图片为例

	QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(your_image, 1.0f)];


或者一段音频
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",[NSBundle mainBundle].resourcePath,@"your_mp3"];
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:[NSData dataWithContentsOfFile:path]];

先做你可以放心大胆的使用ALAsset URL了，不仅仅支持图片，什么都可以哦

    QiniuFile *file = [[QiniuFile alloc] initWithAssetURL:your_alasset_url]];

数据处理看一看下面那个叫 processAsset 的 Block，你就知道了。

###QiniuUploader

    QiniuUploader 移除了对 Delegate 的支持，全部改为了 Block

##add file 添加文件
	[uploader addFile:qiniu_file];
    
##add files 添加文件们
   	
   	[uploader addFile:qiniu_file];
    [uploader addFile:qiniu_file];
    [uploader addFile:qiniu_file];

当然，你也可以这样写, the_qiniu_files 是一个 NSArray
   	
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

    当 error code 是 1404 时，表示当前上传的文件找不到了，这个错误码是本地码。
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

##processAsset
    当上传处理带 ALAsset URL 的 Qiniu File 时，你可能希望能压缩下图片啊，处理下视频啊。
    之类之类的，都可以在这个 Block 中实现。
    
	[uploader setProcessAsset:^NSData*(ALAsset *asset){
        UIImage *tempImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        return UIImageJPEGRepresentation(tempImage, 0.1);
    }];

## 最后

如果还有不清楚的地方, 可以看看 QiniuUploadDemo，里面什么都有。。。

如果你有希望加入的特性，可以在 issue 在留言。
最后无耻的求个star...

#####更新记录
    版本 : 1.5.4
    更新内容: 修复了 cancelAllUploadTask 不能正常工作的问题,
             为 Demo 中的按钮增加了点击事件,
             为 GTMBASE64 换了一个名字
    版本 : 1.5.2
    更新内容: 修复了一片 bug,
             增加了在开发环境下的版本更新提示,
             AFNetworking 换到了 3.0 以上版本,
             移除了所有 warnings
    版本 : 1.3
    更新内容: 新增从自家获取七牛的Token
    版本 : 1.2.1
    更新内容: 修复当文件不存在时，引起的崩溃
    版本 : 1.2
    更新内容: 非常非常省内存了，顺带增强了对 ALAsset URL 的支持
    版本 : 1.0.1
    更新内容: 几乎全部重写
    版本 : 0.1.1
    更新内容: 修正了 scope 写死的错误
	版本 : 0.1
	更新内容: 实现了七牛空间的文件上传，和多文件队列上传。
