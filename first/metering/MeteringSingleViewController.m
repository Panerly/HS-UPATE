//
//  MeteringSingleViewController.m
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringSingleViewController.h"
#import "SingleViewController.h"
#import "MeterInfoTableViewCell.h"

@interface MeteringSingleViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *cellID;
    UIImageView *loading;
}
@end

@implementation MeteringSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"任务详情";
    
    [self _createTableView];
    [self _requestData];
}
- (void)_createTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    cellID = @"meterInfoID";
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestData)];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    
    [_tableView registerNib:[UINib nibWithNibName:@"MeterInfoTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];

}


//请求列表信息
- (void)_requestData {
    //刷新控件
    loading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
    
    if (_tableView.mj_header.isRefreshing) {
        [loading removeFromSuperview];
    }
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://192.168.3.175:8080/Meter_Reading/Meter_infoServlet"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            [weakSelf.tableView.mj_header endRefreshing];
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
            
            NSError *error;
            
            for (NSDictionary *dic in responseObject) {
                MeterInfoModel *meterInfoModel = [[MeterInfoModel alloc] initWithDictionary:dic error:&error];
                [_dataArr addObject:meterInfoModel];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            
            [loading removeFromSuperview];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        [loading removeFromSuperview];
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
    
}



#pragma mark - UITableView Delegate & DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MeterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterInfoTableViewCell" owner:self options:nil] lastObject];
    }
    cell.meterInfoModel= _dataArr[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleViewController *singleVC = [[SingleViewController alloc] init];
    singleVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:singleVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
