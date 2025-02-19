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
/** mainScrollView可以滑动的最大的offsetY,也就是顶部banner位置的高度 */
@property (nonatomic, assign) CGFloat maxOffsetY;

@property (nonatomic, strong, readonly) NSMapTable *innerScrollViews;
/** 当前联动的ScrollView */
@property (nonatomic, weak) UIScrollView *activeScrollView;
@end

@implementation LSYScrollViewNestStructure{
    NSString *_key;
}

- (void)dealloc
{
    [UIScrollView lsyNest_removeStructureForKey:_key];
}

- (instancetype)initWithKey:(NSString *)key{
    self = [super init];
    if (self) {
        _key = key;
        _innerScrollViews = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

@end

@interface LSYScrollViewNestParam : NSObject

@property (nonatomic, copy) NSString *key;
/** 每个相关ScrollView都强持有structure,全局字典弱持有 */
@property (nonatomic, strong) LSYScrollViewNestStructure *structure;

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

//+(void)load{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        <#code to be executed once#>
//    });
//}

- (void)lsyNest_registerAsMainWithDelegate:(id<UIScrollViewDelegate>)delegate maxOffsetY:(CGFloat)maxOffsetY forKey:(NSString *)key{
    [self lsyNest_hockScrollViewDidScrollIfNeed:delegate];
    LSYScrollViewNestStructure *structure = [UIScrollView lsyNest_structureForKey:key];
    structure.mainScrollView = self;
    structure.maxOffsetY = maxOffsetY;
    LSYScrollViewNestParam *param = [self lsyNest_param];
    param.key = key;
    param.isMainScrollView = YES;
    param.shouldScroll = YES;
    param.structure = structure;
}

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key{
    [self lsyNest_registerAsInnerWithDelegate:delegate ofIndex:-1 forKey:key];
}

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate ofIndex:(NSInteger)index forKey:(NSString *)key{
    [self lsyNest_hockScrollViewDidScrollIfNeed:delegate];
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
    param.structure = structure;
}

+ (void)lsyNest_setActiveIndex:(NSInteger)index forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:key];
    if (!structure) {
        return;
    }
    UIScrollView *scrollView = [structure.innerScrollViews objectForKey:@(index)];
    if (!scrollView) {
        return;
    }
    structure.activeScrollView = scrollView;
    if (structure.mainScrollView.contentOffset.y < structure.maxOffsetY) {
        scrollView.contentOffset = CGPointZero;
        [scrollView lsyNest_param].shouldScroll = NO;
    }
}

#pragma mark - 一般用不上

- (void)lsyNest_setActive{
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:[self lsyNest_param].key];
    if (!structure) {
        return;
    }
    structure.activeScrollView = self;
    if (structure.mainScrollView.contentOffset.y < structure.maxOffsetY) {
        self.contentOffset = CGPointZero;
        [self lsyNest_param].shouldScroll = NO;
    }
}

- (void)lsyNest_updateMainScrollViewMaxOffsetY:(CGFloat)maxOffsetY{
    [UIScrollView lsyNest_updateMainScrollViewMaxOffsetY:maxOffsetY forKey:[self lsyNest_param].key];
}

+ (void)lsyNest_updateMainScrollViewMaxOffsetY:(CGFloat)maxOffsetY forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:key];
    if (structure) {
        structure.maxOffsetY = maxOffsetY;
    }
}

+ (void)lsyNest_removeStructureForKey:(NSString *)key{
    [[self lsyNest_structureMap] removeObjectForKey:key];
}

#pragma mark - private method

