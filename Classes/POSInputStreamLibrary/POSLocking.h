//
//  POSLocking.h
//  POSInputStreamLibrary
//
//  Created by Osipov on 06.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol POSLocking <NSLocking>
- (BOOL)waitWithTimeout:(dispatch_time_t)timeout;
@end

@interface POSGCDLock : NSObject <POSLocking>
@end

@interface POSDummyLock : NSObject <POSLocking>
@end
