//
//  POSBlobInputStreamAssetDataSource.m
//  POSInputStreamLibrary
//
//  Created by Osipov on 06.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSBlobInputStreamAssetDataSource.h"
#import "POSFastAssetReader.h"
#import "POSAdjustedAssetReaderIOS7.h"
#import "POSAdjustedAssetReaderIOS8.h"
#import "POSLocking.h"
#import "ALAssetsLibrary+POS.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>

NSString * const POSBlobInputStreamAssetDataSourceErrorDomain = @"com.github.pavelosipov.POSBlobInputStreamAssetDataSource";

static const char * const POSInputStreamSharedOpenDispatchQueueName = "com.github.pavelosipov.POSInputStreamSharedOpenDispatchQueue";

NSInteger const kPOSReadFailureReturnCode = -1;

typedef NS_ENUM(int, ResetMode) {
    ResetModeReopenWhenError,
    ResetModeFailWhenError
};

@interface NSError (POSBlobInputStreamAssetDataSource)
+ (NSError *)pos_assetOpenErrorWithURL:(NSURL *)assetURL reason:(NSError *)reason;
+ (NSError *)pos_assetReadErrorWithURL:(NSURL *)assetURL reason:(NSError *)reason;
@end

@interface POSBlobInputStreamAssetDataSource ()
@property (nonatomic) NSError *error;
@property (nonatomic) NSURL *assetURL;
@property (nonatomic) ALAssetsLibrary *assetsLibrary;
@property (nonatomic) ALAsset *asset;
@property (nonatomic) ALAssetRepresentation *assetRepresentation;
@property (nonatomic) POSLength assetSize;
@property (nonatomic) id<POSAssetReader> assetReader;
@property (nonatomic) POSLength readOffset;
@end

@implementation POSBlobInputStreamAssetDataSource

@dynamic openCompleted, hasBytesAvailable, atEnd;

#pragma mark - Lifecycle

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Unexpected deadly init invokation '%@', use %@ instead.",
                                           NSStringFromSelector(_cmd),
                                           NSStringFromSelector(@selector(initWithAssetURL:))]
                                 userInfo:nil];
}

- (instancetype)initWithAssetURL:(NSURL *)assetURL {
    NSParameterAssert(assetURL);
    if (self = [super init]) {
        _openSynchronously = NO;
        _assetURL = assetURL;
        _adjustedJPEGCompressionQuality = .93f;
        _adjustedImageMaximumSize = 1024 * 1024;
    }
    return self;
}

#pragma mark - POSBlobInputStreamDataSource

+ (dispatch_queue_t)sharedOpenDispatchQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create(POSInputStreamSharedOpenDispatchQueueName, NULL);
    });
    return queue;
}

- (BOOL)isOpenCompleted {
    return _assetSize > 0;
}

- (void)open {
    if (![self isOpenCompleted]) {
        [self p_open];
    }
}

- (void)setAssetSize:(POSLength)assetSize {
    const BOOL shouldEmitOpenCompletedEvent = ![self isOpenCompleted];
    if (shouldEmitOpenCompletedEvent) {
        [self willChangeValueForKey:POSBlobInputStreamDataSourceOpenCompletedKeyPath];
    }
    _assetSize = assetSize;
    if (shouldEmitOpenCompletedEvent) {
        [self didChangeValueForKey:POSBlobInputStreamDataSourceOpenCompletedKeyPath];
    }
}

- (BOOL)hasBytesAvailable {
    return [_assetReader hasBytesAvailableFromOffset:_readOffset];
}

- (BOOL)isAtEnd {
    return _assetSize <= _readOffset;
}

