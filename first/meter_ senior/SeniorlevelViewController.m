//
//  SeniorlevelViewController.m
//  first
//
//  Created by HS on 2016/12/1.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SeniorlevelViewController.h"
#import "JHPieChart.h"

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>
//#import <BaiduMapAPI_Map/BMKCircle.h>
//#import <BaiduMapAPI_Map/BMKOverlayView.h>

@interface SeniorlevelViewController ()
<
BMKMapViewDelegate,
BMKLocationServiceDelegate
>
{
    BOOL map_type;
    BOOL isBigMeter;
    UIButton *selectedBtn;
    UIView *paopaoBgView;
    int bmkViewTag;
    UIImage *bmkImage;
    BOOL flag;
    NSTimer *timer;
    JHPieChart *pie;
    UIButton *refreshBtn;
}

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKMapView *bmkMapView;
@property (nonatomic, strong) NSMutableArray *annomationArray;

@end

@implementation SeniorlevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    map_type = YES;
    flag = YES;
    
    [self setNavColor];
    
    [self initMapView];
    
    [self setSelectBtn];
    
    [self initLeftBarItem];
    
    [self _requestMeterData];
    
    _bigMeterDataArr = [NSMutableArray array];
    _litMeterDataArr = [NSMutableArray array];
    _annomationArray = [NSMutableArray array];
    
}

