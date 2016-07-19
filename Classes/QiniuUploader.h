//
//  QiniuUploader.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "QiniuToken.h"
#import "QiniuFile.h"


typedef void (^UploadOneFileSucceededBlock)(AFHTTPSessionManager *manager, NSInteger index, NSString *key);
typedef void (^UploadOneFileFailedBlock)(AFHTTPSessionManager *manager, NSInteger index, NSDictionary *error);
typedef void (^UploadOneFileProgressBlock)(AFHTTPSessionManager *manager, NSInteger index, NSProgress *process);
typedef void (^UploadAllFilesCompleteBlock)(void);


typedef NSData* (^processAssetBlock)(ALAsset *asset);

@interface QiniuUploader : NSObject


@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (retain, nonatomic) NSMutableArray *files;

@property (nonatomic, copy) UploadOneFileSucceededBlock uploadOneFileSucceeded;
@property (nonatomic, copy) UploadOneFileFailedBlock uploadOneFileFailed;
@property (nonatomic, copy) UploadOneFileProgressBlock uploadOneFileProgress;
@property (nonatomic, copy) UploadAllFilesCompleteBlock uploadAllFilesComplete;
@property (nonatomic, copy) processAssetBlock processAsset;


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
- (Boolean)startUploadWithAccessToken:(NSString *)theAccessToken;

/**
 *  cancel and clear All Upload Task
 */
- (Boolean)cancelAllUploadTask;


@end
