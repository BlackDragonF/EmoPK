//
//  EMListViewController.m
//  EmoPK
//
//  Created by 陈志浩 on 2017/5/5.
//  Copyright © 2017年 BlackDragon. All rights reserved.
//

#import "EMListViewController.h"

@interface EMListViewController ()
@property (weak, readwrite, nonatomic) IBOutlet UIButton * singlePlayerButton;
@property (weak, readwrite, nonatomic) IBOutlet UIButton * twoPlayersButton;
@end

@implementation EMListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)listUnwindSegueToRedViewController:(UIStoryboardSegue *)segue {
    
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
