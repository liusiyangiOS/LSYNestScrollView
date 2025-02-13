//
//  MainContentView.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "NormalContentView.h"
#import "CommonTabView.h"
#import <Masonry/Masonry.h>
#import "Page1View.h"
#import "Page2View.h"
#import "UIScrollView+LSYNest.h"

#define kPageViewTagOrigin 'page'

@interface NormalContentView ()<UIScrollViewDelegate>{
    CommonTabView *_tabView;
    NSInteger _index;
}
@property (nonatomic, copy) NSString *key;
@end

@implementation NormalContentView

- (instancetype)initWithIndex:(NSInteger)index key:(nonnull NSString *)key{
    self = [super init];
    if (self) {
        //复杂使用方法示例
        _index = index;
        _key = key;
        [self configUI];
    }
    return self;
}

- (void)configUI{
    NSArray *titles = @[@"附近",@"我关注的"];
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
    
    NSArray *pageClassArray = @[@"Page1View",@"Page2View"];
    for (int i = 0; i < pageClassArray.count; i++) {
        NSInteger index = -1;
        if (_index >= 0) {
            //复杂使用场景,需要自定义index
            index = [self realIndexOfIndex:i];
        }
        UIView *pageView = [NSClassFromString(pageClassArray[i]) alloc];
        if ([pageView conformsToProtocol:@protocol(NestPageProtocol)]) {
            pageView = (UIView *)[(id<NestPageProtocol>)pageView initWithIndex:index key:_key];
        }
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
        //第三步,切换的时候,更新active的ScrollView
        [UIScrollView lsyNest_setActiveIndex:[weakSelf realIndexOfIndex:index] forKey:weakSelf.key];
    };
}

- (NSInteger)realIndexOfIndex:(NSInteger)index{
    if (_index < 0) {
        return index;
    }
    //随便怎么给都行,只要在原来的_index位置拓展子index就行
    return (_index + 1) * 10000 + index;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _tabView.index = scrollView.contentOffset.x / UIScreen.mainScreen.bounds.size.width;
    //第三步,切换的时候,更新active的ScrollView
    [UIScrollView lsyNest_setActiveIndex:[self realIndexOfIndex:_tabView.index] forKey:_key];
}

@end
