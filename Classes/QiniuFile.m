//
//  QiniuFile.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "QiniuFile.h"

@implementation QiniuFile



- (id)initWithAssetURL:(NSURL *)assetURL
{
    if (self = [super init]) {
        self.mimeType = @"image/jpeg";
        self.assetURL = assetURL;
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

@end
