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
#import "LUNSegmentedControl.h"

@interface LocaDBViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
LUNSegmentedControlDelegate,
LUNSegmentedControlDataSource
>
@property (strong, nonatomic) LUNSegmentedControl *segmentedControl;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation LocaDBViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"本地数据";
    
    [self createTableView];
  
    [self setSegment];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self segmentedControl:self.segmentedControl didScrollWithXOffset:0];
    [self queryDB];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.db close];
}

- (void)setSegment {
    self.segmentedControl = [[LUNSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth/2.5, 30)];
    self.segmentedControl.transitionStyle = LUNSegmentedControlTransitionStyleFade;
    self.segmentedControl.delegate = self;
    self.segmentedControl.dataSource = self;
    self.navigationItem.titleView = self.segmentedControl;
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
    
//    NSLog(@"文件路径：%@",fileName);
    
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


- (void)createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight - 49) style:UITableViewStylePlain];
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

#pragma mark - segmentControl delegate & datasource
- (NSArray<UIColor *> *)segmentedControl:(LUNSegmentedControl *)segmentedControl gradientColorsForStateAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @[[UIColor colorWithRed:160 / 255.0 green:223 / 255.0 blue:56 / 255.0 alpha:1.0], [UIColor colorWithRed:177 / 255.0 green:255 / 255.0 blue:0 / 255.0 alpha:1.0]];
            
            break;
            
        case 1:
            return @[[UIColor colorWithRed:178 / 255.0 green:0 / 255.0 blue:235 / 255.0 alpha:1.0], [UIColor colorWithRed:233 / 255.0 green:0 / 255.0 blue:147 / 255.0 alpha:1.0]];
            break;
            
//        case 2:
//            return @[[UIColor colorWithRed:178 / 255.0 green:0 / 255.0 blue:235 / 255.0 alpha:1.0], [UIColor colorWithRed:233 / 255.0 green:0 / 255.0 blue:147 / 255.0 alpha:1.0]];
//            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl {
    return 2;
}

- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index {
    if (index == 0) {
       return [[NSAttributedString alloc] initWithString:@"小表抄收" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13]}];
    }
    return [[NSAttributedString alloc] initWithString:@"大表抄收" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13]}];
}

- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForSelectedStateAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return [[NSAttributedString alloc] initWithString:@"小表抄收" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]}];
            break;
        case 1:
            return [[NSAttributedString alloc] initWithString:@"大表抄收" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]}];
            break;
            
        default:
            break;
    }
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"TAB %li",(long)index] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]}];
}


- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didScrollWithXOffset:(CGFloat)offset {
    CGFloat maxOffset = self.segmentedControl.frame.size.width / self.segmentedControl.statesCount * (self.segmentedControl.statesCount - 1);
    if (offset == 0) {
        [self queryDB];
    }
    if (PanScreenWidth == 414) {//plus
        
        if (offset == (NSInteger)maxOffset+1) {
            [self queryBigMeterDB];
        }
    } else {
        if (offset == (NSInteger)maxOffset) {
            [self queryBigMeterDB];
        }
    }
//    CGFloat leftDistance = (self.backgroundScrollView.contentSize.width - width) * 0.25;
//    CGFloat rightDistance = (self.backgroundScrollView.contentSize.width - width) * 0.75;
//    CGFloat backgroundScrollViewOffset = leftDistance + ((offset / maxOffset) * (self.backgroundScrollView.contentSize.width - rightDistance - leftDistance));
//    width = self.view.frame.size.width;
//    leftDistance = -width * 0.75;
//    rightDistance = width * 0.5;
//    CGFloat rectangleScrollViewOffset = leftDistance + ((offset / maxOffset) * (self.rectangleScrollView.contentSize.width - rightDistance - leftDistance));
//    [self.rectangleScrollView setContentOffset:CGPointMake(rectangleScrollViewOffset, 0)];
//    [self.backgroundScrollView setContentOffset:CGPointMake(backgroundScrollViewOffset,0)];
}
@end
