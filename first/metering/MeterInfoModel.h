//
//  MeterInfoModel.h
//  first
//
//  Created by HS on 16/8/10.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MeterInfoModel : JSONModel
//小区名
@property (nonatomic, strong) NSString *install_Addr;
//照片名称1
@property (nonatomic, strong) NSString *collect_Img_Name1;
//照片名称2
@property (nonatomic, strong) NSString *collect_Img_Name2;
//照片名称3
@property (nonatomic, strong) NSString *collect_Img_Name3;
//所属小区或区域
@property (nonatomic, strong) NSString *collector_Area;
//通讯联络号
@property (nonatomic, strong) NSString *comm_Id;
//安装时间
@property (nonatomic, strong) NSString *install_Time;
//水表口径
@property (nonatomic, strong) NSString *meter_Cali;
@property (nonatomic, strong) NSString *meter_Id;
@property (nonatomic, strong) NSString *meter_Name;
@property (nonatomic, strong) NSString *meter_Txm;
@property (nonatomic, strong) NSString *meter_Wid;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) NSString *user_Id;
@property (nonatomic, strong) NSString *water_Kind;
//标示
@property (nonatomic, strong) NSString *bs;

//经纬度
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@property (nonatomic, strong) NSString *id;

@end
