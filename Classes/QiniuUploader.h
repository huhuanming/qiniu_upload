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

typedef void (^UploadOneFileSucceededBlock)(NSInteger index, NSString *key, NSDictionary *info);
typedef void (^UploadOneFileFailedBlock)(NSInteger index, NSDictionary *error);
typedef void (^UploadOneFileProgressBlock)(NSInteger index, NSProgress *process);
typedef void (^UploadAllFilesCompleteBlock)(void);


@interface QiniuUploader : NSObject <NSURLSessionTaskDelegate>

@property (retain, atomic) NSMutableArray *files;

@property UploadOneFileSucceededBlock uploadOneFileSucceeded;
@property UploadOneFileFailedBlock uploadOneFileFailed;
@property UploadOneFileProgressBlock uploadOneFileProgress;
@property UploadAllFilesCompleteBlock uploadAllFilesComplete;
@property (assign, atomic)Boolean isRunning;

/**
 *  add QiniuFile to QiniuUploader
 *  @param file QiniuFile
 */
- (void)addFile:(QiniuFile *)file;
/**
 *  Upload binary data to qiniu cloud storage.
 *  @param theFiles binary data of upload file
 */
- (void)addFiles:(NSArray *)theFiles;

/**
 *  start upload files to qiniu cloud storage.
 *  @return Boolean if files were nil, it will return NO.
 */
- (Boolean)startUpload;


/**
 *  start upload files to qiniu cloud storage.
 *  @param AccessToken Qiniu AccessToken from your sever
 *  @return Boolean if files were nil, it will return NO.
 */
- (Boolean)startUploadWithAccessToken:(NSString *)theAccessToken
                                            __deprecated_msg("deprecated in version 1.6.0");

/**
 *  cancel uploading task at once.
 */
- (Boolean)cancelAllUploadTask;


@end
