# CHANGELOG

## x.x.x Release notes (yyyy-MM-dd)

=============================================================

### API breaking changes

### Enhancements

### Bugfixes

## 3.0.0 Release notes (2017-08-24)

### API breaking changes

* 将 files 从 NSMutableArray 改为 NSArray
* 将 Block 设置移到了 startUpload 函数上
* 移除了直接在 QiniuUploader 上设置 Token
* 添加了并发上传的支持

## 2.0.3 Release notes (2017-07-24)

=============================================================

### Bugfixes

* 修复七牛 URL 失效的问题
* 修复 Markdown 样式失效的问题
* 修复 iOS 10 下选择图片，崩溃的问题

## 2.0.2 Release notes (2016-09-16)

=============================================================

### Enhancements

* error 统一为 NSError 类型
* 七牛上传失败的错误信息都写入到了 error 中，可以对应七牛的失败错误码查看

## 2.0.0 Release notes (2016-09-03)

=============================================================

## API breaking changes

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

## 1.5.4

=============================================================

### Enhancements

* 为 Demo 中新增了价格按钮事件
* 为 GTMBASE64 更换了名字，避免同一工程中，文件名重复

### Bugfixes

* 修复了 cancelAllUploadTask 不能正常工作的问题

## 1.5.2

=============================================================

### Enhancements

* 增加了在开发环境下的版本更新提示
* 依赖的 AFNetworking 换到了 3.0 以上版本
* 修复了所有 warnings

## 1.3

=============================================================

### Enhancements

* 从服务器获取七牛的 token

## 1.2.1

=============================================================

### Bugfixes

* 修复当文件不存在时，引起的崩溃

## 1.2

=============================================================

### Enhancements

* 增强了对 ALAsset URL 的支持

## 1.0.1

=============================================================

大规模重构

## 0.1.1

=============================================================

### Bugfixes

* 修正了 scope 写死的错误

## 0.1

=============================================================

实现了七牛空间的文件上传，和多文件队列上传。
