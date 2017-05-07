//
//  EMEmotionProcessor.h
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/6.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EMAttributeResult.h"

@class UIImage;
@class EMDetectResult;


typedef NS_ENUM(NSInteger, EMEmotionCategory) {
    EMEmotionCategoryPositive,
    EMEmotionCategoryNegative,
    EMEmotionCategoryNeutrality,
};

@interface EMEmotionProcessor : NSObject
+ (instancetype)sharedProcessor;
- (EMDetectResult *)detectWithImage:(UIImage *)image;
- (EMAttributeResult *)continueWithAttribute;
- (void)endWithProcess;
@end
