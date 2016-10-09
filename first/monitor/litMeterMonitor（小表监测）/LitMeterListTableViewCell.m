//
//  LitMeterListTableViewCell.m
//  first
//
//  Created by HS on 16/9/28.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterListTableViewCell.h"

@implementation LitMeterListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _village_name.text = self.litMeterModel.village_name;
    _village_num.text = [NSString stringWithFormat:@"%@户",self.litMeterModel.village_num];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
