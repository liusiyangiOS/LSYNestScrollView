//
//  MainViewController.h
//  LSYNestScrollView
//
//  Created by liusiyang on 2025/2/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NestViewControllerType) {
    /** 一般用法示例 */
    NestViewControllerTypeNormal  = 0,
    /** 复杂用法示例 */
    NestViewControllerTypeComplex = 1
};

@interface NestViewController : UIViewController

- (instancetype)initWithType:(NestViewControllerType)type;

@end

NS_ASSUME_NONNULL_END
