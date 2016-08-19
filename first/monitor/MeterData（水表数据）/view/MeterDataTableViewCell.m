//
//  MeterDataTableViewCell.m
//  first
//
//  Created by HS on 16/6/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeterDataTableViewCell.h"

@implementation MeterDataTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _message.text = [NSString stringWithFormat:@"水表数据: %@",_meterDataModel.message];
    _collect_dt.text = [NSString stringWithFormat:@"收发时间: %@",_meterDataModel.collect_dt];
    _collect_num.text = [NSString stringWithFormat:@"参考读数: %@",_meterDataModel.collect_num];
    
    _messageFlg.text = [self isNormol:_meterDataModel.messageFlg];
    
}

- (NSString *)isNormol :(NSString *)messageFlg
{
    if ([messageFlg isEqualToString:@"0"]) {
        
        return @"处理状态: 已处理";
    }else
    {
        return @"处理状态: 未处理";
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
