//
//  LoginViewController.m
//  first
//
//  Created by HS on 16/5/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "LoginViewController.h"
#import "HSTabBarController.h"
#import "AFHTTPSessionManager.h"
#import "HyTransitions.h"
#import "HyLoglnButton.h"
#import "ConfigViewController.h"
//#import "KeychainItemWrapper.h"

@interface LoginViewController ()<UIViewControllerTransitioningDelegate,UITextFieldDelegate>
{
    HyLoglnButton *logInButton;
    UIImageView *_hsLogoView;
    NSString *device;
//    KeychainItemWrapper *wrapper;
    NSString *notiUserName;
    NSString *notiPassWord;
    NSUserDefaults *defaults;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgImageView.image = [UIImage imageNamed:@"bg_weater2.jpg"];
    [self.view addSubview:bgImageView];
    
    defaults = [NSUserDefaults standardUserDefaults];
    _flag = 1;
    
    [self _getCode];
//    [self configKeyChainItemWrapper];
    
    //判断机型
    if (PanScreenHeight == 736) {
        device = @"6p";
    }
    else if (PanScreenHeight == 667) {
        device = @"6";
    }
    else if (PanScreenHeight == 568) {
        device = @"5";
    }
    else {
        device = @"4";
    }

    //创建杭水logo
    [self _createLogoImage];
    
    //监听键盘弹出的方式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    
    //创建登录btn
    [self _createLogBtn];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)_getCode
{
    self.passWord.text = [defaults objectForKey:@"passWord"];
    self.userName.text = [defaults objectForKey:@"userName"];
    self.ipLabel = [defaults objectForKey:@"ip"];
    self.dbLabel = [defaults objectForKey:@"db"];
}

//- (void)configKeyChainItemWrapper
//{
//    wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"PassWordNumber" accessGroup:@"hzsb.com.hzsbcop.pan"];
//    
//    //取出密码
//    self.passWord.text = [wrapper objectForKey:(id)kSecValueData];
//    
//    //取出账号
//    self.userName.text = [wrapper objectForKey:(id)kSecAttrAccount];
//    
//    //清空设置
//    //    [wrapper resetKeychainItem];
//}

- (void)_createLogoImage
{
    _hsLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    if ([device isEqualToString:@"4"]) {
        _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
        _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 30);
        
    }else if([device isEqualToString:@"6p"])
    {
        _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
        _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 30);
    }
    else if ([device isEqualToString:@"6"])
    {
    _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
    _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 50);
    }
    else if ([device isEqualToString:@"5"])
    {
        _hsLogoView.frame = CGRectMake(0, 0, PanScreenHeight/6*2.05, PanScreenHeight/6);
        _hsLogoView.center = CGPointMake(self.view.center.x, _hsLogoView.frame.size.height/2 + 50);
    }
    [self.view addSubview:_hsLogoView];
}

//int flag = 1;
- (void)popKeyBoard:(NSNotification *)notification
{
    //获取键盘的高度
    NSValue *value = notification.userInfo[@"UIKeyboardBoundsUserInfoKey"];
    CGRect rect = [value CGRectValue];
    CGFloat height = rect.size.height;
    
    
    if (_flag == 1) {
        
        _flag+=2;

            if ([device isEqualToString:@"4"]) {
                _hsLogoView.transform = CGAffineTransformScale(_hsLogoView.transform, .5, .5);
                _hsLogoView.transform = CGAffineTransformTranslate(_hsLogoView.transform, 1, -50);

            }else
            {
                _hsLogoView.transform = CGAffineTransformScale(_hsLogoView.transform, .7, .7);
            }
    }
    // 调整View的高度
    [UIView animateWithDuration:0.25 animations:^{

        //调整布局
        _userBaseView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height/4-height+40);

        if ([device isEqualToString:@"4"]) {
            
        }
        if ([device isEqualToString:@"5"]) {
            
            logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - height - 70, PanScreenWidth - 40, 40);
            
        }else
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - height - 50, PanScreenWidth - 40, 40);
        
    }];
    
}

//创建登录按钮
- (void)_createLogBtn
{
    logInButton= [[HyLoglnButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40)];
    
    [logInButton setBackgroundColor:[UIColor colorWithRed:0 green:119/255.0f blue:204.0f/255.0f alpha:1]];
    
    [logInButton setTitle:@"登录" forState:UIControlStateNormal];
    
    [logInButton addTarget:self action:@selector(LoginBtn) forControlEvents:UIControlEventTouchUpInside];
    
    logInButton.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:logInButton];
}

//初始化加载storyboard
- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"loginVC"];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


