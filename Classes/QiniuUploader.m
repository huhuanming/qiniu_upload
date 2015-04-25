//
//  QiniuUploader.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-17.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "QiniuUploader.h"

#define kQiniuUpUploadUrl @"http://up.qiniu.com"

@implementation QiniuUploader

- (id)init
{
    return [self initWithToken];
}

- (id)initWithToken
{
    if (self = [super init]) {
        self.files = [[NSMutableArray alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
        self.token = [QiniuToken sharedQiniuToken];
        if (!self.token) {
            [NSException raise:@"QiniuToken is nil" format:@"not resgister QiniuToken with Scope, AccessKey And SecretKey"];
        }
    }
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

- (Boolean)startUpload
{
    if (!self.files) {
        return NO;
    }
    NSOperation *operation = [[NSOperation alloc] init];
    [self.operationQueue addOperation:operation];
    
    for (NSInteger i = 0; i < self.files.count; i++) {
        AFHTTPRequestOperation *theOperation = [self QiniuOperation:i];
        [theOperation addDependency:operation];
        [self.operationQueue addOperation:theOperation];
        operation = theOperation;
    }
    return YES;
}

- (Boolean)cancelAllUploadTask
{
    if (self.operationQueue.operations.count == 0) {
        return NO;
    }
    [self.operationQueue cancelAllOperations];
    return YES;
}

- (AFHTTPRequestOperation*)QiniuOperation:(NSInteger)index
{
    QiniuFile *theFile = self.files[index];
     AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://up.qiniu.com"]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (theFile.key){
        parameters[@"key"] = theFile.key;
    }
    parameters[@"token"] = [self.token uploadToken];
    NSMutableURLRequest *request = [operationManager.requestSerializer
                                     multipartFormRequestWithMethod:@"POST"
                                                          URLString:kQiniuUpUploadUrl
                                                         parameters:parameters
                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                         //                                                                    if (mimeType) {
                                         //                                                                        [formData appendPartWithFileURL:fileURL
                                         //                                                                                                   name:@"file"
                                         //                                                                                               fileName:filePath
                                         //                                                                                               mimeType:mimeType
                                         //                                                                                                  error:nil];
                                         //                                                                    }else{
                                         [formData appendPartWithFileData:theFile.rawData name:@"file" fileName:@"file" mimeType:theFile.mimeType];
                                         //                                                                    }
                                         
                                     } error:nil];
    AFHTTPRequestOperation *operation = [operationManager HTTPRequestOperationWithRequest:request
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
                    if (self.uploadOneFileSucceeded) {
                        self.uploadOneFileSucceeded(operation,index,responseObject[@"key"]);
                    }
                    if (index == self.files.count -1) {

                        if (self.uploadAllFilesComplete) {
                            self.uploadAllFilesComplete();
                        }
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                    if (self.uploadOneFileFailed) {
                        self.uploadOneFileFailed(operation, index, [error copy]);
                    }
                    
            }];
     __block AFHTTPRequestOperation *progressOperation = operation;

    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double percent = totalBytesWritten * 0.1 / totalBytesExpectedToWrite;

        if (self.uploadOneFileProgress) {
            self.uploadOneFileProgress(progressOperation, index, percent);
        }
    }];

    return operation;
}

@end
