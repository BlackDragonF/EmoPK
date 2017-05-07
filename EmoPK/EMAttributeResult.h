//
//  EMAttributeResult.h
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/6.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, EMEmotion) {
    EMEmotionAngry,
    EMEmotionHappy,
    EMEmotionPeaceful,
    EMEmotionSad,
    EMEmotionPanic
};

#import "cv_face.h"

@interface EMAttributeResult : NSObject
@property (readwrite, nonatomic) EMEmotion emotion1;
@property (readwrite, nonatomic) EMEmotion emotion2;
@property (readwrite, nonatomic) cv_face_t * player1;
@property (readwrite, nonatomic) cv_face_t * player2;
@end
