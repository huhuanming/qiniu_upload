//
//  DemoViewController.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "DemoViewController.h"
#import "QiniuUploader.h"

#define scope @"motor"
#define accessKey @"7mGeCoNe_ecBsW210i5a0VDu4Yz8nZ5Ph6xUlV2E"
#define secretKey @"mUYYCo5yerv7ae28Ey1rfqAoiIEG4NkNqeITjn0m"

@interface DemoViewController ()<QiniuUploaderDelegate>

@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, 260, 200)];
    [imageView setImage:[UIImage imageNamed:@"test.jpg"]];
    [self.view addSubview:imageView];
    
    //give token
    QiniuToken *token = [[QiniuToken alloc] initWithScope:scope SecretKey:secretKey Accesskey:accessKey];
    
    //give file
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(imageView.image, 1.0f)];
    
    //startUpload
    QiniuUploader *uploader = [[QiniuUploader alloc] initWithToken:token];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader setDelegate:self];
    [uploader startUpload];
}

- (void)uploadOneFileSucceeded:(AFHTTPRequestOperation *)operation Index:(NSInteger)index ret:(NSDictionary *)ret
{
    NSLog(@"index:%d ret:%@",index,ret);
}

- (void)uploadAllFilesComplete
{
    NSLog(@"all complete");
}
- (void)uploadOneFileFailed:(AFHTTPRequestOperation *)operation Index:(NSInteger)index error:(NSError *)error
{
    NSLog(@"index:%d responseObject:%@",index,operation.responseObject);

}

- (void)uploadOneFileProgress:(NSInteger)index UploadPercent:(double)percent
{
    NSLog(@"index:%d percent:%lf",index,percent);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
