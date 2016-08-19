//
//  MeterDataViewController.m
//  first
//
//  Created by HS on 16/6/27.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeterDataViewController.h"
#import "MeterDataTableViewCell.h"
#import "MeterDataModel.h"
#import "KSDatePicker.h"
//#import "MSSCalendarViewController.h"
//#import "MSSCalendarDefine.h"

@interface MeterDataViewController ()

<
UITableViewDelegate,
UITableViewDataSource
>
//MSSCalendarViewControllerDelegate

{
    NSString *cellID;
    NSUserDefaults *defaults;
//    MSSCalendarViewController *cvc;
}
@end

@implementation MeterDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"水表数据";
    
    cellID = @"meterDataID";
    
    [self _getUserInfo];
    
    [self _getSysTime];
    
    [self _setTableView];
    
//    UIBarButtonItem *calender = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendar@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(openCalender)];
//    self.navigationItem.rightBarButtonItems = @[calender];
}

//- (void)openCalender
//{
//    cvc = [[MSSCalendarViewController alloc] init];
//    cvc.limitMonth = 12 * 15;// 显示几个月的日历
//    /*
//     MSSCalendarViewControllerLastType 只显示当前月之前
//     MSSCalendarViewControllerMiddleType 前后各显示一半
//     MSSCalendarViewControllerNextType 只显示当前月之后
//     */
//    cvc.type = MSSCalendarViewControllerLastType;
//    cvc.beforeTodayCanTouch = YES;// 今天之后的日期是否可以点击
//    cvc.afterTodayCanTouch = NO;// 今天之前的日期是否可以点击
//    cvc.startDate = [self.fromDate.text integerValue];// 选中开始时间
//    cvc.endDate = [self.toDate.text integerValue];// 选中结束时间
//    /*以下两个属性设为YES,计算中国农历非常耗性能（在5s加载15年以内的数据没有影响）*/
//    cvc.showChineseHoliday = YES;// 是否展示农历节日
//    cvc.showChineseCalendar = YES;// 是否展示农历
//    cvc.showHolidayDifferentColor = YES;// 节假日是否显示不同的颜色
//    cvc.showAlertView = YES;// 是否显示提示弹窗
//    cvc.delegate = self;
//    [self presentViewController:cvc animated:YES completion:nil];
//}
//
//- (void)calendarViewConfirmClickWithStartDate:(NSInteger)startDate endDate:(NSInteger)endDate
//{
//    _fromDate.text = [NSString stringWithFormat:@"%ld",(long)startDate];
//    _toDate.text = [NSString stringWithFormat:@"%ld",(long)endDate];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
//    NSString *startDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_fromDate.text integerValue]]];
//    NSString *endDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_toDate.text integerValue]]];
//    _fromDate.text = [NSString stringWithFormat:@"%@",startDateString];
//    _toDate.text = [NSString stringWithFormat:@"%@",endDateString];
//}



- (void)_setTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"MeterDataTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
}

- (void)_getSysTime
{
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    self.fromDate.text = time;
    self.toDate.text = time;
}

- (void)_getUserInfo
{
    defaults = [NSUserDefaults standardUserDefaults];
    _userName = [defaults objectForKey:@"userName"];
    self.passWord = [defaults objectForKey:@"passWord"];
    self.ip = [defaults objectForKey:@"ip"];
    self.db = [defaults objectForKey:@"db"];
}

- (void)_requestData:(NSString *)fromDate :(NSString *)toDate :(NSString *)callerLabel
{
    
    if ([fromDate caseInsensitiveCompare:toDate]<=0) {
        
        [SVProgressHUD showWithStatus:@"加载中"];
        
        NSString *logInUrl = [NSString stringWithFormat:@"http://%@/waterweb/MessageServlet",self.ip];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        
        NSDictionary *parameters = @{@"username":self.userName,
                                     @"password":self.passWord,
                                     @"db":self.db,
                                     @"date1":fromDate,
                                     @"date2":toDate,
                                     @"calling_tele":callerLabel
                                     };
        
        AFHTTPResponseSerializer *serializer = manager.responseSerializer;
        
        serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        
        __weak typeof(self) weakSelf = self;
        
        NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
            
            NSError *error = nil;
            
            if (responseObject) {
                
                if ([[responseObject objectForKey:@"count"] integerValue] == 0) {
                    
                    [SCToastView showInView:self.view text:@"暂无数据!" duration:1.5 autoHide:YES];
                    
                } else {

                    [SVProgressHUD showInfoWithStatus:@"加载成功"];
                    
                    NSDictionary *dicResponse = [responseObject objectForKey:@"meters"];
                    
                    self.dataNum.text = [NSString stringWithFormat:@"数    量: %@",[responseObject objectForKey:@"count"]];
                    
                    for (NSDictionary *dic in dicResponse) {
                        
                        self.userNameLabel.text = [NSString stringWithFormat:@"用户名: %@",[dic objectForKey:@"user_name"]];
                        self.userNumLabel.text = [NSString stringWithFormat:@"用户号: %@",[dic objectForKey:@"meter_id"]];
                        
                        MeterDataModel *meterDataModel = [[MeterDataModel alloc] initWithDictionary:dic error:&error];
                        [_dataArr addObject:meterDataModel];
                    }
                    
                    [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"加载失败:%@",error]];
            
        }];
        [task resume];
    } else {
        [SCToastView showInView:self.view text:@"错误的选择区间!" duration:1.5 autoHide:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.userNumLabel removeFromSuperview];
    [self.userNameLabel removeFromSuperview];
    [self.dataNum removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.userNumLabel removeFromSuperview];
    [self.userNameLabel removeFromSuperview];
    [self.dataNum removeFromSuperview];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeterDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterDataTableViewCell" owner:self options:nil] lastObject];
    }
    cell.serialNum.text = [NSString stringWithFormat:@"%li",(long)indexPath.row];
    cell.serialNum.font = [UIFont systemFontOfSize:10];
    cell.serialNum.textColor = [UIColor redColor];
    cell.meterDataModel = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SCToastView showInView:self.view text:@"加载中" duration:0.5 autoHide:YES];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"水表数据" message:[NSString stringWithFormat:@"%@",((MeterDataModel *)_dataArr[indexPath.row]).message] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_callerLabel resignFirstResponder];
    [_fromDate resignFirstResponder];
    [_toDate resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

- (IBAction)conformBtn:(id)sender {
    
    [_callerLabel resignFirstResponder];
    [_fromDate resignFirstResponder];
    [_toDate resignFirstResponder];

    [self _requestData:_fromDate.text :_toDate.text :_callerLabel.text];
}
- (IBAction)dateBtn:(UIButton *)sender {
    
    [_fromDate resignFirstResponder];
    [_toDate resignFirstResponder];
    
    KSDatePicker* picker = [[KSDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 300)];
    
    picker.appearance.radius = 5;
    
    //设置回调
    picker.appearance.resultCallBack = ^void(KSDatePicker* datePicker,NSDate* currentDate,KSDatePickerButtonType buttonType){
        
        if (buttonType == KSDatePickerButtonCommit) {
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if (sender.tag == 100) {
                
                _fromDate.text = [formatter stringFromDate:currentDate];
            }else {
                _toDate.text = [formatter stringFromDate:currentDate];
            }
        }
    };
    // 显示
    [picker show];

}
@end
