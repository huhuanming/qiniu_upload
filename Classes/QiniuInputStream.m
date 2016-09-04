//
//  QiniuInputStream.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 16/9/3.
//  Copyright © 2016年 胡 桓铭. All rights reserved.
//

#import "QiniuInputStream.h"

@interface QiniuInputStream()
@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) NSData *footer;
@property (nonatomic) NSUInteger currentPart, delivered, length;
@property (nonatomic) NSStreamStatus status;
@end

@implementation QiniuInputStream
@synthesize delegate;

- (void)updateLength
{
    self.length = self.footer.length + [[self.parts valueForKeyPath:@"@sum.length"] unsignedIntegerValue];
}
- (id)init
{
    self = [super init];
    if (self)
    {
        self.parts    = [NSMutableArray array];
        self.boundary = [[NSProcessInfo processInfo] globallyUniqueString];
        self.footer   = [[NSString stringWithFormat:kFooterFormat, self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
        [self updateLength];
    }
    return self;
}
- (void)addPartWithName:(NSString *)name string:(NSString *)string
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name boundary:self.boundary string:string]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name boundary:self.boundary data:data contentType:@"application/octet-stream"]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data contentType:(NSString *)type
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name boundary:self.boundary data:data contentType:type]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString*)filename data:(NSData *)data contentType:(NSString *)type
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name boundary:self.boundary data:data contentType:type filename:filename]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name path:(NSString *)path
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name filename:nil boundary:self.boundary path:path]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename path:(NSString *)path
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name filename:filename boundary:self.boundary path:path]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name filename:filename boundary:self.boundary stream:stream streamLength:streamLength]];
    [self updateLength];
}

#if TARGET_OS_IOS
- (void)addPartWithName:(NSString *)name asset:(ALAsset *)asset;
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithName:name filename:nil boundary:self.boundary asset:asset]];
    [self updateLength];
}
#endif

- (void)addPartWithHeaders:(NSDictionary *)headers string:(NSString *)string
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithHeaders:headers string:string boundary:self.boundary]];
    [self updateLength];
}

- (void)addPartWithHeaders:(NSDictionary *)headers path:(NSString *)path
{
    [self.parts addObject:[[QiniuMultipartElement alloc] initWithHeaders:headers path:path boundary:self.boundary]];
    [self updateLength];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;
    
    self.status = NSStreamStatusReading;
    while (self.delivered < self.length && sent < len && self.currentPart < self.parts.count)
    {
        if ((read = [[self.parts objectAtIndex:self.currentPart] read:(buffer + sent) maxLength:(len - sent)]) == 0)
        {
            self.currentPart ++;
            continue;
        }
        sent            += read;
        self.delivered  += read;
    }
    if (self.delivered >= (self.length - self.footer.length) && sent < len)
    {
        read            = MIN(self.footer.length - (self.delivered - (self.length - self.footer.length)), len - sent);
        [self.footer getBytes:buffer + sent range:NSMakeRange(self.delivered - (self.length - self.footer.length), read)];
        sent           += read;
        self.delivered += read;
    }
    return sent;
}
- (BOOL)hasBytesAvailable
{
    return self.delivered < self.length;
}
- (void)open
{
    self.status = NSStreamStatusOpen;
}
- (void)close
{
    self.status = NSStreamStatusClosed;
}
- (NSStreamStatus)streamStatus
{
    if (self.status != NSStreamStatusClosed && self.delivered >= self.length)
    {
        self.status = NSStreamStatusAtEnd;
    }
    return self.status;
}
- (void)_scheduleInCFRunLoop:(NSRunLoop *)runLoop forMode:(id)mode {}
- (void)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext)context {}
- (void)removeFromRunLoop:(__unused NSRunLoop *)aRunLoop forMode:(__unused NSString *)mode {}
@end
