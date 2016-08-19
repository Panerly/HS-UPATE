//
//  MeterDataModel.h
//  first
//
//  Created by HS on 16/6/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MeterDataModel : JSONModel
//参考读数
@property (nonatomic, strong) NSString *collect_num;
//收发时间
@property (nonatomic, strong) NSString *collect_dt;
//水表数据
@property (nonatomic, strong) NSString *message;
//处理状态
@property (nonatomic, strong) NSString *messageFlg;

@end
