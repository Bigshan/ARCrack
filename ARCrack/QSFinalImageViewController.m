//
//  QSFinalImageViewController.m
//  ARCrack
//
//  Created by shiqishan on 2016/12/25.
//  Copyright © 2016年 shiqishan. All rights reserved.
//

#import "QSFinalImageViewController.h"

@interface QSFinalImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QSFinalImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.originImage;
}

- (void)setOriginImage:(UIImage *)originImage {
    _originImage = originImage;
    self.imageView.image = _originImage;
}

- (IBAction)closeButtonClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)saveButtonClicked:(UIButton *)sender {
    UIImageWriteToSavedPhotosAlbum(self.originImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

@end
