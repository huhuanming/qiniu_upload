//
//  QiniuUploader.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuToken.h"
#import "QiniuFile.h"
#import "QiniuInputStream.h"

@interface QiniuUploader : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (assign, atomic) NSInteger maxConcurrentNumber;
@property (assign, atomic, readonly) Boolean isRunning;
@property (retain, atomic) NSArray * _Nonnull files;


+ (id _Nullable)sharedUploader;

/**
 *  start upload files to qiniu cloud storage.
 *  @param AccessToken Qiniu AccessToken from your sever
 *  @return Boolean if files were nil, it will return NO.
 */
- (Boolean)startUpload:(NSString * _Nonnull)theAccessToken
               uploadOneFileSucceededHandler: (nullable void (^)(NSInteger index, NSDictionary * _Nonnull info)) successHandler
             uploadOneFileFailedHandler: (nullable void (^)(NSInteger index, NSError * _Nullable error)) failHandler
             uploadOneFileProgressHandler: (nullable void (^)(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend)) progressHandler
               uploadAllFilesComplete: (nullable void (^)()) completHandler;

/**
 *  cancel uploading task at once.
 */
- (Boolean)cancelAllUploadTask;


@end
