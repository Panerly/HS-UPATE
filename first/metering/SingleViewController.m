//
//  SingleViewController.m
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SingleViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SingleViewController ()
<
AVCaptureMetadataOutputObjectsDelegate
>
{
    UIImagePickerController *_imagePickerController;
    //确定传的是哪个照片
    NSInteger num;

    UIImageView *loading;
}



@end

@implementation SingleViewController

static BOOL flag;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isBigMeter?@"大表抄收页":@"小表抄收也";
    flag = YES;
    
    [self _getCode];
     
    [self _makeImageTouchLess];
    
    UIBarButtonItem *loca = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"定位3@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(locaBtn)];
    
    self.navigationItem.rightBarButtonItems = @[loca];
    
    if (self.meter_id_string) {
        self.meter_id.text = self.meter_id_string;
    
        [self getInfo:self.meter_id_string];
        
    }
}

/**
 *  获取本地库单户详情
 *
 *  @param install_addr <#install_addr description#>
 */
- (void)getInfo :(NSString *)install_addr {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@  区域编码：%@", fileName, install_addr);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from litMeter_info where install_addr = '%@'",install_addr]];
        _dataArr = [NSMutableArray array];
        [_dataArr removeAllObjects];
        
        while ([restultSet next]) {
            self.meter_id.text = [restultSet stringForColumn:@"meter_id"];
            self.user_name.text = [NSString stringWithFormat:@"户号：%@",[restultSet stringForColumn:@"user_id"]];
            self.install_addr.text = [restultSet stringForColumn:@"install_addr"];
            self.previousReading.text = [restultSet stringForColumn:@"collector_num"];
            self.previousSettle.text = [restultSet stringForColumn:@"install_time"];
            self.collect_area = [restultSet stringForColumn:@"collector_area"];
        }
    }
}


- (void)_makeImageTouchLess
{
    self.firstImage.multipleTouchEnabled = NO;
    self.secondImage.multipleTouchEnabled = NO;
    self.thirdImage.multipleTouchEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)locaBtn
{
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"正在定位..." duration:1 autoHide:YES];
    //检测定位功能是否开启
    if([CLLocationManager locationServicesEnabled]){
        if(!_locationManager){
            self.locationManager = [[CLLocationManager alloc] init];
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
        }
        //设置代理
        self.locationManager.delegate = self;
        //设置定位精度
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置距离筛选
        [self.locationManager setDistanceFilter:5.0];
        //开始定位
        [self.locationManager startUpdatingLocation];
        //设置开始识别方向
        [self.locationManager startUpdatingHeading];
        
    }else{
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
    
    return nil;
}

#pragma mark - CLLocationManagerDelegate 代理方法实现
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"经度：%f,纬度：%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"定位成功" duration:1 autoHide:YES];
    [_locationManager stopUpdatingLocation];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"使用当前坐标 ？" message:[NSString stringWithFormat:@"\n经度：%f\n\n纬度：%f",newLocation.coordinate.longitude,newLocation.coordinate.latitude] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _x = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
        _y = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:cancel];
    [alertVC addAction:action];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];

}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"定位失败"];
}


- (IBAction)takePhoto:(UIButton *)sender {
    
    [self _camera:sender.tag];
}

- (void)_camera:(NSInteger )imageValue{
    num = imageValue;
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:NULL];
    }else
    {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = YES;
        [self selectImageFromCamera];
    }
}



- (void)_getCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.userNameLabel = [defaults objectForKey:@"userName"];
    self.passWordLabel = [defaults objectForKey:@"passWord"];
    self.ipLabel = [defaults objectForKey:@"ip"];
    self.dbLabel = [defaults objectForKey:@"db"];
}

