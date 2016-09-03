//
//  POSAssetReader.h
//  POSInputStreamLibrary
//
//  Created by Pavel Osipov on 08.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

FOUNDATION_EXTERN NSString * const POSBlobInputStreamAssetDataSourceErrorDomain;

typedef long long POSLength;

@protocol POSAssetReader

- (void)openAsset:(ALAssetRepresentation *)assetRepresentation
       fromOffset:(POSLength)offset
completionHandler:(void (^)(POSLength assetSize, NSError *error))completionHandler;

- (BOOL)hasBytesAvailableFromOffset:(POSLength)offset;

- (BOOL)prepareForNewOffset:(POSLength)offset;

- (NSInteger)read:(uint8_t *)buffer
       fromOffset:(POSLength)offset
        maxLength:(NSUInteger)maxLength
            error:(NSError **)error;

@end
