//
//  AppDelegate.h
//  CellLeftSlip
//
//  Created by JiangDong Zhang on 2017/7/26.
//  Copyright © 2017年 JiangDong Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

