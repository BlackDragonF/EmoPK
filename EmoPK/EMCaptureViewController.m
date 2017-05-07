//
//  EMCaptureViewController.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/5.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMCaptureViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "EMEmotionProcessor.h"
#import "EMDetectResult.h"

#import <SVProgressHUD.h>

#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height

@interface EMCaptureViewController ()
@property (strong, readwrite, nonatomic) AVCaptureSession * session;
@property (strong, readwrite, nonatomic) AVCaptureDeviceInput * frontInputDevice;
@property (strong, readwrite, nonatomic) AVCaptureDeviceInput * backInputDevice;
@property (strong, readwrite, nonatomic) AVCaptureStillImageOutput * stillImageOutput;
@property (strong, readwrite, nonatomic) AVCaptureVideoPreviewLayer* previewLayer;

@property (weak, readwrite, nonatomic) IBOutlet UIView * backView;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * helpButton;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * backButton;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * reverseButton;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * flashButton;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * shootButton;

@property (weak, readwrite, nonatomic) IBOutlet UILabel * countdownLabel;

@property (readwrite, nonatomic) BOOL isFrontCamera;

@property (strong, readwrite, nonatomic) UIImage * targetImage;
@property (strong, readwrite, nonatomic) EMDetectResult * result;
@end

@implementation EMCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCamera];
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCamera {
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.isFrontCamera = YES;
    for (AVCaptureDevice * device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == AVCaptureDevicePositionFront) {
            self.frontInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        } else if (device.position == AVCaptureDevicePositionBack) {
            self.backInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
//    self.inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    if ([self.session canAddInput:self.frontInputDevice]) {
        [self.session addInput:self.frontInputDevice];
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.previewLayer.frame = self.backView.frame;
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
}

- (IBAction)flash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeOff;
        }
    } else {
        NSLog(@"设备不支持闪光灯");
    }
    [device unlockForConfiguration];
}

- (IBAction)reverse {
    [self.previewLayer.session beginConfiguration];
    if (self.isFrontCamera) {
        [[self.previewLayer session] removeInput:self.frontInputDevice];
        [self.previewLayer.session addInput:self.backInputDevice];
    } else {
        [[self.previewLayer session] removeInput:self.backInputDevice];
        [self.previewLayer.session addInput:self.frontInputDevice];
    }
    [self.previewLayer.session commitConfiguration];
    self.isFrontCamera = !self.isFrontCamera;
}

- (IBAction)shoot {
    self.countdownLabel.text = @"3";
    [self lockAllButtons];
    [self performSelector:@selector(didShoot) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(countToTwo) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(countToOne) withObject:nil afterDelay:2.0];
    [self performSelector:@selector(countToZero) withObject:nil afterDelay:3.0];
}

- (void)countToTwo {
    self.countdownLabel.text = @"2";
}

- (void)countToOne {
    self.countdownLabel.text = @"1";
}

- (void)countToZero {
    self.countdownLabel.text = @"...";
}
- (void)didShoot {
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    [stillImageConnection setVideoScaleAndCropFactor:1];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        NSData * jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//        CGAffineTransform transform = CGAffineTransformIdentity;
//        transform = CGAffineTransformRotate(transform, M_PI);
//        transform = CGAffineTransformScale(transform, -1, 1);
//        CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
//                                                 CGImageGetBitsPerComponent(image.CGImage), 0,
//                                                 CGImageGetColorSpace(image.CGImage),
//                                                 CGImageGetBitmapInfo(image.CGImage));
//        CGContextConcatCTM(ctx, transform);
//        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//        UIImage *image2 = [UIImage imageWithCGImage:cgimg];
//        CGContextRelease(ctx);
//        CGImageRelease(cgimg);
        
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                    imageDataSampleBuffer,
                                                                    kCMAttachmentMode_ShouldPropagate);
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            return;
        }
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
            
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
            {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                @autoreleasepool {
                    CGImageRef iref = [rep fullScreenImage];
                    if (iref) {
                        UIImage * image = [UIImage imageWithCGImage:iref];
                        self.targetImage = image;
                        self.result = [[EMEmotionProcessor sharedProcessor]detectWithImage:image];
                        self.countdownLabel.text = @"";
                        [self unlockAllButtons];
                        if (self.result != nil) {
                            [self performSegueWithIdentifier:@"FinishCapture" sender:nil];
                        } else {
                            [SVProgressHUD setMinimumDismissTimeInterval:1.5];
                            [SVProgressHUD showInfoWithStatus:@"未能识别到至少2个人，请重新拍照"];
                            [[EMEmotionProcessor sharedProcessor] endWithProcess];
                        }
                        
                        iref = nil;
                    }
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
            {
                NSLog(@"Can't get image - %@",[myerror localizedDescription]);
            };
            
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:assetURL
                           resultBlock:resultblock
                          failureBlock:failureblock];
        }];
        
    }];
}

- (IBAction)help {
    
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)lockAllButtons {
    self.helpButton.userInteractionEnabled = NO;
    self.backButton.userInteractionEnabled = NO;
    self.reverseButton.userInteractionEnabled = NO;
    self.flashButton.userInteractionEnabled = NO;
    self.shootButton.userInteractionEnabled = NO;
}

- (void)unlockAllButtons {
    self.helpButton.userInteractionEnabled = YES;
    self.backButton.userInteractionEnabled = YES;
    self.reverseButton.userInteractionEnabled = YES;
    self.flashButton.userInteractionEnabled = YES;
    self.shootButton.userInteractionEnabled = YES;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FinishCapture"]) {
        UIViewController * vc = segue.destinationViewController;
        [vc setValue:self.targetImage forKey:@"targetImage"];
        [vc setValue:self.result forKey:@"result"];
        self.result = nil;
    }
}

- (IBAction)unwindSegueToRedViewController:(UIStoryboardSegue *)segue {
    
}

@end
