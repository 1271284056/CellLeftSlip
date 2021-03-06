//
//  JDLeftSlipCell.m
//  CellLeftSlip
//
//  Created by JiangDong Zhang on 2017/7/26.
//  Copyright © 2017年 JiangDong Zhang. All rights reserved.
//

#import "JDLeftSlipCell.h"

@interface JDLeftSlipCellAction ()

@property (nonatomic, copy) void (^handler)(JDLeftSlipCellAction *action, NSIndexPath *indexPath);
@property (nonatomic, assign) JDLeftSlipCellActionStyle style;
@end
@implementation JDLeftSlipCellAction

// 初始化 容器按钮属性
+ (instancetype)rowActionWithStyle:(JDLeftSlipCellActionStyle)style title:(NSString *)title handler:(void (^)(JDLeftSlipCellAction *action, NSIndexPath *indexPath))handler {
    JDLeftSlipCellAction *action = [JDLeftSlipCellAction new];
    action.title = title;
    action.handler = handler;
    action.style = style;
    return action;
}

- (CGFloat)margin {
    return _margin == 0 ;
}


@end



// -------JDLeftSlipCell------

// cell的状态
typedef NS_ENUM(NSInteger, JDLeftSlipCellState) {
    LYSideslipCellStateNormal,
    LYSideslipCellStateAnimating,
    LYSideslipCellStateOpen
};

@interface JDLeftSlipCell ()

@property (nonatomic, assign) BOOL sideslip; // 是否有cell侧滑
@property (nonatomic, assign) JDLeftSlipCellState state; // 侧滑状态

@end

@implementation JDLeftSlipCell{
    UITableView *_tableView;
    NSArray <JDLeftSlipCellAction *>* _actions;
    UIPanGestureRecognizer *_panGesture; // cell手势
    UIPanGestureRecognizer *_tableViewPan;  //tableview手势
}





#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupSideslipCell];
        
 
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSideslipCell];
    }
    return self;
}

- (void)setupSideslipCell {
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewPan:)];
    _panGesture.delegate = self;
    [self.contentView addGestureRecognizer:_panGesture];
    self.contentView.backgroundColor = [UIColor yellowColor];
}

- (void)layoutSubviews {
    CGFloat x = 0;
    if (_sideslip) x = self.contentView.frame.origin.x;
    
    [super layoutSubviews];
    
 
    
    // 右边按钮布局 totalWidth cell整体长度
    CGFloat totalWidth = 0;
    for (UIButton *btn in _btnContainView.subviews) {
        btn.frame = CGRectMake(totalWidth, 0, btn.frame.size.width, self.frame.size.height);
        totalWidth += btn.frame.size.width;
    }
    _btnContainView.frame = CGRectMake(self.frame.size.width - totalWidth, 0, totalWidth, self.frame.size.height);
    
    //    NSLog(@"%@,%f",NSStringFromCGRect(self.contentView.frame), self.bounds.size.width),
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (_sideslip) [self hiddenSideslip];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer == _panGesture) {
        
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [gesture translationInView:gesture.view];
        
        // 如果手势相对于水平方向的角度大于45°, 则不触发侧滑
        BOOL shouldBegin = fabs(translation.y) <= fabs(translation.x);
        if (!shouldBegin) return NO;
        
        // 侧滑代理
        if ([_delegate respondsToSelector:@selector(sideslipCell:canSideslipRowAtIndexPath:)]) {
            shouldBegin = [_delegate sideslipCell:self canSideslipRowAtIndexPath:self.indexPath] || _sideslip;
        }
        
        if (shouldBegin) {
            // 向代理获取侧滑展示内容数组
            if ([_delegate respondsToSelector:@selector(sideslipCell:editActionsForRowAtIndexPath:)]) {
                NSArray <JDLeftSlipCellAction*> *actions = [_delegate sideslipCell:self editActionsForRowAtIndexPath:self.indexPath];
                if (!actions || actions.count == 0) return NO;
                [self setActions:actions];
            } else {
                return NO;
            }
        }
        return shouldBegin;
    }
    return YES;
}

#pragma mark - Response Events tableView手势
- (void)tableViewPan:(UIPanGestureRecognizer *)pan {
    if ( pan.state == UIGestureRecognizerStateBegan) {
        [self hiddenAllSideslip];
    }
}

// cell手势开始
- (void)contentViewPan:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan translationInView:pan.view];
    UIGestureRecognizerState state = pan.state;
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if (state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.contentView.frame;
        frame.origin.x += point.x;
        if (frame.origin.x > 15) { //右滑
            frame.origin.x = 15;
        } else if (frame.origin.x < -30 - _btnContainView.frame.size.width) {
            // 左滑 最多可以有30的额度
            frame.origin.x = -30 - _btnContainView.frame.size.width;
        }
        self.contentView.frame = frame;
        
    } else if (state == UIGestureRecognizerStateEnded) {
        
        // velocityInView：在指定坐标系统中pan gesture拖动的速度
        CGPoint velocity = [pan velocityInView:pan.view];
        if (self.contentView.frame.origin.x == 0) {
            return;
        } else if (self.contentView.frame.origin.x > 5) {
            [self hiddenWithBounceAnimation];
        } else if ((self.contentView.frame.origin.x) <= -30 && velocity.x <= 0) {
            // 左滑
            [self showSideslip];
        } else {
            [self hiddenSideslip];
        }
        
    } else if (state == UIGestureRecognizerStateCancelled) {
        [self hiddenAllSideslip];
    }
}

