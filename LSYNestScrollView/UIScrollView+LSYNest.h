//
//  UIScrollView+LSYNest.h
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (LSYNest)

/**
 滑动手势是否与其他的ScrollView的滑动手势同时识别
 默认NO,innnerScrollView会在注册的时候设置为YES,这个属性没特殊需要不用管
 除innnerScrollView之外的,使用者可根据自己的需要进行设置
 */
@property (nonatomic, assign) BOOL lsyNest_recognizeSimultaneouslyForPan;

/**
 将ScrollView注册为嵌套模式的主ScrollView(最外层的)
 @param delegate ScrollView的delegate
 @param key 嵌套ScrollView体系的key,会将相同的key的ScrollView进行关联
 */
- (void)lsyNest_registerAsMainWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key;

/**
 将ScrollView注册为嵌套模式的子ScrollView(内部的),根据添加顺序自动设置index
 @param delegate ScrollView的delegate
 @param key 嵌套ScrollView体系的key,会将相同的key的ScrollView进行关联
 */
- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key;

/**
 将ScrollView注册为嵌套模式的子ScrollView(内部的)
 @param delegate ScrollView的delegate
 @param index 指定ScrollView所在位置的索引,遇到复杂业务逻辑的时候可能会用的上,若小于0,则根据添加顺序自动设置index
 @param key 嵌套ScrollView体系的key,会将相同的key的ScrollView进行关联
 */
- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate ofIndex:(NSInteger)index forKey:(NSString *)key;

/** 将自己设置为active */
- (void)lsyNest_setActive;

/**
 将index对应的ScrollView设置为active,即与main联动的状态(默认与第一个注册的联动)
 */
+ (void)lsyNest_setActiveIndex:(NSInteger)index forKey:(NSString *)key;

/**
 删除key对应的嵌套结构
 */
+ (void)lsyNest_removeStructureForKey:(NSString *)key;



#pragma mark - 临时方法

-(void)lsyNest_didScroll;

@end

NS_ASSUME_NONNULL_END
