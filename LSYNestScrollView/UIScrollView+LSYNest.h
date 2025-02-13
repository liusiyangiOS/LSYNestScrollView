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
 将ScrollView注册为嵌套模式的主ScrollView(最外层的)
 @param delegate ScrollView的delegate
 @param maxOffsetY mainScrollView可以滑动的最大的offsetY,也就是顶部banner位置的高度
 @param key 嵌套ScrollView体系的key,会将相同的key的ScrollView进行关联
 */
- (void)lsyNest_registerAsMainWithDelegate:(id<UIScrollViewDelegate>)delegate maxOffsetY:(CGFloat)maxOffsetY forKey:(NSString *)key;

/**
 将ScrollView注册为嵌套模式的子ScrollView(内部的),根据添加顺序自动设置index
 @param delegate ScrollView的delegate
 @param key 嵌套ScrollView体系的key,会将相同的key的ScrollView进行关联
 */
- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key;

/** 将index对应的ScrollView设置为active,即与main联动的状态(默认与第一个注册的联动) */
+ (void)lsyNest_setActiveIndex:(NSInteger)index forKey:(NSString *)key;

#pragma mark - 一般用不上,但还是提供下

/**
 滑动手势是否与其他的ScrollView的滑动手势同时识别
 默认NO,innnerScrollView会在注册的时候设置为YES,main和inner的这个属性[请不要改],改了会出问题
 其他ScrollView,使用者可根据自己的需要进行设置,如果设置成YES,则该ScrollView的滑动手势会与main和inner一起识别
 很少会有这样的需求,所以[一般用不上]
 */
@property (nonatomic, assign) BOOL lsyNest_recognizeSimultaneouslyForPan;

/**
 将ScrollView注册为嵌套模式的子ScrollView(内部的)
 [一般用不上]
 增加了index参数,可自由设置,index不要求连贯,可以根据使用者需要随意指定,以满足特殊需求
 @param delegate ScrollView的delegate
 @param index 指定ScrollView所在位置的索引,遇到复杂业务逻辑的时候可能会用的上,若小于0,则根据添加顺序自动设置index
 @param key 嵌套ScrollView体系的key,会将相同的key的ScrollView进行关联
 */
- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate ofIndex:(NSInteger)index forKey:(NSString *)key;

/** 将自己设置为active,因为有更简单的设置方法了,所以[一般用不上] */
- (void)lsyNest_setActive;

/** 更新maxOffsetY(如果需要的话),因为这个值一旦设置了,很少有需求需要修改,所以[一般用不上] */
- (void)lsyNest_updateMainScrollViewMaxOffsetY:(CGFloat)maxOffsetY;

/** 更新maxOffsetY(如果需要的话),同上,很少有需求要更新这个,[一般用不上] */
+ (void)lsyNest_updateMainScrollViewMaxOffsetY:(CGFloat)maxOffsetY forKey:(NSString *)key;

/**
 移除key对应的嵌套结构
 因为内部会在所有相关ScrollView全部释放后[自动移除],使用者不需要关心移除问题,所以[一般用不上]
 如果使用者有特殊需求,需要在自动移除之前手动移除,则可以调用此方法
 */
+ (void)lsyNest_removeStructureForKey:(NSString *)key;

#pragma mark - 临时方法

-(void)lsyNest_didScroll;

@end

NS_ASSUME_NONNULL_END
