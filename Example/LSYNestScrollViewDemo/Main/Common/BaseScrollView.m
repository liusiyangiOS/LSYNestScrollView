//
//  BaseScrollView.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "BaseScrollView.h"
#import "UIScrollView+LSYNest.h"

@implementation BaseScrollView

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    //只有mainScrollView才响应此方法
//    //todo 测滑返回手势，不用同时识别
//    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
//        && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
//        UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
//        return scrollView.lsyNest_recognizeSimultaneouslyForPan;
//    }
//    return NO;
//}

@end
