//
//  LitMeterDetailModel.h
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface LitMeterDetailModel : JSONModel

/**
 *  户名
 */
@property (nonatomic, strong) NSString *user_addr;

/**
 *  用户ID
 */
@property (nonatomic, strong) NSString *user_id;


/**
 *  地理坐标
 */
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@end
