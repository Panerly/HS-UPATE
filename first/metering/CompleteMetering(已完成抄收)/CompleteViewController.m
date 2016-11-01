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
@property(nonatomic, strong) UIButton *selectAllBtn;//全选按钮
//@property (nonatomic, strong) UIView *coverView;
@property(nonatomic, strong) UIButton *uploadBtn;//上传
@property(nonatomic, strong) NSMutableArray *uploadArr;//上传数据的数组
@end

@implementation CompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已完成";
//    [self createDB];
//    [self updateDB];
    [self createTableView];
    [self setSegmentedCtrl];
    [self setUploadAndselectBtn];
    self.uploadArr = [NSMutableArray array];
}

- (void)setUploadAndselectBtn {
    //选择按钮
    UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    selectedBtn.frame = CGRectMake(0, 0, 60, 30);
    [selectedBtn setTitle:@"选择" forState:UIControlStateNormal];
    [selectedBtn addTarget:self action:@selector(selectedBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithCustomView:selectedBtn];
//    self.navigationItem.rightBarButtonItem =selectItem;
    
    
    //全选
    _selectAllBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _selectAllBtn.frame = CGRectMake(0, 0, 60, 30);
    [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_selectAllBtn addTarget:self action:@selector(selectAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_selectAllBtn];
    self.navigationItem.rightBarButtonItems = @[selectItem,leftItem];
    _selectAllBtn.hidden = YES;
    
    
    //上传按钮
    _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadBtn.backgroundColor = [UIColor lightGrayColor];
    [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    _uploadBtn.frame = CGRectMake(25, PanScreenHeight - 50 - 49, PanScreenWidth - 50, (PanScreenWidth - 50)/7);
    _uploadBtn.clipsToBounds = YES;
    _uploadBtn.layer.cornerRadius = (PanScreenWidth - 50)/7/2;
    [_uploadBtn addTarget:self action:@selector(uploadClick:) forControlEvents:UIControlEventTouchUpInside];
    _uploadBtn.enabled = NO;
}
//上传按钮点击事件
- (void)uploadClick:(UIButton *) button {
    
    if (self.tableView.editing) {
        [self uploadDB];
    }
    else return;
}

- (void)uploadDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    [db open];
    NSLog(@"需要上传的：%@",self.uploadArr);
    
    for (int i = 0; i < self.uploadArr.count; i++) {
        [db executeUpdate:[NSString stringWithFormat:@"delete from meter_complete where user_id = '%@'",((CompleteModel *)self.uploadArr[i]).user_id]];
        
    }
    
    
    FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
    [self.dataArr removeAllObjects];
    while ([restultSet next]) {
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        NSString *user_id = [restultSet stringForColumn:@"user_id"];
        
        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        [self.dataArr addObject:completeModel];
    }
    [db close];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [SCToastView showInView:self.tableView text:@"上传成功" duration:.5 autoHide:YES];
}
//选择按钮点击响应事件
- (void)selectedBtn:(UIButton *)button {
    
    _uploadBtn.enabled = YES;
    //支持同时选中多行
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.editing) {
        _selectAllBtn.hidden = NO;
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [self.uploadArr removeAllObjects];
        [self refreshBtnState];
    }else{
        _selectAllBtn.hidden = YES;
        _uploadBtn.backgroundColor = [UIColor lightGrayColor];
        [button setTitle:@"选择" forState:UIControlStateNormal];
        _uploadBtn.enabled = NO;
        [self.uploadArr removeAllObjects];
        [self refreshBtnState];
    }
    
}

//全选
- (void)selectAllBtnClick:(UIButton *)button {
//    _uploadBtn.backgroundColor = [UIColor redColor];
    for (int i = 0; i < self.dataArr.count; i ++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self.uploadArr addObjectsFromArray:self.dataArr];
    }
    [self refreshBtnState];
    NSLog(@"self.deleteArr:%@  %@", self.uploadArr,self.dataArr);
}



