//
//  ViewController.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/6.
//

#import "ViewController.h"
#import "NestViewController.h"
#import <Masonry/Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"一般使用方式" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(normalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-50);
    }];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 setTitle:@"复杂使用方式" forState:UIControlStateNormal];
    [button1 setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(complexButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(50);
    }];
}

- (void)normalButtonClicked:(UIButton *)sender {
    NestViewController *mainVC = [[NestViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:YES];
}

- (void)complexButtonClicked:(UIButton *)sender {
    NestViewController *mainVC = [[NestViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:YES];
}

@end