- (void)initLeftBarItem {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame     = CGRectMake(0, 0, 30, 30);
    btn.showsTouchWhenHighlighted = YES;
    [btn setImage:[UIImage imageNamed:@"icon_pie"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setChartSwitch:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *pieItem              = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = pieItem;
}

//大小表饼图切换
- (void)setChartSwitch :(UIView *)sender{
    
    //大表已超
    int bigMeterCompleteNum   = 0;
    //大表未超
    int bigMeterUnCompleteNum = 0;
    //小表已超
    int litMeterCompleteNum   = 0;
    //小表未超
    int litMeterUnCompleteNum = 0;
    
    for (int i = 0; i < _bigMeterDataArr.count; i++) {
        
        if ([((MapDataModel *)_bigMeterDataArr[i]).bs isEqualToString:@"0"]) {//大表未抄
            bigMeterUnCompleteNum++;
        }else{//大表已抄
            bigMeterCompleteNum++;
        }
    }
    for (int i = 0; i < _litMeterDataArr.count; i++) {
        if ([((MapDataModel *)_litMeterDataArr[i]).bs isEqualToString:@"0"]) {//小表未抄
            litMeterUnCompleteNum++;
        }else{//小表已抄
            litMeterCompleteNum++;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    if (!pie) {
        
        pie        = [[JHPieChart alloc] initWithFrame:CGRectMake(0, 0, 300, 310)];
        pie.center = CGPointMake(CGRectGetMaxX(self.view.frame)/2, CGRectGetMaxY(self.view.frame)/2);
        pie.backgroundColor    = [UIColor whiteColor];
        pie.clipsToBounds      = YES;
        pie.layer.cornerRadius = 8;
        /*    When touching a pie chart, the animation offset value     */
        pie.positionChangeLengthWhenClick = 15;
        
    }
    NSMutableArray *numArr = [NSMutableArray arrayWithCapacity:4];
    [numArr addObject:[NSString stringWithFormat:@"%d",bigMeterCompleteNum]];
    [numArr addObject:[NSString stringWithFormat:@"%d",bigMeterUnCompleteNum]];
    [numArr addObject:[NSString stringWithFormat:@"%d",litMeterCompleteNum]];
    [numArr addObject:[NSString stringWithFormat:@"%d",litMeterUnCompleteNum]];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(300 - 50, 0, 50, 50)];
    closeBtn.tintColor = [UIColor redColor];
    [closeBtn setImage:[UIImage imageNamed:@"close@2x"] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [pie addSubview:closeBtn];
    /* Pie chart value, will automatically according to the percentage of numerical calculation */
    pie.valueArr = numArr;
    /* The description of each sector must be filled, and the number must be the same as the pie chart. */
    pie.descArr = @[@"大表已抄",@"大表未抄",@"小表已抄",@"小表未抄"];
    
    [weakSelf.view addSubview:pie];
    
    //Start animation
    [pie showAnimation];
}

//关闭饼状图
- (void)closeAction {
    if (pie) {
        
        [UIView animateWithDuration:.5 animations:^{
            pie.alpha = .3;
            pie.transform = CGAffineTransformMakeScale(.01, .01);
        } completion:^(BOOL finished) {
            [pie removeFromSuperview];
            pie = nil;
        }];
        
    }
}

//切换按钮
- (void)setSelectBtn {
    
    selectedBtn       = [UIButton buttonWithType:UIButtonTypeSystem];
    selectedBtn.frame = CGRectMake(0, 0, 60, 30);
    selectedBtn.showsTouchWhenHighlighted = YES;
    [selectedBtn setTitle:@"大表" forState:UIControlStateNormal];
    [selectedBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [selectedBtn addTarget:self action:@selector(_selectBigMeter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectItem             = [[UIBarButtonItem alloc] initWithCustomView:selectedBtn];
    self.navigationItem.rightBarButtonItems = @[selectItem];
    isBigMeter                              = YES;
}

//设置导航栏颜色
-(void)setNavColor{
    self.navigationController.navigationBar.barStyle     = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = COLORRGB(226, 107, 16);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

//大小表切换
- (void)_selectBigMeter {
    
    [timer invalidate];
    [self setTimer];
    
    bmkViewTag = 300;
    [_bmkMapView removeAnnotations:_annomationArray];
    if (isBigMeter) {
        
        for (int i = 0; i < _bigMeterDataArr.count; i++) {
            
            BMKPointAnnotation* bigMeterAnnotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude  = [((MapDataModel *)_bigMeterDataArr[i]).y floatValue];
            coor.longitude = [((MapDataModel *)_bigMeterDataArr[i]).x floatValue];
            bigMeterAnnotation.coordinate = coor;
            [_bmkMapView addAnnotation:bigMeterAnnotation];
            [_annomationArray addObject:bigMeterAnnotation];
            bmkViewTag++;
        }
        [selectedBtn setTitle:@"小表" forState:UIControlStateNormal];
        [selectedBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }else {
        
        for (int i = 0; i < _litMeterDataArr.count; i++) {
            
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude  = [((MapDataModel *)_litMeterDataArr[i]).y floatValue];
            coor.longitude = [((MapDataModel *)_litMeterDataArr[i]).x floatValue];
            annotation.coordinate = coor;
            [_bmkMapView addAnnotation:annotation];
            [_annomationArray addObject:annotation];
            bmkViewTag++;
        }
        [selectedBtn setTitle:@"大表" forState:UIControlStateNormal];
        [selectedBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    isBigMeter = !isBigMeter;
}

//请求水表抄收数据
- (void)_requestMeterData {
    
    [refreshBtn removeFromSuperview];
    refreshBtn = nil;
    
    NSString *mapMeterDataUrl                 = [NSString stringWithFormat:@"%@",mapCompleteApi];
    
    NSURLSessionConfiguration *config         = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager             = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer      = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf              = self;
    
    NSURLSessionTask *meterTask               = [manager GET:mapMeterDataUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            NSError *error;
            
            NSMutableArray *muteArr = [NSMutableArray array];
            
            for (NSDictionary *responseDic in responseObject) {
                
                _mapDataModel = [[MapDataModel alloc] initWithDictionary:responseDic error:&error];
                
                if ([_mapDataModel.area_id isEqualToString:@"00"]) {
                    
                    [weakSelf.bigMeterDataArr addObject:_mapDataModel];
                } else {
                    
                    [weakSelf.litMeterDataArr addObject:_mapDataModel];
                }
                [muteArr addObject:_mapDataModel];
            }

            if (isBigMeter) {
                
                for (int i = 0; i < weakSelf.bigMeterDataArr.count; i++) {
                    
                    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
                    CLLocationCoordinate2D coor;
                    coor.latitude  = [((MapDataModel *)_bigMeterDataArr[i]).y floatValue];
                    coor.longitude = [((MapDataModel *)_bigMeterDataArr[i]).x floatValue];
                    annotation.coordinate = coor;
                    [_bmkMapView addAnnotation:annotation];
                    [_annomationArray addObject:annotation];
                }
            } else {
                for (int i = 0; i < weakSelf.litMeterDataArr.count; i++) {
                    
                    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
                    CLLocationCoordinate2D coor;
                    coor.latitude  = [((MapDataModel *)_litMeterDataArr[i]).y floatValue];
                    coor.longitude = [((MapDataModel *)_litMeterDataArr[i]).x floatValue];
                    annotation.coordinate = coor;
                    [_bmkMapView addAnnotation:annotation];
                    [_annomationArray addObject:annotation];
                }
            }
            [weakSelf setTimer];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error.code == -1004) {
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"服务器连接失败"] duration:1.5 autoHide:YES];
        }else {
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"数据加载失败！\n%@",[error description]] duration:1.5 autoHide:YES];
            
        }
        
        if (!refreshBtn) {
            
            refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, PanScreenHeight - 50 - 59, 50, 50)];
            [refreshBtn setImage:[UIImage imageNamed:@"icon_refresh"] forState:UIControlStateNormal];
            [refreshBtn addTarget:self action:@selector(_requestMeterData) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:refreshBtn];
        }
        
    }];
    
    [meterTask resume];
}

//初始化地图
- (void)initMapView {
    
    _bmkMapView             = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _locService             = [[BMKLocationService alloc] init];
    
//    _bmkMapView.delegate    = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
//    _locService.delegate    = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    //设置地图类型
    _bmkMapView.mapType            = BMKMapTypeStandard;
    //罗盘模式
    _bmkMapView.userTrackingMode   = BMKUserTrackingModeFollowWithHeading;
    //显示当前位置
    _bmkMapView.showsUserLocation  = YES;
    // 设定是否显式比例尺
    _bmkMapView.showMapScaleBar    = YES;
    
//    self.view                      = _bmkMapView;
    [self.view addSubview:_bmkMapView];
    
    [self initDirectionBtn];
    [self initlayerBtn];
}

//切换视角btn
- (void)initDirectionBtn {
    
    UIButton *directionBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15 - 40 - 49, 40, 40)];
    
    [directionBtn setImage:[UIImage imageNamed:@"icon_direction@2x"] forState:UIControlStateNormal];
    
    directionBtn.backgroundColor    = [UIColor whiteColor];
    
    directionBtn.layer.cornerRadius = 5;
    
    directionBtn.alpha              = .8f;
    
    [directionBtn addTarget:self action:@selector(directionAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_bmkMapView addSubview:directionBtn];
}

//设定定位模式
- (void)directionAction {
    
    _bmkMapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    
    [_bmkMapView updateFocusIfNeeded];
}
//切换地图类型（标准、卫星）
- (void)initlayerBtn {
    
    UIButton *layerBtn       = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15*2 - 40*2 - 49, 40, 40)];
    
    layerBtn.backgroundColor = [UIColor whiteColor];
    
    [layerBtn setImage:[UIImage imageNamed:@"icon_layer@2x"] forState:UIControlStateNormal];
    
    layerBtn.layer.cornerRadius = 5;
    
    layerBtn.alpha              = .8f;
    
    [layerBtn addTarget:self action:@selector(layerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:layerBtn];
}

//切换图层
- (void)layerAction :(BOOL)type{
    
    _bmkMapView.mapType = map_type ? BMKMapTypeSatellite:BMKMapTypeStandard;
    
    map_type            = !map_type;
}

//代理
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_bmkMapView viewWillAppear];
    _bmkMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    bmkViewTag           = 300;
}

