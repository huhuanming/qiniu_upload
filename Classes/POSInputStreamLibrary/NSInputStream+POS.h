//
//  NSInputStream+POS.h
//  POSBlobInputStreamLibrary
//
//  Created by Pavel Osipov on 17.07.13.
//  Copyright (c) 2013 Pavel Osipov. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface NSInputStream (POS)

+ (NSInputStream *)pos_inputStreamWithAssetURL:(NSURL *)assetURL;
+ (NSInputStream *)pos_inputStreamWithAssetURL:(NSURL *)assetURL asynchronous:(BOOL)asynchronous;

+ (NSInputStream *)pos_inputStreamForCFNetworkWithAssetURL:(NSURL *)assetURL;
+ (NSInputStream *)pos_inputStreamForAFNetworkingWithAssetURL:(NSURL *)assetURL;

@end
