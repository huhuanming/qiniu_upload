//
//  QiniuFile.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuFile : NSObject


/**
 *  binary data of upload file.
 */
@property (copy, nonatomic) NSData *fileData;


/**
 *  name of this file. It's could be nil.
 */
@property (copy, nonatomic) NSString *key;


/**
 *  Default value is @"image/jpeg"
 */
@property (copy, nonatomic) NSString *mimeType;

/**
 *  initialize instance with binary data, and key name for it.
 *  @param theData binary data
 */
- (id)initWithFileData:(NSData *)theData;

/**
 *  initialize instance with binary data.
 *  @param theData binary data
 *  @param key name of this binary data
 */
- (id)initWithFileData:(NSData *)theData withKey:(NSString*)theKey;


@end
