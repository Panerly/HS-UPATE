//
//  LitMeterDetailListViewController.m
//  first
//
//  Created by HS on 16/9/30.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LitMeterDetailListViewController.h"
#import "LitMeterDetailModel.h"
#import "LitMeterDetailTableViewCell.h"

#import "LitMeterDetailViewController.h"

@interface LitMeterDetailListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LitMeterDetailListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"户信息";
    
    [self setEffectView];
    
    [self initTableView];
    
    [self requestData];
}
- (void)ReturnTextBlock:(ReturnTextBlock)block {
    self.returnTextBlock = block;
}

- (void)viewWillDisappear:(BOOL)animated {
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

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    
    [_tableView registerNib:[UINib nibWithNibName:@"LitMeterDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"litMeterDetailCellID"];
    
    self.tableView.separatorStyle = NO;
    [_tableView setExclusiveTouch:YES];
    
    _tableView.mj_header = [MJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    
    [self.view addSubview:_tableView];
}

- (void)requestData {
    [SVProgressHUD showWithStatus:@"加载中"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    manager.requestSerializer.timeoutInterval = 60;
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    NSString *communityURL = [NSString stringWithFormat:@"http://192.168.3.156:8080/Hzsb/VillageServlet"];
    __weak typeof(self) weekSelf = self;

    NSDictionary *parameters = @{
                                 @"village_name":self.village_name
                                 };
    NSURLSessionTask *task = [manager POST:communityURL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            NSError *error = nil;
            [SVProgressHUD showInfoWithStatus:@"加载成功"];

            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
            NSLog(@"%@",responseObject);
            for (NSDictionary *dic in responseObject) {
                LitMeterDetailModel *model = [[LitMeterDetailModel alloc] initWithDictionary:dic error:&error];
                [_dataArr addObject:model];
            }
        }
        
        [weekSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showInfoWithStatus:@"加载失败" maskType:SVProgressHUDMaskTypeGradient];
    }];
    [task resume];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LitMeterDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"litMeterDetailCellID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LitMeterDetailTabelCell" owner:self options:nil] lastObject];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.litMeterDetailModel = _dataArr[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LitMeterDetailViewController *detail = [[LitMeterDetailViewController alloc] init];
    if (self.returnTextBlock != nil) {
//        self.returnTextBlock(((LitMeterDetailModel *)_dataArr[indexPath.row]).);
    }
    [self.navigationController showViewController:detail sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
