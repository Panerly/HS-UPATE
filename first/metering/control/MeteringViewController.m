//
//  MeteringViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringViewController.h"
#import "MeteringSingleViewController.h"
#import "SingleViewController.h"
#import "TestViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "MeterInfoModel.h"
#import "MeterInfoTableViewCell.h"

@interface MeteringViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    //判断是大表还是小表
    BOOL isBitMeter;
    UIImageView *loading;
    NSString *cellID;
}
@property (nonatomic, assign) NSInteger num;
@end

@implementation MeteringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.backgroundColor = [UIColor orangeColor];
    
    isBitMeter = YES;
    _num = 5;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    
    [self _createTableView];
    
    [self _requestData];
    
//    UIButton *btn = [[UIButton alloc] init];
//    btn.clipsToBounds = YES;
//    btn.layer.cornerRadius = 10;
//    btn.backgroundColor = [UIColor redColor];
//    [btn setTitle:@"通知+1" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).with.offset(PanScreenWidth/6);
//        make.top.equalTo(self.view.mas_top).with.offset(100);
//        make.size.equalTo(CGSizeMake(PanScreenWidth/4, 50));
//    }];
//    
//    UIButton *btn2 = [[UIButton alloc] init];
//    btn2.clipsToBounds = YES;
//    btn2.layer.cornerRadius = 10;
//    btn2.backgroundColor = [UIColor redColor];
//    [btn2 setTitle:@"通知-1" forState:UIControlStateNormal];
//    [btn2 addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn2];
//    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.mas_right).with.offset(-PanScreenWidth/6);
//        make.top.equalTo(self.view.mas_top).with.offset(100);
//        make.size.equalTo(CGSizeMake(PanScreenWidth/4, 50));
//    }];
//
//
//    UIButton *btn3 = [[UIButton alloc] init];
//    btn3.clipsToBounds = YES;
//    btn3.layer.cornerRadius = 10;
//    btn3.backgroundColor = [UIColor redColor];
//    [btn3 setTitle:@"跳转" forState:UIControlStateNormal];
//    [btn3 addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn3];
//    [btn3 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.mas_right).with.offset(-PanScreenWidth/6);
//        make.top.equalTo(self.view.mas_top).with.offset(160);
//        make.size.equalTo(CGSizeMake(PanScreenWidth/4, 50));
//    }];
    
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
//    self.navigationItem.rightBarButtonItems = @[share];
}

//- (void)share{
//    UIImage *image = [UIImage imageNamed:@"bg_server.jpg"];
//    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
//    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    
//    id<ISSCAttachment> localAttachment = [ShareSDKCoreService attachmentWithPath:encodedImageStr];
//    //1.2、以下参数分别对应：内容、默认内容、图片、标题、链接、描述、分享类型
//    id<ISSContent> publishContent = [ShareSDK content:@"分享测试"
//                                       defaultContent:nil
//                                                image:localAttachment
//                                                title:@"测试标题"
//                                                  url:@"http://www.hzsb.com"
//                                          description:nil
//                                            mediaType:SSPublishContentMediaTypeImage];
//
//    
//    //1+、创建弹出菜单容器（iPad应用必要，iPhone应用非必要）
//    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:nil
//                            arrowDirect:UIPopoverArrowDirectionUp];
//    //2、展现分享菜单
//    [ShareSDK showShareActionSheet:container
//                         shareList:nil
//                           content:publishContent
//                     statusBarTips:NO
//                       authOptions:nil
//                      shareOptions:nil
//                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//                                
//                                NSLog(@"=== response state :%zi ",state);
//                                
//                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//                                //可以根据回调提示用户。
//                                if (state == SSResponseStateSuccess)
//                                {
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"分享成功!" preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                    
//                                }
//                                else if (state == SSResponseStateFail) {
//                                    
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:[NSString stringWithFormat:@"Error Description：%@",[error errorDescription]] preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                }
//                            }];
//    
//    
//}



- (void)push
{
    TestViewController *testVC = [[TestViewController alloc] init];
    [self presentViewController:testVC animated:YES completion:^{
        
    }];
}

//static int i = 0;
//- (void)viewWillAppear:(BOOL)animated
//{
//    if (i == 0) {
//        self.tabBarItem.badgeValue = nil;
//        i = 1;
//    }else {
//        
//        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",i ];
//    }
//}
////测试：通知加减
//- (void)btnAction
//{
//    if (i > 99) {
//        self.tabBarItem.badgeValue = @"99+";
//    }else {
//        if (i == 0) {
//            self.tabBarItem.badgeValue = nil;
//            i = 1;
//        } else {
//            if (self.tabBarItem.badgeValue == nil) {
//                self.tabBarItem.badgeValue = @"1";
//            }
//            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",i++];
//        }
//    }
//    
//}
//
//-(void)btn
//{
//    if (i>=1) {
//        
//        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",--i];
//        if (i==0) {
//            self.tabBarItem.badgeValue = nil;
//        }
//    }else
//    {
//        if (self.tabBarItem.badgeValue == nil) {
//            self.tabBarItem.badgeValue = @"1";
//            i = 1;
//        }
//        self.tabBarItem.badgeValue = nil;
//    }
//    
//}
- (void)_createTableView
{
    cellID = @"meterInfoID";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];

    [_tableView registerNib:[UINib nibWithNibName:@"MeterInfoTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    [_tableView setExclusiveTouch:YES];
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestData)];
    _tableView.mj_header.automaticallyChangeAlpha = YES;
}

//初始化加载storyboard
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        imageView.center = self.view.center;
        UIImage *image = [UIImage sd_animatedGIFNamed:@"cry4"];
        [imageView setImage:image];
        [self.view addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 25)];
        label.text = @"此功能暂未推出！";
        label.textColor = [UIColor darkGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).with.offset(10);
            make.centerX.equalTo(self.view.centerX);
        }];
        
        self = [[UIStoryboard storyboardWithName:@"Metering" bundle:nil] instantiateViewControllerWithIdentifier:@"Metering"];
    }
    return self;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}


- (IBAction)meterTypecOntrol:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            _num = 5;
            isBitMeter = YES;
            [self _requestData];
            break;
        case 1:
            _num = 10;
            isBitMeter = NO;
            [self _requestData];
        default:
            break;
    }
    
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
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
//            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
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
        
        UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:confir];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
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

    cell.backgroundColor = [UIColor clearColor];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterInfoTableViewCell" owner:self options:nil] lastObject];
    }
    cell.meterInfoModel= _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isBitMeter) {
        
        MeteringSingleViewController *meteringVC = [[MeteringSingleViewController alloc] init];
        meteringVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController showViewController:meteringVC sender:nil];
    }
    else
    {
        SingleViewController *singleVC = [[SingleViewController alloc] init];
        singleVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController showViewController:singleVC sender:nil];
    }
}


@end
