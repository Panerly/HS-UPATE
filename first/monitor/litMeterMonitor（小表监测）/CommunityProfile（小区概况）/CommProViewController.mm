//
//  CommProViewController.m
//  first
//
//  Created by HS on 16/8/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CommProViewController.h"
#import "LitMeterDetailViewController.h"

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>

@interface CommProViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

{
    BOOL map_type;
    UIView *paopaoBgView;
}
@end

@implementation CommProViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"小表概览";
    
    map_type = YES;
    
    [self initMapView];
    
}
- (void)initTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 75, 290, 150)];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.delegate = self;
    
    _tableView.dataSource = self;
    
    [paopaoBgView addSubview:_tableView];
}

//初始化地图
- (void)initMapView {
    
    _mapView = [[BMKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _locService = [[BMKLocationService alloc] init];
    
    _mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    //设置地图类型
    _mapView.mapType = BMKMapTypeStandard;
    //罗盘模式
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    //显示当前位置
    _mapView.showsUserLocation = YES;
    
    _mapView.showMapScaleBar = YES;
    
    self.view = _mapView;
    
    [self initDirectionBtn];
    [self initlayerBtn];
}

//切换视角
- (void)initDirectionBtn {
    
    UIButton *directionBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15 - 40, 40, 40)];
    
    [directionBtn setImage:[UIImage imageNamed:@"icon_direction@2x"] forState:UIControlStateNormal];
    
    directionBtn.backgroundColor = [UIColor whiteColor];
    
    directionBtn.layer.cornerRadius = 5;
    
    directionBtn.alpha = .8f;
    
    [directionBtn addTarget:self action:@selector(directionAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mapView addSubview:directionBtn];
}

- (void)directionAction {
    
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    
    [_mapView updateFocusIfNeeded];
}

//切换地图类型（标准、卫星）
- (void)initlayerBtn {
    
    UIButton *layerBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 15 - 40, PanScreenHeight - 15*2 - 40*2, 40, 40)];
    
    layerBtn.backgroundColor = [UIColor whiteColor];
    
    [layerBtn setImage:[UIImage imageNamed:@"icon_layer@2x"] forState:UIControlStateNormal]; 
    
    layerBtn.layer.cornerRadius = 5;
    
    layerBtn.alpha = .8f;
    
    [layerBtn addTarget:self action:@selector(layerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:layerBtn];
}

- (void)layerAction :(BOOL)type{
    
    _mapView.mapType = map_type ? BMKMapTypeSatellite:BMKMapTypeStandard;
    
    map_type = !map_type;
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    // 添加一个PointAnnotation
    for (int i = 0; i < 10; i++) {
        
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = 30.289077 + i*.005;
        coor.longitude = 120.350810 + i*.005;
        annotation.coordinate = coor;
        [_mapView addAnnotation:annotation];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

#pragma mark - BMKLocationServiceDelegate
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}
// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {

        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        
        newAnnotationView.image = [UIImage imageNamed:@"icon_pin"];
        
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示

        newAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]];

        paopaoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 240)];
        
        paopaoBgView.layer.cornerRadius = 10;

        paopaoBgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];

        UIImageView *iconImgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];

        iconImgV.image = [UIImage imageNamed:@"AppIcon60x60"];

        [paopaoBgView addSubview:iconImgV];

        UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(5, 70, 290, 1)];

        v2.backgroundColor = [UIColor lightGrayColor];

        [paopaoBgView addSubview:v2];

//        UITextView *textV = [[UITextView alloc]initWithFrame:CGRectMake(5, 85, 290, 140)];
//        textV.font = [UIFont systemFontOfSize:12];
//        textV.text = @"具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n";
//        
//        textV.backgroundColor = [UIColor clearColor];
//        textV.textAlignment = NSTextAlignmentLeft;
//        textV.editable = NO;
//        [paopaoBgView addSubview:textV];
        
        [self initTableView];

        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(75, 15, 215, 25)];

        label.text = @"杭州市江干区下沙xxxx小区";
        [paopaoBgView addSubview:label];

        UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(75, 41, 210, 1)];

        v1.backgroundColor = [UIColor lightGrayColor];

        [paopaoBgView addSubview:v1];

        UITextView *addressLbl = [[UITextView alloc]initWithFrame:CGRectMake(75, 40, 215, 40)];
        addressLbl.font = [UIFont systemFontOfSize:12];
        addressLbl.text = @"地址：浙江省杭州市下沙江干区";
        addressLbl.backgroundColor = [UIColor clearColor];
        addressLbl.textAlignment = NSTextAlignmentLeft;
        addressLbl.userInteractionEnabled = NO;
        [paopaoBgView addSubview:addressLbl];

        BMKActionPaopaoView *paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:paopaoBgView];

        newAnnotationView.paopaoView = paopaoView;

        return newAnnotationView;
    }
    return nil;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"条码号：110110110\n抄收时间：216-8-18\n浙江省杭州市江干区XXX小区%ld号%ld单元",(long)indexPath.row,(long)indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LitMeterDetailViewController *householdDetail = [[LitMeterDetailViewController alloc] init];
    
    [self.navigationController showViewController:householdDetail sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
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
