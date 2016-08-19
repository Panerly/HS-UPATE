//
//  QueryViewController.m
//  first
//
//  Created by HS on 16/6/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "QueryViewController.h"
#import "QueryTableViewCell.h"
#import "SCViewController.h"
#import "QueryModel.h"
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface QueryViewController ()<UITableViewDelegate,UITableViewDataSource,SCChartDataSource>

{
    NSString *identy;
    NSUserDefaults *defaults;
    SCChart *chartView;
    //流量读数y轴数据
    NSMutableArray *yFlowArr;
    //用于判断是显示流量or水表读数
    NSUInteger _flag;
    NSInteger selectedIndex;
    UIPinchGestureRecognizer *pinch;
    UIScrollView *scrollView;
}
@end

@implementation QueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"大表数据查询";
    self.switchBtn.selectedSegmentIndex = 0;
    
    //设置时流量统计为默认值
    _flag = 0;
    
    [self _getSysTime];
    
    [self _setValue];
    
    [self _setTableView];
    
    [self _createCurveView];
    
    [self requestDayData:_dayDateTime :_dayDateTime];
    
    self.dataArr = [NSMutableArray array];
    self.xArr = [NSMutableArray array];
    self.yArr = [NSMutableArray array];
    yFlowArr = [NSMutableArray array];
}

- (void)_getSysTime
{
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    _dayDateTime = [formatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *formatter_hour = [[NSDateFormatter alloc] init];
    [formatter_hour setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    _hourDateTime = [formatter_hour stringFromDate:[NSDate date]];
    
    NSDate* date1 = [[NSDate alloc] init];
    date1 = [date1 dateByAddingTimeInterval:-30*3600*24];
    _monthDateTime = [formatter stringFromDate:date1];

}

//设置
- (void)_setValue
{
    defaults = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:@"userName"];
    self.passWord = [defaults objectForKey:@"passWord"];
    self.ip = [defaults objectForKey:@"ip"];
    self.db = [defaults objectForKey:@"db"];
    
    self.manageMeterNum.text = [NSString stringWithFormat:@"表编号: %@",self.meter_id];
    self.meterType.text = [NSString stringWithFormat:@"表类型: %@",self.meterTypeValue];
    self.communicationType.text = [NSString stringWithFormat:@"口径: %@",self.communicationTypeValue];
    self.installAddr.text = [NSString stringWithFormat:@"安装地址: %@",self.installAddrValue];
}

//设置代理
- (void)_setTableView
{
    identy = @"queryIdenty";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}

//创建曲线图
- (void)_createCurveView
{
    scrollView = [[UIScrollView alloc] init];
    scrollView.scrollEnabled = YES;
    scrollView.zoomScale = 2;
    
    //添加缩放手势
    pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleAction:)];
    [scrollView addGestureRecognizer:pinch];

    scrollView.contentSize = CGSizeMake(PanScreenWidth*2, 150);
    [_curveView addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_curveView.mas_left).with.offset(10);
        make.top.equalTo(_curveView.mas_top);
        make.right.equalTo(_curveView.right);
        make.bottom.equalTo(_curveView.bottom);
    }];
    
    chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(self.view.frame.origin.x, 0,  PanScreenWidth*2.5, 150) withSource:self withStyle:SCChartLineStyle];
    [chartView showInView:scrollView];
}

static CGFloat i = 1.0;

//缩放frame实现缩放表格
- (void)scaleAction:(UIPinchGestureRecognizer*)pinchs
{
    if (i == 0) {
        i = 1.0f;
    } else {
     
        if (pinchs.velocity < 0.0f) {
            
            i = i - 0.2*(pinchs.scale+1);
            if (i == 0) {
                i = 1.0;
            }
            if (i<=1) {
                i = 1.0;
            }
        }else
        {
            i = i + 0.2*pinchs.scale;
            if (i >= 50) {
                i = 50.0;
            }
        }
    }
    NSLog(@"缩放倍率：%f",i);
    scrollView.contentSize = CGSizeMake(PanScreenWidth*i, 150);
    [chartView removeFromSuperview];
    chartView = [[SCChart alloc] initwithSCChartDataFrame:CGRectMake(0, 0,  PanScreenWidth*i, 150) withSource:self withStyle:SCChartLineStyle];
    [chartView showInView:scrollView];
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)SCChart_xLableArray:(SCChart *)chart {

    if (i < 2.1) {
        //空间太小 所以在4倍内显示数字
        NSMutableArray *array = [NSMutableArray array];
        [array removeAllObjects];
        for (int j = 0; j < _xArr.count; j++) {
            [array addObject:[NSString stringWithFormat:@"%d",j]];
        }
        return array;
    }
    //缩放至4到8倍时显示抄收小时数据
    else if (i >= 2.1 && i < 4) {
        NSMutableArray *array = [NSMutableArray array];
        [array removeAllObjects];
        for (int j = 0; j < _xArr.count; j++) {
            [array addObject:[_xArr[j] substringWithRange:NSMakeRange(10, 10)]];
        }
        return array;
    }
    //4倍以上有足够的空间 所以显示详细的时间
    NSMutableArray *array = [NSMutableArray array];
    [array removeAllObjects];
    for (int j = 0; j < _xArr.count; j++) {
        [array addObject:[_xArr[j] substringWithRange:NSMakeRange(2, 17)]];
    }
    return array;
}
//- (NSArray *)getXTitles:(int)num {
//    NSMutableArray *xTitles = [NSMutableArray array];
//    for (int i=0; i<num; i++) {
//        NSString * str = [NSString stringWithFormat:@"%d",i+1];
//        [xTitles addObject:str];
//    }
//    return xTitles;
//}

