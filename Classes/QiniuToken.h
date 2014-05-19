//
//  QiniuToken.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuToken : NSObject


/**
 *  secretKey of cloud storage.
 */
@property (copy, nonatomic) NSString *secretKey;


/**
 *  accessKey of cloud storage.
 */
@property (copy, nonatomic) NSString *accessKey;


/**
 *  scope is a name of cloud storage.
 */
@property (copy, nonatomic) NSString *scope;


/**
 *  uploadToken.
 */
- (NSString *)uploadToken;

/**
 *  initialize instance with scope, secret key and access key.
 *  @param scope scope is a name of cloud storage.
 *  @param SecretKey secretKey of cloud storage.
 *  @param Accesskey accessKey of cloud storage.
 */
- (id)initWithScope:(NSString *)theScope SecretKey:(NSString*)theSecretKey Accesskey:(NSString*)theAccessKey;


@end
