//
//  DemoViewController.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "DemoViewController.h"
#import "QiniuUploader.h"


const static NSString *QiniuScope =  @"jichedang";
const static NSString *QiniuAccessKey  =  @"_Na9jCMtIIj1obn1ULmucVh0G-vgW8bookGw1JMI";
const static NSString *QiniuSecretKey  =  @"IOIgoQilr8CrSjFj7PCM5NYEO47T5iAyCX_8HUIW";


@interface DemoViewController (){
    UIImageView *imageView;
}

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
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, 260, 200)];
    [imageView setImage:[UIImage imageNamed:@"test.jpg"]];
    [self.view addSubview:imageView];
    
   
    //register qiniu
    [QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"];
    // upload images
    [self uploadImageFiles];
    // upload audios
    [self uploadAudio];
}

- (void)uploadImageFiles
{
    //add file
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(imageView.image, 1.0f)];
    
    //startUpload
    QiniuUploader *uploader = [[QiniuUploader alloc] init];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPRequestOperation *operation, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index,key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPRequestOperation *operation, NSInteger index, double percent){
        NSLog(@"index:%ld percent:%lf",(long)index,percent);
        
    }];
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
    }];
    [uploader setUploadOneFileFailed:^(AFHTTPRequestOperation *operation, NSInteger index, NSDictionary *error){
        NSLog(@"%@",error);
    }];
    [uploader startUpload];
}

- (void)uploadAudio
{
    //add file
    NSString *path = [NSString stringWithFormat:@"%@/%@",[NSBundle mainBundle].resourcePath,@"ふつうのdisco.mp3"];
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:[NSData dataWithContentsOfFile:path]];
    
    //startUpload
    QiniuUploader *uploader = [[QiniuUploader alloc] init];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPRequestOperation *operation, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index,key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPRequestOperation *operation, NSInteger index, double percent){
        NSLog(@"index:%ld percent:%lf",(long)index,percent);
        
    }];
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
    }];
    [uploader setUploadOneFileFailed:^(AFHTTPRequestOperation *operation, NSInteger index, NSDictionary *error){
        NSLog(@"%@",error);
    }];
    [uploader startUpload];
}

@end
