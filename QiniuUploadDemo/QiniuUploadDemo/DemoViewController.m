//
//  DemoViewController.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "DemoViewController.h"
#import "QiniuUploader.h"


@interface DemoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,
    UIAlertViewDelegate>{
    UIImageView *imageView;
    QiniuUploader *uploader;
}

@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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
    
    
    UIButton *imageSelectedButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imageSelectedButton setFrame:CGRectMake(60,260, 100, 50)];
    [imageSelectedButton setTitle:@"select image" forState:UIControlStateNormal];
    [self.view addSubview:imageSelectedButton];
    [imageSelectedButton addTarget:self action:@selector(imageSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *imageUploaderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imageUploaderButton setFrame:CGRectMake(20,300, 100, 50)];
    [imageUploaderButton setTitle:@"upload image" forState:UIControlStateNormal];
    [self.view addSubview:imageUploaderButton];
    [imageUploaderButton addTarget:self action:@selector(imageUploadClick:) forControlEvents:UIControlEventTouchUpInside];

    
    UIButton *audioUploaderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [audioUploaderButton setFrame:CGRectMake(140,300, 100, 50)];
    [audioUploaderButton setTitle:@"upload audio" forState:UIControlStateNormal];
    [self.view addSubview:audioUploaderButton];
    [audioUploaderButton addTarget:self action:@selector(audioUploadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopButton setFrame:CGRectMake(240,300, 100, 50)];
    [stopButton setTitle:@"stop All!" forState:UIControlStateNormal];
    [self.view addSubview:stopButton];
    [stopButton addTarget:self action:@selector(stopClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //register qiniu
    [QiniuToken registerWithScope:@"temp" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"];
    NSLog(@"%@",[[QiniuToken sharedQiniuToken] uploadToken]);
}

// click events

- (void)imageSelectedClick:(id)sender
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.allowsEditing = YES; //是否可编辑
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imageUploadClick:(id)sender
{
    [self uploadImageFiles];
}

- (void)audioUploadClick:(id)sender
{
    [self uploadAudio];
}

- (void)stopClick:(id)sender
{
    [uploader cancelAllUploadTask];
    NSLog(@"All uploading task stop now!!!");
}

// Upload

- (void)uploadImageFiles
{
    //add file
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(imageView.image, 1.0f)];
    
    //startUpload
    uploader = [[QiniuUploader alloc] init];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPSessionManager *manager, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index, key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPSessionManager *manager, NSInteger index, NSProgress *process){
        NSLog(@"index:%ld percent:%@",(long)index, process);
        
    }];
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Images" message:@"All Uploaded" delegate:self cancelButtonTitle:@"Okay.." otherButtonTitles:nil];
    
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
        [alertView show];
    }];
    [uploader setUploadOneFileFailed:^(AFHTTPSessionManager *manager, NSInteger index, NSDictionary *error){
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
    uploader = [[QiniuUploader alloc] init];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPSessionManager *manager, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index, key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPSessionManager *manager, NSInteger index, NSProgress *process){
        NSLog(@"index:%ld percent:%@",(long)index, process);
        
    }];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Audio" message:@"one Uploaded" delegate:self cancelButtonTitle:@"Okay.." otherButtonTitles:nil];
    
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
        [alertView show];
    }];
    [uploader setUploadOneFileFailed:^(AFHTTPSessionManager *manager, NSInteger index, NSDictionary *error){
        NSLog(@"%@",error);
    }];
    [uploader startUpload];
}

// UIImagePickerControllerdelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [pickerController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@",info);
    
    [imageView setImage:(UIImage*)info[@"UIImagePickerControllerOriginalImage"]];
    
    QiniuFile *file = [[QiniuFile alloc] initWithAssetURL:info[@"UIImagePickerControllerReferenceURL"]];
    
    uploader = [[QiniuUploader alloc] init];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPSessionManager *manager, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index,key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPSessionManager *manager, NSInteger index,NSProgress *process){
        NSLog(@"index:%ld percent:%@",(long)index, process);
    }];
    
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
    }];
    [uploader setUploadOneFileFailed:^(AFHTTPSessionManager *manager, NSInteger index, NSDictionary *error){
        NSLog(@"%@",error);
    }];
    
    [uploader setProcessAsset:^NSData*(ALAsset *asset){
        [metaArray addObject:[asset valueForProperty:ALAssetPropertyDate]];
        UIImage *tempImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        return UIImageJPEGRepresentation(tempImage, 0.1);
    }];
    [uploader startUpload];

}

@end
