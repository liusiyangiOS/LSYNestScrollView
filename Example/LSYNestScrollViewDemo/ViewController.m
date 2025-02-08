//
//  ViewController.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/6.
//

#import "ViewController.h"
#import "MainViewController.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"跳转" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(jumpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)jumpButtonClicked:(UIButton *)sender {
    MainViewController *mainVC = [[MainViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:YES];
}

@end
