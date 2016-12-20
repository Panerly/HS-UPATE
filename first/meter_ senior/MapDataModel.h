//
//  MapDataModel.h
//  first
//
//  Created by HS on 2016/12/5.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MapDataModel : JSONModel

@property (nonatomic, strong) NSString *area_id;
@property (nonatomic, strong) NSString *bs;
@property (nonatomic, strong) NSString *collect_dt;
@property (nonatomic, strong) NSString *collect_img_name1;
@property (nonatomic, strong) NSString *collect_img_name2;
@property (nonatomic, strong) NSString *collect_num;
@property (nonatomic, strong) NSString *install_addr;
@property (nonatomic, strong) NSString *meter_id;
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@end
