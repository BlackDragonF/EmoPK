//
//  EMEmotionProcessor.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/6.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMEmotionProcessor.h"

#import <UIKit/UIKit.h>

#import "EMDetectResult.h"
#import "EMAttributeResult.h"
#import "cv_face.h"

@interface EMEmotionProcessor() {
    cv_handle_t _hDetector;
    cv_handle_t _hAttribute;
    cv_face_t * pFaceArray;
    int iFaceCount;
    unsigned char * pBGRAImage;
    int iWidth;
    int iHeight;
}

@end

@implementation EMEmotionProcessor
+ (instancetype)sharedProcessor {
    static EMEmotionProcessor * processor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processor = [[EMEmotionProcessor alloc] init];
    });
    return processor;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *strLicensePath = [[NSBundle mainBundle] pathForResource:@"FACESDK_8EBDD0B5-FB25-496A-84A4-FB1EE3FA709C" ofType:@"lic"];
        if(!strLicensePath) {
            NSLog(@"获取证书路径失败");
        }
        NSString *path = NSHomeDirectory();
        NSString *licenseRepoPath = [path stringByAppendingString:@"/Library/LicenseRepo"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if(![manager fileExistsAtPath:licenseRepoPath]) {
            if(![manager createDirectoryAtPath:licenseRepoPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                NSLog(@"创建证书配置路径失败");
                return self;
            }
        }
        
        cv_result_t iResult = CV_OK;
        iResult = cv_face_public_init_license([strLicensePath UTF8String], [licenseRepoPath UTF8String]);
        if(iResult!=CV_OK) {
            NSLog(@"证书配置失败，错误码：%d", iResult);
            return self;
        }
        cv_face_create_detector(&_hDetector, NULL, CV_DETECT_ENABLE_ALIGN_21);
        
        NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"attribute" ofType:@"model"];
        
        cv_face_create_attribute_detector(&_hAttribute, [strModelPath UTF8String]);
        
        if (!_hDetector ||!_hAttribute) {
            NSLog(@"算法SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符");
            return self;
        }
        pFaceArray = NULL;
        iFaceCount = 0;
        pBGRAImage = NULL;
    }
    return self;
}

- (unsigned char *)getBGRAfromImage:(UIImage *)image {
    CGImageRef cgImage = [image CGImage];
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    iWidth = image.size.width*image.scale;
    iHeight = image.size.height*image.scale;
    int iBytesPerPixel = 4;
    int iBytesPerRow = iBytesPerPixel * iWidth;
    int iBitsPerComponent = 8;
    unsigned char * pImage = malloc(iWidth * iHeight * iBytesPerPixel);
    CGContextRef context = CGBitmapContextCreate(pImage,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                                                 );
    CGRect rect = CGRectMake(0 , 0 , iWidth , iHeight);
    CGContextDrawImage(context , rect ,cgImage);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
    
    return pImage;
}

- (EMDetectResult *)detectImage:(UIImage *)image
{
    
    int iWidth = image.size.width*image.scale;
    int iHeight= image.size.height*image.scale;
    
    pBGRAImage = [self getBGRAfromImage:image];
    
    if (pBGRAImage == NULL) {
        NSLog(@"pBGRAImage create fail .") ;
        return nil;
    }
    
    
    
    
    cv_result_t iRet = CV_OK;
    
    iRet = cv_face_detect(_hDetector, pBGRAImage, CV_PIX_FMT_BGRA8888, iWidth, iHeight, iWidth * 4, CV_FACE_UP, &pFaceArray, &iFaceCount);
    
    if (iRet != CV_OK) {
        NSLog(@"cv_face_detect Feature error %d\n", iRet);
    }
    if (iFaceCount < 2) {
        return nil;
    }
    cv_face_t * pTemp = &pFaceArray[0];
    EMDetectResult * result = [[EMDetectResult alloc] init];
    CGRect rect = CGRectMake(pTemp->rect.left/2, pTemp->rect.top/2, (pTemp->rect.right - pTemp->rect.left)/2, (pTemp->rect.top - pTemp->rect.bottom)/2);
    result.avatarRect1 = rect;
    pTemp = &pFaceArray[1];
    rect = CGRectMake(pTemp->rect.left/2, pTemp->rect.top/2, (pTemp->rect.right - pTemp->rect.left)/2, (pTemp->rect.top - pTemp->rect.bottom)/2);
    result.avatarRect2 = rect;
    return result;
//    NSMutableString *strAttributeResult = [NSMutableString string];
//    if(iFaceCount > 0) {
//        for (int i = 0; i < iFaceCount; i++) {
//            
//            int pAttributeResultFeature[CV_FEATURE_LENGTH] = {0};
//            int pAttributeResultEmotion[CV_EMOTION_LENGTH] = {0};
//            
//            iRet = cv_face_attribute_detect(_hAttribute, pBGRAImage, CV_PIX_FMT_BGRA8888, iWidth, iHeight, iWidth * 4, &pFaceArray[i], pAttributeResultFeature, pAttributeResultEmotion);
//            
//            if(iRet != CV_OK) {
//                NSLog(@"cv_face_attribute_detect Feature error %d\n", iRet);
//            } else {
//                
//                [strAttributeResult appendFormat:@"age : %d\n",pAttributeResultFeature[0]];
//                [strAttributeResult appendFormat:@"gender : %@\n",pAttributeResultFeature[1] < 50 ? @"female" : @"male"];
//                
//                [strAttributeResult appendFormat:@"attractive : %d\n",pAttributeResultFeature[2]];
//                [strAttributeResult appendFormat:@"eyeglass: %@\n", pAttributeResultFeature[3] > 50 ? @"yes" : @"no"];
//                [strAttributeResult appendFormat:@"sunglass: %@\n", pAttributeResultFeature[4] > 50 ? @"yes" : @"no"];
//                [strAttributeResult appendFormat:@"smile : %@\n",pAttributeResultFeature[5] > 50 ? @"yes" : @"no"];
//                [strAttributeResult appendFormat:@"mask : %@\n",pAttributeResultFeature[6] > 50 ? @"yes" : @"no"];
//                
//                NSString *strRace = @"";
//                switch (pAttributeResultFeature[7]) {
//                    case 0:
//                    {
//                        strRace = @"Yellow";
//                        break;
//                    }
//                    case 1:
//                    {
//                        strRace = @"Black";
//                        break;
//                    }
//                    case 2:
//                    {
//                        strRace = @"White";
//                        break;
//                    }
//                    default:
//                        break;
//                }
//                [strAttributeResult appendFormat:@"race : %@\n",strRace];
//                
//                [strAttributeResult appendFormat:@"eye_open : %@\n",pAttributeResultFeature[8] > 50 ? @"yes" : @"no"];
//                [strAttributeResult appendFormat:@"mouth_open : %@\n",pAttributeResultFeature[9] > 50 ? @"yes" : @"no"];
//                [strAttributeResult appendFormat:@"beard : %@\n",pAttributeResultFeature[10] > 50 ? @"yes" : @"no"];
//                
//                
//                int iScore = pAttributeResultEmotion[0];
//                
//                NSArray *arrEmotion = [NSArray arrayWithObjects:@"angry", @"calm", @"confused", @"disgust", @"happy", @"sad", @"scared", @"suprised",@"squint",@"scream", nil];
//                NSString *strEmotion = @"";
//                
//                for (int j = 0; j < arrEmotion.count; j ++) {
//                    if (iScore < pAttributeResultEmotion[j]) {
//                        iScore = pAttributeResultEmotion[j];
//                        strEmotion =  [arrEmotion objectAtIndex:j];
//                    }
//                }
//                [strAttributeResult appendFormat:@"emotion : %@\n" , strEmotion];
//                
//            }
//            [strAttributeResult appendString:@"\n\n"];
//        }
//    }else {
//        [strAttributeResult appendString:@"can't find face"];
//    }
    
//    cv_face_release_detector_result(pFaceArray, iFaceCount);
//    free(pBGRAImage);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AttributeResult" message:strAttributeResult delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
//    [alert show];
}

