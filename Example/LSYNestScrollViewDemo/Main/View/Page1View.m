//
//  Page1View.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/7.
//

#import "Page1View.h"
#import "UIScrollView+LSYNest.h"
#import <Masonry/Masonry.h>

@interface Page1View ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation Page1View

- (instancetype)initWithIndex:(NSInteger)index key:(NSString *)key{
    self = [super init];
    if (self) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        tableView.separatorColor = [UIColor lightGrayColor];
        tableView.dataSource = self;
        //第二步,设置innerScrollView
        if (index < 0) {
            [tableView lsyNest_registerAsInnerWithDelegate:self forKey:key];
        }else{
            //复杂使用方法示例
            [tableView lsyNest_registerAsInnerWithDelegate:self ofIndex:index forKey:key];
        }
        //注册的时候传入代理了,所以就不需要再次设置了
    //    tableView.delegate = self;
        tableView.rowHeight = 100;
        tableView.tableFooterView = [[UIView alloc] init];
        [self addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [tableView reloadData];
    }
    return self;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"title";
    cell.detailTextLabel.text = @"content";
    return cell;
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"------重写不受影响");
    [scrollView lsyNest_didScroll];
}

@end
