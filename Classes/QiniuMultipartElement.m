//
//  QiniuMultipartElement.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 16/9/3.
//  Copyright © 2016年 胡 桓铭. All rights reserved.
//

#import "QiniuMultipartElement.h"

static NSString * MIMETypeForExtension(NSString * extension) {
    
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    if (uti != NULL)
    {
        CFStringRef mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        CFRelease(uti);
        if (mime != NULL)
        {
            NSString *type = [NSString stringWithString:(__bridge NSString *)mime];
            CFRelease(mime);
            return type;
        }
    }
    return @"application/octet-stream";
}

@implementation QiniuMultipartElement
- (void)updateLength
{
    self.length = self.headersLength + self.bodyLength + 2;
    [self.body open];
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary string:(NSString *)string
{
    self               = [super init];
    self.headers       = [[NSString stringWithFormat:kHeaderStringFormat, boundary, name] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    self.body          = [NSInputStream inputStreamWithData:stringData];
    self.bodyLength    = stringData.length;
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data contentType:(NSString *)contentType
{
    self               = [super init];
    self.headers       = [[NSString stringWithFormat:kHeaderDataFormat, boundary, name, contentType] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body          = [NSInputStream inputStreamWithData:data];
    self.bodyLength    = [data length];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data contentType:(NSString *)contentType filename:(NSString*)filename
{
    self               = [super init];
    self.headers       = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, contentType] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body          = [NSInputStream inputStreamWithData:data];
    self.bodyLength    = [data length];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary path:(NSString *)path
{
    if (!filename)
    {
        filename = path.lastPathComponent;
    }
    self.headers       = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, MIMETypeForExtension(path.pathExtension)] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body          = [NSInputStream inputStreamWithFileAtPath:path];
    self.bodyLength    = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] unsignedIntegerValue];
    [self updateLength];
    return self;
}
- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary stream:(NSInputStream *)stream streamLength:(NSUInteger)streamLength
{
    self.headers       = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, MIMETypeForExtension(filename.pathExtension)] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body          = stream;
    self.bodyLength    = streamLength;
    [self updateLength];
    return self;
}
- (id)initWithHeaders:(NSDictionary *)headers string:(NSString *)string boundary:(NSString *)boundary
{
    self = [super init];
    if (self) {
        
        _headers = [self makeHeadersDataFromHeadersDict:headers boundary:boundary];
        _headersLength = _headers.length;
        NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
        _body = [NSInputStream inputStreamWithData:stringData];
        _bodyLength = stringData.length;
        [self updateLength];
    }
    return self;
}

- (id)initWithHeaders:(NSDictionary *)headers path:(NSString *)path boundary:(NSString *)boundary
{
    self = [super init];
    if (self) {
        
        _headers = [self makeHeadersDataFromHeadersDict:headers boundary:boundary];
        _headersLength = _headers.length;
        _body = [NSInputStream inputStreamWithFileAtPath:path];
        _bodyLength = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] unsignedIntegerValue];
        [self updateLength];
    }
    return self;
}

#if TARGET_OS_IOS
- (id)initWithName:(NSString *)name filename:(NSString *)filename boundary:(NSString *)boundary asset:(ALAsset *)asset
{
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    if (!filename) {
        filename = rep.filename;
    }
    NSString* mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass
    ((__bridge CFStringRef)[rep UTI], kUTTagClassMIMEType);

    self.headers       = [[NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, mimeType] dataUsingEncoding:NSUTF8StringEncoding];
    self.headersLength = [self.headers length];
    self.body          = [NSInputStream pos_inputStreamWithAssetURL:rep.url];
    self.bodyLength    =  (NSUInteger)rep.size;
    [self updateLength];
    return self;
}
#endif

- (NSData *)makeHeadersDataFromHeadersDict:(NSDictionary *)headers boundary:(NSString *)boundary
{
    NSMutableString *headersString = [[NSMutableString alloc] initWithFormat:@"--%@", boundary];
    [self appendNewLine:headersString];
    
    for (NSString *key in headers.allKeys) {
        
        [headersString appendString:[[NSString alloc] initWithFormat:@"%@: %@", key, headers[key]]];
        [self appendNewLine:headersString];
    }
    
    [self appendNewLine:headersString];
    
    NSData *result = [headersString dataUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (void)appendNewLine:(NSMutableString *)string {
    
    [string appendString:@"\r\n"];
}

- (NSUInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;
    
    if (self.delivered >= self.length)
    {
        return 0;
    }
    if (self.delivered < self.headersLength && sent < len)
    {
        read            = MIN(self.headersLength - self.delivered, len - sent);
        [self.headers getBytes:buffer + sent range:NSMakeRange(self.delivered, read)];
        sent           += read;
        self.delivered += sent;
    }
    while (self.delivered >= self.headersLength && self.delivered < (self.length - 2) && sent < len)
    {
        if ((read = [self.body read:buffer + sent maxLength:len - sent]) == 0)
        {
            break;
        }
        sent           += read;
        self.delivered += read;
    }
    if (self.delivered >= (self.length - 2) && sent < len)
    {
        if (self.delivered == (self.length - 2))
        {
            *(buffer + sent) = '\r';
            sent ++; self.delivered ++;
        }
        *(buffer + sent) = '\n';
        sent ++; self.delivered ++;
    }
    return sent;
}
@end

