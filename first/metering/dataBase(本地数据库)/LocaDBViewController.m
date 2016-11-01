//
//  LocaDBViewController.m
//  first
//
//  Created by HS on 16/8/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LocaDBViewController.h"
#import "DBModel.h"
#import "TableViewCell.h"
#import "SingleViewController.h"

@interface LocaDBViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation LocaDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"本地数据";
    
    [self createTableView];
  
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryDB];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.db close];
}

- (void)setupUI {
    UISegmentedControl *segmentCtrl = [[UISegmentedControl alloc] initWithItems:@[@"小表待抄",@"大表待抄"]];
    //    [segmentCtrl setSelectedSegmentIndex:0];
    segmentCtrl.selectedSegmentIndex = 0;
    [segmentCtrl addTarget:self action:@selector(segmentCtrlAction:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:segmentCtrl];
    [segmentCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).with.offset(CGRectGetMaxY(self.navigationController.navigationBar.frame)+10);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.equalTo(CGSizeMake(PanScreenWidth/2.5, 30));
    }];
}



- (void)queryDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
   
    NSLog(@"文件路径：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *resultSet = [db executeQuery:@"select *from litMeter_info where collector_area = '01' order by id"];
        
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        while ([resultSet next]) {
            
            NSString *meter_id = [resultSet stringForColumn:@"meter_id"];
            NSString *user_addr = [resultSet stringForColumn:@"install_addr"];

            DBModel *dbModel = [[DBModel alloc] init];
            dbModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
            dbModel.user_addr =[NSString stringWithFormat:@"%@",user_addr];
            [_dataArr addObject:dbModel];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

    }
    
    self.db = db;
}

- (void)queryBigMeterDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *resultSet = [db executeQuery:@"select *from litMeter_info where collector_area = '02' order by id"];
        
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        while ([resultSet next]) {
            
            NSString *meter_id = [resultSet stringForColumn:@"meter_id"];
            NSString *user_addr = [resultSet stringForColumn:@"install_addr"];
            
            DBModel *dbModel = [[DBModel alloc] init];
            dbModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
            dbModel.user_addr =[NSString stringWithFormat:@"%@",user_addr];
            [_dataArr addObject:dbModel];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    self.db = db;
    
}

/**
 *  大小表切换
 */
- (void)segmentCtrlAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self queryDB];
            break;
        case 1:
            [self queryBigMeterDB];
            break;
        default:
            break;
    }
}

- (void)createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, PanScreenWidth, PanScreenHeight - 45 - 49) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil] lastObject];
    }
    cell.DBModel = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SingleViewController *singleVC = [[SingleViewController alloc] init];
    singleVC.meter_id_string = ((DBModel *)_dataArr[indexPath.row]).user_addr;
    singleVC.meter_id.text = ((DBModel *)_dataArr[indexPath.row]).meter_id;
    singleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController showViewController:singleVC sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
