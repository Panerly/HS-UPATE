//
//  LitMeterListViewController.m
//  first
//
//  Created by HS on 16/8/15.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterListViewController.h"
#import "LitMeterDetailListViewController.h"
#import "LitMeterListTableViewCell.h"
#import "LitMeterModel.h"

@interface LitMeterListViewController ()<UITableViewDelegate, UITableViewDataSource>
//{
//    NSMutableArray *villageNameArr;
//}
@end

@implementation LitMeterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"小区列表";
    self.view.backgroundColor = [UIColor cyanColor];
    
    [self setEffectView];
    
    [self initTableView];

    [self requestCommunityData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)setEffectView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setImage:[UIImage imageNamed:@"bg_server.jpg"]];
    [self.view addSubview:imageView];
    
    UIVisualEffectView *effectView;
    if (!effectView) {
        effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight)];
    }
    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    [self.view addSubview:effectView];
}

/**
 *  请求小区数据
 */
- (void)requestCommunityData {
    
    [SVProgressHUD showWithStatus:@"加载中"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval = 60;
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    NSString *communityURL = [NSString stringWithFormat:@"http://192.168.3.156:8080/Hzsb/HzsbServlet"];
    __weak typeof(self) weekSelf = self;
    
    NSURLSessionTask *task = [manager POST:communityURL parameters:NULL progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        if (!weekSelf.dataArray) {
            weekSelf.dataArray = [NSMutableArray array];
        }
        [SVProgressHUD showInfoWithStatus:@"加载成功"];
        if (responseObject) {
            NSError *error = nil;
            for (NSDictionary *dic in [responseObject objectForKey:@"village"]) {
                LitMeterModel *litMeterModel = [[LitMeterModel alloc] initWithDictionary:dic error:&error];
                [weekSelf.dataArray addObject:litMeterModel];
            }
        }
        [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showInfoWithStatus:@"加载失败"];
        NSLog(@"%@",error);
    }];
    [task resume];
}

- (void)initTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64 - 49)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.backgroundColor = [UIColor colorWithRed:44/255.0f green:147/255.0f blue:209/255.0f alpha:1];
    _tableView.backgroundColor = [UIColor clearColor];
    
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestCommunityData)];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    
    [_tableView registerNib:[UINib nibWithNibName:@"LitMeterListTableViewCell" bundle:nil] forCellReuseIdentifier:@"LitMeterListID"];
    
    [self.view addSubview:_tableView];
}

///**
// *  测试（假数据）
// */
//- (void)loadData {
//    if (!self.dataArray) {
//        self.dataArray = [NSMutableArray array];
//    }
//    if (!self.isExpland) {
//        self.isExpland = [NSMutableArray array];
//    }
//    
//    self.dataArray = [NSArray arrayWithObjects:@[@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号"],@[@"xx幢xx单元xx号",@"vxx幢xx单元xx号",@"xx幢xx单元xx号"],@[@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号",@"xx幢xx单元xx号"],nil].mutableCopy;
//    //用0代表收起，非0代表展开，默认都是收起的
//    for (int i = 0; i < self.dataArray.count; i++) {
//        [self.isExpland addObject:@0];
//    }
//    [self.tableView reloadData];
//}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LitMeterListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LitMeterListID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LitMeterListTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.litMeterModel = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LitMeterDetailListViewController *detail = [[LitMeterDetailListViewController alloc] init];
    detail.village_name = ((LitMeterModel *)_dataArray[indexPath.row]).village_name;
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController showViewController:detail sender:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}


@end
