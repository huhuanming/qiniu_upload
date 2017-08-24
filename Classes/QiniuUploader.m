//
//  QiniuUploader.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "QiniuUploader.h"

#define kQiniuUploadURL @"https://upload.qbox.me"
#define kQiniuTaskKey @"qiniuTaskKey"

typedef void (^UploadOneFileSucceededHandler)(NSInteger index, NSDictionary * _Nonnull info);
typedef void (^UploadOneFileFailedHandler)(NSInteger index, NSError * _Nullable error);
typedef void (^UploadOneFileProgressHandler)(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void (^UploadAllFilesCompleteHandler)(void);

@implementation QiniuUploader{
    NSString *accessToken;
    NSMutableArray *fileQueue;
    NSMutableArray *operations;
    NSMutableDictionary *taskRefs;
    NSMutableDictionary *responsesData;
    __weak QiniuUploader *weakSelf;
    NSURLSession *defaultSession;
    UploadOneFileSucceededHandler oneSucceededHandler;
    UploadOneFileFailedHandler oneFailedHandler;
    UploadOneFileProgressHandler oneProgressHandler;
    UploadAllFilesCompleteHandler allCompleteHandler;
}

- (id)init
{
    if (self = [super init]) {
        _files = [[NSMutableArray alloc] init];
        _isRunning = NO;
        _maxConcurrentNumber = 1;

        fileQueue = [[NSMutableArray alloc] init];
        operations = [[NSMutableArray alloc] init];
        taskRefs = [[NSMutableDictionary alloc] init];
        responsesData = [[NSMutableDictionary alloc] init];
        
        weakSelf = self;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 15.0f;
        
        defaultSession = [NSURLSession sessionWithConfiguration:config delegate: self delegateQueue:nil];
        config = nil;
    }
    #ifdef DEBUG
        [QiniuUploader checkVersion];
    #endif
    return self;
}

+(id)sharedUploader
{
    static QiniuUploader *uploader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(uploader == nil)
            uploader = [[QiniuUploader alloc] init];
    });
    return uploader;
}

- (Boolean)startUpload:(NSString * _Nonnull)theAccessToken
        uploadOneFileSucceededHandler: (nullable void (^)(NSInteger index, NSDictionary * _Nonnull info)) successHandler
           uploadOneFileFailedHandler: (nullable void (^)(NSInteger index, NSError * _Nullable error)) failHandler
         uploadOneFileProgressHandler: (nullable void (^)(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend)) progressHandler
               uploadAllFilesComplete: (nullable void (^)()) completeHandler
{
    accessToken = theAccessToken;
    oneSucceededHandler = successHandler;
    oneFailedHandler = failHandler;
    oneProgressHandler = progressHandler;
    allCompleteHandler = completeHandler;
    return [self startUpload];
}

- (Boolean)startUpload
{
    if (self.files.count == 0) {
        return false;
    }
    _isRunning = YES;
    [self createFileQueue];
    [self uploadQueue];
    return true;
}

- (void)createFileQueue {
    [fileQueue removeAllObjects];
    
    [self.files enumerateObjectsUsingBlock:
     ^(NSString *string, NSUInteger index, BOOL *stop)
     {
         [fileQueue addObject:@(index)];
     }];
}

- (NSInteger)deFileQueue {
  @synchronized (fileQueue) {
    if (fileQueue.count == 0) {
        return 0;
    }
    NSNumber *fileIndex = [fileQueue firstObject];
    [fileQueue removeObjectAtIndex:0];
    return fileIndex.intValue;
  }
}

- (void)uploadQueue {
    
    
    NSInteger poolSize = fileQueue.count < self.maxConcurrentNumber ? fileQueue.count : self.maxConcurrentNumber;
    
    for (NSUInteger i = 0; i < poolSize; i++) {
        NSInteger fileIndex = [weakSelf deFileQueue];
        [self uploadFile:fileIndex];
    }
}

- (void)uploadFile:(NSInteger)fileIndex
{
    
    QiniuFile *file = weakSelf.files[fileIndex];
    
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
    NSURLSessionTask * uploadTask = [defaultSession dataTaskWithRequest:request];
    
    NSString *taskDescription = [NSString stringWithFormat:@"%ld", fileIndex];

    @synchronized (taskRefs) {
        taskRefs[taskDescription] = uploadTask;
    }
    
    [uploadTask setTaskDescription:taskDescription];
    [uploadTask resume];
}

- (void)uploadComplete
{
    NSInteger fileIndex = [weakSelf deFileQueue];
    if (fileIndex > 0) {
        [weakSelf uploadFile:fileIndex];
    } else {
        @synchronized (taskRefs) {
            if (taskRefs.count == 0 && allCompleteHandler) {

                [fileQueue removeAllObjects];
                [responsesData removeAllObjects];
                _isRunning = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    allCompleteHandler();
                    
                    oneSucceededHandler = nil;
                    oneFailedHandler = nil;
                    oneProgressHandler = nil;
                    allCompleteHandler = nil;
                });
            }
        }
    }
}

- (Boolean)cancelAllUploadTask
{
    [self stopUpload];
    return YES;
}

- (void)stopUpload
{
    @synchronized (taskRefs) {
        [taskRefs.allValues enumerateObjectsUsingBlock: ^(NSURLSessionTask *task, NSUInteger index, BOOL *stop)
         {
             [task suspend];
             [task cancel];
        }];
        [taskRefs removeAllObjects];
        [fileQueue removeAllObjects];
        _isRunning = NO;
    }
}

#pragma NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    NSInteger taskIndex = task.taskDescription.integerValue;
    if (oneProgressHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            oneProgressHandler(taskIndex, bytesSent, totalBytesSent, totalBytesExpectedToSend);
        });
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (data) {
        responsesData[dataTask.taskDescription] = data;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSInteger fileIndex =  task.taskDescription.integerValue;
    if(error) {
        if (oneFailedHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                oneFailedHandler(fileIndex, error);
            });
        }
    } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSData *data = responsesData[task.taskDescription];
        if (httpResponse.statusCode == 200 && data) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments) error:nil];
            if (oneSucceededHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    oneSucceededHandler(fileIndex, response);
                });
            }
        } else {
            if (oneFailedHandler) {
                error = [NSError errorWithDomain:kQiniuUploadURL code:httpResponse.statusCode userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString([NSString stringWithUTF8String:[data bytes]], @"")}];
                dispatch_async(dispatch_get_main_queue(), ^{
                    oneFailedHandler(fileIndex, error);
                });
            }
        }
        
    }

    @synchronized (taskRefs) {
        [taskRefs removeObjectForKey: task.taskDescription];
    }
    [weakSelf uploadComplete];
}

#pragma version


+ (NSString *)versionName {
    return @"3.0.0";
}

+ (NSInteger)version {
    return 15;
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
