//
//  TableViewCell.m
//  first
//
//  Created by HS on 16/8/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.meter_id.text = [NSString stringWithFormat:@"meter_id:%@",self.DBModel.meter_id];
    self.user_id.text = [NSString stringWithFormat:@"user_id:%@",self.DBModel.user_id];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
