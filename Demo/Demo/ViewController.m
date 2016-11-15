//
//  ViewController.m
//  Demo
//
//  Created by 吴磊 on 2016/11/14.
//  Copyright © 2016年 wleo. All rights reserved.
//

#import "ViewController.h"
#import <SGTImageFramework/SGTPhotoPickerController.h>
#import <SGTImageFramework/SGTPhoto.h>
#import "SGTFileUploadManager.h"
#import "SGTOSSUpload.h"

@interface ViewController ()<SGTPhotoPickerControllerDelegate>
@property (nonatomic, strong, nonnull) NSMutableArray<SGTPhotoSelectProtocol>*photos;
@property (nonatomic, strong, nonnull) NSMutableArray* uploadTasks;
@property (nonatomic, strong) SGTFileUploadManager *maneger;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _photos = [NSMutableArray<SGTPhotoSelectProtocol> array];
    _maneger = [[SGTFileUploadManager alloc] init];
    _maneger.fileUploader = [[SGTOSSUpload alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
//        upload asset
        SGTPhotoPickerController *picker = [[SGTPhotoPickerController alloc] initWithMaxPickCount:10];
        picker.photoPickerDelegate = self;
        [self.navigationController presentViewController:picker animated:true completion:nil];
    }
}

- (void)sgtphotoPickFinishedWithImages:(NSArray<SGTPhotoSelectProtocol> *)photos otherInfo:(NSDictionary *)info {
    [_photos addObjectsFromArray:photos];
    NSLog(@"upload start");
    [self upload];
}

- (void)upload {
    [_maneger reset];
    _uploadTasks = [NSMutableArray array];
    for (NSInteger i = 0 ; i < _photos.count; i++) {
        id<SGTPhotoSelectProtocol> photo = _photos[i];
        [photo saveToDisk:^(BOOL finish) {
            if (finish) {
                UploadTask *task = [[UploadTask alloc] initWithFilePath:photo.fullLocalFilePath name:[photo.fullLocalFilePath lastPathComponent] url:@"" param:nil];
                [self.uploadTasks addObject:task];
                [self startUploadIfFinishSave];
            }
        }];
    }
}

- (void)startUploadIfFinishSave {
    if (_uploadTasks.count == _photos.count) {
        [_maneger addUploadTasks:_uploadTasks];
        [_maneger start];
    }
}

@end
