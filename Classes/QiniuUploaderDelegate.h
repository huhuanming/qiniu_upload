//
//  QiniuUploadDelegate.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QiniuUploaderDelegate <NSObject>

@optional
/**
 *  upload one file of files were succeeded.
 *  @param operation current operation of this upload task
 *  @param Index flle's order
 *  @param ret response object from Qiniu Colud.
 */
- (void)uploadOneFileSucceeded:(AFHTTPRequestOperation *)operation Index:(NSInteger)index ret:(NSDictionary *)ret;

/**
 *  upload one file of files were failed.
 *  @param operation current operation of this upload task
 *  @param Index flle's order
 *  @param error error from Qiniu Colud.
 */
- (void)uploadOneFileFailed:(AFHTTPRequestOperation *)operation Index:(NSInteger)index error:(NSError *)error;

/**
 *  upload one file of files.
 *  @param Index flle's order
 *  @param percent upload percent.
 */
- (void)uploadOneFileProgress:(NSInteger)index UploadPercent:(double)percent;
@required

/**
 *  Called when all files upload complete.
 */
- (void)uploadAllFilesComplete;



@end
