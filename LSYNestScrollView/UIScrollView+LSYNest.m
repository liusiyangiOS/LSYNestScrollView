//
//  UIScrollView+LSYNest.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "UIScrollView+LSYNest.h"
#import <objc/runtime.h>

@interface LSYScrollViewNestStructure : NSObject

@property (nonatomic, weak) UIScrollView *mainScrollView;

@property (nonatomic, strong, readonly) NSMapTable *innerScrollViews;
/** 当前联动的ScrollView */
@property (nonatomic, weak) UIScrollView *activeScrollView;
@end

@implementation LSYScrollViewNestStructure

- (instancetype)init{
    self = [super init];
    if (self) {
        _innerScrollViews = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

@end

@interface LSYScrollViewNestParam : NSObject

@property (nonatomic, copy) NSString *key;

@property (nonatomic, assign) BOOL isMainScrollView;

@property (nonatomic, assign) BOOL shouldScroll;

/**
 滑动手势是否与其他的ScrollView的滑动手势同时识别
 默认NO,innnerScrollView会在注册的时候设置为YES
 除innnerScrollView之外的,使用者可根据自己的需要进行设置
 */
@property (nonatomic, assign) BOOL recognizeSimultaneouslyForPan;
@end

@implementation LSYScrollViewNestParam

@end

@implementation UIScrollView (LSYNest)

- (void)lsyNest_registerAsMainWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [UIScrollView lsyNest_structureForKey:key];
    structure.mainScrollView = self;
    LSYScrollViewNestParam *param = [self lsyNest_param];
    param.key = key;
    param.isMainScrollView = YES;
    param.shouldScroll = YES;
}

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key{
    [self lsyNest_registerAsInnerWithDelegate:delegate ofIndex:-1 forKey:key];
}

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate ofIndex:(NSInteger)index forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [UIScrollView lsyNest_structureForKey:key];
    if (!structure.innerScrollViews.count) {
        //默认第一个注册的inner与main联动
        structure.activeScrollView = self;
    }
    if (index < 0) {
        index = structure.innerScrollViews.count;
    }
    [structure.innerScrollViews setObject:self forKey:@(index)];
    LSYScrollViewNestParam *param = [self lsyNest_param];
    param.key = key;
    param.recognizeSimultaneouslyForPan = YES;
}

- (void)lsyNest_setActive{
    LSYScrollViewNestStructure *structure = [UIScrollView lsyNest_structureForKey:[self lsyNest_param].key];
    structure.activeScrollView = self;
}

+ (void)lsyNest_setActiveIndex:(NSInteger)index forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [UIScrollView lsyNest_structureForKey:key];
    structure.activeScrollView = [structure.innerScrollViews objectForKey:@(index)];
}

+ (void)lsyNest_removeStructureForKey:(NSString *)key{
    [[self lsyNest_structureMap] removeObjectForKey:key];
}

#pragma mark - 临时方法

-(void)lsyNest_didScroll{
    LSYScrollViewNestParam *currentParam = [self lsyNest_param];
    LSYScrollViewNestStructure *structure = [UIScrollView lsyNest_structureForKey:currentParam.key];
    if (currentParam.isMainScrollView) {
        LSYScrollViewNestParam *activeParam = [structure.activeScrollView lsyNest_param];
        if (activeParam.shouldScroll) {
//            scrollView.contentOffset = CGPointMake(0, targetOffsetY);
            self.contentOffset = CGPointMake(0, targetOffsetY);
        }
        return;
    }
    //    CGFloat targetOffsetY = self.targetOffsetY;
    //    if (self.listView.shouldScroll){
    //        scrollView.contentOffset = CGPointMake(0, targetOffsetY);
    //    }else if (scrollView.contentOffset.y >= targetOffsetY) {
    //        scrollView.contentOffset = CGPointMake(0, targetOffsetY);
    //        self.headerView.isStopSliding = YES;
    //    }else {
    //    }
}

#pragma mark - private method

#pragma mark - setter & getter

+ (NSMutableDictionary *)lsyNest_structureMap{
    static NSMutableDictionary *lsyNest_structureMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lsyNest_structureMap = [NSMutableDictionary dictionary];
    });
    return lsyNest_structureMap;
}

+ (LSYScrollViewNestStructure *)lsyNest_structureForKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:key];
    if (!structure) {
        structure = [LSYScrollViewNestStructure new];
        [[UIScrollView lsyNest_structureMap] setObject:structure forKey:key];
    }
    return structure;
}

-(LSYScrollViewNestParam *)lsyNest_param{
    LSYScrollViewNestParam *param = objc_getAssociatedObject(self, _cmd);
    if (!param) {
        param = [LSYScrollViewNestParam new];
        objc_setAssociatedObject(self, _cmd, param, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return param;
}

-(void)setLsyNest_recognizeSimultaneouslyForPan:(BOOL)lsyNest_recognizeSimultaneouslyForPan{
    [self lsyNest_param].recognizeSimultaneouslyForPan = lsyNest_recognizeSimultaneouslyForPan;
}

-(BOOL)lsyNest_recognizeSimultaneouslyForPan{
    return [self lsyNest_param].recognizeSimultaneouslyForPan;
}

@end
