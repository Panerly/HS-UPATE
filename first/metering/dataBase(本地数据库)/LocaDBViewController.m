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
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createDB];
    [self updateDB];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.db close];
}

- (void)updateDB {
    FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM meter_info order by user_id"];
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([restultSet next]) {
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        int user_id = [restultSet intForColumn:@"user_id"];
        
        
        DBModel *dbModel = [[DBModel alloc] init];
        dbModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        dbModel.user_id =[NSString stringWithFormat:@"%d",user_id];
        [_dataArr addObject:dbModel];
    }
    if (_dataArr.count == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        label.text = @"暂无数据";
        label.textAlignment = NSTextAlignmentCenter;
        label.center = _tableView.center;
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)createDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
   
    NSLog(@"文件路径：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
//        [db executeUpdate:@"drop table meter_info"];
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS meter_info (id integer PRIMARY KEY AUTOINCREMENT,meter_id text not null, user_id integer not null,Collect_img_name1 BLOB null, Collect_img_name2 BLOB null, Collect_img_name3 BLOB null);"];
       
        
        /**
         *  meter_info
         大表基本信息表
         id int 主键  自动增加
         meter_id nvarchar(20) 水表编号
         user_id nvarchar(20) 用户号(单位代码)
         meter_txm nvarchar(20)条形码号
         meter_wid nvarchar(20) 表位号
         collector_area nvarchar(2) 所属小区或区域
         install_time datetime 安装时间
         install_addr nvarchar(50) 安装地点
         comm_id nvarchar(20) 通讯联络号
         water_kind nvarchar(20) 用水性质
         meter_cali int 水表口径
         meter_name varchar(50) 水表类型
         x decimal(18, 5) 经度坐标
         y decimal(18, 5) 纬度坐标
         remark nvarchar(100) 备注
         bs nvarchar(2) 标识
         Collect_img_name1 nvarchar(50) 照片名称1 
         Collect_img_name2 nvarchar(50) 照片名称2
         Collect_img_name3 照片名称3
         */
        
        
        BOOL createBigMeter = [db executeUpdate:@"create table if not exists bigmeter_info (id integer primary key autoincrement, meter_id text not null, user_id text null, meter_txm nvarchar(20) null, meter_wid nvarchar(20) null, collector_area nvarchar(2) null, install_time datetime null, install_addr nvarchar(50) null, install_addr nvarchar(50) not null, comm_id nvarchar(20) null, water_kind nvarchar(20) null, meter_cali int null, meter_name varchar(50) null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, bs nvarchar(2) null, Collect_img_name1 nvarchar(50) null, Collect_img_name2 nvarchar(50) null, Collect_img_name3 nvarchar(50) null);"];
        
        if (result) {
            NSLog(@"创建小表成功");
        } else {
            NSLog(@"创建失败！");
            [SCToastView showInView:_tableView text:@"创建小表失败" duration:.5 autoHide:YES];
        }
        
        if (createBigMeter) {
            NSLog(@"创建大表成功");
        } else {
            NSLog(@"创建大表失败！");
            [SCToastView showInView:_tableView text:@"创建大表失败" duration:.5 autoHide:YES];
        }
        
    }
    
    self.db = db;
    
    UISegmentedControl *segmentCtrl = [[UISegmentedControl alloc] initWithItems:@[@"小表待抄",@"大表待抄"]];
    [segmentCtrl setSelectedSegmentIndex:0];
    [segmentCtrl addTarget:self action:@selector(segmentCtrlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentCtrl];
    [segmentCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).with.offset(CGRectGetMaxY(self.navigationController.navigationBar.frame)+10);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.equalTo(CGSizeMake(PanScreenWidth/3, 30));
    }];
    
    
    UIButton *insertBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 64+10, 60, 25)];
    insertBtn.backgroundColor = [UIColor cyanColor];
    insertBtn.layer.cornerRadius = 8;
    [insertBtn setTitle:@"插入" forState:UIControlStateNormal];
    [insertBtn addTarget:self action:@selector(insert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:insertBtn];
    
    
    
    UIButton *queryBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 20 - 50, 64+10, 60, 25)];
    [queryBtn setBackgroundColor:[UIColor lightGrayColor]];
    queryBtn.layer.cornerRadius = 8;
    [queryBtn setTitle:@"删除" forState:UIControlStateNormal];
    [queryBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:queryBtn];
}

/**
 *  大小表切换
 */
- (void)segmentCtrlAction:(UISegmentedControl *)sender {
    
}


/**
 *  数据插入
 */
- (void)insert {
    for (int i = 0; i < 10; i++) {
        NSString *meter_id = [NSString stringWithFormat:@"杭州水表%d",arc4random_uniform(100)];
        [self.db executeUpdate:@"INSERT INTO meter_info (meter_id, user_id) VALUES (?,?);", meter_id, @(arc4random_uniform(100))];
    }
    NSLog(@"插入成功");
    FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM meter_info order by user_id"];
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([restultSet next]) {
        int ID = [restultSet intForColumn:@"id"];
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        int user_id = [restultSet intForColumn:@"user_id"];
        
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSString stringWithFormat:@"%d",ID] forKey:@"ID"];
        [dic setObject:meter_id forKey:@"meter_id"];
        [dic setObject:[NSString stringWithFormat:@"%d",user_id] forKey:@"user_id"];

        DBModel *dbModel = [[DBModel alloc] init];
        dbModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        dbModel.user_id =[NSString stringWithFormat:@"%d",user_id];
        [_dataArr addObject:dbModel];
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)delete {
    NSLog(@"删除");
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请输入" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancel];

    [self.db executeUpdate:@"delete from meter_info"];
    FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM meter_info order by user_id"];
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([restultSet next]) {
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        int user_id = [restultSet intForColumn:@"user_id"];
        
        DBModel *dbModel = [[DBModel alloc] init];
        dbModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        dbModel.user_id =[NSString stringWithFormat:@"%d",user_id];
        [_dataArr addObject:dbModel];
    }
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)query {
    NSLog(@"查询语句");
    
    FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM meter_info order by user_id"];
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([restultSet next]) {
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        int user_id = [restultSet intForColumn:@"user_id"];

        DBModel *dbModel = [[DBModel alloc] init];
        dbModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        dbModel.user_id =[NSString stringWithFormat:@"%d",user_id];
        [_dataArr addObject:dbModel];
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
    singleVC.meter_id_string = ((DBModel *)_dataArr[indexPath.row]).meter_id;
    singleVC.meter_id.text = ((DBModel *)_dataArr[indexPath.row]).user_id;
    singleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController showViewController:singleVC sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
