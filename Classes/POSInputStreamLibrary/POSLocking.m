//
//  POSLocking.m
//  POSInputStreamLibrary
//
//  Created by Osipov on 06.05.15.
//  Copyright (c) 2015 Pavel Osipov. All rights reserved.
//

#import "POSLocking.h"

@implementation POSGCDLock {
    dispatch_semaphore_t semaphore_;
}

- (void)lock {
    semaphore_ = dispatch_semaphore_create(0);
}

- (void)unlock {
    dispatch_semaphore_signal(semaphore_);
}

- (BOOL)waitWithTimeout:(dispatch_time_t)timeout {
    return dispatch_semaphore_wait(semaphore_, timeout) == 0;
}

@end

@implementation POSDummyLock
- (void)lock {}
- (void)unlock {}
- (BOOL)waitWithTimeout:(dispatch_time_t)timeout { return YES; }
@end
