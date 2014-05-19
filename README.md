
qiniu_upload 是一款支持七牛云存储的ios/mac sdk。它基于AFNetworking 2.x版本和七牛官方API构建。

（ _(:3」∠)_上面的话太严肃了写得我好难受）

qiniu_upload 除了文件上传等基本功能完，还实现了多文件队列上传。

后期还有官方api中说的url回调特性，也会加入其中（挖坑中..）


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

	QiniuToken *qToken = [[QiniuToken alloc] initWithScope:scope SecretKey:secretKey Accesskey:accessKey];

###QiniuFile
初始化要上传的七牛文件，图片，音频，都可以。

	QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(imageView.image, 1.0f)];


###QiniuUploader

##单文件上传
	QiniuUploader *uploader = [[QiniuUploader alloc] initWithToken:qToken];
	[uploader addFile:file];
    [uploader setDelegate:self];
    [uploader startUpload];
    
##多文件上传
   	
   	[uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader setDelegate:self];
    [uploader startUpload];
 
当然，你也可以这样写
   	
   	[uploader addFiles:theFiles];
    [uploader setDelegate:self];
    [uploader startUpload];
    
####QiniuUploaderDelegate

每当一个文件上传时的时候会调用这三个函数。index是当前上传的文件在队列中的序号

	- (void)uploadOneFileSucceeded:(AFHTTPRequestOperation *)operation Index:(NSInteger)index ret:(NSDictionary *)ret;
	
	- (void)uploadOneFileFailed:(AFHTTPRequestOperation *)operation Index:(NSInteger)index error:(NSError *)error;
	
	- (void)uploadOneFileProgress:(NSInteger)index UploadPercent:(double)percent;
	
当所有文件上传完毕后调用下面这个函数。这个函数被调用时，并不意味着所有文件都成功上传了，有可能某些文件并没有上传成功。
	
	- (void)uploadAllFilesComplete
	
####cancelAllUploadTask
	
当你希望取消掉所有上传任务时
	
	[uploader cancelAllUploadTask]
	


#####更新记录
	版本 : 0.1
	更新内容: 实现了七牛空间的文件上传，和多文件队列上传。