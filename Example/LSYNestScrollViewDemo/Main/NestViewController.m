//
//  MainViewController.m
//  LSYNestScrollView
//
//  Created by liusiyang on 2025/2/6.
//

#import "NestViewController.h"
#import <Masonry/Masonry.h>
#import "BaseScrollView.h"
#import "NormalContentView.h"
#import "ComplexContentView.h"
#import "UIScrollView+LSYNest.h"

#define STATUSBAR_HEIGHT \
({ CGFloat topHeight = 20.0f;\
if (@available(iOS 11.0, *)) {\
UIWindow *window = [[UIApplication sharedApplication] delegate].window;\
topHeight = window.safeAreaInsets.top;\
}\
(topHeight);})

/**
 正常来讲这个key应该尽量保证每个场景不一样
 如果情况复杂,可能同一个场景的不同实例也需要不同的key(比如同事存在同一种场景的两个不同实例,就得区分)
 同一个场景同事存在多个实例的情况,可以考虑将mainScrollView的实例地址作为key
 本例比较简单,就直接用相同的key了
 */
static NSString * const kNormalNestKey = @"Example";

@interface NestViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    NestViewControllerType _type;
}

@end

@implementation NestViewController

- (instancetype)initWithType:(NestViewControllerType)type{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _scrollView = [[BaseScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.directionalLockEnabled = YES;
    CGFloat imageHeight = UIScreen.mainScreen.bounds.size.width * 75 / 120;
    //第一步,设置mainScrollView
    [_scrollView lsyNest_registerAsMainWithDelegate:self maxOffsetY:imageHeight forKey:kNormalNestKey];
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
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.width.equalTo(_scrollView);
        make.height.equalTo(@(imageHeight));
    }];
    
    UIView *mainV = nil;
    if (_type == NestViewControllerTypeComplex) {
        mainV = [[ComplexContentView alloc] initWithKey:kNormalNestKey];
    }else{
        mainV = [[NormalContentView alloc] initWithIndex:-1 key:kNormalNestKey];
    }
    [_scrollView addSubview:mainV];
    [mainV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.width.bottom.equalTo(_scrollView);
        make.top.equalTo(imageView.mas_bottom);
        make.height.equalTo(self.view);
    }];
}

@end
