//
//  EMCaptureResultViewController.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/6.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMCaptureResultViewController.h"

#import "EMDetectResult.h"
#import "EMEmotionProcessor.h"
#import "opencv2/opencv.hpp"
#import "opencv2/imgcodecs/ios.h"
#import "cv_face.h"

using namespace cv;
typedef struct Bgd{
    char name[20];
    int x_blank;
    int y_blank;
    int newwidth;
    int newheight;
}Bgd;
Bgd bgd[15]={{"angry1.png",170,140,90,90},{"angry2.jpg",120,70,240,240},{"angry3.png",100,50,140,140},{"calm1.jpg",120,70,240,240},{"calm2.png",130,100,120,120},{"calm3.png",90,80,100,100},{"calm4.png",90,80,100,100},{"happy1.jpg",120,70,240,240},{"happy2.jpg",120,70,240,240},{"happy3.jpg",120,70,240,240},{"happy4.png",130,100,120,120},{"happy5.png",130,100,120,120},
    {"sad1.png",90,80,100,100},{"sad2.png",90,80,100,100},{"scary1.png",90,80,100,100}};



@interface EMCaptureResultViewController ()
@property (weak, readwrite, nonatomic) IBOutlet UIImageView * imageView;

@property (strong, readwrite, nonatomic) UIImage * targetImage;
@property (strong, readwrite, nonatomic) EMDetectResult * result;
@property (strong, readwrite, nonatomic) EMAttributeResult * attributeResult;

@property (weak, readwrite, nonatomic) IBOutlet UIImageView * playerView1;
@property (weak, readwrite, nonatomic) IBOutlet UIImageView * playerView2;
@property (weak, readwrite, nonatomic) IBOutlet UIImageView * emotionView1;
@property (weak, readwrite, nonatomic) IBOutlet UIImageView * emotionView2;

@property (weak, readwrite, nonatomic) IBOutlet UILabel * player1Label;
@property (weak, readwrite, nonatomic) IBOutlet UILabel * player2Label;

@property (readwrite, nonatomic) EMBattleResult battleResult;
@end

