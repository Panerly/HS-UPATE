//
//  SingleViewController.m
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SingleViewController.h"
#import <AVFoundation/AVFoundation.h>

static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";

@interface SingleViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    UIImagePickerController *_imagePickerController;
    //确定传的是哪个照片
    NSInteger num;
//    //扫描确认btn
//    UIButton *scanBtn;
    UIImageView *loading;
}

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;

@end

@implementation SingleViewController

static BOOL flag;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"抄表·单户";
    flag = YES;
    
    [self _getCode];
    
    [self _makeImageTouchLess];
    
    UIBarButtonItem *loca = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"定位3@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(openLight)];
    //    UIBarButtonItem *scan = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"qrcode_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(QRcode)];
    self.navigationItem.rightBarButtonItems = @[loca];
    
    [self _requestData];
}

- (void)_makeImageTouchLess
{
    self.firstImage.multipleTouchEnabled = NO;
    self.secondImage.multipleTouchEnabled = NO;
    self.thirdImage.multipleTouchEnabled = NO;
}

//请求列表信息
- (void)_requestData {
    //刷新控件
    loading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
    
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://192.168.3.175:8080/Meter_Reading/User_infoServlet"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
//    __weak typeof(self) weakSelf = self;
    
//    NSDictionary *parameters = @{
//                                 @"meter_id":
//                                 };
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            NSLog(@"抄表界面：%@",responseObject);
            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
            
//            NSError *error;
//            
//            for (NSDictionary *dic in responseObject) {
////                MeterInfoModel *meterInfoModel = [[MeterInfoModel alloc] initWithDictionary:dic error:&error];
////                [_dataArr addObject:meterInfoModel];
//            }
            
            [loading removeFromSuperview];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [loading removeFromSuperview];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.view = [[[NSBundle mainBundle] loadNibNamed:@"SingleViewCtl" owner:self options:nil] lastObject];
//        UIBarButtonItem *loca = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"定位3@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(openLight)];
//        //    UIBarButtonItem *scan = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"qrcode_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(QRcode)];
//        self.navigationItem.rightBarButtonItems = @[loca];
//    }
//    return self;
//}

- (void)openLight
{
//    //开启手电
//    [self systemLightSwitch:flag];
    [self locaBtn];
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
//
//- (void)QRcode {
//    
//    if (!_scanView) {
//        _scanView = [[UIView alloc] initWithFrame:self.view.bounds];
//    }
//    _scanView.center = self.view.center;
//    _scanView.backgroundColor = [UIColor blackColor];
//    _scanView.alpha = .8;
//    [self.view addSubview:_scanView];
//    
//    if (!scanBtn) {
//        
//        scanBtn = [[UIButton alloc] init];
//    }
//    [scanBtn setTitle:@"确定" forState:UIControlStateNormal];
//    scanBtn.backgroundColor = [UIColor redColor];
//    scanBtn.clipsToBounds = YES;
//    scanBtn.layer.cornerRadius = 5;
//    [scanBtn addTarget:self action:@selector(conformBtn) forControlEvents:UIControlEventTouchUpInside];
//    [_scanView addSubview:scanBtn];
//    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(CGSizeMake(80, 30));
//        make.centerX.equalTo(_scanView.centerX);
//        make.bottom.equalTo(_scanView.bottom).with.offset(-50);
//    }];
//    
//    [self startReading];
//    
//}

//- (void)conformBtn
//{
//    [UIView animateWithDuration:.5 animations:^{
//        
//        _videoPreviewLayer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
//        
//    } completion:^(BOOL finished) {
//        
//        [UIView animateWithDuration:.5 animations:^{
//            
//            _scanView.transform = CGAffineTransformMakeScale(.01, .01);
//            _videoPreviewLayer.transform = CATransform3DMakeScale(.01, .01, .01);
//            
//        } completion:^(BOOL finished) {
//            
//            [_scanView removeFromSuperview];
//            [_videoPreviewLayer removeFromSuperlayer];
//            
//            _scanView = nil;
//            _videoPreviewLayer = nil;
//            
//        }];
//    }];
//}

////开始读取
//- (BOOL)startReading
//{
//    // 获取 AVCaptureDevice 实例
//    NSError * error;
//    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    // 初始化输入流
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
//    if (!input) {
//        NSLog(@"%@", [error localizedDescription]);
//        return NO;
//    }
//    // 创建会话
//    _captureSession = [[AVCaptureSession alloc] init];
//    // 添加输入流
//    [_captureSession addInput:input];
//    // 初始化输出流
//    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
//    // 添加输出流
//    [_captureSession addOutput:captureMetadataOutput];
//    
//    // 创建dispatch queue.
//    dispatch_queue_t dispatchQueue;
//    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
//    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
//    // 设置元数据类型 AVMetadataObjectTypeQRCode
//    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
//    
//    // 创建输出对象
//    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
//    _videoPreviewLayer.cornerRadius = 10;
//    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//    [_videoPreviewLayer setFrame:CGRectMake(20, _scanView.center.y-PanScreenHeight/6, PanScreenWidth - 40, PanScreenHeight/3)];
//    [self.view.layer addSublayer:_videoPreviewLayer];
//    
//    
//    // 开始会话
//    [_captureSession startRunning];
//    
//    return YES;
//}
//
////停止读取
//- (void)stopReading
//{
//    // 停止会话
//    [_captureSession stopRunning];
//    _captureSession = nil;
//}
//
////获取捕获数据
//-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
//      fromConnection:(AVCaptureConnection *)connection
//{
//    if (metadataObjects != nil && [metadataObjects count] > 0) {
//        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
//        NSString *result = metadataObj.stringValue;
////        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
////            result = metadataObj.stringValue;
////        } else {
////            NSLog(@"不是二维码");
////        }
//        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
//    }
//}
////处理结果
//- (void)reportScanResult:(NSString *)result
//{
//    [self stopReading];
//    NSLog(@"%@",result);
//    UILabel *resultLabel = [[UILabel alloc] init];
//    resultLabel.text = result;
//    resultLabel.textColor = [UIColor whiteColor];
//    resultLabel.textAlignment = NSTextAlignmentCenter;
//    [_scanView addSubview:resultLabel];
//    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(CGSizeMake(200, 25));
//        make.centerX.equalTo(_scanView.centerX);
//        make.top.equalTo(_scanView.mas_top).with.offset(84);
//    }];
//    
//    if (!_lastResult) {
//        return;
//    }
//    _lastResult = NO;
//    
//    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"条形码扫描" message:result preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    [alertVC addAction:action];
//    [self presentViewController:alertVC animated:YES completion:^{
//        
//    }];
//
//    // 以下处理了结果，继续下次扫描
//    _lastResult = YES;
//}

////打开闪光灯
//- (void)systemLightSwitch:(BOOL)open
//{
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    if ([device hasTorch]) {
//        [device lockForConfiguration:nil];
//        if (open) {
//            [device setTorchMode:AVCaptureTorchModeOn];
//            flag = !flag;
//        } else {
//            [device setTorchMode:AVCaptureTorchModeOff];
//            flag = !flag;
//        }
//        [device unlockForConfiguration];
//    }
//}

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



- (IBAction)savePhoto:(id)sender {
    NSLog(@"保存照片");
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
    NSLog(@"上传照片");

    NSString *uploadUrl = [NSString stringWithFormat:@"http://192.168.3.156:8080/waterweb/UploadImageServlet"];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSDictionary *parameters;
    
    NSData *data = UIImageJPEGRepresentation(_firstImage.image, 1.0f);
//    NSString *encodedImageStr = [data base64Encoding];
    if (_firstImage.image) {
        
//        parameters = @{
//                       @"db":self.dbLabel,
//                       @"meter_id":@"58179442",
//                       @"mFile":_firstImage.image
//                       };
        parameters = @{
                       @"img":data
                       };
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"照片不能为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        }];
        [alert addAction:action];

        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSURLSessionTask *task =[manager POST:uploadUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传成功：%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败：%@",error);
    }];
    [task resume];
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
