//
//  ViewController.m
//  CellLeftSlip
//
//  Created by JiangDong Zhang on 2017/7/26.
//  Copyright © 2017年 JiangDong Zhang. All rights reserved.
//

#import "ViewController.h"
#import "JDLeftSlipCell.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,JDLeftSlipCellDelegate>

@property(nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController

#define kScreenWidth        ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight       ([[UIScreen mainScreen] bounds].size.height)

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[JDLeftSlipCell class] forCellReuseIdentifier:NSStringFromClass([JDLeftSlipCell class])];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JDLeftSlipCell *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JDLeftSlipCell class]) forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - LYSideslipCellDelegate
- (NSArray<JDLeftSlipCellAction *> *)sideslipCell:(JDLeftSlipCell *)sideslipCell editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JDLeftSlipCellAction *tagAction = [JDLeftSlipCellAction rowActionWithStyle:JDLeftSlipCellActionStyleNormal title:nil handler:^(JDLeftSlipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击的打标签按钮, %@",indexPath);
        [sideslipCell hiddenAllSideslip];
    }];
    tagAction.backgroundColor = [UIColor lightGrayColor];
    tagAction.image = [UIImage imageNamed:@"Fav_Edit_Tag"];
    
    JDLeftSlipCellAction *deleteAction = [JDLeftSlipCellAction rowActionWithStyle:JDLeftSlipCellActionStyleNormal title:nil handler:^(JDLeftSlipCellAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"%@,点击的删除按钮",indexPath);
        [sideslipCell hiddenAllSideslip];
    }];
    deleteAction.backgroundColor = [UIColor lightGrayColor];
    deleteAction.image = [UIImage imageNamed:@"Fav_Edit_Delete"];

    return @[tagAction, deleteAction];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.tableView hiddenAllSideslip];
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}



@end
