//
//  MainViewController.m
//  LSYNestScrollView
//
//  Created by liusiyang on 2025/2/6.
//

#import "NormalViewController.h"
#import <Masonry/Masonry.h>
#import "BaseScrollView.h"
#import "NormalContentView.h"
#import "UIScrollView+LSYNest.h"

#define STATUSBAR_HEIGHT \
({ CGFloat topHeight = 20.0f;\
if (@available(iOS 11.0, *)) {\
UIWindow *window = [[UIApplication sharedApplication] delegate].window;\
topHeight = window.safeAreaInsets.top;\
}\
(topHeight);})

static NSString * const kNormalNestKey = @"NormalExample";

@interface NormalViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
}

@end

@implementation NormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _scrollView = [[BaseScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.directionalLockEnabled = YES;
    //第一步,设置mainScrollView
    [_scrollView lsyNest_registerAsMainWithDelegate:self forKey:kNormalNestKey];
    //注册的时候传入代理了,所以就不需要再次设置了
//    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIImage *bgImage = [UIImage imageNamed:@"MainHeaderBg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    [_scrollView addSubview:imageView];
    CGFloat imageHeight = 75.0/120;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.equalTo(_scrollView);
        make.height.equalTo(imageView.mas_width).multipliedBy(imageHeight);
    }];
    
    NormalContentView *mainV = [[NormalContentView alloc] initWithIndex:-1 key:kNormalNestKey];
    [_scrollView addSubview:mainV];
    [mainV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.width.bottom.equalTo(_scrollView);
        make.top.equalTo(imageView.mas_bottom);
        make.height.equalTo(self.view);
    }];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [scrollView lsyNest_didScroll];
}

@end
