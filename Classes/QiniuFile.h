//
//  QiniuFile.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface QiniuFile : NSObject




@property NSURL *assetURL;


/**
 *  name of this file. It's could be nil.
 */
@property (copy, nonatomic) NSString *key;


/**
 *  Default value is @"image/jpeg"
 */
@property (copy, nonatomic) NSString *mimeType;

@property (copy, nonatomic) NSData *rawData;


/**
 *  (only support image)initialize instance with binary data, and key name for it.
 *  @param theAsset the alasset for ios native resource
 */
- (id)initWithAssetURL:(NSURL *)assetURL;

/**
 *  (only support image)initialize instance with binary data, and key name for it.
 *  @param theData binary data
 */
- (id)initWithFileData:(NSData *)theData;


///**
// *  initialize instance with binary data, and key name for it.
// *  @param theData binary data
// *
// */
//- (id)initWithFileData:(NSData *)theData;

/**
 *  initialize instance with binary data.
 *  @param theData binary data
 *  @param key name of this binary data
 */
- (id)initWithFileData:(NSData *)theData withKey:(NSString*)theKey;



@end
