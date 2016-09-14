//
//  CompleteTableViewCell.m
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CompleteTableViewCell.h"
#import "CompleteViewController.h"


@implementation CompleteTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.meter_id.text = [NSString stringWithFormat:@"meter_id:%@",self.completeModel.meter_id];
    self.user_id.text = [NSString stringWithFormat:@"user_id:%@",self.completeModel.user_id];
    self.compImage.image = self.completeModel.image;
    _click = self.completeModel.user_id;
}



- (UIViewController *)findVC
{
    UIResponder *next = self.nextResponder;
    
    while (1) {
        
        if ([next isKindOfClass:[UIViewController class]]) {
            return  (UIViewController *)next;
        }
        next =  next.nextResponder;
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

//上传数据
- (IBAction)upload:(id)sender {
    
    [self createDB];
    
}
- (void)createDB {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    [db open];
    [db executeUpdate:[NSString stringWithFormat:@"delete from meter_complete where user_id = '%@'",_click]];
    
    FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM meter_complete order by user_id"];
    [((CompleteViewController *)[self findVC]).dataArr removeAllObjects];
    while ([restultSet next]) {
        NSString *meter_id = [restultSet stringForColumn:@"meter_id"];
        NSString *user_id = [restultSet stringForColumn:@"user_id"];

        CompleteModel *completeModel = [[CompleteModel alloc] init];
        completeModel.meter_id = [NSString stringWithFormat:@"%@",meter_id];
        completeModel.user_id =[NSString stringWithFormat:@"%@",user_id];
        [((CompleteViewController *)[self findVC]).dataArr addObject:completeModel];
    }
    [db close];
    
    [((CompleteViewController *)[self findVC]).tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [SCToastView showInView:((CompleteViewController *)[self findVC]).tableView text:@"上传成功" duration:.5 autoHide:YES];
}

@end
