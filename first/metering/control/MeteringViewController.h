//
//  MeteringViewController.h
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeterInfoModel.h"
@interface MeteringViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)meterTypecOntrol:(UISegmentedControl *)sender;

@property (nonatomic, strong) MeterInfoModel *meterInfoModel;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end