//数值多重数组 Y轴值数组
- (NSArray *)SCChart_yValueArray:(SCChart *)chart {
    NSMutableArray *ary = [NSMutableArray array];
    NSString *unit;
    switch (self.switchBtn.selectedSegmentIndex) {
        case 0:
            unit = @"m³/h";
        break;
        case 1:
            unit = @"吨";
        break;
        case 2:
            unit = @"吨";
        default:
            break;
    }
    for (int i = 0; i <_yArr.count; i++) {
        NSString *num = _yArr[i];
        NSString *str = [NSString stringWithFormat:@"%@%@",num,unit];
        [ary addObject:str];
    }
    return @[ary];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)SCChart_ColorArray:(SCChart *)chart {
    return @[SCGreen,SCRed,SCBrown];
}
//判断显示横线条
- (BOOL)SCChart:(SCChart *)chart ShowHorizonLineAtIndex:(NSInteger)index {
    return YES;
}

//详情视图
- (IBAction)curveAction:(id)sender {
    
    SCViewController *curveVC = [[SCViewController alloc] init];
    
    curveVC.xArr= _xArr;
    
    if (selectedIndex == 0) {
        curveVC.yArr = yFlowArr;
    }
    else if (selectedIndex == 1) {
        curveVC.xArr = _xArr;
        curveVC.yArr = _yArr;
    }
    else if (selectedIndex == 2) {
        
        curveVC.yArr = _yArr;
    }
    [self.navigationController showViewController:curveVC sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

//选择日用量或月用量的数据
- (IBAction)flowStatistics:(UISegmentedControl *)sender {
//    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无数据" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    [alertVC addAction:action];
    
    selectedIndex = sender.selectedSegmentIndex;
    
    switch (sender.selectedSegmentIndex) {
        case 0://时流量查询（每十五分钟）
            [self requestDayData:_dayDateTime :_dayDateTime];
            break;
            
        case 1://日流量查询(每小时流量)
            [self requestHourData:_dayDateTime];
            break;
        case 2://月流量查询（每天）
            [self requestData:_monthDateTime :_dayDateTime];
        default:
            break;
    }
    
}
//请求一天每小时水表抄收数据
- (void)requestHourData:(NSString *)date {
    
    [SVProgressHUD showWithStatus:@"加载中"];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/DateServlet",self.ip];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
//    NSDictionary *parameters = @{@"meter_id":self.meter_id,
//                                 @"date1":date,
//                                 @"username":self.userName,
//                                 @"db":self.db,
//                                 @"password":self.passWord
//                                 };
    NSDictionary *parameters = @{@"meter_id":self.meter_id,
                                 @"date":@"2016-7-21",
                                 @"db":self.db
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {

            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            [_dataArr removeAllObjects];
            [_xArr removeAllObjects];
            [_yArr removeAllObjects];
            
            NSError *error = nil;
            
            for (NSDictionary *dataDic in responseObject) {
                QueryModel *queryModel = [[QueryModel alloc] initWithDictionary:dataDic error:&error];
                [self.dataArr addObject:queryModel];
                [_yArr addObject:queryModel.collect_num];
                [_xArr addObject:queryModel.collect_dt];
            }
            NSMutableArray *array = [NSMutableArray array];
            [array removeAllObjects];
            for (int i = 0; i < _xArr.count; i++) {
                if ( i < 10) {
                    [array addObject:[NSString stringWithFormat:@"%@ 0%d:00:00.0",[_xArr[i] substringWithRange:NSMakeRange(0, 10)],i]];
                }else{
                [array addObject:[NSString stringWithFormat:@"%@.0",_xArr[i]]];
                }
            }
            _xArr = array;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            [chartView setNeedsDisplay];
            [chartView strokeChart];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"请求失败：%@",error]];
    }];
    
    [task resume];
}

