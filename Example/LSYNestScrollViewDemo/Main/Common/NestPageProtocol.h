//
//  NestPageProtocol.h
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NestPageProtocol <NSObject>

- (instancetype)initWithIndex:(NSInteger)index key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
