//
//  QiniuInputStream.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 16/9/3.
//  Copyright © 2016年 胡 桓铭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuMultipartElement.h"

@interface QiniuInputStream : NSInputStream
@property (nonatomic, readonly) NSString *boundary;
@property (nonatomic, readonly) NSUInteger length;

- (void)addPartWithName:(NSString *)name string:(NSString *)string;
- (void)addPartWithName:(NSString *)name data:(NSData *)data;
- (void)addPartWithName:(NSString *)name data:(NSData *)data contentType:(NSString *)type;
- (void)addPartWithName:(NSString *)name filename:(NSString*)filename data:(NSData *)data contentType:(NSString *)type;
- (void)addPartWithName:(NSString *)name path:(NSString *)path;
#if TARGET_OS_IOS
- (void)addPartWithName:(NSString *)name asset:(ALAsset *)asset;
#endif
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename path:(NSString *)path;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength;
- (void)addPartWithHeaders:(NSDictionary *)headers string:(NSString *)string;
- (void)addPartWithHeaders:(NSDictionary *)headers path:(NSString *)path;

@end
