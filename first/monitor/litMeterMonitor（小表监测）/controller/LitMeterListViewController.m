//
//  LitMeterListViewController.m
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterListViewController.h"
#import "LitMeterDetailViewController.h"

@interface LitMeterListViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation LitMeterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"暂定小表列表";
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self initTableView];
    [self loadData];
}

- (void)initTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor colorWithRed:44/255.0f green:147/255.0f blue:209/255.0f alpha:1];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}
- (void)loadData {
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    if (!self.isExpland) {
        self.isExpland = [NSMutableArray array];
    }
    
    self.dataArray = [NSArray arrayWithObjects:@[@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号"],@[@"xx幢xx单元xx号",@"vxx幢xx单元xx号",@"xx幢xx单元xx号"],@[@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号"],nil].mutableCopy;
    //用0代表收起，非0代表展开，默认都是收起的
    for (int i = 0; i < self.dataArray.count; i++) {
        [self.isExpland addObject:@0];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *array = self.dataArray[section];
    if ([self.isExpland[section] boolValue]) {
        return array.count;
    }
    else {
        return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

//自定义SectionHeader
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIButton *headerSection = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 44)];
    
    headerSection.backgroundColor = [UIColor clearColor];
    [headerSection setBackgroundImage:[UIImage imageNamed:@"icon_section"] forState:UIControlStateNormal];
    
    NSString *imgName = ![self.isExpland[section] boolValue]?@"icon_drop_up@3x":@"icon_drop_down@3x";
    UIImage *img = [UIImage imageNamed:imgName];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(PanScreenWidth-img.size.width-20, (44-img.size.height)/2.0, img.size.width, img.size.height);
    [headerSection addSubview:imgView];
    
    //分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44-0.5, PanScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [headerSection addSubview:lineView];
    
    headerSection.tag = 666+section;
    
    //标题
    [headerSection setTitle:[NSString stringWithFormat:@"%@号小区",@(section)] forState:UIControlStateNormal];
    headerSection.titleLabel.font = [UIFont systemFontOfSize:16];
    [headerSection setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [headerSection addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return headerSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)buttonAction:(UIButton *)button {
    
    NSInteger section = button.tag - 666;
    
    //纪录展开的状态
    self.isExpland[section] = [self.isExpland[section] isEqual:@0]?@1:@0;
    
    //刷新点击的section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LitMeterDetailViewController *detail = [[LitMeterDetailViewController alloc] init];
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController showViewController:detail sender:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