//登录
- (IBAction)LoginBtn {
    
    
//#warning 测试用直接进入首页
//    __weak typeof(self) weakSelf = self;
//    HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
//    
//    tabBarCtrl.transitioningDelegate = self;
//    
//    [weakSelf presentViewController:tabBarCtrl animated:YES completion:^{
//        
//    }];
   
//    //保存账号
//    [wrapper setObject:self.passWord.text forKey:(id)kSecAttrAccount];
//    
//    //保存密码
//    [wrapper setObject:self.userName.text forKey:(id)kSecValueData];
    
    self.ipLabel = [defaults objectForKey:@"ip"];
    self.dbLabel = [defaults objectForKey:@"db"];
    
    if (self.ipLabel == nil && self.dbLabel == nil) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请配置数据库和IP！" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        [logInButton ErrorRevertAnimationCompletion:^{
            
        }];

    }else {
    
    [UIView animateWithDuration:.25 animations:^{
        
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
        
        _hsLogoView.transform = CGAffineTransformIdentity;
        _userName.transform = CGAffineTransformIdentity;
        _passWord.transform = CGAffineTransformIdentity;
        _userBaseView.transform = CGAffineTransformIdentity;
        
        [_passWord resignFirstResponder];
        [_userName resignFirstResponder];
        
    }];
    
    //登录API 需传入的参数：用户名、密码、数据库名、IP地址
    NSString *logInUrl = [NSString stringWithFormat:@"http://%@/waterweb/LoginServlet",self.ipLabel];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.requestSerializer.timeoutInterval= 10;
    
    NSDictionary *parameters = @{@"username":self.userName.text,
                                 @"password":self.passWord.text,
                                 @"db":self.dbLabel,
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
        
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                //用户名或密码错误
                if ([[responseObject objectForKey:@"type"] isEqualToString:@"0"]) {
                    
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名或密码错误！" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [alertVC addAction:action];
                    [self presentViewController:alertVC animated:YES completion:^{
                        
                    }];
                    
                    [logInButton ErrorRevertAnimationCompletion:^{
                        
                    }];
                    
                //数据库配置错误
                }else if ([[responseObject objectForKey:@"type"] isEqualToString:@"404"]) {
                    
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据库配置错误！" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [alertVC addAction:action];
                    [self presentViewController:alertVC animated:YES completion:^{
                        
                    }];
                    
                    [logInButton ErrorRevertAnimationCompletion:^{
                        
                    }];
                }
                
                //成功进入首页
                else {
                    
                    //保存用户名和密码
                    defaults = [NSUserDefaults standardUserDefaults];
                    
                    [defaults setObject:weakSelf.userName.text forKey:@"userName"];
                    
                    [defaults setObject:weakSelf.passWord.text forKey:@"passWord"];
                    
                    [defaults setObject:[responseObject objectForKey:@"type"] forKey:@"type"];
                    
                    [defaults setObject:[responseObject objectForKey:@"area_list"] forKey:@"area_list"];
                    
                    [defaults setObject:[responseObject objectForKey:@"meter_cali_list"] forKey:@"meter_cali_list"];
                    
                    [defaults setObject:[responseObject objectForKey:@"meter_name_list"] forKey:@"meter_name_list"];
                    
                    [defaults setObject:[responseObject objectForKey:@"sb_type_list"] forKey:@"sb_type_list"];
                    
                    [defaults setObject:[responseObject objectForKey:@"type_list"] forKey:@"type_list"];
                    
                    [defaults synchronize];
                    
                    //成功进入
                    [logInButton ExitAnimationCompletion:^{
                        
                        HSTabBarController *tabBarCtrl = [[HSTabBarController alloc] init];
                        
                        tabBarCtrl.transitioningDelegate = self;
                        
                        [weakSelf presentViewController:tabBarCtrl animated:YES completion:^{
                            
                        }];
                    
                    }];
                    
                }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        } else if (error.code == 3840){
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"配置错误!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];

        }else {
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"服务器连接失败!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        [logInButton ErrorRevertAnimationCompletion:^{
            
        }];
        
    }];
    
    [task resume];
    }
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _flag = 1;
    [UIView animateWithDuration:.25 animations:^{
        
        _hsLogoView.transform = CGAffineTransformIdentity;
        _userName.transform = CGAffineTransformIdentity;
        _passWord.transform = CGAffineTransformIdentity;
        _userBaseView.transform = CGAffineTransformIdentity;
        
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
        [_passWord resignFirstResponder];
        [_userName resignFirstResponder];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    _userName.delegate = self;
    _passWord.delegate = self;
    _userName.returnKeyType = UIReturnKeyNext;
    _passWord.returnKeyType = UIReturnKeyDone;
    
    _flag = 1;
    [UIView animateWithDuration:.25 animations:^{
        
        _hsLogoView.transform = CGAffineTransformIdentity;
        _userName.transform = CGAffineTransformIdentity;
        _passWord.transform = CGAffineTransformIdentity;
        _userBaseView.transform = CGAffineTransformIdentity;
        
        logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
        [_passWord resignFirstResponder];
        [_userName resignFirstResponder];
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.5f isBOOL:true];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    return [[HyTransitions alloc]initWithTransitionDuration:0.4f StartingAlpha:0.8f isBOOL:false];
}
- (IBAction)configBtn:(id)sender {
    
    ConfigViewController *configVC = [[ConfigViewController alloc] init];
    [self presentViewController:[[ConfigViewController alloc] init] animated:YES completion:^{
        [configVC setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    }];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_userName resignFirstResponder];
        [_passWord becomeFirstResponder];
    }
    if (textField.returnKeyType == UIReturnKeyDone) {
        //用户结束输入
        [textField resignFirstResponder];
        _flag = 1;
        [UIView animateWithDuration:.25 animations:^{
            
            _hsLogoView.transform = CGAffineTransformIdentity;
            _userName.transform = CGAffineTransformIdentity;
            _passWord.transform = CGAffineTransformIdentity;
            _userBaseView.transform = CGAffineTransformIdentity;
            
            logInButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - (40 + 80), [UIScreen mainScreen].bounds.size.width - 40, 40);
            [_passWord resignFirstResponder];
            [_userName resignFirstResponder];
        }];
    }
    
    return YES;
}
@end
