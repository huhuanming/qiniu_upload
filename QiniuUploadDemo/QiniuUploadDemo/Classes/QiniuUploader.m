//
//  QiniuUploader.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "QiniuUploader.h"

#define kQiniuUpUploadUrl @"http://up.qiniu.com"

@implementation QiniuUploader{
    NSString *accessToken;
    NSMutableArray *operations;
    NSURLSessionUploadTask *currentTask;
    Boolean isStop;
}

- (id)init
{
    return [self initWithToken];
}

- (id)initWithToken
{
    if (self = [super init]) {
        self.files = [[NSMutableArray alloc] init];
        operations = [[NSMutableArray alloc] init];
    }
    #ifdef DEBUG
        [QiniuUploader checkVersion];
    #endif
    return self;
}

- (void)addFile:(QiniuFile *)file
{
    [self.files addObject:file];
}

- (void)addFiles:(NSArray *)theFiles
{
    [self.files addObjectsFromArray:theFiles];
}

- (Boolean)startUploadWithAccessToken:(NSString *)theAccessToken
{
    accessToken = theAccessToken;
    return [self startUpload];
}

- (Boolean)startUpload
{
    if (!self.files) {
        return NO;
    }

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperations:operations waitUntilFinished:YES];
    return YES;
}

- (Boolean)cancelAllUploadTask
{
    if (currentTask) {
        [currentTask cancel];
        isStop = true;
        currentTask = nil;
        return YES;
    }
    return NO;
}

+ (NSString *)versionName {
    return @"1.5.4";
}

+ (NSInteger)version {
    return 2;
}

#ifdef DEBUG
+ (void)checkVersion {
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/huhuanming/qiniu_upload/master/Classes/version.json"]];
    
    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error) {
            NSLog(@"%@", error);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
            NSString *versionName = dic[@"versionName"];
            NSNumber *version = dic[@"version"];
            if (version.intValue > [self version]) {
                NSLog(@"QiniuUpload was updated! the new version is %@, but current version is %@. https://github.com/huhuanming/qiniu_upload", versionName, [self versionName]);
            }
        }
    }];
    [sessionDataTask resume];
}
#endif

@end
