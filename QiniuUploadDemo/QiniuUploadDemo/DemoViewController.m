//
//  DemoViewController.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 14-5-18.
//  Copyright (c) 2014年 hu. All rights reserved.
//

#import "DemoViewController.h"
#import "QiniuUploader.h"


@interface DemoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    UIImageView *imageView;
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
    [imageSelectedButton addTarget:self action:@selector(imageSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *imageUploaderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imageUploaderButton setFrame:CGRectMake(20,300, 100, 50)];
    [imageUploaderButton setTitle:@"upload image" forState:UIControlStateNormal];
    [self.view addSubview:imageUploaderButton];
   
    
    UIButton *audioUploaderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [audioUploaderButton setFrame:CGRectMake(140,300, 100, 50)];
    [audioUploaderButton setTitle:@"upload audio" forState:UIControlStateNormal];
    [self.view addSubview:audioUploaderButton];
    //register qiniu
    
    [QiniuToken registerWithScope:@"your_scope" SecretKey:@"your_secretKey" Accesskey:@"your_accesskey"];
    NSLog(@"%@",[[QiniuToken sharedQiniuToken] uploadToken]);
//    // upload images
    [self uploadImageFiles];
//    // upload audios
//    [self uploadAudio];
    
    
}

- (void)imageSelected:(id)sender
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.allowsEditing = YES; //是否可编辑
    [self presentViewController:pickerController animated:YES completion:nil];
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
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPSessionManager *manager, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index, key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPSessionManager *manager, NSInteger index, NSProgress *process){
        NSLog(@"index:%ld percent:%@",(long)index, process);
        
    }];
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
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
    QiniuUploader *uploader = [[QiniuUploader alloc] init];
    [uploader addFile:file];
    [uploader addFile:file];
    [uploader addFile:file];
    
    [uploader setUploadOneFileSucceeded:^(AFHTTPSessionManager *manager, NSInteger index, NSString *key){
        NSLog(@"index:%ld key:%@",(long)index, key);
    }];
    
    [uploader setUploadOneFileProgress:^(AFHTTPSessionManager *manager, NSInteger index, NSProgress *process){
        NSLog(@"index:%ld percent:%@",(long)index, process);
        
    }];
    [uploader setUploadAllFilesComplete:^(void){
        NSLog(@"complete");
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
    
    QiniuUploader *uploader = [[QiniuUploader alloc] init];
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