- (id)propertyForKey:(NSString *)key {
    if (![key isEqualToString:NSStreamFileCurrentOffsetKey]) {
        return nil;
    }
    return @(_readOffset);
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key {
    if (![key isEqualToString:NSStreamFileCurrentOffsetKey]) {
        return NO;
    }
    if (![property isKindOfClass:[NSNumber class]]) {
        return NO;
    }
    const long long requestedOffest = [property longLongValue];
    if (requestedOffest < 0) {
        return NO;
    }
    _readOffset = requestedOffest;
    if (_assetReader) {
        return [_assetReader prepareForNewOffset:_readOffset];
    }
    return YES;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)bufferLength {
    return NO;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength {
    NSParameterAssert(buffer);
    NSParameterAssert(maxLength > 0);
    if (self.atEnd) {
        return 0;
    }
    NSError *error;
    const POSLength readResult = [_assetReader read:buffer
                                         fromOffset:_readOffset
                                          maxLength:maxLength
                                              error:&error];
    const POSLength readOffset = _readOffset + readResult;
    NSParameterAssert(readOffset <= _assetSize);
    const BOOL atEnd = readOffset >= _assetSize;
    if (atEnd) {
        [self willChangeValueForKey:POSBlobInputStreamDataSourceAtEndKeyPath];
    }
    _readOffset = readOffset;
    if (atEnd) {
        [self didChangeValueForKey:POSBlobInputStreamDataSourceAtEndKeyPath];
    } else if (error) {
        [self p_open];
    }
    return (NSInteger)readResult;
}

#pragma mark - Private

- (void)p_open {
    id<POSLocking> lock = [self p_lockForOpening];
    [lock lock];
    dispatch_async(self.openDispatchQueue ?: dispatch_get_main_queue(), ^{ @autoreleasepool {
        self.assetsLibrary = [ALAssetsLibrary new];
        [_assetsLibrary pos_assetForURL:_assetURL resultBlock:^(ALAsset *asset, ALAssetsGroup *assetsGroup) {
            ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
            if (assetRepresentation) {
                self.asset = asset;
                self.assetRepresentation = assetRepresentation;
                self.assetReader = (assetsGroup
                                    ? [POSFastAssetReader new]
                                    : [self p_assetReaderForAssetRepresentation:assetRepresentation]);
                [_assetReader
                 openAsset:assetRepresentation
                 fromOffset:_readOffset
                 completionHandler:^(POSLength assetSize, NSError *error) {
                     if (error != nil || assetSize <= 0 || (_assetSize != 0 && _assetSize != assetSize)) {
                         self.error = [NSError pos_assetOpenErrorWithURL:_assetURL reason:error];
                     } else {
                         self.assetSize = assetSize;
                     }
                     [lock unlock];
                 }];
            } else {
                self.error = [NSError pos_assetOpenErrorWithURL:_assetURL reason:nil];
                [lock unlock];
            }
        } failureBlock:^(NSError *error) {
            self.error = [NSError pos_assetOpenErrorWithURL:_assetURL reason:error];
            [lock unlock];
        }];
    }});
    [lock waitWithTimeout:DISPATCH_TIME_FOREVER];
}

- (id<POSAssetReader>)p_assetReaderForAssetRepresentation:(ALAssetRepresentation *)representation {
    if (_assetReader) {
        return _assetReader;
    }
    if (!UTTypeConformsTo((__bridge CFStringRef)representation.UTI, kUTTypeImage)) {
        return [POSFastAssetReader new];
    }
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0 &&
        representation.size <= _adjustedImageMaximumSize) {
        POSAdjustedAssetReaderIOS8 *assetReader = [POSAdjustedAssetReaderIOS8 new];
        assetReader.suspiciousSize = _adjustedImageMaximumSize;
        assetReader.completionDispatchQueue = self.openDispatchQueue;
        return assetReader;
    }
    if (representation.metadata[@"AdjustmentXMP"] != nil) {
        POSAdjustedAssetReaderIOS7 *assetReader = [POSAdjustedAssetReaderIOS7 new];
        assetReader.JPEGCompressionQuality = _adjustedJPEGCompressionQuality;
        assetReader.completionDispatchQueue = self.openDispatchQueue;
        return assetReader;
    }
    return [POSFastAssetReader new];
}

- (id<POSLocking>)p_lockForOpening {
    if ([self shouldOpenSynchronously]) {
        if (!self.openDispatchQueue) {
            // If you want open stream synchronously you should
            // do that in some worker thread to avoid deadlock.
            NSParameterAssert(![[NSThread currentThread] isMainThread]);
        }
        return [POSGCDLock new];
    } else {
        return [POSDummyLock new];
    }
}

@end

@implementation NSError (POSBlobInputStreamAssetDataSource)

+ (NSError *)pos_assetOpenErrorWithURL:(NSURL *)assetURL reason:(NSError *)reason {
    NSString *description = [NSString stringWithFormat:@"Failed to open asset with URL %@", assetURL];
    if (reason) {
        return [NSError errorWithDomain:POSBlobInputStreamAssetDataSourceErrorDomain
                                   code:POSBlobInputStreamAssetDataSourceErrorCodeOpen
                               userInfo:@{ NSLocalizedDescriptionKey: description, NSUnderlyingErrorKey: reason }];
    } else {
        return [NSError errorWithDomain:POSBlobInputStreamAssetDataSourceErrorDomain
                                   code:POSBlobInputStreamAssetDataSourceErrorCodeOpen
                               userInfo:@{ NSLocalizedDescriptionKey: description }];
    }
}

+ (NSError *)pos_assetReadErrorWithURL:(NSURL *)assetURL reason:(NSError *)reason {
    NSString *description = [NSString stringWithFormat:@"Failed to read asset with URL %@", assetURL];
    if (reason) {
        return [NSError errorWithDomain:POSBlobInputStreamAssetDataSourceErrorDomain
                                   code:POSBlobInputStreamAssetDataSourceErrorCodeRead
                               userInfo:@{ NSLocalizedDescriptionKey: description, NSUnderlyingErrorKey: reason }];
    } else {
        return [NSError errorWithDomain:POSBlobInputStreamAssetDataSourceErrorDomain
                                   code:POSBlobInputStreamAssetDataSourceErrorCodeRead
                               userInfo:@{ NSLocalizedDescriptionKey: description }];
    }
}

@end
