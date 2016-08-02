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
    isStop = false;
    [self getQiniuFileSourceDataAndCreateOperation:0];
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

- (NSURLSessionUploadTask
   *)QiniuOperation:(NSInteger)index sourceData:(NSData*)sourceData
{
    QiniuFile *theFile = self.files[index];
     AFHTTPSessionManager *operationManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://up.qiniu.com"]];
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
    NSURLSessionUploadTask *task = [operationManager uploadTaskWithRequest:request fromData:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        self.uploadOneFileProgress(operationManager, index, uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (self.uploadOneFileFailed && error.code != -999) {
                self.uploadOneFileFailed(operationManager, index, [error copy]);
            }
        } else {
            if (self.uploadOneFileSucceeded) {
                self.uploadOneFileSucceeded(operationManager,index,responseObject[@"key"]);
                if (index != self.files.count - 1 && isStop == false) {
                    [self getQiniuFileSourceDataAndCreateOperation:index+1];
                }
            }
            if (index == self.files.count - 1) {
                currentTask = nil;
                if (self.uploadAllFilesComplete) {
                    self.uploadAllFilesComplete();
                }
            }
        }
    }];
    
    return task;
}

- (void)getQiniuFileSourceDataAndCreateOperation:(NSInteger)index
{
    QiniuFile *qiniuFile = self.files[index];
    if (qiniuFile.rawData) {
        NSURLSessionUploadTask *task = [self QiniuOperation:index sourceData:qiniuFile.rawData];
        currentTask = task;
        [task resume];
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
                NSURLSessionUploadTask *task = [self QiniuOperation:index sourceData:sourceData];
                currentTask = task;
                [task resume];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
        }];
        
    }
}

+ (NSString *)versionName {
    return @"1.5.4";
}

+ (NSInteger)version {
    return 2;
}


#ifdef DEBUG
+ (void)checkVersion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"https://raw.githubusercontent.com/huhuanming/qiniu_upload/master/Classes/version.json" parameters: nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSString *versionName = dic[@"versionName"];
        NSNumber *version = dic[@"version"];
        if (version.intValue > [self version]) {
            NSLog(@"QiniuUpload 更新了，最新版本是 %@, 当前版本是 %@, 地址: https://github.com/huhuanming/qiniu_upload", versionName, [self versionName]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"QiniuUpload 版本检查失败，可能遇到网络问题");
    }];
}
#endif

@end
