//
//  QiniuMultipartElement.h
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 16/9/3.
//  Copyright © 2016年 胡 桓铭. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
#import <MobileCoreServices/UTType.h>
#import "NSInputStream+POS.h"
#endif

#define kHeaderStringFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define kHeaderDataFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\nContent-Type: %@\r\n\r\n"
#define kHeaderPathFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n"
#define kFooterFormat @"--%@--\r\n"

@interface QiniuMultipartElement : NSObject
@property (nonatomic, strong) NSData *headers;
@property (nonatomic, strong) NSInputStream *body;
@property (nonatomic) NSUInteger headersLength, bodyLength, length, delivered;

- (id)initWithName:(NSString *)name boundary:(NSString *)boundary string:(NSString *)string;

- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data contentType:(NSString *)contentType;

- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data contentType:(NSString *)contentType filename:(NSString*)filename;

- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary path:(NSString *)path;

- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength;

- (id)initWithHeaders:(NSDictionary *)headers string:(NSString *)string boundary:(NSString *)boundary;

- (id)initWithHeaders:(NSDictionary *)headers path:(NSString *)path boundary:(NSString *)boundary;

#if TARGET_OS_IOS
- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary asset:(ALAsset *)asset;
#endif

@end