- (IBAction)uploadPhoto:(id)sender {
    
    NSLog(@"上传数据");
    
    [AnimationView showInView:self.view];
    
    NSString *uploadUrl = [NSString stringWithFormat:@"http://192.168.3.175:8080/Meter_Reading/Reading_nowServlet"];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSData *data = UIImageJPEGRepresentation(_firstImage.image, .1f);
    NSData *data2 = UIImageJPEGRepresentation(_secondImage.image, .1f);
    
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];

    NSDictionary *para = [NSDictionary dictionary];
    NSArray *arr = @[data?data:@"nil",data2?data2:@"nil"];
    
    int increase = [_thisPeriodValue.text intValue] - [_previousReading.text intValue];
    int increaseAlarm = _isBigMeter?[[[NSUserDefaults standardUserDefaults] objectForKey:@"bigMeterAlarmValue"] intValue]:[[[NSUserDefaults standardUserDefaults] objectForKey:@"litMeterAlarmValue"] intValue];
    
    if (increaseAlarm>0) {//判断是否有预设值
        if (increase > increaseAlarm) {
            [AnimationView dismiss];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表增幅值大于警报增幅值！\n请核实后重新填入，或者进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
            }];
        }else{//通过增幅监测
            if ([_thisPeriodValue.text intValue] < [_previousReading.text intValue]) {
                
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表值不能低于上期抄收值！" preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }else {//通过水表逆流监测 开始上传
                NSString *dataRE = @"nil";
                if ([_meteringSituation.text isEqualToString:@""]) {
                    _meteringSituation.text = @"正常";
                }
                NSDictionary *parameters = @{
                                             @"meter_id"      : _meter_id.text,
                                             @"collect_dt"    : currentTime,
                                             @"collect_num"   : _thisPeriodValue.text,
                                             @"collect_avg"   : [NSString stringWithFormat:@"%ld",[_thisPeriodValue.text integerValue] - [_previousReading.text integerValue]],
                                             @"collect_status": _meteringSituation.text,
                                             @"bs"            : @"1",
                                             @"msg"           : arr?arr:dataRE
                                             };
                para = parameters;
                AFHTTPResponseSerializer *serializer = manager.responseSerializer;
                
                serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
                
                NSURLSessionTask *task =[manager POST:uploadUrl parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    [AnimationView dismiss];
                    
                    NSLog(@"上传成功：%@",responseObject);
                    
                    [SCToastView showInView:self.view text:@"上传成功" duration:1 autoHide:YES];
                    
                    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    
                    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
                    
                    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
                    
                    if ([db open]) {
                        
                        [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
                        
                        [db close];
                    } else {
                        [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
                    }
                    //成功后退出
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"上传失败：%@",error);
                    [AnimationView dismiss];
                    [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败！\n原因:%@",error] duration:5 autoHide:YES];
                }];
                [task resume];
            }
        }
        
    }else{
        [AnimationView dismiss];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"预设增幅警报值不能为0，\n进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
}

//保存到本地数据库
- (IBAction)saveToLocal:(id)sender {
    if ([_thisPeriodValue.text intValue] < [_previousReading.text intValue]) {
        if ([_thisPeriodValue.text intValue] < [_previousReading.text intValue]) {
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表值不能低于上期抄收值！" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        
    } else {
        if (!_x || !_y) {
            UIAlertAction *conformBtn = [UIAlertAction actionWithTitle:@"定位" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self locaBtn];
            }];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"不使用" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertController *alertVC2 = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定不使用当前地理坐标?" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC2 addAction:cancelBtn];
            [alertVC2 addAction:conformBtn];
            [self presentViewController:alertVC2 animated:YES completion:^{
                
            }];
        }
        
        NSLog(@"保存照片");
        
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
        
        FMDatabase *db = [FMDatabase databaseWithPath:fileName];
        
        if ([db open]) {
            
            BOOL result = [db executeUpdate:@"create table if not exists meter_complete (id integer PRIMARY KEY AUTOINCREMENT,user_name text not null,install_addr text not null, meter_id text null, collect_area text null,Collect_img_name1 text null, Collect_img_name2 nvarchar(50) null, Collect_img_name3 nvarchar(50) null, x decimal(18, 5) null, y decimal(18, 5) null, remark nvarchar(100) null, install_time datetime null, collect_num numeric(18, 2) not null, user_id text null);"];
            
            if (result) {
                NSLog(@"创建抄收完成表成功");
            } else {
                NSLog(@"创建抄收完成表失败！");
                [SCToastView showInView:self.view text:@"创建抄收完成表失败" duration:.5 autoHide:YES];
            }
        }
        NSData *imageData = UIImageJPEGRepresentation(_firstImage.image, .4);
        NSData *imageData2 = UIImageJPEGRepresentation(_secondImage.image, 1);
        NSData *imageData3 = UIImageJPEGRepresentation(_thirdImage.image, 1);
        
        [db executeUpdate:@"insert into meter_complete (user_name, install_addr, meter_id, collect_num, remark, Collect_img_name1, Collect_img_name2, Collect_img_name3, user_id, collect_area) values (?,?,?,?,?,?,?,?,?,?);",_user_name.text, _install_addr.text, _thisPeriodValue.text,_meter_id.text, _meteringExplain.text, imageData, imageData2, imageData3, _meter_id_string,_collect_area];
        
        if ([db open]) {
            
            [db executeUpdate:[NSString stringWithFormat:@"delete from litMeter_info where install_addr = '%@'",_meter_id_string]];
            
            [db close];
        } else {
            [SCToastView showInView:self.view text:@"数据库打开失败" duration:.5 autoHide:YES];
        }
        
        [SCToastView showInView:self.view text:@"保存成功" duration:.5 autoHide:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:.25 animations:^{
        [self.previousSettle resignFirstResponder];
        [self.previousReading resignFirstResponder];
        [self.thisPeriodValue resignFirstResponder];
        [self.meteringExplain resignFirstResponder];
        [self.meteringSituation resignFirstResponder];
    }];
}

#pragma mark 从摄像头获取图片或视频
- (void)selectImageFromCamera
{
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //录制视频时长，默认10s
    _imagePickerController.videoMaximumDuration = 15;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeJPEG];
    //设置摄像头模式（拍照，录制视频）为拍照模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:_imagePickerController animated:YES completion:^{
        
    }];
}

//获取成功后赋值
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    if (num == 300) {
        
        self.firstImage.image = image;
    }
    if (num == 301) {
        self.secondImage.image = image;
        
    }
    if (num == 302) {
        self.thirdImage.image = image;
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
