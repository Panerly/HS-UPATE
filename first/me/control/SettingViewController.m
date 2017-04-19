//
//  SettingViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "UserInfoViewController.h"
#import "UIImageView+WebCache.h"


@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *identy;
    NSString *userIdenty;
    NSUInteger fileSize;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    [bgView setImage:[UIImage imageNamed:@"bg_weather3.jpg"]];
//    [self.view addSubview:bgView];
//
//    UIVisualEffectView *effectView;
//    if (!effectView) {
//        effectView = [[UIVisualEffectView alloc] initWithFrame:self.view.frame];
//    }
//    effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    [self.view addSubview:effectView];
    
    self.view.backgroundColor = COLORRGB(231, 231, 231);
    
    [self _createTableView];
    
    [self _createVersion];
    
    [self setLogOutBtn];
}

- (void)_createVersion {
    
    UIButton *versionBtn = [[UIButton alloc] initWithFrame:CGRectMake((PanScreenWidth-200)/2, PanScreenHeight - 49 -50, 200, 40)];
    [versionBtn setTitle:@"版本：V1.1.8" forState:UIControlStateNormal];
    [versionBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [versionBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [versionBtn addTarget:self action:@selector(versionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:versionBtn];
}

//版本更新内容
- (void)versionAction {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本提示" message:@"1.兼容 iOS 8.0\n2.快速查看前后日期数据\n3.更新内容提示\n4.BUG反馈群：QQ群:511584754" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (void)setLogOutBtn {
    
    UIButton *logOutBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, PanScreenHeight - 49 - 50 - 40, PanScreenWidth - 20 * 2, 40)];
    [logOutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    [logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    logOutBtn.clipsToBounds         = YES;
    logOutBtn.layer.cornerRadius    = 20;
    logOutBtn.backgroundColor       = [UIColor redColor];
    logOutBtn.titleLabel.textColor  = [UIColor blackColor];
    [self.view addSubview:logOutBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    fileSize = [[SDImageCache sharedImageCache] getDiskCount];
    [_tableView reloadData];
}

- (void)_createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStyleGrouped];
    
    _tableView.backgroundColor = [UIColor clearColor];
    
    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    
    userIdenty  = @"userIdenty";
    identy      = @"logoutIdenty";
    
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    [self.view addSubview:_tableView];
}


#pragma UITableView DataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 2) {
//        return PanScreenWidth/3;
//    }
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"账户设置";
    }
    else if (section == 1) {
        return @"缓存";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingTableViewCell *userCell = [tableView dequeueReusableCellWithIdentifier:userIdenty];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (!userCell) {
            
            userCell = [[[NSBundle mainBundle] loadNibNamed:@"SettingTableViewCell" owner:self options:nil] lastObject];
            
//            UIVisualEffectView *effectView;
//            if (!effectView) {
//                effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, userCell.frame.size.height)];
//            }
//            effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            
            userCell.backgroundColor = [UIColor whiteColor];
//            [userCell insertSubview:effectView belowSubview:userCell.contentView];
        }
        return userCell;
    }

    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1 && indexPath.row == 0) {

//        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, cell.frame.size.height)];
//        effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIImageView *cleanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreClear@2x"]];
        cleanImageView.frame = CGRectMake(10, (50-30)/2, 30, 30);
        [cell addSubview:cleanImageView];
        
        UILabel *cleanLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(cell.frame)-30, 100, 30)];
        cleanLabel.text = @"清理缓存";
        cleanLabel.textColor = [UIColor lightGrayColor];
//        cleanLabel.textColor = [UIColor colorWithRed:81/255.0f green:155/255.0f blue:248/255.0f alpha:1];
        cleanLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:cleanLabel];
        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PanScreenWidth-60, (50-25)/2, 60, 25)];
//        label.text = [NSString stringWithFormat:@"%.1fM",fileSize / 1024.0 / 1024.0];
//        label.font = [UIFont boldSystemFontOfSize:18];
//        [cell addSubview:label];

        //        [cell addSubview:effectView];
        
        return cell;
    }
//    if (indexPath.section == 1 && indexPath.row == 1) {
//        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, cell.frame.size.height)];
//        effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        
//        UIImageView *cleanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_version"]];
//        cleanImageView.frame = CGRectMake(10, (50-30)/2, 30, 30);
//        [effectView addSubview:cleanImageView];
//        
//        UILabel *cleanLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
//        cleanLabel.center = effectView.center;
//        cleanLabel.text = @"版本信息V1.1.1";
//        cleanLabel.textColor = [UIColor lightGrayColor];
//        cleanLabel.textAlignment = NSTextAlignmentCenter;
//        [effectView addSubview:cleanLabel];
//        
//        [cell addSubview:effectView];
//        
//        return cell;
//    }
//    if (indexPath.section == 1 && indexPath.row == 3) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 5, PanScreenWidth-40, 40)];
//        view.backgroundColor = [UIColor redColor];
//        view.userInteractionEnabled = NO;
//        view.layer.cornerRadius = 20;
//        [cell addSubview:view];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width-70)/2, (40-25)/2, 70, 25)];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.userInteractionEnabled = NO;
//        label.text = @"退出登录";
//        [view addSubview:label];
//        view.userInteractionEnabled = NO;
//        return cell;
//    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        
        userInfoVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController showViewController:userInfoVC sender:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (fileSize/1024.0/1024.0 > 0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否清理缓存？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [[SDImageCache sharedImageCache] cleanDisk];
                fileSize = [[SDImageCache sharedImageCache] getDiskCount];
                [self.tableView reloadData];
                
                [SCToastView showInView:self.view text:@"已清理" duration:.5f autoHide:YES];
            }];
            
            [alert addAction:cancel];
            [alert addAction:confirm];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        } else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无缓存可清除！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
           
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];

        }
        
        
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        
    }
//    if (indexPath.section == 1 && indexPath.row == 1){
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"版本提示" message:@"1. 修正历史抄见用量提示，修正流量单位\n2.延长统计显示时长\n3.优化体验\n4.修正小表数据\n5.BUG反馈群：QQ群:511584754" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//        
//        [alert addAction:cancel];
//        
//        [self presentViewController:alert animated:YES completion:^{
//            
//        }];
//        
//    }
//    if (indexPath.section == 1 && indexPath.row == 3) {
//        /**
//         *  退出登出
//         *
//         *  @param logOut 登出
//         *
//         *  @return 退回至登录界面
//         */
//        [self performSelector:@selector(logOut) withObject:nil afterDelay:0.01];
//        
//    }
}
- (void)logOut {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@"no" forKey:@"login_status"];
    
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}
@end
