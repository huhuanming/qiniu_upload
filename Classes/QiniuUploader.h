//
//  QiniuUploader.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "QiniuToken.h"
#import "QiniuUploaderDelegate.h"
#import "QiniuFile.h"

@interface QiniuUploader : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (assign, nonatomic) id<QiniuUploaderDelegate> delegate;
@property (retain, nonatomic) QiniuToken *token;
@property (retain, nonatomic) NSMutableArray *files;



/**
 *  Init QiniuUploader with given QiniuToken
 *  @param theToken QiniuToken
 */

- (id)initWithToken:(QiniuToken *)theToken;

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
 *  cancel and clear All Upload Task
 */
- (Boolean)cancelAllUploadTask;


@end