// 点击侧滑按钮
- (void)actionBtnDidClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sideslipCell:rowAtIndexPath:didSelectedAtIndex:)]) {
        [self.delegate sideslipCell:self rowAtIndexPath:self.indexPath didSelectedAtIndex:btn.tag];
    }
    if (btn.tag < _actions.count) {
        JDLeftSlipCellAction *action = _actions[btn.tag];
        if (action.handler) action.handler(action, self.indexPath);
    }
    self.state = LYSideslipCellStateNormal;
}

// 轻点手势
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_sideslip) [self hiddenAllSideslip];
}

#pragma mark - Methods 右滑动画
- (void)hiddenWithBounceAnimation {
    self.state = LYSideslipCellStateAnimating;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:-10];
    } completion:^(BOOL finished) {
        [self hiddenSideslip];
    }];
}

// 隐藏所有侧滑
- (void)hiddenAllSideslip {
    [self.tableView hiddenAllSideslip];
}

//隐藏侧滑
- (void)hiddenSideslip {
    if (self.contentView.frame.origin.x == 0) return;
    
    self.state = LYSideslipCellStateAnimating;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:0];
    } completion:^(BOOL finished) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
        self.state = LYSideslipCellStateNormal;
    }];
}

//显示侧滑
- (void)showSideslip {
    self.state = LYSideslipCellStateAnimating;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:-_btnContainView.frame.size.width];
    } completion:^(BOOL finished) {
        self.state = LYSideslipCellStateOpen;
    }];
}

#pragma mark - Setter
- (void)setContentViewX:(CGFloat)x {
    CGRect frame = self.contentView.frame;
    frame.origin.x = x;
    self.contentView.frame = frame;
}

// 设置侧滑按钮
- (void)setActions:(NSArray <JDLeftSlipCellAction *>*)actions {
    _actions = actions;
    
    if (_btnContainView) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
    }
    
    _btnContainView = [UIView new];
    [self insertSubview:_btnContainView belowSubview:self.contentView];
    
    for (int i = 0; i < actions.count; i++) {
        JDLeftSlipCellAction *action = actions[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.adjustsImageWhenHighlighted = NO;
        
        [btn setTitle:action.title forState:UIControlStateNormal];
        
        if (action.backgroundColor) {
            btn.backgroundColor = action.backgroundColor;
        } else {
            btn.backgroundColor = action.style == JDLeftSlipCellActionStyleNormal? [UIColor whiteColor] : [UIColor redColor];
        }
        
        if (action.image) {
            [btn setImage:action.image forState:UIControlStateNormal];
        }
        
        if (action.fontSize != 0) {
            btn.titleLabel.font = [UIFont systemFontOfSize:action.fontSize];
        }
        
        if (action.titleColor) {
            [btn setTitleColor:action.titleColor forState:UIControlStateNormal];
        }
        
        // 左滑 按钮 的宽度
        
        CGFloat width = [action.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : btn.titleLabel.font} context:nil].size.width;
        width += (action.image ? action.image.size.width : 0);
        btn.frame = CGRectMake(0, 0, width + action.margin*2, self.frame.size.height);

        
        
        btn.tag = i;
        [btn addTarget:self action:@selector(actionBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainView addSubview:btn];
    }
}

- (void)setState:(JDLeftSlipCellState)state {
    _state = state;
    
    if (state == LYSideslipCellStateNormal) {
        self.tableView.allowsSelection = YES;
        for (JDLeftSlipCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:JDLeftSlipCell.class]) {
                cell.sideslip = NO;
            }
        }
        
    } else if (state == LYSideslipCellStateAnimating) {
        
    } else if (state == LYSideslipCellStateOpen) {
        self.tableView.allowsSelection = NO;
        for (JDLeftSlipCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:JDLeftSlipCell.class]) {
                cell.sideslip = YES;
            }
        }
    }
}

#pragma mark - Getter

// tableView
- (UITableView *)tableView {
    if (!_tableView) {
        id view = self.superview;
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        _tableView = (UITableView *)view;
    }
    return _tableView;
}

- (NSIndexPath *)indexPath {
    return [self.tableView indexPathForCell:self];
}
@end


@implementation UITableView (JDLeftSlipCell)
- (void)hiddenAllSideslip {
    for (JDLeftSlipCell *cell in self.visibleCells) {
        if ([cell isKindOfClass:JDLeftSlipCell.class]) {
            [cell hiddenSideslip];
        }
    }
}

@end