@implementation EMCaptureResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player1Label.hidden = NO;
    self.player2Label.hidden = NO;
    Mat img;
    UIImageToMat(self.targetImage, img);
    rectangle(img, cv::Point(self.result.avatarRect1.origin.x,self.result.avatarRect1.origin.y), cv::Point(self.result.avatarRect1.origin.x+self.result.avatarRect1.size.width,self.result.avatarRect1.origin.y+self.result.avatarRect1.size.height), cv::Scalar(255,255,0));
    rectangle(img, cv::Point(self.result.avatarRect2.origin.x,self.result.avatarRect2.origin.y), cv::Point(self.result.avatarRect2.origin.x+self.result.avatarRect2.size.width,self.result.avatarRect2.origin.y+self.result.avatarRect2.size.height), cv::Scalar(255,0,0));
    self.targetImage=MatToUIImage(img);
    self.imageView.image = self.targetImage;
    /*
    CAShapeLayer * player1Layer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.result.avatarRect1);
    player1Layer.path = path;
    CGPathRelease(path);
    player1Layer.strokeColor = [UIColor colorWithRed:0.969 green:0.882 blue:0.282 alpha:1].CGColor;
    player1Layer.lineWidth = 2.0;
    player1Layer.fillColor = [UIColor clearColor].CGColor;
    [self.imageView.layer addSublayer:player1Layer];
    CAShapeLayer * player2Layer = [CAShapeLayer layer];
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathAddRect(path2, NULL, self.result.avatarRect2);
    player2Layer.path = path2;
    CGPathRelease(path2);
    player2Layer.strokeColor = [UIColor colorWithRed:0.408 green:0.808 blue:0.957 alpha:1].CGColor;
    player2Layer.lineWidth = 2.0;
    player2Layer.fillColor = [UIColor clearColor].CGColor;
    [self.imageView.layer addSublayer:player2Layer];
    */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        self.attributeResult = [[EMEmotionProcessor sharedProcessor] continueWithAttribute];
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2000ull * NSEC_PER_MSEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                self.playerView1.animationImages = [self animationImagesWithEmotion:self.attributeResult.emotion1];
                self.playerView1.animationDuration = 1.0;
                self.playerView1.animationRepeatCount = NSIntegerMax;
                [self.playerView1 startAnimating];
                self.playerView2.animationImages = [self animationImagesWithEmotion:self.attributeResult.emotion2];
                self.playerView2.animationDuration = 1.0;
                self.playerView2.animationRepeatCount = NSIntegerMax;
                [self.playerView2 startAnimating];
                self.imageView.hidden = YES;
                self.player1Label.hidden = YES;
                self.player2Label.hidden = YES;
                [self generateEmotions];
            });
        });
        if (self.attributeResult.emotion1 == EMEmotionHappy) {
            if (self.attributeResult.emotion2 == EMEmotionSad || self.attributeResult.emotion2 == EMEmotionPanic || self.attributeResult.emotion2 == EMEmotionAngry) {
                self.battleResult = EMBattleResultWin;
            } else if (self.attributeResult.emotion2 == EMEmotionHappy) {
                self.battleResult = EMBattleResultDraw;
            } else {
                self.battleResult = EMBattleResultLose;
            }
        } else if (self.attributeResult.emotion1 == EMEmotionSad || self.attributeResult.emotion1 == EMEmotionAngry || self.attributeResult.emotion1 == EMEmotionPanic) {
            if (self.attributeResult.emotion2 == EMEmotionPeaceful) {
                self.battleResult = EMBattleResultWin;
            } else if (self.attributeResult.emotion2 == EMEmotionHappy) {
                self.battleResult = EMBattleResultLose;
            } else {
                self.battleResult = EMBattleResultDraw;
            }
        } else {
            if (self.attributeResult.emotion2 == EMEmotionHappy) {
                self.battleResult = EMBattleResultWin;
            } else if (self.attributeResult.emotion2 == EMEmotionPeaceful) {
                self.battleResult = EMBattleResultDraw;
            } else {
                self.battleResult = EMBattleResultLose;
            }
        }
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5000ull * NSEC_PER_MSEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"FinalResult" sender:nil];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)generateEmotions {
    Mat face1;
    UIImgtoEmoImg(self.targetImage, face1, *self.attributeResult.player1, self.attributeResult.emotion1);
    Mat face2;
    UIImgtoEmoImg(self.targetImage, face2, *self.attributeResult.player2, self.attributeResult.emotion2);
    UIImage *emotionImg1=MatToUIImage(face1);
    UIImage *emotionImg2=MatToUIImage(face2);
    self.emotionView1.image = emotionImg1;
    self.emotionView2.image = emotionImg2;
}
- (NSArray *)animationImagesWithEmotion:(EMEmotion)emotion {
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    NSString * emotionName;
    switch (emotion) {
        case EMEmotionHappy:
            emotionName = @"happy";
            break;
        case EMEmotionAngry:
            emotionName = @"angry";
            break;
        case EMEmotionPanic:
            emotionName = @"panic";
            break;
        case EMEmotionSad:
            emotionName = @"sad";
            break;
        case EMEmotionPeaceful:
            emotionName = @"calm";
            break;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:emotionName ofType:@"bundle"];
    NSArray *arrays = [fileMgr contentsOfDirectoryAtPath:path error:nil];
    NSMutableArray *imagesArr = [NSMutableArray array];
    for (NSString *name in arrays) {
        UIImage *image = [UIImage imageNamed:[[emotionName stringByAppendingString:@".bundle"] stringByAppendingPathComponent:name]];
        if (image) {
            [imagesArr addObject:image];
        }
    }
    return imagesArr;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FinalResult"]) {
        UIViewController * vc = segue.destinationViewController;
        [vc setValue:[NSNumber numberWithInteger:self.battleResult] forKey:@"result"];
        [vc setValue:self.emotionView1.image forKey:@"image1"];
        [vc setValue:self.emotionView2.image forKey:@"image2"];
        [[EMEmotionProcessor sharedProcessor] endWithProcess];
    }
}


