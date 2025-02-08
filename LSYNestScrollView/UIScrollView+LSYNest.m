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

@end

@implementation LSYScrollViewNestStructure

- (instancetype)init
{
    self = [super init];
    if (self) {
        _innerScrollViews = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

@end

@interface LSYScrollViewNestParam : NSObject

@property (nonatomic, assign) BOOL isMainScrollView;
/** 联动的ScrollView,只有mainScrollView才有值 */
@property (nonatomic, weak) UIScrollView *activeScrollView;
/** 主ScrollView,只有innerScrollView才有值 */
@property (nonatomic, weak) UIScrollView *mainScrollView;

@property (nonatomic, assign) BOOL shouldScroll;

@end

@implementation LSYScrollViewNestParam

@end

@implementation UIScrollView (LSYNest)

- (void)lsyNest_registerAsMainWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:key];
    structure.mainScrollView = self;
    LSYScrollViewNestParam *param = [self lsyNest_param];
    param.isMainScrollView = YES;
    if (structure.innerScrollViews.count) {
        //默认第一个注册的inner与main联动
        [structure.mainScrollView lsyNest_param].activeScrollView = self;
    }
}

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate forKey:(NSString *)key{
    [self lsyNest_registerAsInnerWithDelegate:delegate ofIndex:-1 forKey:key];
}

- (void)lsyNest_registerAsInnerWithDelegate:(id<UIScrollViewDelegate>)delegate ofIndex:(NSInteger)index forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [[UIScrollView lsyNest_structureMap] objectForKey:key];
    if (structure.mainScrollView && !structure.innerScrollViews.count) {
        //默认第一个注册的inner与main联动
        [structure.mainScrollView lsyNest_param].activeScrollView = self;
    }
    if (index < 0) {
        index = structure.innerScrollViews.count;
    }
    [structure.innerScrollViews setObject:self forKey:@(index)];
    LSYScrollViewNestParam *param = [self lsyNest_param];
    param.mainScrollView = structure.mainScrollView;
}

- (void)lsyNest_setActive{
    UIScrollView *mainScrollView = [self lsyNest_param].mainScrollView;
    [mainScrollView lsyNest_param].activeScrollView = self;
}

+ (void)lsyNest_setActiveIndex:(NSInteger)index forKey:(NSString *)key{
    LSYScrollViewNestStructure *structure = [[self lsyNest_structureMap] objectForKey:key];
    UIScrollView *scrollView = [structure.innerScrollViews objectForKey:@(index)];
    [scrollView lsyNest_setActive];
}

+ (void)lsyNest_removeStructureForKey:(NSString *)key{
    [[self lsyNest_structureMap] removeObjectForKey:key];
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

-(LSYScrollViewNestParam *)lsyNest_param{
    LSYScrollViewNestParam *param = objc_getAssociatedObject(self, _cmd);
    if (!param) {
        param = [LSYScrollViewNestParam new];
        objc_setAssociatedObject(self, _cmd, param, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return param;
}

//- (void)setLsyNest_shouldScroll:(BOOL)lsyNest_shouldScroll{
//    
//}
//
//-(BOOL)lsyNest_shouldScroll{
//    
//}

@end
