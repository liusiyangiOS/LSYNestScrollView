//
//  MainViewController.m
//  LSYNestScrollView
//
//  Created by liusiyang on 2025/2/6.
//

#import "MainViewController.h"
#import <Masonry/Masonry.h>
#import "BaseScrollView.h"
#import "MainContentView.h"

#define STATUSBAR_HEIGHT \
({ CGFloat topHeight = 20.0f;\
if (@available(iOS 11.0, *)) {\
UIWindow *window = [[UIApplication sharedApplication] delegate].window;\
topHeight = window.safeAreaInsets.top;\
}\
(topHeight);})

@interface MainViewController ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _scrollView = [[BaseScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.directionalLockEnabled = YES;
    _scrollView.delegate = self;
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
    
    MainContentView *mainV = [[MainContentView alloc] init];
    [_scrollView addSubview:mainV];
    [mainV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.width.bottom.equalTo(_scrollView);
        make.top.equalTo(imageView.mas_bottom);
        make.height.equalTo(self.view);
    }];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGFloat targetOffsetY = self.targetOffsetY;
//    if (self.listView.shouldScroll){
//        scrollView.contentOffset = CGPointMake(0, targetOffsetY);
//        self.headerView.isStopSliding = YES;
//    }else if (scrollView.contentOffset.y >= targetOffsetY) {
//        scrollView.contentOffset = CGPointMake(0, targetOffsetY);
//        self.headerView.isStopSliding = YES;
//        if (self.listView.collectionView.dragging) {
//            self.listView.shouldScroll = YES;
//        }
//    }else {
//        self.headerView.isStopSliding = NO;
//    }
}

@end
