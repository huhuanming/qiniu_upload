//
//  NSInputStream+POS.m
//  POSBlobInputStreamLibrary
//
//  Created by Pavel Osipov on 17.07.13.
//  Copyright (c) 2013 Pavel Osipov. All rights reserved.
//

#import "NSInputStream+POS.h"

#import "POSBlobInputStream.h"
#import "POSBlobInputStreamAssetDataSource.h"

@implementation NSInputStream (POS)

+ (NSInputStream *)pos_inputStreamWithAssetURL:(NSURL *)assetURL {
    return [NSInputStream pos_inputStreamWithAssetURL:assetURL asynchronous:YES];
}

+ (NSInputStream *)pos_inputStreamWithAssetURL:(NSURL *)assetURL asynchronous:(BOOL)asynchronous {
    POSBlobInputStreamAssetDataSource *dataSource = [[POSBlobInputStreamAssetDataSource alloc] initWithAssetURL:assetURL];
    dataSource.openSynchronously = !asynchronous;
    POSBlobInputStream *stream = [[POSBlobInputStream alloc] initWithDataSource:dataSource];
    stream.shouldNotifyCoreFoundationAboutStatusChange = YES;
    return stream;
}

+ (NSInputStream *)pos_inputStreamForCFNetworkWithAssetURL:(NSURL *)assetURL {
    POSBlobInputStreamAssetDataSource *dataSource = [[POSBlobInputStreamAssetDataSource alloc] initWithAssetURL:assetURL];
    dataSource.openSynchronously = YES;
    POSBlobInputStream *stream = [[POSBlobInputStream alloc] initWithDataSource:dataSource];
    stream.shouldNotifyCoreFoundationAboutStatusChange = NO;
    return stream;
}

+ (NSInputStream *)pos_inputStreamForAFNetworkingWithAssetURL:(NSURL *)assetURL {
    POSBlobInputStreamAssetDataSource *dataSource = [[POSBlobInputStreamAssetDataSource alloc] initWithAssetURL:assetURL];
    dataSource.openSynchronously = YES;
    dataSource.openDispatchQueue = POSBlobInputStreamAssetDataSource.sharedOpenDispatchQueue;
    POSBlobInputStream *stream = [[POSBlobInputStream alloc] initWithDataSource:dataSource];
    stream.shouldNotifyCoreFoundationAboutStatusChange = NO;
    return stream;
}

@end
