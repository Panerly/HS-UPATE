//
//  CommProViewController.m
//  first
//
//  Created by HS on 16/8/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CommProViewController.h"

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>

@interface CommProViewController ()

@end

@implementation CommProViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"小表概览";
    [self initMapView];
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
    
    self.view = _mapView;
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
        
        newAnnotationView.image = [UIImage imageNamed:@"icon_annotation@2x"];
        
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示

        newAnnotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1"]];

        UIView *paopaoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 240)];
        
        paopaoBgView.layer.cornerRadius = 10;

        paopaoBgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];

        UIImageView *iconImgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 50, 50)];

        iconImgV.image = [UIImage imageNamed:@"AppIcon60x60"];

        [paopaoBgView addSubview:iconImgV];

        UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(5, 70, 290, 1)];

        v2.backgroundColor = [UIColor lightGrayColor];

        [paopaoBgView addSubview:v2];

        UITextView *textV = [[UITextView alloc]initWithFrame:CGRectMake(5, 85, 290, 140)];
        textV.font = [UIFont systemFontOfSize:12];
        textV.text = @"具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n\n具体：11幢2单元301\n条码号：110110110\n姓名：张三\n抄收时间：2016-8-18\n";
        textV.backgroundColor = [UIColor clearColor];
        textV.textAlignment = NSTextAlignmentLeft;
        textV.editable = NO;
        [paopaoBgView addSubview:textV];

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
