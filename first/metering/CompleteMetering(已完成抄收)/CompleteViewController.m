//
//  CompleteViewController.m
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CompleteViewController.h"
#import "CompleteTableViewCell.h"
#import "CompleteModel.h"

@interface CompleteViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FMDatabase *db;
@end

@implementation CompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已完成抄收列表";
    [self createDB];
    [self updateDB];
    [self createTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createDB];
    [self updateDB];
}

- (void)updateDB {
    [self.db open];
    
    FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
    
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([restultSet next]) {
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        NSString *user_id = [restultSet stringForColumn:@"user_id"];
        NSLog(@"meter_id = %@ user_id = %ld",meter_id,(long)user_id);
        NSData *imageData =[restultSet dataForColumn:@"Collect_img_name1"];

        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        completeModel.image = [UIImage imageWithData:imageData];
        [_dataArr addObject:completeModel];
    }
    [self.db close];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)createDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    self.db = db;
}


- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"CompleteTableViewCell" bundle:nil] forCellReuseIdentifier:@"completeID"];
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completeID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CompleteTableViewCell" owner:self options:nil] lastObject];
    }
    cell.completeModel = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
