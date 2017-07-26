//
//  JDLeftSlipCell.h
//  CellLeftSlip
//
//  Created by JiangDong Zhang on 2017/7/26.
//  Copyright © 2017年 JiangDong Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, JDLeftSlipCellActionStyle) {
    JDLeftSlipCellActionStyleNormal = 0, // 正常 白色
    JDLeftSlipCellActionStyleDestructive = 1 // 删除 红底
};

//cell 右面容器视图属性设置

@interface JDLeftSlipCellAction : NSObject

+ (instancetype)rowActionWithStyle:(JDLeftSlipCellActionStyle)style title:( NSString *)title handler:(void (^)(JDLeftSlipCellAction *action, NSIndexPath *indexPath))handler;
@property (nonatomic, readonly) JDLeftSlipCellActionStyle style;
@property (nonatomic, copy) NSString *title;          // 文字内容
@property (nonatomic, strong) UIImage *image;         // 按钮图片. 默认无图
@property (nonatomic, assign) CGFloat fontSize;                 // 字体大小. 默认17
@property (nonatomic, strong) UIColor *titleColor;    // 文字颜色. 默认白色
@property (nonatomic, copy) UIColor *backgroundColor; // 背景颜色. 默认透明
@property (nonatomic, assign) CGFloat margin;                   // 内容左右间距. 默认0
@property (nonatomic, assign) CGFloat btnW;                   


@end

//-------------代理------------

@class JDLeftSlipCell;
@protocol JDLeftSlipCellDelegate <NSObject>
@optional;
/**
 *  选中了侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *  @param index        选中的是第几个action
 */
- (void)sideslipCell:(JDLeftSlipCell *)sideslipCell rowAtIndexPath:(NSIndexPath *)indexPath didSelectedAtIndex:(NSInteger)index;

/**
 *  告知当前位置的cell是否需要侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *
 *  @return YES 表示当前cell可以侧滑, NO 不可以
 */
- (BOOL)sideslipCell:(JDLeftSlipCell *)sideslipCell canSideslipRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  返回侧滑事件
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *
 *  @return 数组为空, 则没有侧滑事件
 */
- (NSArray<JDLeftSlipCellAction *> *)sideslipCell:(JDLeftSlipCell *)sideslipCell editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

//--------------------------




@interface JDLeftSlipCell : UITableViewCell


@property (nonatomic, weak) id<JDLeftSlipCellDelegate> delegate;

/**
 *  按钮容器
 */
@property (nonatomic, strong) UIView *btnContainView;

/**
 *  隐藏侧滑按钮
 */
- (void)hiddenAllSideslip;
- (void)hiddenSideslip;
@end


@interface UITableView (JDLeftSlipCell)

- (void)hiddenAllSideslip;

@end