/** hock UIScrollView代理的ScrollViewDidScroll方法,增加需要的内容 */
- (void)lsyNest_hockScrollViewDidScrollIfNeed:(id<UIScrollViewDelegate>)delegate{
    self.delegate = delegate;
    Class delegateClass = delegate.class;
    if ([[UIScrollView lsyNest_hockClassSet] containsObject:delegateClass]) {
        //已经hock过了
        return;
    }
    [[UIScrollView lsyNest_hockClassSet] addObject:delegateClass];
    
    SEL swizzledSelector = @selector(lsyNest_scrollViewDidScroll:);
    if (class_getInstanceMethod(delegateClass, swizzledSelector)) {
        //已有该方法,说明已经swizzl过了
        return;
    }
    //给delegate添加swizzl方法
    Method addedMethod = class_getInstanceMethod(self.class, swizzledSelector);
    class_addMethod(delegateClass, swizzledSelector, method_getImplementation(addedMethod), method_getTypeEncoding(addedMethod));
    
    SEL originalSelector = @selector(scrollViewDidScroll:);
    Method originalMethod = class_getInstanceMethod(delegateClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(delegateClass, swizzledSelector);
    
    BOOL noOriginMethod = class_addMethod(delegateClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (noOriginMethod){
        //没有origin方法,直接添加swizzl方法
        class_replaceMethod(delegateClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

-(void)lsyNest_scrollViewDidScroll:(UIScrollView *)scrollView{
    [self lsyNest_scrollViewDidScroll:scrollView];
    LSYScrollViewNestParam *currentParam = [scrollView lsyNest_param];
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:currentParam.key];
    if (!structure) {
        return;
    }
    if (currentParam.isMainScrollView) {
        LSYScrollViewNestParam *activeParam = [structure.activeScrollView lsyNest_param];
        //todo 增加个状态,发送个通知
        if (activeParam.shouldScroll) {
            scrollView.contentOffset = CGPointMake(0, structure.maxOffsetY);
        }else if (scrollView.contentOffset.y >= structure.maxOffsetY) {
            scrollView.contentOffset = CGPointMake(0, structure.maxOffsetY);
            activeParam.shouldScroll = YES;
        }
        return;
    }
    if (!currentParam.shouldScroll) {
        scrollView.contentOffset = CGPointZero;
    }else if (scrollView.contentOffset.y <= 0) {
        scrollView.contentOffset = CGPointZero;
        currentParam.shouldScroll = NO;
    }
}

#pragma mark - setter & getter

+ (NSMapTable *)lsyNest_structureMap{
    static NSMapTable *lsyNest_structureMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lsyNest_structureMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return lsyNest_structureMap;
}

+ (NSMutableSet *)lsyNest_hockClassSet{
    static NSMutableSet *lsyNest_hockClassSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lsyNest_hockClassSet = [NSMutableSet set];
    });
    return lsyNest_hockClassSet;
}

+ (LSYScrollViewNestStructure *)lsyNest_structureForKey:(NSString *)key{
    if (!key || ![key isKindOfClass:NSString.class]) {
        return nil;
    }
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:key];
    if (!structure) {
        structure = [[LSYScrollViewNestStructure alloc] initWithKey:key];
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

#pragma mark - 临时方法

-(void)lsyNest_didScroll{
    LSYScrollViewNestParam *currentParam = [self lsyNest_param];
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:currentParam.key];
    if (!structure) {
        return;
    }
    if (currentParam.isMainScrollView) {
        LSYScrollViewNestParam *activeParam = [structure.activeScrollView lsyNest_param];
        //todo 增加个状态,发送个通知
        if (activeParam.shouldScroll) {
//            scrollView.contentOffset = CGPointMake(0, structure.maxOffsetY);
            self.contentOffset = CGPointMake(0, structure.maxOffsetY);
        }else if (self.contentOffset.y >= structure.maxOffsetY) {
            self.contentOffset = CGPointMake(0, structure.maxOffsetY);
            activeParam.shouldScroll = YES;
        }
        return;
    }
    if (!currentParam.shouldScroll) {
//        scrollView.contentOffset = CGPointZero;
        self.contentOffset = CGPointZero;
    }else if (self.contentOffset.y <= 0) {
        self.contentOffset = CGPointZero;
        currentParam.shouldScroll = NO;
    }
}

@end
