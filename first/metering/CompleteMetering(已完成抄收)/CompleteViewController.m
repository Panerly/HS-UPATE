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
{
    BOOL _isBigMeter;
    UIImage *_firstImage;
    UIImage *_secondImage;
    UIImage *_thirdImage;
}
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
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
//    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
//    
//    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
//    [db open];
//    NSLog(@"需要上传的：%@",self.uploadArr);
//    
//    for (int i = 0; i < self.uploadArr.count; i++) {
//        [db executeUpdate:[NSString stringWithFormat:@"delete from meter_complete where user_id = '%@'",((CompleteModel *)self.uploadArr[i]).user_id]];
//        
//    }
//    
//    
//    FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
//    [self.dataArr removeAllObjects];
//    while ([restultSet next]) {
//        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
//        NSString *user_id = [restultSet stringForColumn:@"user_id"];
//        
//        CompleteModel *completeModel = [[CompleteModel alloc] init];
//        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
//        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
//        [self.dataArr addObject:completeModel];
//    }
//    [db close];
//    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    [SCToastView showInView:self.tableView text:@"上传成功" duration:.5 autoHide:YES];
    [self uploadData:nil];
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
    if (!self.uploadArr) {
        self.uploadArr = [NSMutableArray arrayWithCapacity:self.dataArr.count];
    }
    for (int i = 0; i < self.dataArr.count; i++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        [self.uploadArr addObject:self.dataArr[i]];
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
    _isBigMeter = NO;
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
            _isBigMeter = NO;
            [self.uploadArr removeAllObjects];
            break;
        case 1:
            [self updateBigMeterDB];
            _isBigMeter = YES;
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
        NSString *collect_time = [resultSet stringForColumn:@"collect_time"];
        NSString *remark = [resultSet stringForColumn:@"remark"];
        NSString *collecTime = [resultSet stringForColumn:@"collect_time"];
        NSString *collect_num = [resultSet stringForColumn:@"collect_num"];
        NSString *user_name = [resultSet stringForColumn:@"user_name"];
        NSString *collect_area = [resultSet stringForColumn:@"collect_area"];
        NSString *install_addr = [resultSet stringForColumn:@"install_addr"];
        NSString *collect_avg = [resultSet stringForColumn:@"collect_avg"];
        NSString *metering_status = [resultSet stringForColumn:@"metering_status"];
        NSString *x = [resultSet stringForColumn:@"x"];
        NSString *y = [resultSet stringForColumn:@"y"];
        
        NSData *first_image = [resultSet dataForColumn:@"Collect_img_name1"];
        NSData *second_image = [resultSet dataForColumn:@"Collect_img_name2"];
        NSData *third_image = [resultSet dataForColumn:@"Collect_img_name3"];
        
        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        completeModel.collect_time = collecTime;
        completeModel.remark = remark;
        completeModel.collect_num = collect_num;
        completeModel.user_name = user_name;
        completeModel.collect_area = collect_area;
        completeModel.install_addr = install_addr;
        completeModel.collect_avg = collect_avg;
        completeModel.metering_status = metering_status;
        completeModel.x = x;
        completeModel.y = y;
        completeModel.collect_time = [NSString stringWithFormat:@"%@",collect_time];
        completeModel.image = [UIImage imageWithData:first_image];
        completeModel.second_img = [UIImage imageWithData:second_image];
        completeModel.third_img = [UIImage imageWithData:third_image];
        
        [self.dataArr addObject:completeModel];

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
//        NSString *meter_id = [resultSet stringForColumn:@"meter_id"];
//        NSString *user_id = [resultSet stringForColumn:@"user_id"];
//        NSString *collect_time = [resultSet stringForColumn:@"collect_time"];
//        NSLog(@"meter_id = %@ user_id = %ld",meter_id,(long)user_id);
//        NSData *imageData = [resultSet dataForColumn:@"Collect_img_name1"];
//        
//        CompleteModel *completeModel = [[CompleteModel alloc] init];
//        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
//        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
//        completeModel.collect_time = [NSString stringWithFormat:@"%@",collect_time];
//        completeModel.image = [UIImage imageWithData:imageData];
//        [_dataArr addObject:completeModel];
        NSString *meter_id = [resultSet stringForColumn:@"meter_id"];
        NSString *user_id = [resultSet stringForColumn:@"user_id"];
        NSString *collect_time = [resultSet stringForColumn:@"collect_time"];
        NSString *remark = [resultSet stringForColumn:@"remark"];
        NSString *collecTime = [resultSet stringForColumn:@"collect_time"];
        NSString *collect_num = [resultSet stringForColumn:@"collect_num"];
        NSString *user_name = [resultSet stringForColumn:@"user_name"];
        NSString *collect_area = [resultSet stringForColumn:@"collect_area"];
        NSString *install_addr = [resultSet stringForColumn:@"install_addr"];
        NSString *collect_avg = [resultSet stringForColumn:@"collect_avg"];
        NSString *metering_status = [resultSet stringForColumn:@"metering_status"];
        NSString *x = [resultSet stringForColumn:@"x"];
        NSString *y = [resultSet stringForColumn:@"y"];
        
        NSData *first_image = [resultSet dataForColumn:@"Collect_img_name1"];
        NSData *second_image = [resultSet dataForColumn:@"Collect_img_name2"];
        NSData *third_image = [resultSet dataForColumn:@"Collect_img_name3"];
        
        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        completeModel.collect_time = collecTime;
        completeModel.remark = remark;
        completeModel.collect_num = collect_num;
        completeModel.user_name = user_name;
        completeModel.collect_area = collect_area;
        completeModel.install_addr = install_addr;
        completeModel.collect_avg = collect_avg;
        completeModel.metering_status = metering_status;
        completeModel.x = x;
        completeModel.y = y;
        completeModel.collect_time = [NSString stringWithFormat:@"%@",collect_time];
        completeModel.image = [UIImage imageWithData:first_image];
        completeModel.second_img = [UIImage imageWithData:second_image];
        completeModel.third_img = [UIImage imageWithData:third_image];
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
    //去掉自带分割线
    [_tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
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
    return 110;
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

- (void)uploadData:(id)sender {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    [db open];
    NSLog(@"需要上传的：%@",self.uploadArr);
    
    [AnimationView showInView:self.view];
    
    NSString *uploadUrl = [NSString stringWithFormat:@"http://192.168.3.175:8080/Meter_Reading/Reading_nowServlet1"];
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    [manager setSecurityPolicy:securityPolicy];
    
//    NSMutableArray *img_arr = [NSMutableArray array];
//    NSMutableArray *img_arr2 = [NSMutableArray array];
//    NSMutableArray *collect_time_arr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
//    NSMutableArray *collect_num_arr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
//    NSMutableArray *collect_avg_arr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
//    NSMutableArray *meter_id_arr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
//    NSMutableArray *collect_status_arr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
    NSMutableArray *install_addr_arr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
    
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithCapacity:_uploadArr.count];
    NSMutableArray *paraArr = [NSMutableArray arrayWithCapacity:_uploadArr.count];
    
    NSMutableDictionary *paraDicAll = [NSMutableDictionary dictionaryWithCapacity:_uploadArr.count];

    for (int i = 0; i < _uploadArr.count; i++) {
        NSData *data = UIImageJPEGRepresentation(((CompleteModel *)_uploadArr[i]).image, .1f);
        NSData *data2 = UIImageJPEGRepresentation(((CompleteModel *)_uploadArr[i]).second_img, .1f);
        
        [install_addr_arr addObject:((CompleteModel *)_uploadArr[i]).install_addr];
        
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).meter_id forKey:@"meter_id"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).collect_time forKey:@"collect_dt"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).collect_num forKey:@"collect_num"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).collect_avg forKey:@"collect_avg"];
        [paraDic setObject:((CompleteModel *)_uploadArr[i]).metering_status forKey:@"collect_status"];
        [paraDic setObject:@"1" forKey:@"bs"];
        [paraDic setObject:data?data:@"nil" forKey:@"msg"];
        [paraDic setObject:data2?data2:@"nil" forKey:@"msg2"];
        
        [paraDicAll setObject:paraDic forKey:@"meter_bs"];
        [paraArr addObject:paraDicAll];
    }
    
