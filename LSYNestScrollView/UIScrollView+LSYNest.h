//
//  UIScrollView+LSYNest.h
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (LSYNest)

- (void)lsyNest_registerAsMainWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key;

/**
 自动索引+1
 */
- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key;

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate ofIndex:(NSInteger)index forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
