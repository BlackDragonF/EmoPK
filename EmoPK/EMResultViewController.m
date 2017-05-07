//
//  EMResultViewController.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/6.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMResultViewController.h"

#import "EMCaptureResultViewController.h"
#import <SVProgressHUD.h>

@interface EMResultViewController ()
@property (strong, readwrite, nonatomic) UIImage * image1;
@property (strong, readwrite, nonatomic) UIImage * image2;
@property (strong, readwrite, nonatomic) NSNumber * result;

@property (weak, readwrite, nonatomic) IBOutlet UIView * resultView;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * backButton;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * againButton;
@property (weak, readwrite, nonatomic) IBOutlet UILabel * resultLabel;

@property (weak, readwrite, nonatomic) IBOutlet UIImageView * emotionView1;
@property (weak, readwrite, nonatomic) IBOutlet UIImageView * emotionView2;
@end

@implementation EMResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"resultView"]];
    EMBattleResult battleResult = [self.result integerValue];
    if (battleResult == EMBattleResultWin) {
        self.resultLabel.text = @"玩家1获胜";
    } else if (battleResult == EMBattleResultLose) {
        self.resultLabel.text = @"玩家2获胜";
    } else {
        self.resultLabel.text = @"平局";
    }
    self.emotionView1.image = self.image1;
    self.emotionView2.image = self.image2;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissPoppingUpView {
    self.resultView.hidden = YES;
}

- (IBAction)saveEmotionsToAlbum {
    UIImageWriteToSavedPhotosAlbum(self.image1, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    UIImageWriteToSavedPhotosAlbum(self.image2, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD showInfoWithStatus:@"已保存表情包至相册"];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