//刷新上传按钮的状态
- (void)refreshBtnState{
    if (self.uploadArr.count >= 1) {
            [self.view addSubview:_uploadBtn];
//            _uploadBtn.transform = CGAffineTransformMakeScale(.01, .01);
//            [UIView animateWithDuration:.35 animations:^{
//                _uploadBtn.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//                
//            }];
        _uploadBtn.backgroundColor = [UIColor redColor];
    }else {
        if (self.uploadArr.count < 1) {
            _uploadBtn.backgroundColor = [UIColor lightGrayColor];
            [_uploadBtn removeFromSuperview];
        }
    }
}


//切换控件部署
- (void)setSegmentedCtrl {
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"小表完成",@"大表完成"]];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(segmentedCtrlAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    [segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(PanScreenWidth/2.5, 30));
        make.top.equalTo(self.view.mas_top).with.offset(69);
        make.centerX.equalTo(self.view.centerX);
    }];
}
//大小表切换
- (void)segmentedCtrlAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self updateDB];
            [self.uploadArr removeAllObjects];
            break;
        case 1:
            [self updateBigMeterDB];
            [self.uploadArr removeAllObjects];
            break;
        default:
            break;
    }
}
/**
 *  查询数据库更新表格
 *
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createDB];
    [self updateDB];
}

//从数据库获取更新数据 刷新tableview
- (void)updateDB {
    [self.db open];
    
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM meter_complete where collect_area = '01' order by user_id"];
    
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([resultSet next]) {
        NSString *meter_id = [resultSet stringForColumn:@"meter_id"];
        NSString *user_id = [resultSet stringForColumn:@"user_id"];
        NSLog(@"meter_id = %@ user_id = %ld",meter_id,(long)user_id);
        NSData *imageData =[resultSet dataForColumn:@"Collect_img_name1"];

        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        completeModel.image = [UIImage imageWithData:imageData];
        [_dataArr addObject:completeModel];
    }
    [self.db close];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)updateBigMeterDB {
    [self.db open];
    
    FMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM meter_complete where collect_area = '02' order by user_id"];
    
    _dataArr = [NSMutableArray array];
    [_dataArr removeAllObjects];
    
    while ([resultSet next]) {
        NSString *meter_id = [resultSet stringForColumn:@"meter_id"];
        NSString *user_id = [resultSet stringForColumn:@"user_id"];
        NSLog(@"meter_id = %@ user_id = %ld",meter_id,(long)user_id);
        NSData *imageData =[resultSet dataForColumn:@"Collect_img_name1"];
        
        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        completeModel.image = [UIImage imageWithData:imageData];
        [_dataArr addObject:completeModel];
    }
    [self.db close];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

//连接数据库
- (void)createDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    self.db = db;
}


- (void)createTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, PanScreenWidth, PanScreenHeight - 50) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = COLORRGB(227, 230, 255);
    [_tableView registerNib:[UINib nibWithNibName:@"CompleteTableViewCell" bundle:nil] forCellReuseIdentifier:@"completeID"];
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

//取消选中时 将存放在self.deleteArr中的数据移除
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    [self.uploadArr removeObject:[self.dataArr objectAtIndex:indexPath.row]];
    [self refreshBtnState];
}

//是否可以编辑  默认的时YES
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//选择编辑的方式,按照选择的方式对表进行处理
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
    
}
//选择你要对表进行处理的方式  默认是删除方式
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

//选中时将选中行的在self.dataArray 中的数据添加到删除数组self.deleteArr中
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_uploadBtn.enabled || self.tableView.editing) {
        
        [self.uploadArr addObject:[self.dataArr objectAtIndex:indexPath.row]];
        [self refreshBtnState];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompleteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"completeID" forIndexPath:indexPath];
    cell.layer.shouldRasterize = YES;
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CompleteTableViewCell" owner:self options:nil] lastObject];
    }
    cell.completeModel = _dataArr[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
//    //长按手势
//    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressedAct:)];
//    longPressed.minimumPressDuration = 1;
//    [cell addGestureRecognizer:longPressed];
    
    return cell;
}
//-(void)longPressedAct:(UILongPressGestureRecognizer *)gesture
//{
//    if(gesture.state == UIGestureRecognizerStateBegan) {
//        CGPoint point = [gesture locationInView:self.tableView];
//        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
//        if(indexPath == nil) return ;
//        self.tableView.editing = YES;
//        [self refreshBtnState];
//        [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
//        _selectAllBtn.hidden = NO;
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
