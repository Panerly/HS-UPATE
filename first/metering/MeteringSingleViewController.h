//
//  MeteringSingleViewController.h
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterInfoModel.h"

@interface MeteringSingleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MeterInfoModel *meterInfoModel;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end
