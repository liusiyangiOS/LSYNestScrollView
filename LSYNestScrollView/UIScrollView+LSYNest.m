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
    [self lsyNest_hookScrollViewDidScrollIfNeed:delegate];
    //先设置代理再hook,如果代理没实现代理方法,增加的代理方法当次不生效,这你敢信???
    //好吧,猜测是因为scrollViewDidScroll:这样的方法调用次数太多了,每次都判断delegate是否实现了该方法比较耗时,所以在设置delegate的时候,直接判断了是否实现了对应的方法,然后将结果存在了本地,不是每次都判断的
    //为了防止外边已经先设置过代理了,导致当次添加方法不生效,先置空才重新添加
    self.delegate = nil;
    self.delegate = delegate;
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
    [self lsyNest_hookScrollViewDidScrollIfNeed:delegate];
    //同上,这里必须要这么写
    self.delegate = nil;
    self.delegate = delegate;
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

/** hook UIScrollView代理的ScrollViewDidScroll方法,增加需要的内容 */
- (void)lsyNest_hookScrollViewDidScrollIfNeed:(id<UIScrollViewDelegate>)delegate{
    Class delegateClass = delegate.class;
    if ([[UIScrollView lsyNest_hookClassSet] containsObject:delegateClass]) {
        //已经hook过了
        return;
    }
    [[UIScrollView lsyNest_hookClassSet] addObject:delegateClass];

    //先给delegate添加swizzl方法,因为delegate里边没有swizzl方法
    SEL swizzledSelector = @selector(lsyNest_scrollViewDidScroll:);
    Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);
    class_addMethod(delegateClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    //然后需要重新获取delegateClass的swizzl方法(之前获取的是self的)
    swizzledMethod = class_getInstanceMethod(delegateClass, swizzledSelector);
    
    SEL originalSelector = @selector(scrollViewDidScroll:);
    Method originalMethod = class_getInstanceMethod(delegateClass, originalSelector);
    if (!originalMethod) {
        //没有originMethod,添加空实现
        void (^ block)(UIScrollView *scrollView) = ^(UIScrollView *scrollView){
            NSLog(@"---默认实现");
        };
        class_addMethod(delegateClass, originalSelector, imp_implementationWithBlock(block), "v@:@");
        //重新获取originalMethod
        originalMethod = class_getInstanceMethod(delegateClass, originalSelector);
        //交换实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
        return;
    }
    
    //这里为什么要先尝试添加方法?因为如果需要swizzl的方法在父类,那么是不可以直接swizzl的,会有问题
    BOOL success = class_addMethod(delegateClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success){
        //如果添加成功了,说明没有实现originalMethod或者在父类,当前类没有覆写,那么直接添加swizzl方法即可
        class_replaceMethod(delegateClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

-(void)lsyNest_scrollViewDidScroll:(UIScrollView *)scrollView{
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
    }else{
        if (!currentParam.shouldScroll) {
            scrollView.contentOffset = CGPointZero;
        }else if (scrollView.contentOffset.y <= 0) {
            scrollView.contentOffset = CGPointZero;
            currentParam.shouldScroll = NO;
        }
    }
    //因为会修改contentOffset,所以最后调用原方法
    [self lsyNest_scrollViewDidScroll:scrollView];
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

+ (NSMutableSet *)lsyNest_hookClassSet{
    static NSMutableSet *lsyNest_hookClassSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lsyNest_hookClassSet = [NSMutableSet set];
    });
    return lsyNest_hookClassSet;
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

@end
