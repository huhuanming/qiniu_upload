//
//  QiniuFile.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "QiniuFile.h"

@implementation QiniuFile



- (id)initWithALAsset:(ALAsset *)theAsset
{
    if (self = [super init]) {
        self.mimeType = @"image/jpeg";
        self.asset = theAsset;
    }
    return self;
}

- (id)initWithFileData:(NSData *)theData
{
    return [self initWithFileData:theData withKey:nil];
}

- (id)initWithFileData:(NSData *)theData withKey:(NSString*)theKey
{
    if (self = [super init]) {
        self.key = theKey;
        self.rawData = theData;
        self.mimeType = @"image/jpeg";
    }
    return self;
}

- (NSData *)rawData
{
    if (_rawData) {
        return _rawData;
    }
    ALAssetRepresentation *representation = [self.asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc(representation.size);
    NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
    NSData *sourceData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return sourceData;
}

@end
