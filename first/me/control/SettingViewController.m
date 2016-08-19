//
//  SettingViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"
#import "LoginViewController.h"
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _createTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    fileSize = [[SDImageCache sharedImageCache] getDiskCount];
    [_tableView reloadData];
}

- (void)_createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStyleGrouped];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    userIdenty = @"userIdenty";
    identy = @"logoutIdenty";
    
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
}


#pragma UITableView DataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 70;
    }
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

    userCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (!userCell) {
            
            userCell = [[[NSBundle mainBundle] loadNibNamed:@"SettingTableViewCell" owner:self options:nil] lastObject];
            
        }
        
        return userCell;
    }

    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIImageView *cleanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreClear@2x"]];
        cleanImageView.frame = CGRectMake(10, (50-30)/2, 30, 30);
        [cell addSubview:cleanImageView];
        
        cell.textLabel.text = @"点击清理";
        cell.textLabel.textColor = [UIColor colorWithRed:81/255.0f green:155/255.0f blue:248/255.0f alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PanScreenWidth-60, (50-25)/2, 60, 25)];
        label.text = [NSString stringWithFormat:@"%.1fM",fileSize / 1024.0 / 1024.0];
        label.font = [UIFont boldSystemFontOfSize:18];
        [cell addSubview:label];
        
        return cell;
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        
        [self.navigationController showViewController:userInfoVC sender:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (fileSize/10240/1024.0 > 0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否清理缓存？" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
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
        } else {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无缓存可清除！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
           
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:^{
                
            }];

        }
        
        
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.flag = 1;
        [self presentViewController:loginVC animated:YES completion:nil];
        loginVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}
@end
