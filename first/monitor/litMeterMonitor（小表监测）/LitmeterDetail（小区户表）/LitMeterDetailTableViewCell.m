//
//  LitMeterDetailTableViewCell.m
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterDetailTableViewCell.h"

@implementation LitMeterDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.userAddr.text = self.litMeterDetailModel.user_addr;
    NSLog(@"cell里打印：%@",self.userAddr.text);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  导航
 *
 *  @param sender <#sender description#>
 */
- (IBAction)navi:(id)sender {
}
@end
