//
//  CommonTabView.h
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTabView : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) void (^ selectedChangedAction)(NSInteger index);

- (instancetype)initWithTitles:(NSArray <NSString *>*)titles;

@end

NS_ASSUME_NONNULL_END
