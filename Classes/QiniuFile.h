//
//  QiniuFile.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
#import <AssetsLibrary/AssetsLibrary.h>
#endif

@interface QiniuFile : NSObject


#if TARGET_OS_IOS
@property ALAsset *asset;
#endif

/**
 *  name of this file. It's could be nil.
 */
@property (copy, nonatomic) NSString *key;


/**
 *  Default value is @"image/jpeg"
 */
@property (copy, nonatomic) NSString *mimeType;

@property (copy, nonatomic) NSString *path;

@property (copy, nonatomic) NSData *rawData;


/**
 *  initialize instance with file path.
 *  @param path file path
 */
- (id)initWithPath:(NSString *)path;


/**
 *  initialize instance with binary data, and key name for it.
 *  @param theAsset the alasset for ios native resource
 */

#if TARGET_OS_IOS
- (id)initWithAsset:(ALAsset *)asset;
#endif

/**
 *  (only support image)initialize instance with binary data, and key name for it.
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
