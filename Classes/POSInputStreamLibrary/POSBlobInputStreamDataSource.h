//
//  POSBlobInputStreamDataSource.h
//  POSBlobInputStreamLibrary
//
//  Created by Pavel Osipov on 16.07.13.
//  Copyright (c) 2013 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const POSBlobInputStreamDataSourceOpenCompletedKeyPath;
FOUNDATION_EXTERN NSString * const POSBlobInputStreamDataSourceHasBytesAvailableKeyPath;
FOUNDATION_EXTERN NSString * const POSBlobInputStreamDataSourceAtEndKeyPath;
FOUNDATION_EXTERN NSString * const POSBlobInputStreamDataSourceErrorKeyPath;

@protocol POSBlobInputStreamDataSource <NSObject>

//
// Self-explanatory KVO-compliant properties.
//
@property (nonatomic, readonly, getter = isOpenCompleted) BOOL openCompleted;
@property (nonatomic, readonly) BOOL hasBytesAvailable;
@property (nonatomic, readonly, getter = isAtEnd) BOOL atEnd;
@property (nonatomic, readonly) NSError *error;

//
// This selector will be called before anything else.
//
- (void)open;

//
// Data Source configuring.
//
- (id)propertyForKey:(NSString *)key;
- (BOOL)setProperty:(id)property forKey:(NSString *)key;

//
// Data Source data.
// The contracts of these selectors are the same as for NSInputStream.
//
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength;
- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)bufferLength;

@end
