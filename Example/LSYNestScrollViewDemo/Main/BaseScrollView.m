//
//  BaseScrollView.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "BaseScrollView.h"

@implementation BaseScrollView

/**
 同时识别多个手势

 @param gestureRecognizer gestureRecognizer description
 @param otherGestureRecognizer otherGestureRecognizer description
 @return return value description
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //todo 测滑返回手势，不用同时识别
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        && [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
        //todo 增加个属性,可直接控制scrollView是否透传事件
//        if ([scrollView isKindOfClass:[ZPLiveBroadcastListHorizontalCollectionView class]]) {
//            return NO;//不往下透传事件
//        }
//        // 解决scrollView横向滚动不能与其他scrollView纵向滚动互斥的问题
//        if (fabs(scrollView.contentOffset.x) > 0 && fabs(scrollView.contentOffset.y) == 0) {
//            // 横向滚动
//            return NO;
//        }
        return YES;
    }
    return NO;
}

@end
