//
//  POSBlobInputStream.h
//  POSBlobInputStreamLibrary
//
//  Created by Pavel Osipov on 02.07.13.
//  Copyright (c) 2013 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const POSBlobInputStreamErrorDomain;

typedef NS_ENUM(NSUInteger, POSBlobInputStreamErrorCode) {
    POSBlobInputStreamErrorCodeDataSourceFailure = 0
};

@protocol POSBlobInputStreamDataSource;

@interface POSBlobInputStream : NSInputStream

@property (nonatomic, assign) BOOL shouldNotifyCoreFoundationAboutStatusChange;

// Designated initializer.
- (id)initWithDataSource:(NSObject<POSBlobInputStreamDataSource> *)dataSource;

@end
