//
//  POSFastAssetReader.m
//  POSInputStreamLibrary
//
//  Created by Pavel Osipov on 08.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSFastAssetReader.h"

static uint64_t const kAssetCacheBufferSize = 131072;

@implementation POSFastAssetReader {
    uint8_t _assetCache[kAssetCacheBufferSize];
    POSLength _assetSize;
    POSLength _assetCacheSize;
    POSLength _assetCacheOffset;
    POSLength _assetCacheInternalOffset;
    ALAssetRepresentation *_assetRepresentation;
}

#pragma mark - POSAssetReader

- (void)openAsset:(ALAssetRepresentation *)assetRepresentation
       fromOffset:(POSLength)offset
completionHandler:(void (^)(POSLength, NSError *))completionHandler {
    _assetRepresentation = assetRepresentation;
    NSError *error;
    [self p_refillCacheFromOffset:offset error:&error];
    completionHandler(_assetSize, error);
}

- (BOOL)hasBytesAvailableFromOffset:(POSLength)offset {
    if ([self p_cachedBytesCount] <= 0) {
        return NO;
    }
    return offset < _assetCacheOffset + _assetCacheSize;
}

- (BOOL)prepareForNewOffset:(POSLength)offset {
    return [self p_refillCacheFromOffset:offset error:nil];
}

- (NSInteger)read:(uint8_t *)buffer
       fromOffset:(POSLength)offset
        maxLength:(NSUInteger)maxLength
            error:(NSError **)error {
    const POSLength readResult = MIN(maxLength, [self p_cachedBytesCount]);
    memcpy(buffer, _assetCache + _assetCacheInternalOffset, (unsigned long)readResult);
    _assetCacheInternalOffset += readResult;
    const POSLength nextReadOffset = offset + readResult;
    if ([self p_cachedBytesCount] <= 0 ||
        [self p_unreadBytesCountFromOffset:nextReadOffset] > 0) {
        [self p_refillCacheFromOffset:nextReadOffset error:error];
    }
    return (NSInteger)readResult;
}

#pragma mark - Private

- (POSLength)p_unreadBytesCountFromOffset:(POSLength)offset {
    return _assetSize - offset;
}

- (POSLength)p_cachedBytesCount {
    return _assetCacheSize - _assetCacheInternalOffset;
}

- (BOOL)p_refillCacheFromOffset:(POSLength)offset error:(NSError **)error {
    const NSUInteger readResult = [_assetRepresentation getBytes:_assetCache
                                                      fromOffset:offset
                                                          length:kAssetCacheBufferSize
                                                           error:error];
    if (readResult <= 0) {
        if (error) {
            NSString *desc = [NSString stringWithFormat:@"Failed to read asset bytes in range %@ from asset of size %@.",
                              NSStringFromRange(NSMakeRange((NSUInteger)offset, (NSUInteger)kAssetCacheBufferSize)),
                              @(_assetSize)];
            *error = [NSError errorWithDomain:POSBlobInputStreamAssetDataSourceErrorDomain
                                         code:-2000
                                     userInfo:@{NSLocalizedDescriptionKey: desc}];
        }
        return NO;
    }
    _assetSize = [_assetRepresentation size];
    _assetCacheSize = readResult;
    _assetCacheOffset = offset;
    _assetCacheInternalOffset = 0;
    return YES;
}

@end
