//
//  MeteringViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringViewController.h"
#import "MeteringSingleViewController.h"
#import "SingleViewController.h"
#import "TestViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "MeterInfoModel.h"
#import "MeterInfoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
//自定义tableview
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"

#import "LocaDBViewController.h"
#import "CompleteViewController.h"
#import "FTPopOverMenu.h"

#import "ScanImageViewController.h"

static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
static NSString *const menuCellIdentifier = @"rotationCell";

@interface MeteringViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
AVCaptureMetadataOutputObjectsDelegate,
YALContextMenuTableViewDelegate
>

{
    //判断是大表还是小表
    BOOL isBitMeter;
    UIImageView *loading;
    NSString *cellID;
    //扫描确认btn
    UIButton *scanBtn;
    //弹窗用的tableview，与界面重复，避免加载数据源混乱用BOOL区分
    BOOL isTap;
}
@property (nonatomic, assign) NSInteger num;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;


@end

//判断手电开启
static BOOL flashIsOn;

@implementation MeteringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *scan = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = scan;

    flashIsOn = YES;
    
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(presentMenuButtonTapped)];
    self.navigationItem.rightBarButtonItem = more;
    
    [self initiateMenuOptions];
    
    isBitMeter = YES;
    isTap = NO;
    
    _num = 5;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    
    [self _createTableView];
    
    [self _requestData];
    
//    UIButton *btn = [[UIButton alloc] init];
//    btn.clipsToBounds = YES;
//    btn.layer.cornerRadius = 10;
//    btn.backgroundColor = [UIColor redColor];
//    [btn setTitle:@"通知+1" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).with.offset(PanScreenWidth/6);
//        make.top.equalTo(self.view.mas_top).with.offset(100);
//        make.size.equalTo(CGSizeMake(PanScreenWidth/4, 50));
//    }];
//    
//    UIButton *btn2 = [[UIButton alloc] init];
//    btn2.clipsToBounds = YES;
//    btn2.layer.cornerRadius = 10;
//    btn2.backgroundColor = [UIColor redColor];
//    [btn2 setTitle:@"通知-1" forState:UIControlStateNormal];
//    [btn2 addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn2];
//    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.mas_right).with.offset(-PanScreenWidth/6);
//        make.top.equalTo(self.view.mas_top).with.offset(100);
//        make.size.equalTo(CGSizeMake(PanScreenWidth/4, 50));
//    }];
//
//
//    UIButton *btn3 = [[UIButton alloc] init];
//    btn3.clipsToBounds = YES;
//    btn3.layer.cornerRadius = 10;
//    btn3.backgroundColor = [UIColor redColor];
//    [btn3 setTitle:@"跳转" forState:UIControlStateNormal];
//    [btn3 addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn3];
//    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.mas_right).with.offset(-PanScreenWidth/6);
//        make.top.equalTo(self.view.mas_top).with.offset(160);
//        make.size.equalTo(CGSizeMake(PanScreenWidth/4, 50));
//    }];
    
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
//    self.navigationItem.rightBarButtonItems = @[share];
}

