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

typedef void (^UploadOneFileSucceededBlock)(NSInteger index, NSString * _Nonnull key, NSDictionary * _Nonnull info);
typedef void (^UploadOneFileFailedBlock)(NSInteger index, NSError * _Nullable error);
typedef void (^UploadOneFileProgressBlock)(NSInteger index, NSProgress * _Nonnull process);
typedef void (^UploadAllFilesCompleteBlock)(void);


@interface QiniuUploader : NSObject <NSURLSessionTaskDelegate>

@property (retain, atomic) NSMutableArray * _Nonnull files;

@property UploadOneFileSucceededBlock _Nullable uploadOneFileSucceeded;
@property UploadOneFileFailedBlock _Nullable uploadOneFileFailed;
@property UploadOneFileProgressBlock _Nullable uploadOneFileProgress;
@property UploadAllFilesCompleteBlock _Nullable uploadAllFilesComplete;
@property (assign, atomic)Boolean isRunning;

/**
 *  add QiniuFile to QiniuUploader
 *  @param file QiniuFile
 */
- (void)addFile:(QiniuFile * _Nonnull)file;
/**
 *  Upload binary data to qiniu cloud storage.
 *  @param theFiles binary data of upload file
 */
- (void)addFiles:(NSArray * _Nonnull)theFiles;

/**
 *  start upload files to qiniu cloud storage.
 *  @return Boolean if files were nil, it will return NO.
 */
- (Boolean)startUpload __deprecated_msg("deprecated in version 2.4.0");


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