/*
void UIImgtoEmoImg(UIImage *photo,Mat &output,cv_face_t face,int emotion){
    Mat img;
    UIImageToMat(photo, img);
    int x=face.rect.left;
    int y=face.rect.top;
    int width=face.rect.right-face.rect.left;
    int height=face.rect.bottom-face.rect.top;
    Mat roi_face=img(cv::Rect(x,y,width,height));
    Mat gray_face;
    cvtColor(roi_face, gray_face, CV_RGB2GRAY);
    Mat mask(cv::Size(gray_face.cols,gray_face.rows),CV_8U,cv::Scalar(255));
    int thresh=30;
    int flag=0;
    for(int i=0;i<gray_face.rows;i++){
        for(int j=0;j<gray_face.cols;j++){
            for(int k=0;k<106;k++){
                if(sqrt(pow(abs(i-(face.points_array[k].y-y)),2)+pow(abs(j-(face.points_array[k].x-x)),2))<thresh){
                    flag=1;
                    break;
                }
            }
            if(flag){
                flag=0;
                continue;
            }
            gray_face.at<uchar>(i,j)=255;
            mask.at<uchar>(i,j)=0;
        }
    }
    Mat rgb_face;
    cvtColor(gray_face, rgb_face, CV_GRAY2BGRA);
    clock_t time=clock();
    int id;
    if(emotion==0){
        id=time%2;
    }
    else if(emotion==1){
        id=2+time%2;
    }
    else if(emotion==2){
        id=4+time%3;
    }
    else if(emotion==3){
        id=7+time%3;
    }
    else{
        id=10;
    }
    Bgd bgdimg=bgd[id];
    int newheight=bgdimg.newheight;
    int newwidth=bgdimg.newwidth;
    int x_blank=bgdimg.x_blank;
    int y_blank=bgdimg.y_blank;
    NSString *name=[NSString stringWithCString:bgdimg.name encoding:NSASCIIStringEncoding];
    UIImage *ui_blank=[UIImage imageNamed:name];
    Mat blank;
    UIImageToMat(ui_blank, blank);
    cvtColor(blank, blank, CV_RGB2RGBA);
    resize(rgb_face, rgb_face, cv::Size(newwidth,newheight));
    for(int i=0;i<rgb_face.rows;i++){
        for(int j=0;j<rgb_face.cols;j++){
            if(mask.at<uchar>(i,j)==255)
                blank.at<Vec4b>(i+y_blank,j+x_blank)=rgb_face.at<Vec4b>(i,j);
        }
    }
    output=blank;
}*/
/*
void UIImgtoEmoImg(UIImage *photo,Mat &Emoimg,cv_face_t face,int emotion){
    int x=face.rect.left;
    int y=face.rect.top;
    int width=face.rect.right-face.rect.left;
    int height=face.rect.bottom-face.rect.top;
    clock_t time=clock();
    int id;
    /*
    if(emotion==0){
        id=time%2;
    }
    else if(emotion==1){
        id=2+time%2;
    }
    else if(emotion==2){
        id=4+time%3;
    }
    else if(emotion==3){
        id=7+time%3;
    }
    else{
        id=10;
    }*//*
    id=time%8;
    Bgd bgdimg=bgd[id];
    Mat img;
    UIImageToMat(photo, img);
    int newheight=bgdimg.newheight;
    int newwidth=bgdimg.newwidth;
    int x_blank=bgdimg.x_blank;
    int y_blank=bgdimg.y_blank;
    NSString *name=[NSString stringWithCString:bgdimg.name encoding:NSASCIIStringEncoding];
    UIImage *ui_blank=[UIImage imageNamed:name];
    Mat blank;
    UIImageToMat(ui_blank, blank);
    Mat output;
    blank.copyTo(output);
    Mat mask(cv::Size(newwidth,newheight),CV_8U,Scalar(0));
    circle(mask, cv::Point(newwidth/2,newwidth/2), newheight/2, Scalar(255),-1);
    Mat roi=img(cv::Rect(x,y,width,height));
    Mat iface;
    resize(roi, iface, cv::Size(newwidth,newheight));
    Mat grey;
    cvtColor(iface, grey, CV_RGB2GRAY);
    GaussianBlur(grey, grey, cv::Size(5,5), 0);
    normalize(grey, grey, 0, 255,NORM_MINMAX);
    grey.convertTo(grey, -1,2,0);
    normalize(grey, grey, 0, 255,NORM_MINMAX);
    equalizeHist(grey, grey);
    grey.convertTo(grey, -1,2,30);
    grey=grey&mask;
    int x_center=newwidth/2;
    int y_center=newheight/2;
    int radius=newheight/2;
    for(int i=0;i<grey.rows;i++){
        for(int j=0;j<grey.cols;j++){
            if(mask.at<uchar>(i,j)==255){
                double dist=sqrt(pow(abs(j-x_center), 2)+pow(abs(i-y_center),2));
                if(dist<=radius&&dist>radius-1){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+100,255);
                }
                else if(dist<=radius-1&&dist>radius-2){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+90,255);
                }
                else if(dist<=radius-2&&dist>radius-3){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+80,255);
                }
                else if(dist<=radius-3&&dist>radius-4){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+70,255);
                }
                else if(dist<=radius-4&&dist>radius-5){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+60,255);
                }
                else if(dist<=radius-5&&dist>radius-6){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+40,255);
                }
                else if(dist<=radius-6&&dist>radius-7){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+20,255);
                }
                else if(dist<=radius-7&&dist>radius-8){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+10,255);
                }
            }
        }
    }
    cvtColor(grey, grey, CV_GRAY2BGRA);
    for(int i=0;i<grey.rows;i++){
        for(int j=0;j<grey.cols;j++){
            output.at<Vec4b>(y_blank+i,x_blank+j)=grey.at<Vec4b>(i,j);
        }
    }
    
    for(int i=0;i<mask.rows;i++){
        for(int j=0;j<mask.cols;j++){
            if(mask.at<uchar>(i,j)==0){
                output.at<Vec4b>(y_blank+i,x_blank+j)=blank.at<Vec4b>(y_blank+i,x_blank+j);
            }
        }
    }
    Emoimg=output;
}*/
void UIImgtoEmoImg(UIImage *photo,Mat &Emoimg,cv_face_t iface,int emotion){
    int x=iface.rect.left;
    int y=iface.rect.top;
    int width=iface.rect.right-iface.rect.left;
    int height=iface.rect.bottom-iface.rect.top;
    x+=10;
    y+=10;
    width-=10;
    height-=10;
    clock_t time=clock();
    int id;
    
    if(emotion==0){
        id=time%3;
    }
    else if(emotion==1){
        id=3+time%4;
    }
    else if(emotion==2){
        id=7+time%5;
    }
    else if(emotion==3){
        id=12+time%2;
    }
    else{
        id=14;
    }
    Bgd bgdimg=bgd[id];
    Mat img;
    UIImageToMat(photo, img);
    int newheight=bgdimg.newheight;
    int newwidth=bgdimg.newwidth;
    int x_blank=bgdimg.x_blank;
    int y_blank=bgdimg.y_blank;
    NSString *name=[NSString stringWithCString:bgdimg.name encoding:NSASCIIStringEncoding];
    UIImage *ui_blank=[UIImage imageNamed:name];
    Mat blank;
    UIImageToMat(ui_blank, blank);
    Mat output;
    blank.copyTo(output);
    Mat mask(cv::Size(newwidth,newheight),CV_8U,Scalar(0));
    circle(mask, cv::Point(newwidth/2,newwidth/2), newheight/2, Scalar(255),-1);
    Mat roi=img(cv::Rect(x,y,width,height));
    Mat face;
    resize(roi, face, cv::Size(newwidth,newheight));
    Mat grey;
    cvtColor(face, grey, CV_RGB2GRAY);
    GaussianBlur(grey, grey, cv::Size(5,5), 0);
    normalize(grey, grey, 0, 255,NORM_MINMAX);
    grey.convertTo(grey, -1,2,0);
    normalize(grey, grey, 0, 255,NORM_MINMAX);
    equalizeHist(grey, grey);
    grey.convertTo(grey, -1,2,30);
    grey=grey&mask;
    int x_center=newwidth/2;
    int y_center=newheight/2;
    int radius=newheight/2;
    for(int i=0;i<grey.rows;i++){
        for(int j=0;j<grey.cols;j++){
            if(mask.at<uchar>(i,j)==255){
                double dist=sqrt(pow(abs(j-x_center), 2)+pow(abs(i-y_center),2));
                if(dist<=radius&&dist>radius-1){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+150,255);
                }
                else if(dist<=radius-1&&dist>radius-2){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+130,255);
                }
                else if(dist<=radius-2&&dist>radius-3){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+110,255);
                }
                else if(dist<=radius-3&&dist>radius-4){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+90,255);
                }
                else if(dist<=radius-4&&dist>radius-5){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+70,255);
                }
                else if(dist<=radius-5&&dist>radius-6){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+50,255);
                }
                else if(dist<=radius-6&&dist>radius-7){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+30,255);
                }
                else if(dist<=radius-7&&dist>radius-8){
                    grey.at<uchar>(i,j)=min(grey.at<uchar>(i,j)+10,255);
                }
            }
        }
    }
    cvtColor(grey, grey, CV_GRAY2BGRA);
    for(int i=0;i<grey.rows;i++){
        for(int j=0;j<grey.cols;j++){
            output.at<Vec4b>(y_blank+i,x_blank+j)=grey.at<Vec4b>(i,j);
        }
    }
    
    for(int i=0;i<mask.rows;i++){
        for(int j=0;j<mask.cols;j++){
            if(mask.at<uchar>(i,j)==0){
                output.at<Vec4b>(y_blank+i,x_blank+j)=blank.at<Vec4b>(y_blank+i,x_blank+j);
            }
        }
    }
    Emoimg=output;
}


@end
