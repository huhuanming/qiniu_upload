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

@implementation QiniuUploader{
    NSString *accessToken;
    NSMutableArray *fileQueue;
    NSMutableArray *operations;
    NSMutableDictionary *taskRefs;
    __weak NSURLSessionTask *currentTask;
    NSURLSession *defaultSession;
}

- (id)init
{
    if (self = [super init]) {
        self.files = [[NSMutableArray alloc] init];
        fileQueue = [[NSMutableArray alloc] init];
        operations = [[NSMutableArray alloc] init];
        taskRefs = [[NSMutableDictionary alloc] init];
        
        defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate: self delegateQueue: nil];
        self.isRunning = NO;
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

- (Boolean)startUploadWithAccessToken:(NSString *)theAccessToken
{
    accessToken = theAccessToken;
    return [self startUpload];
}

- (Boolean)startUpload
{
    if (self.files.count == 0) {
        return false;
    }
    self.isRunning = YES;
    [self createFileQueue];
    [self uploadQueue];
    return true;
}

- (void)createFileQueue {
    [fileQueue removeAllObjects];
    
    [self.files enumerateObjectsUsingBlock:
     ^(NSString *string, NSUInteger index, BOOL *stop)
     {
         QiniuIndexFile *indexFile = [[QiniuIndexFile alloc] initWithIndex:index];
         [fileQueue addObject:indexFile];
     }];
}

- (nullable QiniuIndexFile *)deFileQueue {
  @synchronized (fileQueue) {
    if (fileQueue.count == 0) {
        return nil;
    }
    QiniuIndexFile *indexFile = [fileQueue firstObject];
    [fileQueue removeObjectAtIndex:0];
    return indexFile;
  }
}

- (void)uploadQueue {
    
    NSInteger maxConcurrent = 3;
    
    NSInteger poolSize = fileQueue.count < maxConcurrent ? fileQueue.count : maxConcurrent;
    
    for (NSUInteger i = 0; i < poolSize; i++) {
        QiniuIndexFile *indexFile = [self deFileQueue];
        [self uploadFile:indexFile.index UUID:indexFile.uuid];
    }
}

- (void)uploadFile:(NSInteger)fileIndex UUID:(NSString *)uuid
{
    
    QiniuFile *file = self.files[fileIndex];
    
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
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask * uploadTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error) {
            if (weakSelf.uploadOneFileFailed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.uploadOneFileFailed(fileIndex, error);
                });
            }
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments) error:nil];
                if (weakSelf.uploadOneFileSucceeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.uploadOneFileSucceeded(fileIndex, dic);
                    });
                }
            } else {
                if (weakSelf.uploadOneFileFailed) {
                    error = [NSError errorWithDomain:kQiniuUploadURL code:httpResponse.statusCode userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString([NSString stringWithUTF8String:[data bytes]], @"")}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.uploadOneFileFailed(fileIndex, error);
                    });
                }
            }
            
        }
        
        @synchronized (taskRefs) {
            [taskRefs removeObjectForKey: uuid];
        }
        [weakSelf uploadComplete];
    }];
    
    @synchronized (taskRefs) {
        taskRefs[uuid] = uploadTask;
    }
    
    [uploadTask setTaskDescription:[NSString stringWithFormat:@"%ld", fileIndex]];
    [uploadTask resume];
}

- (void)uploadComplete
{
    QiniuIndexFile *indexFile = [self deFileQueue];
    if (indexFile) {
        [self uploadFile:indexFile.index UUID:indexFile.uuid];
    } else {
        __weak typeof(self) weakSelf = self;
        @synchronized (taskRefs) {
            if (taskRefs.count == 0 && weakSelf.uploadAllFilesComplete) {

                [fileQueue removeAllObjects];
                weakSelf.isRunning = NO;

                dispatch_async(dispatch_get_main_queue(), ^{
                  weakSelf.uploadAllFilesComplete();
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
        [taskRefs.allValues enumerateObjectsUsingBlock:
         ^(NSURLSessionTask *task, NSUInteger index, BOOL *stop)
         {
             [task suspend];
             [task cancel];
        }];
        [taskRefs removeAllObjects];
        [fileQueue removeAllObjects];
        self.isRunning = NO;
    }
}

- (void)dealloc
{
  [defaultSession resetWithCompletionHandler:^{}];
}

#pragma NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    __weak typeof(self) weakSelf = self;
    if (weakSelf.uploadOneFileProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.uploadOneFileProgress(task.taskDescription.integerValue, bytesSent, totalBytesSent, totalBytesExpectedToSend);
        });
    }
}

#pragma version


+ (NSString *)versionName {
    return @"2.0.3";
}

+ (NSInteger)version {
    return 15;
}

#ifdef DEBUG
+ (void)checkVersion {
// TODO:
// 暂时关闭
//    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/huhuanming/qiniu_upload/master/Classes/version.json"]];
//    
//    NSURLSessionDataTask *checktask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        if (error) {
//            NSLog(@"QiniuUpload cannot check updates, error:%@", error);
//        } else {
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments) error:nil];
//            NSNumber *version = dic[@"version"];
//            if (version.intValue > [self version]) {
//                NSLog(@"QiniuUpload was updated! the new version is %@, but current version is %@. https://github.com/huhuanming/qiniu_upload, desc: %@", dic[@"versionName"], [self versionName], dic[@"desc"]);
//            }
//        }
//    }];
//    [checktask resume];
}
#endif

@end

@implementation QiniuIndexFile

- (instancetype)init {
    if (self = [super init]) {
        _uuid = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (id)initWithIndex:(NSInteger)index
{
    self = [self init];
    _index = index;
    return self;
}
    
@end