//    NSDictionary *para = [NSDictionary dictionary];
//    NSArray *arr = @[img_arr?img_arr:@"nil",img_arr2?img_arr2:@"nil"];
//    
//    NSDictionary *parameters = @{
//                                 @"meter_id"      : meter_id_arr,
//                                 @"collect_dt"    : collect_time_arr,
//                                 @"collect_num"   : collect_num_arr,
//                                 @"collect_avg"   : collect_avg_arr,
//                                 @"collect_status": collect_status_arr,
//                                 @"bs"            : @"1",
//                                 @"msg"           : arr
//                                 };
//    para = parameters;
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:uploadUrl parameters:paraArr progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"--------%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [AnimationView dismiss];
        
        NSLog(@"上传成功：%@",responseObject);
        
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
        
        FMDatabase *db = [FMDatabase databaseWithPath:fileName];
        
        if ([db open]) {
            for (int i = 0; i < _uploadArr.count; i++) {
                
                [db executeUpdate:[NSString stringWithFormat:@"delete from meter_complete where install_addr = '%@'",install_addr_arr[i]]];
            }
            
            [db close];
        } else {
            [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
        }
        FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
        [self.dataArr removeAllObjects];
        while ([restultSet next]) {
            NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
            NSString *user_id = [restultSet stringForColumn:@"user_id"];
            NSData *first_image = [restultSet dataForColumn:@"Collect_img_name1"];
            NSData *second_image = [restultSet dataForColumn:@"Collect_img_name2"];
            NSData *third_image = [restultSet dataForColumn:@"Collect_img_name3"];
        
            CompleteModel *completeModel = [[CompleteModel alloc] init];
            completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
            completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
            completeModel.image = [UIImage imageWithData:first_image];
            completeModel.second_img = [UIImage imageWithData:second_image];
            completeModel.third_img = [UIImage imageWithData:third_image];
            [self.dataArr addObject:completeModel];
        }
        [db close];
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [SCToastView showInView:weakSelf.tableView text:@"上传成功" duration:.5 autoHide:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败：%@",error);
        [AnimationView dismiss];
        [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败！\n原因:%@",error] duration:5 autoHide:YES];
    }];
    [task resume];
}


@end