- (void)action :(UIButton *)sender{
    [FTPopOverMenu showForSender:sender
                        withMenu:@[@"MenuOne",@"MenuTwo",@"MenuThr"]
                  imageNameArray:@[@"setting_icon",@"setting_icon",@"setting_icon"]
                       doneBlock:^(NSInteger selectedIndex) {
                           if (selectedIndex == 0) {
                               ScanImageViewController *scanVC = [[ScanImageViewController alloc] init];
                               [self.navigationController showViewController:scanVC sender:nil];
                           }
                           NSLog(@"done block. do something. selectedIndex : %ld", (long)selectedIndex);
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
}

//- (void)share{
//    UIImage *image = [UIImage imageNamed:@"bg_server.jpg"];
//    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
//    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    
//    id<ISSCAttachment> localAttachment = [ShareSDKCoreService attachmentWithPath:encodedImageStr];
//    //1.2、以下参数分别对应：内容、默认内容、图片、标题、链接、描述、分享类型
//    id<ISSContent> publishContent = [ShareSDK content:@"分享测试"
//                                       defaultContent:nil
//                                                image:localAttachment
//                                                title:@"测试标题"
//                                                  url:@"http://www.hzsb.com"
//                                          description:nil
//                                            mediaType:SSPublishContentMediaTypeImage];
//
//    
//    //1+、创建弹出菜单容器（iPad应用必要，iPhone应用非必要）
//    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:nil
//                            arrowDirect:UIPopoverArrowDirectionUp];
//    //2、展现分享菜单
//    [ShareSDK showShareActionSheet:container
//                         shareList:nil
//                           content:publishContent
//                     statusBarTips:NO
//                       authOptions:nil
//                      shareOptions:nil
//                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                
//                                NSLog(@"=== response state :%zi ",state);
//                                
//                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//                                //可以根据回调提示用户。
//                                if (state == SSResponseStateSuccess)
//                                {
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"分享成功!" preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                    
//                                }
//                                else if (state == SSResponseStateFail) {
//                                    
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:[NSString stringWithFormat:@"Error Description：%@",[error errorDescription]] preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                }
//                            }];
//    
//    
//}



- (void)push
{
    TestViewController *testVC = [[TestViewController alloc] init];
    [self presentViewController:testVC animated:YES completion:^{
        
    }];
}

//static int i = 0;
//- (void)viewWillAppear:(BOOL)animated
//{
//    if (i == 0) {
//        self.tabBarItem.badgeValue = nil;
//        i = 1;
//    }else {
//        
//        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",i ];
//    }
//}
////测试：通知加减
//- (void)btnAction
//{
//    if (i > 99) {
//        self.tabBarItem.badgeValue = @"99+";
//    }else {
//        if (i == 0) {
//            self.tabBarItem.badgeValue = nil;
//            i = 1;
//        } else {
//            if (self.tabBarItem.badgeValue == nil) {
//                self.tabBarItem.badgeValue = @"1";
//            }
//            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",i++];
//        }
//    }
//    
//}
//
//-(void)btn
//{
//    if (i>=1) {
//        
//        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",--i];
//        if (i==0) {
//            self.tabBarItem.badgeValue = nil;
//        }
//    }else
//    {
//        if (self.tabBarItem.badgeValue == nil) {
//            self.tabBarItem.badgeValue = @"1";
//            i = 1;
//        }
//        self.tabBarItem.badgeValue = nil;
//    }
//    
//}
- (void)_createTableView
{
    cellID = @"meterInfoID";
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, PanScreenWidth, PanScreenHeight-50) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
        
        [_tableView registerNib:[UINib nibWithNibName:@"MeterInfoTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
        
        [_tableView setExclusiveTouch:YES];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestData)];
        _tableView.mj_header.automaticallyChangeAlpha = YES;
    }
    
    if (!self.contextMenuTableView) {
        
        self.contextMenuTableView = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.scrollEnabled = NO;
        self.contextMenuTableView.animationDuration = 0.1;
        self.contextMenuTableView.yalDelegate = self;
        self.contextMenuTableView.menuItemsSide = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        [self.contextMenuTableView registerNib:[UINib nibWithNibName:@"ContextMenuCell" bundle:nil] forCellReuseIdentifier:menuCellIdentifier];
        
    }
}

//初始化加载storyboard
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self = [[UIStoryboard storyboardWithName:@"Metering" bundle:nil] instantiateViewControllerWithIdentifier:@"Metering"];
    }
    return self;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}


- (IBAction)meterTypecOntrol:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            _num = 5;
            isBitMeter = YES;
            [self _requestData];
            break;
        case 1:
            _num = 10;
            isBitMeter = NO;
            [self _requestData];
        default:
            break;
    }
    
}

