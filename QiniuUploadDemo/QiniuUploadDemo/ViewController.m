//
//  ViewController.m
//  QiniuUploadDemo
//
//  Created by 胡 桓铭 on 16/9/3.
//  Copyright © 2016年 胡 桓铭. All rights reserved.
//

#import "ViewController.h"
#import "QiniuUploader.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,
UIAlertViewDelegate>{
    UIImageView *imageView;
    QiniuUploader *uploader;
}
@end

@implementation ViewController

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
    [imageUploaderButton setTitle:@"upload images" forState:UIControlStateNormal];
    [self.view addSubview:imageUploaderButton];
    [imageUploaderButton addTarget:self action:@selector(imageUploadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *audioUploaderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [audioUploaderButton setFrame:CGRectMake(140,300, 100, 50)];
    [audioUploaderButton setTitle:@"upload audios" forState:UIControlStateNormal];
    [self.view addSubview:audioUploaderButton];
    [audioUploaderButton addTarget:self action:@selector(audioUploadClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopButton setFrame:CGRectMake(240,300, 100, 50)];
    [stopButton setTitle:@"stop All!" forState:UIControlStateNormal];
    [self.view addSubview:stopButton];
    [stopButton addTarget:self action:@selector(stopClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //register qiniu
    [QiniuToken registerWithScope:@"temp" SecretKey:@"SK" Accesskey:@"AK"];
    NSLog(@"%@",[[QiniuToken sharedQiniuToken] uploadToken]);
    [[QiniuUploader sharedUploader] setMaxConcurrentNumber:3];
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
    if (uploader.isRunning) {
        NSLog(@"不要启动太多上传任务，会很累的诶");
        return;
    }

    //add file
    QiniuFile *file = [[QiniuFile alloc] initWithFileData:UIImageJPEGRepresentation(imageView.image, 1.0f)];
    
    //startUpload
    uploader = [QiniuUploader sharedUploader];
    [uploader setFiles:@[file, file, file, file, file, file]];
    
    [uploader startUpload:[QiniuToken sharedQiniuToken].uploadToken uploadOneFileSucceededHandler:^(NSInteger index, NSDictionary * _Nonnull info) {
        NSLog(@"index: %ld info: %@",(long)index, info);
    } uploadOneFileFailedHandler:^(NSInteger index, NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    } uploadOneFileProgressHandler:^(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"index:%ld percent:%f",(long)index, totalBytesSent * 1.0 / totalBytesExpectedToSend);
    } uploadAllFilesComplete:^{
        NSLog(@"complete");
    }];
}

- (void)uploadAudio
{
    if (uploader.isRunning) {
        NSLog(@"不要启动太多上传任务，会很累的诶");
        return;
    }

    //add file
    NSString *path = [NSString stringWithFormat:@"%@/%@",[NSBundle mainBundle].resourcePath,@"ふつうのdisco.mp3"];
    QiniuFile *file = [[QiniuFile alloc] initWithPath:path];
    //startUpload
    uploader = [QiniuUploader sharedUploader];
    uploader.files = @[file, file, file, file];
    
    [uploader startUpload:[QiniuToken sharedQiniuToken].uploadToken uploadOneFileSucceededHandler:^(NSInteger index, NSDictionary * _Nonnull info) {
        NSLog(@"index: %ld info: %@",(long)index, info);
    } uploadOneFileFailedHandler:^(NSInteger index, NSError * _Nullable error) {
        NSLog(@"error: %@", error);
    } uploadOneFileProgressHandler:^(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"index:%ld percent:%f",(long)index, totalBytesSent * 1.0 / totalBytesExpectedToSend);
    } uploadAllFilesComplete:^{
        NSLog(@"complete");
    }];
}

// UIImagePickerControllerdelegate

- (void)imagePickerController:(UIImagePickerController *)pickerController didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [pickerController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%@",info);
    
    [imageView setImage:(UIImage*)info[@"UIImagePickerControllerOriginalImage"]];
    NSURL *url = info[@"UIImagePickerControllerReferenceURL"];
    
    
    [[[ALAssetsLibrary alloc] init] assetForURL:url resultBlock:^(ALAsset *asset) {
        if (uploader.isRunning) {
            NSLog(@"不要启动太多上传任务，会很累的诶");
            return;
        }
        
        uploader = [QiniuUploader sharedUploader];
        
        QiniuFile *file = [[QiniuFile alloc] initWithAsset:asset];
        uploader.files = @[file];
        
        [uploader startUpload:[QiniuToken sharedQiniuToken].uploadToken uploadOneFileSucceededHandler:^(NSInteger index, NSDictionary * _Nonnull info) {
            NSLog(@"index: %ld info: %@",(long)index, info);
        } uploadOneFileFailedHandler:^(NSInteger index, NSError * _Nullable error) {
            NSLog(@"error: %@", error);
        } uploadOneFileProgressHandler:^(NSInteger index, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
             NSLog(@"index:%ld percent:%f",(long)index, totalBytesSent * 1.0 / totalBytesExpectedToSend);
        } uploadAllFilesComplete:^{
            NSLog(@"complete");
        }];
    } failureBlock: nil];
}

@end
