x.x.x Release notes (yyyy-MM-dd)
=============================================================

### API breaking changes

### Enhancements

### Bugfixes

2.0.0 Release notes (2016-09-03)
=============================================================

### API breaking changes

* UploadOneFileSucceededBlock、UploadOneFileFailedBlock、UploadOneFileProgressBlock 参数发生了变化，不再暴露 NSURLSessionTask
* processAssetBlock 已彻底移除, 如果有处理图片的需求，推荐处理完图片后，保存到 temp 文件夹再上传
* 在 QiniuUploader 中新增 @property (assign, atomic)Boolean isRunning 可以检查当前是否正在上传
* 在 QiniuFile 中新增 @property ALAsset *asset 
* 在 QiniuFile 中新增 - (id)initWithPath:(NSString *)path path 是文件路径

### Enhancements

* Xcode 7.3.1 重建了该项目
* 彻底移除了 AFNetworking 的支持
* 支持文件 NSURL 和 ALAsset 从文件流中读取并上传
* 减小了内存占用，清除了可见的内存泄露

1.5.4
=============================================================

### Enhancements

* 为 Demo 中新增了价格按钮事件
* 为 GTMBASE64 更换了名字，避免同一工程中，文件名重复

### Bugfixes

* 修复了 cancelAllUploadTask 不能正常工作的问题


1.5.2
=============================================================

### Enhancements

* 增加了在开发环境下的版本更新提示
* 依赖的 AFNetworking 换到了 3.0 以上版本
* 修复了所有 warnings

1.3
=============================================================

### Enhancements

* 从服务器获取七牛的 token

1.2.1
=============================================================

### Bugfixes

* 修复当文件不存在时，引起的崩溃

1.2
=============================================================

### Enhancements

* 增强了对 ALAsset URL 的支持



1.0.1
=============================================================

大规模重构


0.1.1
=============================================================

### Bugfixes

* 修正了 scope 写死的错误


0.1
=============================================================

实现了七牛空间的文件上传，和多文件队列上传。
