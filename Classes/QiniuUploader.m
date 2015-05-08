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
}

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
    [self getQiniuFileSourceDataAndCreateOperation:0];
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

- (AFHTTPRequestOperation*)QiniuOperation:(NSInteger)index sourceData:(NSData*)sourceData
{
    QiniuFile *theFile = self.files[index];
     AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://up.qiniu.com"]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (theFile.key){
        parameters[@"key"] = theFile.key;
    }
    
    if (!accessToken && ![QiniuToken sharedQiniuToken]) {
        [NSException raise:@"QiniuToken is nil" format:@"not resgister QiniuToken with Scope, AccessKey And SecretKey"];
    }
    parameters[@"token"] = accessToken?:[[QiniuToken sharedQiniuToken] uploadToken];
    NSMutableURLRequest *request = [operationManager.requestSerializer
                                     multipartFormRequestWithMethod:@"POST"
                                                          URLString:kQiniuUpUploadUrl
                                                         parameters:parameters
                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                         [formData appendPartWithFileData:sourceData name:@"file" fileName:@"file" mimeType:theFile.mimeType];
                                     } error:nil];
    AFHTTPRequestOperation *operation = [operationManager HTTPRequestOperationWithRequest:request
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
                    if (self.uploadOneFileSucceeded) {
                        self.uploadOneFileSucceeded(operation,index,responseObject[@"key"]);
                        if (index != self.files.count -1) {
                            [self getQiniuFileSourceDataAndCreateOperation:index+1];
                        }
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
        double percent = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;

        if (self.uploadOneFileProgress) {
            self.uploadOneFileProgress(progressOperation, index, percent);
        }
    }];

    return operation;
}

- (void)getQiniuFileSourceDataAndCreateOperation:(NSInteger)index
{
    QiniuFile *qiniuFile = self.files[index];
    if (qiniuFile.rawData) {
        AFHTTPRequestOperation *theOperation = [self QiniuOperation:index sourceData:qiniuFile.rawData];
        [self.operationQueue addOperation:theOperation];
    }else{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:qiniuFile.assetURL resultBlock:^(ALAsset *asset) {
            NSData *sourceData = nil;
            if (self.processAsset) {
                sourceData = self.processAsset(asset);
            }else{
                UIImage *tempImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                sourceData = UIImageJPEGRepresentation(tempImage, 1.0);
            }
            if (!sourceData) {
                 self.uploadOneFileFailed(nil, index, [[[NSError alloc] initWithDomain:@"no found binary data in this image" code:1404 userInfo:nil] copy]);
            }else{
                AFHTTPRequestOperation *theOperation = [self QiniuOperation:index sourceData:sourceData];
                [self.operationQueue addOperation:theOperation];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
        }];
        
    }
}

@end
