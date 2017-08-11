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

typedef void (^UploadOneFileSucceededBlock)(NSInteger index, NSDictionary * _Nonnull info);
typedef void (^UploadOneFileFailedBlock)(NSInteger index, NSError * _Nullable error);
typedef void (^UploadOneFileProgressBlock)(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^UploadAllFilesCompleteBlock)(void);


@interface QiniuUploader : NSObject <NSURLSessionTaskDelegate>

@property (retain, atomic) NSArray * _Nonnull files;

@property UploadOneFileSucceededBlock _Nullable uploadOneFileSucceeded;
@property UploadOneFileFailedBlock _Nullable uploadOneFileFailed;
@property UploadOneFileProgressBlock _Nullable uploadOneFileProgress;
@property UploadAllFilesCompleteBlock _Nullable uploadAllFilesComplete;
@property (assign, atomic)Boolean isRunning;

+ (id _Nullable)sharedUploader;

/**
 *  start upload files to qiniu cloud storage.
 *  @param AccessToken Qiniu AccessToken from your sever
 *  @return Boolean if files were nil, it will return NO.
 */
- (Boolean)startUploadWithAccessToken:(NSString * _Nonnull)theAccessToken;

/**
 *  cancel uploading task at once.
 */
- (Boolean)cancelAllUploadTask;


@end

@interface QiniuIndexFile : NSObject

@property (assign, atomic) NSInteger index;
@property (retain, nonatomic ,readonly) NSString * _Nonnull uuid;

- (id _Nonnull )initWithIndex:(NSInteger)index;

@end