//置空
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_bmkMapView viewWillDisappear];
    _bmkMapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

#pragma mark - BMKLocationServiceDelegate
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_bmkMapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_bmkMapView updateLocationData:userLocation];
}

//设置定时器
- (void)setTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
    [timer fire];
}
//不断更改图标以实现图表闪烁效果
- (void)changeImage {
    [_bmkMapView removeAnnotations:_annomationArray];
    UIImage *image1 = [UIImage imageNamed:@"icon_bigMeter_uncomplete"];
    UIImage *image2 = [UIImage imageNamed:@"icon_bigMeter"];
    UIImage *image3 = [UIImage imageNamed:@"icon_smallMeter_uncomplete"];
    UIImage *image4 = [UIImage imageNamed:@"icon_smallMeter"];
    if (isBigMeter) {
        bmkViewTag = 300;
        if (flag) {
            
            bmkImage = image1;
        }else {
            
            bmkImage = image2;
        }
        for (int i = 0; i < _bigMeterDataArr.count; i++) {
            
            BMKPointAnnotation* bigMeterAnnotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude  = [((MapDataModel *)_bigMeterDataArr[i]).y floatValue];
            coor.longitude = [((MapDataModel *)_bigMeterDataArr[i]).x floatValue];
            bigMeterAnnotation.coordinate = coor;
            [_bmkMapView addAnnotation:bigMeterAnnotation];
            [_annomationArray addObject:bigMeterAnnotation];
            bmkViewTag++;
        }
    }else {
        
        bmkViewTag = 300;
        if (flag) {
            bmkImage = image3;
        }else {
            
            bmkImage = image4;
        }
        for (int i = 0; i < _litMeterDataArr.count; i++) {
            
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            CLLocationCoordinate2D coor;
            coor.latitude  = [((MapDataModel *)_litMeterDataArr[i]).y floatValue];
            coor.longitude = [((MapDataModel *)_litMeterDataArr[i]).x floatValue];
            annotation.coordinate = coor;
            [_bmkMapView addAnnotation:annotation];
            [_annomationArray addObject:annotation];
            bmkViewTag++;
        }
    }
    flag = !flag;
}

// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {

        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        
        if (isBigMeter) {
            [newAnnotationView setImage:bmkImage];
        } else {
            [newAnnotationView setImage:bmkImage];
        }
        
