//
//  Page2View.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "Page2View.h"
#import "UIScrollView+LSYNest.h"
#import <Masonry/Masonry.h>

@interface Page2View ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end

@implementation Page2View

- (instancetype)initWithIndex:(NSInteger)index key:(NSString *)key{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        flowLayout.itemSize = CGSizeMake((UIScreen.mainScreen.bounds.size.width - 30) / 2, 200);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"Cell"];
        collectionView.dataSource = self;
        //第二步,设置innerScrollView
        if (index < 0) {
            [collectionView lsyNest_registerAsInnerWithDelegate:self forKey:key];
        }else{
            //复杂使用方法示例
            [collectionView lsyNest_registerAsInnerWithDelegate:self ofIndex:index forKey:key];
        }
        //注册的时候传入代理了,所以就不需要再次设置了
    //    collectionView.delegate = self;
        [self addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [collectionView reloadData];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 100;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = UIColor.lightGrayColor;
    return cell;
}

@end