//请求列表信息
- (void)_requestData {
    //刷新控件
    loading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
    
    if (_tableView.mj_header.isRefreshing) {
        [loading removeFromSuperview];
    }
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://192.168.3.175:8080/Meter_Reading/Meter_infoServlet"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
//            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            [weakSelf.tableView.mj_header endRefreshing];
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
            
            NSError *error;
            
            for (NSDictionary *dic in responseObject) {
                MeterInfoModel *meterInfoModel = [[MeterInfoModel alloc] initWithDictionary:dic error:&error];
                [_dataArr addObject:meterInfoModel];
            } 
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
            [loading removeFromSuperview];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        [loading removeFromSuperview];
        
        UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:confir];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];

}
//#pragma mark - UITableView Delegate & DataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return _dataArr.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    MeterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
//
//    cell.backgroundColor = [UIColor clearColor];
//    
//    if (!cell) {
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterInfoTableViewCell" owner:self options:nil] lastObject];
//    }
//    cell.meterInfoModel= _dataArr[indexPath.row];
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    if (isBitMeter) {
//        
//        MeteringSingleViewController *meteringVC = [[MeteringSingleViewController alloc] init];
//        meteringVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController showViewController:meteringVC sender:nil];
//    }
//    else
//    {
//        SingleViewController *singleVC = [[SingleViewController alloc] init];
//        singleVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController showViewController:singleVC sender:nil];
//    }
//}

#pragma mark - openQrcode

- (void)QRcode {

    [SVProgressHUD show];
    
    if (!_scanView) {
        _scanView = [[UIView alloc] initWithFrame:self.view.bounds];
        _scanView.center = self.view.center;
        _scanView.backgroundColor = [UIColor blackColor];
        _scanView.alpha = .8;
        [self.navigationController.view addSubview:_scanView];
    }

    if (!scanBtn) {

        scanBtn = [[UIButton alloc] init];
    }
    [scanBtn setTitle:@"关闭" forState:UIControlStateNormal];
    scanBtn.backgroundColor = [UIColor redColor];
    scanBtn.clipsToBounds = YES;
    scanBtn.layer.cornerRadius = 5;
    [scanBtn addTarget:self action:@selector(conformBtn) forControlEvents:UIControlEventTouchUpInside];
    [_scanView addSubview:scanBtn];
    [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(80, 30));
        make.centerX.equalTo(_scanView.centerX);
        make.bottom.equalTo(_scanView.bottom).with.offset(-120);
    }];
    
    [self startReading];

}
//关闭窗口
- (void)conformBtn
{
    [SVProgressHUD dismiss];
    
    [UIView animateWithDuration:.5 animations:^{
        
        _scanView.transform = CGAffineTransformMakeScale(.001, .001);
        _videoPreviewLayer.transform = CATransform3DMakeScale(.001, .001, .001);
        
    } completion:^(BOOL finished) {
        
        [_scanView removeFromSuperview];
        [_videoPreviewLayer removeFromSuperlayer];
        
        _videoPreviewLayer = nil;
        _scanView = nil;

    }];
}

//开始读取
- (BOOL)startReading
{
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"警告！" message:@"设备不支持！请检查" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self conformBtn];
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
        
        return NO;
    }
    
    //先上锁 设置完属性再解锁
    if ([captureDevice lockForConfiguration:nil]) {
        
        //自动闪光灯
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动对焦
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //自动曝光
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [captureDevice unlockForConfiguration];
    }
    
    
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];

    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];

    // 创建输出对象
    if (!_videoPreviewLayer) {
        
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        _videoPreviewLayer.cornerRadius = 10;
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:CGRectMake(20, _scanView.center.y-PanScreenHeight/4, PanScreenWidth - 40, PanScreenHeight/3)];
        [self.navigationController.view.layer addSublayer:_videoPreviewLayer];
        // 开始会话
        [_captureSession startRunning];
    }
    [SVProgressHUD dismiss];

    return YES;
}

//停止读取
- (void)stopReading
{
    // 停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
}

