//
//  CurrentReceiveViewController.h
//  first
//
//  Created by HS on 16/6/14.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentReceiveViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSString *ipLabel;

@property (nonatomic, strong) NSString *dbLabel;

@property (nonatomic, strong) NSString *userNameLabel;

@property (nonatomic, strong) NSString *passWordLabel;

@property (nonatomic, strong) NSString *typeLabel;

//用于判断是查询历史数据还是实时数据
@property (nonatomic, assign) int isRealTimeOrHis;

@end
