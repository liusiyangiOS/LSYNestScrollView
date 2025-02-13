//
//  ComplexContentView.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/10.
//

#import "ComplexContentView.h"
#import "NormalContentView.h"
#import "UIScrollView+LSYNest.h"
#import "CommonTabView.h"
#import <Masonry/Masonry.h>
#import "Page1View.h"
#import "Page2View.h"

#define kPageViewTagOrigin 'page'

@interface ComplexContentView ()<UIScrollViewDelegate>{
    CommonTabView *_tabView;
}
@property (nonatomic, copy) NSString *key;
@end

@implementation ComplexContentView

- (instancetype)initWithKey:(nonnull NSString *)key{
    self = [super init];
    if (self) {
        //复杂使用方法示例
        _key = key;
        [self configUI];
    }
    return self;
}

- (void)configUI{
    NSArray *titles = @[@"page1",@"嵌套子Tab",@"page2"];
    _tabView = [[CommonTabView alloc] initWithTitles:titles];
    [self addSubview:_tabView];
    [_tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.equalTo(@44);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = UIColor.lightGrayColor;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(_tabView);
        make.height.equalTo(@0.5);
    }];
    
    UIScrollView *scrollView =  [[UIScrollView alloc] init];
    scrollView.directionalLockEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(titles.count * UIScreen.mainScreen.bounds.size.width, 100);
    [self addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(_tabView.mas_bottom);
    }];
    
    NSArray *pageClassArray = @[@"Page1View",@"NormalContentView",@"Page2View"];
    for (int i = 0; i < pageClassArray.count; i++) {
        UIView *pageView = [NSClassFromString(pageClassArray[i]) alloc];
        if ([pageView conformsToProtocol:@protocol(NestPageProtocol)]) {
            pageView = (UIView *)[(id<NestPageProtocol>)pageView initWithIndex:i key:_key];
        }
        pageView.tag = kPageViewTagOrigin + i;
        [scrollView addSubview:pageView];
        [pageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(scrollView);
            make.leading.mas_equalTo(i * UIScreen.mainScreen.bounds.size.width);
            make.width.mas_equalTo(UIScreen.mainScreen.bounds.size.width);
            make.height.equalTo(scrollView);
        }];
    }
    
    __weak typeof(self) weakSelf = self;
    _tabView.selectedChangedAction = ^(NSInteger index) {
        [scrollView setContentOffset:CGPointMake(index * UIScreen.mainScreen.bounds.size.width, 0) animated:YES];
        [weakSelf setActiveIndex:index];
    };
}

- (void)setActiveIndex:(NSInteger)index{
    //第三步,切换的时候,更新active的ScrollView
    UIView *view = [self viewWithTag:kPageViewTagOrigin + index];
    if ([view isKindOfClass:NormalContentView.class]) {
        //NormalContentView需要特殊处理
        [UIScrollView lsyNest_setActiveIndex:[(NormalContentView *)view currentRealIndex] forKey:_key];
    }else{
        [UIScrollView lsyNest_setActiveIndex:index forKey:_key];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _tabView.index = scrollView.contentOffset.x / UIScreen.mainScreen.bounds.size.width;
    [self setActiveIndex:_tabView.index];
}

@end