//查询月流量
- (void)requestData:(NSString *)fromDate :(NSString *)toDate
{
    [SVProgressHUD showWithStatus:@"加载中"];
    
    NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/DosServlet",self.ip];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];

    NSDictionary *parameters = @{@"meter_id":self.meter_id,
                                 @"date1":fromDate,
                                 @"date2":toDate,
                                 @"username":self.userName,
                                 @"db":self.db,
                                 @"password":self.passWord
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {

            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            NSString *count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"count"]];
            if ([count isEqualToString:@"0"]) {
//                [SCToastView showInView:_tableView text:@"暂无数据" duration:4 autoHide:YES];
                [SVProgressHUD showInfoWithStatus:@"暂无数据"];
            }
            NSDictionary *meter1Dic = [responseObject objectForKey:@"meters"];

            NSError *error = nil;
            
            [self.dataArr removeAllObjects];
            [_xArr removeAllObjects];
            [_yArr removeAllObjects];
            
            for (NSDictionary *dic in meter1Dic) {
                QueryModel *queryModel = [[QueryModel alloc] initWithDictionary:dic error:&error];
                [self.dataArr addObject:queryModel];
                [_yArr addObject:queryModel.collect_num];
                [_xArr addObject:queryModel.collect_dt];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            [chartView setNeedsDisplay];
            [chartView strokeChart];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            
//        }];
//        
//        [alertVC addAction:action];
//        [self presentViewController:alertVC animated:YES completion:^{
//            
//        }];
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"请求失败：%@",error]];
    }];
    
    [task resume];
}


//查询时流量
- (void)requestDayData:(NSString *)fromDate :(NSString *)toDate
{
    defaults = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:@"userName"];
    self.passWord = [defaults objectForKey:@"passWord"];
    self.ip = [defaults objectForKey:@"ip"];
    self.db = [defaults objectForKey:@"db"];

    NSString *url = [NSString stringWithFormat:@"http://%@/waterweb/His5Servlet",self.ip];

    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];

    NSDictionary *parameters = @{@"meter_id":self.meter_id,
                                 @"date1":fromDate,
                                 @"date2":toDate,
                                 @"username":self.userName,
                                 @"db":self.db,
                                 @"password":self.passWord
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            [yFlowArr removeAllObjects];
            [_yArr removeAllObjects];
            
            NSString *count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"count"]];
            if ([count isEqualToString:@"0"]) {
                [SVProgressHUD showInfoWithStatus:@"暂无数据"];
            }
            
            NSDictionary *meter1Dic = [responseObject objectForKey:@"meters"];
            
            NSError *error = nil;
            
            [self.dataArr removeAllObjects];
            
            [_xArr removeAllObjects];
            
            for (NSDictionary *dic in meter1Dic) {

                QueryModel *queryModel = [[QueryModel alloc] initWithDictionary:dic error:&error];
                [self.dataArr addObject:queryModel];
                [self.yArr addObject:queryModel.collect_avg];
                [yFlowArr addObject:queryModel.collect_num];
                [_xArr addObject:[dic objectForKey:@"collect_dt"]];
            }

            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
            [chartView setNeedsDisplay];
            [chartView strokeChart];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"请求失败：%@",error]];
        
    }];
    
    [task resume];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"QueryTableViewCell" owner:nil options:nil] lastObject];
    }
    cell.queryModel = self.dataArr[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"水表信息" message:[NSString stringWithFormat:@"\n水表流量: %@m³/h\n\n水表读数: %@吨\n\n抄收时间: %@",((QueryModel *)self.dataArr[indexPath.row]).collect_avg, ((QueryModel *)self.dataArr[indexPath.row]).collect_num, ((QueryModel *)self.dataArr[indexPath.row]).collect_dt] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertController *alertDay = [UIAlertController alertControllerWithTitle:@"水表信息" message:[NSString stringWithFormat:@"\n日用量: %@吨\n\n抄收时间: %@", ((QueryModel *)self.dataArr[indexPath.row]).collect_num, ((QueryModel *)self.dataArr[indexPath.row]).collect_dt] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *alertHour = [UIAlertController alertControllerWithTitle:@"水表信息" message:[NSString stringWithFormat:@"\n时用量: %@吨\n\n抄收时间: %@", ((QueryModel *)self.dataArr[indexPath.row]).collect_num, ((QueryModel *)self.dataArr[indexPath.row]).collect_dt] preferredStyle:UIAlertControllerStyleAlert];
    
    switch (_switchBtn.selectedSegmentIndex) {
        case 0:
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            break;
        case 1:
            [alertHour addAction:action];
            [self presentViewController:alertHour animated:YES completion:^{
                
            }];
        break;
        case 2:
            [alertDay addAction:action];
            [self presentViewController:alertDay animated:YES completion:^{
                
            }];
            break;
        default:
            break;
    }
    
}

@end
