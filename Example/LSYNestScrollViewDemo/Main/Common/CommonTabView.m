//
//  CommonTabView.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "CommonTabView.h"
#import <Masonry/Masonry.h>

#define kButtonTagOrigin 'bTag'

@implementation CommonTabView{
    UIView *_indicator;
}

- (instancetype)initWithTitles:(NSArray <NSString *>*)titles
{
    self = [super init];
    if (self) {
        if (![titles isKindOfClass:NSArray.class]) {
            return self;
        }
        UIView *preView = nil;
        for (int i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            if (![title isKindOfClass:NSString.class]) {
                return self;
            }
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = kButtonTagOrigin + i;
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            [button setTitleColor:UIColor.greenColor forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self);
                if (preView) {
                    make.leading.equalTo(preView.mas_trailing);
                    make.width.equalTo(preView);
                }else{
                    make.leading.equalTo(self);
                }
                if (i == titles.count - 1) {
                    make.trailing.equalTo(self);
                }
            }];
            preView = button;
            
            if (i == 0) {
                button.selected = YES;
                _indicator = [[UIView alloc] init];
                _indicator.backgroundColor = [UIColor greenColor];
                [self addSubview:_indicator];
                [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self);
                    make.height.equalTo(@3);
                    make.centerX.equalTo(button);
                    make.width.equalTo(button);
                }];
            }
        }
    }
    return self;
}

#pragma mark - action method

- (void)buttonClicked:(UIButton *)sender{
    self.index = sender.tag - kButtonTagOrigin;
    if (_selectedChangedAction) {
        self.selectedChangedAction(_index);
    }
}

#pragma mark - setter & getter

-(void)setIndex:(NSInteger)index{
    if (_index != index) {
        UIButton *button = [self viewWithTag:kButtonTagOrigin + _index];
        button.selected = NO;
        button = [self viewWithTag:kButtonTagOrigin + index];
        if (!button) {
            return;
        }
        button.selected = YES;
        [_indicator mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.height.equalTo(@3);
            make.centerX.equalTo(button);
            make.width.equalTo(button);
        }];
        
        _index = index;
    }
}

@end