- (EMDetectResult *)detectWithImage:(UIImage *)image {
    return [self detectImage:image];
}

- (EMAttributeResult *)continueWithAttribute {
    cv_result_t iRet = CV_OK;
    if (iFaceCount >= 2) {
        EMAttributeResult * result = [[EMAttributeResult alloc] init];
        int pAttributeResultFeature[CV_FEATURE_LENGTH] = {0};
        int pAttributeResultEmotion[CV_EMOTION_LENGTH] = {0};

        iRet = cv_face_attribute_detect(_hAttribute, pBGRAImage, CV_PIX_FMT_BGRA8888, iWidth, iHeight, iWidth * 4, &pFaceArray[0], pAttributeResultFeature, pAttributeResultEmotion);

        if(iRet != CV_OK) {
            NSLog(@"cv_face_attribute_detect Feature error %d\n", iRet);
        } else {
            EMEmotion emotion = EMEmotionAngry;
            int iScore = pAttributeResultEmotion[0];
            if (iScore < pAttributeResultEmotion[1]) {
                emotion = EMEmotionPeaceful;
                iScore = pAttributeResultEmotion[1];
            }
            if (iScore < pAttributeResultEmotion[4]) {
                emotion = EMEmotionHappy;
                iScore = pAttributeResultEmotion[4];
            }
            if (iScore < pAttributeResultEmotion[5]) {
                emotion = EMEmotionSad;
                iScore = pAttributeResultEmotion[5];
            }
            if (iScore < pAttributeResultEmotion[6]) {
                emotion = EMEmotionPanic;
                iScore = pAttributeResultEmotion[6];
            }
            result.emotion1 = emotion;
            result.player1 = &pFaceArray[0];
        }
        
        iRet = cv_face_attribute_detect(_hAttribute, pBGRAImage, CV_PIX_FMT_BGRA8888, iWidth, iHeight, iWidth * 4, &pFaceArray[1], pAttributeResultFeature, pAttributeResultEmotion);
        
        if(iRet != CV_OK) {
            NSLog(@"cv_face_attribute_detect Feature error %d\n", iRet);
        } else {
            EMEmotion emotion = EMEmotionAngry;
            int iScore = pAttributeResultEmotion[0];
            if (iScore < pAttributeResultEmotion[1]) {
                emotion = EMEmotionPeaceful;
                iScore = pAttributeResultEmotion[1];
            }
            if (iScore < pAttributeResultEmotion[4]) {
                emotion = EMEmotionHappy;
                iScore = pAttributeResultEmotion[4];
            }
            if (iScore < pAttributeResultEmotion[5]) {
                emotion = EMEmotionSad;
                iScore = pAttributeResultEmotion[5];
            }
            if (iScore < pAttributeResultEmotion[6]) {
                emotion = EMEmotionPanic;
                iScore = pAttributeResultEmotion[6];
            }
            result.emotion2 = emotion;
            result.player2 = &pFaceArray[1];
        }
        return result;
    } else {
        return nil;
    }
}
- (void)endWithProcess {
    cv_face_release_detector_result(pFaceArray, iFaceCount);
    free(pBGRAImage);
    pFaceArray = NULL;
    iFaceCount = 0;
}
@end
