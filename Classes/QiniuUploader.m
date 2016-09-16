//
//  QiniuUploader.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "QiniuUploader.h"

#define kQiniuUploadURL @"https://up.qbox.me"
#define kQiniuTaskKey @"qiniuTaskKey"

@implementation QiniuUploader{
    NSString *accessToken;
    NSMutableArray *operations;
    __weak NSURLSessionTask *currentTask;
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
        self.isRunning = NO;
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
    return [self _startUpload];
}

- (Boolean)startUpload
{
    return [self _startUpload];
}

- (Boolean)_startUpload
{
    if (self.isRunning) {
        return NO;
    }
    if (!self.files && self.files.count == 0) {
        return NO;
    }
    
    if (!accessToken && ![QiniuToken sharedQiniuToken]) {
        [NSException raise:@"QiniuToken is nil" format:@"not resgister QiniuToken with Scope, AccessKey And SecretKey"];
    }
    
    self.isRunning = YES;
    __weak typeof(self) weakSelf = self;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate: weakSelf delegateQueue: nil];
    for (int i = 0; i < self.files.count; i++) {
        NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            QiniuFile *file = self.files[i];
            QiniuInputStream *inputStream = [[QiniuInputStream alloc] init];
            if (file.key) {
                [inputStream addPartWithName:@"key" string:file.key];
            }
            
            [inputStream addPartWithName:@"token" string: accessToken ?: [[QiniuToken sharedQiniuToken] uploadToken]];

            if (file.path) {
                [inputStream addPartWithName:@"file" path: file.path];
            }
            
            if (file.rawData){
                [inputStream addPartWithName:@"file" data: file.rawData];
            }
            
#if TARGET_OS_IOS
            if (file.asset) {
                [inputStream addPartWithName:@"file" asset:file.asset];
            }
#endif
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kQiniuUploadURL]];
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", [inputStream boundary]] forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[inputStream length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBodyStream:inputStream];
            [request setHTTPMethod:@"POST"];
            
            NSURLSessionTask * uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(error) {
                    if (self.uploadOneFileFailed) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.uploadOneFileFailed(i, error);
                        });
                    }
                } else {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                    if (httpResponse.statusCode == 200) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments) error:nil];
                        if (self.uploadOneFileSucceeded) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.uploadOneFileSucceeded(i, dic[@"key"], dic);
                            });
                        }
                    } else {
                        if (self.uploadOneFileFailed) {
                            error = [NSError errorWithDomain:kQiniuUploadURL code:httpResponse.statusCode userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString([NSString stringWithUTF8String:[data bytes]], @"")}];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.uploadOneFileFailed(i, error);
                            });
                        }
                    }
                    
                    if (i == self.files.count - 1) {
                        if(self.uploadAllFilesComplete){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.uploadAllFilesComplete();
                                [self stopUpload];
                            });
                        }
                    } else {
                        [(NSOperation *)operations[i+1] start];
                    }
                }
            }];
            [uploadTask setTaskDescription:[NSString stringWithFormat:@"%d", i]];
            [uploadTask resume];
            currentTask = uploadTask;
        }];
        i > 0 ? [operation addDependency:operations[i - 1]] : 0;
        [operations addObject:operation];
    }
    [(NSOperation *)operations[0] start];
    return YES;
}

- (Boolean)cancelAllUploadTask
{
    [currentTask cancel];
    [self stopUpload];
    return YES;
}

- (void)stopUpload
{
    self.uploadOneFileSucceeded = nil;
    self.uploadOneFileFailed = nil;
    self.uploadOneFileProgress = nil;
    self.uploadAllFilesComplete = nil;
    self.isRunning = NO;
}

#pragma NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    NSProgress *process = [[NSProgress alloc] init];
    process.totalUnitCount = totalBytesExpectedToSend;
    process.completedUnitCount = totalBytesSent;
    if (self.uploadOneFileProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadOneFileProgress([task.taskDescription intValue], process);
        });
    }
}

#pragma version


+ (NSString *)versionName {
    return @"2.0.0";
}

+ (NSInteger)version {
    return 10;
}

#ifdef DEBUG
+ (void)checkVersion {
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/huhuanming/qiniu_upload/master/Classes/version.json"]];
    
    NSURLSessionDataTask *checktask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"QiniuUpload cannot check updates, error:%@", error);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments) error:nil];
            NSNumber *version = dic[@"version"];
            if (version.intValue > [self version]) {
                NSLog(@"QiniuUpload was updated! the new version is %@, but current version is %@. https://github.com/huhuanming/qiniu_upload, desc: %@", dic[@"versionName"], [self versionName], dic[@"desc"]);
            }
        }
    }];
    [checktask resume];
}
#endif

@end
