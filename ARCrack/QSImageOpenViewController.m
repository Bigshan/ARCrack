//
//  QSImageOpenViewController.m
//  ARCrack
//
//  Created by shiqishan on 2016/12/25.
//  Copyright © 2016年 shiqishan. All rights reserved.
//

#import "QSImageOpenViewController.h"
#import "QSFinalImageViewController.h"

#define ISIPHONE    ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? YES :NO)

@interface QSImageOpenViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *cutImageView;
@property (weak, nonatomic) IBOutlet UIImageView *finalImageView;
@property (nonatomic, strong) UIImage *bigImage;
@property (nonatomic, strong) UIImage *cutImage;
@property (nonatomic, strong) UIImage *finalImage;
@property (nonatomic, assign) BOOL isChangingImage;
@property (weak, nonatomic) IBOutlet UISlider *RMin;
@property (weak, nonatomic) IBOutlet UISlider *RMax;
@property (weak, nonatomic) IBOutlet UISlider *GMin;
@property (weak, nonatomic) IBOutlet UISlider *GMax;
@property (weak, nonatomic) IBOutlet UISlider *BMin;
@property (weak, nonatomic) IBOutlet UISlider *BMax;
@property (weak, nonatomic) IBOutlet UISlider *tryCountSlider;
@property (weak, nonatomic) IBOutlet UILabel *label;


@end

@implementation QSImageOpenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)openImage {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    //设置相册呈现的样式
    pickerController.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
    
    //使用模态呈现相册
    [self presentViewController:pickerController animated:YES completion:^{
        
    }];
}

- (void)cutImageOpreation {
    if (self.bigImage) {
        CGFloat x = 0.28*self.bigImage.size.width;
        CGFloat y = 0.48*self.bigImage.size.height;
        CGFloat w = 0.44*self.bigImage.size.width;
        CGFloat h = w;
        if (!ISIPHONE) {
            x = 0.39*self.bigImage.size.width;
            y = 0.66*self.bigImage.size.height;
            w = 0.22*self.bigImage.size.width;
            h = w;
        }
        
        CGRect rect = CGRectMake(x, y, w, h);
        self.cutImage = [self imageFromImage:self.bigImage inRect:rect];
    }
    
    if (self.cutImage) {
        [self changeImage];
    }
}
- (IBAction)updateImage:(UISlider *)sender {
    [self changeImage];
}


- (IBAction)openImageButtonClicked:(UIButton *)sender {
    [self openImage];
}

- (IBAction)generateFinalImage:(UIButton *)sender {
    [self performSegueWithIdentifier:@"presentFinalImage" sender:self.finalImage];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    id resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if ([resultImage isKindOfClass:[UIImage class]]) {
        self.bigImage = resultImage;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self cutImageOpreation];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

/////
- (void)changeImage {
    if (self.isChangingImage) {
        return;
    }
    self.label.text = [NSString stringWithFormat:@"R:%d-%d,G:%d-%d,B:%d-%d",(int)self.RMin.value,(int)self.RMax.value,(int)self.GMin.value,(int)self.GMax.value,(int)self.BMin.value,(int)self.BMax.value];
    
    self.isChangingImage = YES;
    CGImageRef cgimage = [self.cutImage CGImage];
    
    size_t width = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char));
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width * 4;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context =
    CGBitmapContextCreate(data,
                          width,
                          height,
                          bitsPerComponent,
                          bytesPerRow,
                          space,
                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    NSMutableArray * heightArray = [NSMutableArray array];
    for (size_t i = 0; i < height; i++) {
        int tryCount = 0;
        unsigned char firstData[4];
        for (size_t j = 0; j < width; j++) {
            
            size_t pixelIndex = i * width * 4 + j * 4;
            if (0 == j) {
                firstData[0] = data[pixelIndex];
                firstData[1] = data[pixelIndex + 1];
                firstData[2] = data[pixelIndex + 2];
            }
            
            unsigned char red = data[pixelIndex];
            unsigned char green = data[pixelIndex + 1];
            unsigned char blue = data[pixelIndex + 2];
            
            if (![self isRightRed:red Green:green Blue:blue]) {
                tryCount += 1;
            }
            
            if (j == width -1) {
                if (tryCount < self.tryCountSlider.value ) {
                    [heightArray addObject:@(i)];
                }
            }
        }
    }
    
    if ([heightArray count] >= 1) {
        for (int i = 0; i < [heightArray count]; i++) {
            int height = [[heightArray objectAtIndex:i] intValue];
            for (size_t j = 0; j < width; j++) {
                size_t pixelIndexPre = (height-1) * width * 4 + j * 4;
                size_t pixelIndex = height * width * 4 + j * 4;
                data[pixelIndex] = data[pixelIndexPre];
                data[pixelIndex + 1] = data[pixelIndexPre+1];
                data[pixelIndex + 2] = data[pixelIndexPre+2];
                data[pixelIndex + 3] = data[pixelIndexPre+3];
            }
        }
    }
    cgimage = CGBitmapContextCreateImage(context);
    self.finalImage = [UIImage imageWithCGImage:cgimage];
    self.isChangingImage = NO;
}

- (BOOL)isRightRed:(unsigned char)red Green:(unsigned char)green Blue:(unsigned char)blue {
    if (red >= self.RMin.value && red < self.RMax.value) {
        if (green >= self.GMin.value && green < self.GMax.value) {
            if (blue >= self.BMin.value && blue < self.BMax.value) {
                return YES;
            }
        }
    }
    return NO;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QSFinalImageViewController *vc = segue.destinationViewController;
    vc.originImage = sender;
}

- (void)setCutImage:(UIImage *)cutImage {
    _cutImage = cutImage;
    self.cutImageView.image = _cutImage;
}

- (void)setFinalImage:(UIImage *)finalImage {
    _finalImage = finalImage;
    self.finalImageView.image = _finalImage;
}



@end
