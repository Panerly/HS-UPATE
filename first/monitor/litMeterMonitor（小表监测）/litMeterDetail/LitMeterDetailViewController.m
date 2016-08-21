//
//  LitMeterDetailViewController.m
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterDetailViewController.h"
#import "XSChart.h"

@interface LitMeterDetailViewController ()<XSChartDataSource,XSChartDelegate>

@property(nonatomic,strong)NSArray *data;

@end

@implementation LitMeterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"小表户表信息";
    self.view.backgroundColor = [UIColor colorWithRed:44/255.0f green:147/255.0f blue:209/255.0f alpha:1];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, PanScreenHeight - 49 - 20, 100, 35)];
    saveBtn.backgroundColor = [UIColor colorWithRed:121/255.0f green:180/255.0f blue:76/255.0f alpha:1];
    saveBtn.layer.cornerRadius = 10;
    saveBtn.layer.shadowOffset = CGSizeMake(1, 1);
    saveBtn.layer.shadowColor = [[UIColor blackColor]CGColor];
    saveBtn.layer.shadowOpacity = .80f;
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:saveBtn];
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 100 - 20, PanScreenHeight - 49 - 20, 100, 35)];
    nextBtn.backgroundColor = [UIColor colorWithRed:121/255.0f green:180/255.0f blue:76/255.0f alpha:1];
    nextBtn.layer.cornerRadius = 10;
    nextBtn.layer.shadowOffset = CGSizeMake(1, 1);
    nextBtn.layer.shadowColor = [[UIColor blackColor]CGColor];
    nextBtn.layer.shadowOpacity = .80f;
    [nextBtn setTitle:@"重置" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:nextBtn];
    
    _data=@[@1,@2,@3,@4,@9,@6,@12];
    XSChart *chart=[[XSChart alloc]initWithFrame:CGRectMake(0, 270, PanScreenWidth, 220)];
    chart.backgroundColor = [UIColor clearColor];
    chart.dataSource=self;
    chart.delegate=self;
    [self.view addSubview:chart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

#pragma mark - XSChartDataSource,XSChartDelegate
-(NSInteger)numberForChart:(XSChart *)chart
{
    return _data.count;
}
-(NSInteger)chart:(XSChart *)chart valueAtIndex:(NSInteger)index
{
    return [_data[index] floatValue];
}
-(BOOL)showDataAtPointForChart:(XSChart *)chart
{
    return YES;
}
-(NSString *)chart:(XSChart *)chart titleForXLabelAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"%ld",(long)index];
}
-(NSString *)titleForChart:(XSChart *)chart
{
    return @"周用量走势";
}
-(NSString *)titleForXAtChart:(XSChart *)chart
{
    return @"日期";
}
-(NSString *)titleForYAtChart:(XSChart *)chart
{
    return @"日用量/吨";
}
-(void)chart:(XSChart *)view didClickPointAtIndex:(NSInteger)index
{
    [SCToastView showInView:self.view text:[NSString stringWithFormat:@"%ld吨",(long)index] duration:.5 autoHide:YES];
    NSLog(@"click at index:%ld",(long)index);
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