//        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        
        newAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]];
        
        paopaoBgView                    = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 80)];
        
        paopaoBgView.layer.cornerRadius = 10;
        
        paopaoBgView.backgroundColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        
        UIImageView *iconImgV           = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];
        
        iconImgV.image                  = [UIImage imageNamed:@"AppIcon60x60"];
        
        [paopaoBgView addSubview:iconImgV];
        
        UIView *v2         = [[UIView alloc]initWithFrame:CGRectMake(5, 70, 290, 1)];
        
        v2.backgroundColor = [UIColor lightGrayColor];
        
        [paopaoBgView addSubview:v2];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, 215, 25)];
        
        if (isBigMeter) {
            
            if (bmkViewTag-300 >= _bigMeterDataArr.count) {
                label.text = [((MapDataModel *)_bigMeterDataArr[_bigMeterDataArr.count-1]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }else {
                
                label.text = [((MapDataModel *)_bigMeterDataArr[bmkViewTag - 300]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }
        }else {
            if (bmkViewTag-300 >= _bigMeterDataArr.count) {
                label.text = [((MapDataModel *)_litMeterDataArr[_litMeterDataArr.count-1]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }else {
                
                label.text = [((MapDataModel *)_litMeterDataArr[bmkViewTag - 300]).bs isEqualToString:@"0"]?@"抄收状态：待抄":@"抄收状态：已抄收";
            }
        }
        [paopaoBgView addSubview:label];
        
        UIView *v1         = [[UIView alloc]initWithFrame:CGRectMake(75, 41, 210, 1)];
        
        v1.backgroundColor = [UIColor lightGrayColor];
        
        [paopaoBgView addSubview:v1];
        
        UITextView *addressLbl = [[UITextView alloc]initWithFrame:CGRectMake(75, 40, 215, 40)];
        addressLbl.font = [UIFont systemFontOfSize:12];
        
        NSLog(@"大表数据个数：%ld  小表数据个数：%ld", _bigMeterDataArr.count, _litMeterDataArr.count);
        if (isBigMeter) {
            
            if (bmkViewTag-300 >= _bigMeterDataArr.count) {
                
                addressLbl.text = [NSString stringWithFormat:@"地址：%@",((MapDataModel *)_bigMeterDataArr[_bigMeterDataArr.count-1]).install_addr];
            }else {
                
                addressLbl.text = [NSString stringWithFormat:@"地址：%@",((MapDataModel *)_bigMeterDataArr[bmkViewTag - 300]).install_addr];
            }
            
        } else {
            
            if (bmkViewTag-300 >= _litMeterDataArr.count) {
                
                addressLbl.text = [NSString stringWithFormat:@"地址：%@",((MapDataModel *)_litMeterDataArr[_litMeterDataArr.count-1]).install_addr];
            }else {
                
                addressLbl.text = [NSString stringWithFormat:@"地址：%@",((MapDataModel *)_litMeterDataArr[bmkViewTag - 300]).install_addr];
            }
        }
        addressLbl.backgroundColor        = [UIColor clearColor];
        addressLbl.textAlignment          = NSTextAlignmentLeft;
        addressLbl.userInteractionEnabled = NO;
        [paopaoBgView addSubview:addressLbl];
        
        BMKActionPaopaoView *paopaoView  = [[BMKActionPaopaoView alloc]initWithCustomView:paopaoBgView];
        
        newAnnotationView.paopaoView     = paopaoView;
        
        newAnnotationView.paopaoView.tag = bmkViewTag;
        
        
        return newAnnotationView;
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    
    [timer invalidate];
}

- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState fromOldState:(BMKAnnotationViewDragState)oldState {

    //    BMKAnnotationViewDragStateNone = 0,      ///< 静止状态.
    //    BMKAnnotationViewDragStateStarting,      ///< 开始拖动
    //    BMKAnnotationViewDragStateDragging,      ///< 拖动中
    //    BMKAnnotationViewDragStateCanceling,     ///< 取消拖动
    //    BMKAnnotationViewDragStateEnding         ///< 拖动结束
    if (newState == BMKAnnotationViewDragStateStarting) {
        [timer invalidate];
    } else if (newState == BMKAnnotationViewDragStateDragging) {
        [timer invalidate];
    } else if (newState == BMKAnnotationViewDragStateEnding) {
        [timer fire];
    }
}
////委托
//- (BMKOverlayView*)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
//{
//    if([overlay isKindOfClass:[BMKCircle class]])
//    {
//        BMKCircle* circleView = [[BMKCircle alloc] initWithOverlay:overlay];
//        circleView.fillColor = [[UIColorcyanColor] colorWithAlphaComponent:0.5];
//        circleView.strokeColor = [[UIColorblueColor] colorWithAlphaComponent:0.5];
//        circleView.lineWidth = 10.0;
//        return circleView;
//    }
//    returnnil;
//    
//}
- (void)mapStatusDidChanged:(BMKMapView *)mapView {
    [AnimationView dismiss];
    //检测地图的放大倍率
    if (mapView.getMapStatus.fLevel >13.0f) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
