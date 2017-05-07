//
//  EMStartViewController.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/5.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMStartViewController.h"

@interface EMStartViewController ()
@property (weak, readwrite, nonatomic) IBOutlet UIButton * startButton;
@property (weak, readwrite, nonatomic) IBOutlet UIImageView * imageView;
@end

@implementation EMStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed:@"main"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
