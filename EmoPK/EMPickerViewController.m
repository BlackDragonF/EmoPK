//
//  EMPickerViewController.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/6.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMPickerViewController.h"

@interface EMPickerViewController ()
@property (weak, readwrite, nonatomic) IBOutlet UIView * matchView;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * backButton;
@end

@implementation EMPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.matchView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"matchView"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
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