//获取捕获数据
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result = metadataObj.stringValue;
//        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
//            result = metadataObj.stringValue;
//        } else {
//            NSLog(@"不是二维码");
//        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}
//处理结果
- (void)reportScanResult:(NSString *)result {
    
    [self stopReading];
    NSLog(@"扫描结果：%@",result);
    
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.text = result;
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [_scanView addSubview:resultLabel];
    
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(200, 25));
        make.centerX.equalTo(_scanView.centerX);
        make.top.equalTo(_scanView.mas_top).with.offset(84);
    }];

    [self conformBtn];
    
    SingleViewController *singleVC = [[SingleViewController alloc] init];
    singleVC.meter_id_string = result;
    singleVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController showViewController:singleVC sender:nil];
    
    if (!_lastResult) {
        return;
    }
    _lastResult = NO;

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"条形码扫描" message:result preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:^{

    }];

    // 以下处理了结果，继续下次扫描
    _lastResult = YES;
    
    
}


#pragma mark - Local methods

- (void)initiateMenuOptions {
    self.menuTitles = @[
                        @"",
                        @"大表扫码",
                        @"小表扫码",
                        @"开启手电筒",
                        @"请求网络表单",
                        @"查看本地数据库",
                        @"已完成抄收列表"
                        ];
    
    self.menuIcons = @[
                       [UIImage imageNamed:@"icon_close@3x"],
                       [UIImage imageNamed:@"icon_qrcode_big@3x"],
                       [UIImage imageNamed:@"icon_qrcode@3x"],
                       [UIImage imageNamed:@"light@3x"],
                       [UIImage imageNamed:@"icon_db_internet@3x"],
                       [UIImage imageNamed:@"icon_db@3x"],
                       [UIImage imageNamed:@"icon_complete@2x"]
                       ];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Menu dismissed with indexpath.row = %ld", (long)indexPath.row);
    isTap = !isTap;
    if (!isTap) {
        [self.view addSubview:_tableView];
        [self.view insertSubview:_tableView belowSubview:_ctrlBtn];
    }
    
    if (indexPath.row == 1|| indexPath.row == 2) {
        
        [self QRcode];
    }
    if (indexPath.row == 3) {
        [self systemLightSwitch:flashIsOn];
    }
    if (indexPath.row == 4) {
        GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"提示" message:@"此功能暂未开通！" buttonTitle:@"确定" buttonTouchedAction:^{
            
        } dismissAction:^{
            
        }];
        [alertView show];
    }
    if (indexPath.row == 5) {
        LocaDBViewController *locaDB = [[LocaDBViewController alloc] init];
        [self.navigationController showViewController:locaDB sender:nil];
    }
    if (indexPath.row == 6) {
        CompleteViewController *completeVC = [[CompleteViewController alloc] init];
        [self.navigationController showViewController:completeVC sender:nil];
    }
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isTap) {
        [tableView dismisWithIndexPath:indexPath];
        
    }else {
        if (isBitMeter) {
            
            MeteringSingleViewController *meteringVC = [[MeteringSingleViewController alloc] init];
            meteringVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController showViewController:meteringVC sender:nil];
        }
        else
        {
            SingleViewController *singleVC = [[SingleViewController alloc] init];
            singleVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController showViewController:singleVC sender:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isTap) {
        return 50;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isTap) {
        
        return self.menuTitles.count;
    }
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isTap) {
        
        ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        
        if (cell) {
            cell.backgroundColor = [UIColor clearColor];
            cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
            cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
        }
        return cell;
    }
    MeterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterInfoTableViewCell" owner:self options:nil] lastObject];
    }
    cell.meterInfoModel= _dataArr[indexPath.row];
    return cell;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    if (isTap) {
        
        [self.contextMenuTableView reloadData];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (isTap) {
        
        [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        
        [self.contextMenuTableView updateAlongsideRotation];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (isTap) {
        
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        
        
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            //should be called after rotation animation completed
            [self.contextMenuTableView reloadData];
        }];
        [self.contextMenuTableView updateAlongsideRotation];
    }
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)presentMenuButtonTapped {
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
    isTap = !isTap;
    if (isTap) {
        [self.tableView removeFromSuperview];
    } else {
        
        [self _createTableView];
    }
    
}

#pragma mark - openSysLight
//打开闪光灯
- (void)systemLightSwitch:(BOOL)open {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
            flashIsOn = !flashIsOn;
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            flashIsOn = !flashIsOn;
        }
        [device unlockForConfiguration];
    }
}

@end
