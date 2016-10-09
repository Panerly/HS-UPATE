//
//  AppDelegate.m
//  first
//
//  Created by HS on 16/5/19.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "AppDelegate.h"
#import "HSTabBarController.h"
#import "LoginViewController.h"
#import "SingleViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

//ShareSDK头文件
#import <ShareSDK/ShareSDK.h>
//以下是ShareSDK必须添加的依赖库：
//1、SystemConfiguration.framework
//2、QuartzCore.framework
//3、CoreTelephony.framework
//4、libicucore.dylib
//5、libz.1.2.5.dylib
//6、Security.framework
//7、JavaScriptCore.framework
//8、libstdc++.dylib
//9、CoreText.framework

//＝＝＝＝＝＝＝＝＝＝以下是各个平台SDK的头文件，根据需要集成的平台添加＝＝＝
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//以下是腾讯SDK的依赖库：
//libsqlite3.dylib

//微信SDK头文件
#import "WXApi.h"
//以下是微信SDK的依赖库：
//libsqlite3.dylib


////Pinterest SDK头文件
//#import <Pinterest/Pinterest.h>


BMKMapManager* _mapManager;

@interface AppDelegate ()
{
    NSUserDefaults *defaults;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //检测网络
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 一共有四种状态
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"AFNetworkReachability Not Reachable");
                
                [SVProgressHUD showInfoWithStatus:@"似乎已断开与互联网的连接" maskType:SVProgressHUDMaskTypeGradient];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"AFNetworkReachability Reachable via WWAN");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"AFNetworkReachability Reachable via WiFi");
                break;
            case AFNetworkReachabilityStatusUnknown:
            default:
                NSLog(@"AFNetworkReachability Unknown");
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"UBQFxfj8qazWAtt1gkYZLdKGG2AAb83G"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"mapManager start failed!");
    }
    
    
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    self.window.rootViewController = loginVC;
    [self.window makeKeyAndVisible];
    
    //多个控件接受事件时的排他性
    [[UIButton appearance] setExclusiveTouch:YES];
    
    [ShareSDK registerApp:@"158556148371e"];
    
    //初始化社交平台
    [self initializePlat];
    
    [self getPushMessage];
    
    return YES;
}



/**
 *  添加通知
 */
- (void)locationNotification :(NSInteger )alertNum{
    
    if ([[UIApplication sharedApplication]currentUserNotificationSettings].types!=UIUserNotificationTypeNone) {
        
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if (notification!=nil) {
            NSDate *now = [NSDate date];
            //从现在开始，10秒以后通知
            notification.fireDate=[now dateByAddingTimeInterval:0];
            //使用本地时区
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.alertBody=[NSString stringWithFormat:@"小表待抄%ld小区", alertNum];
            //通知提示音 使用默认的
            notification.soundName= UILocalNotificationDefaultSoundName;
            notification.alertAction=NSLocalizedString(@"滑动屏幕进行抄收", nil);
            //这个通知到时间时，你的应用程序右上角显示的数字。
            notification.applicationIconBadgeNumber = 1;
            //add key  给这个通知增加key 便于半路取消。nfkey这个key是我自己随便起的。
            // 假如你的通知不会在还没到时间的时候手动取消 那下面的两行代码你可以不用写了。
            NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"nfkey",nil];
            [notification setUserInfo:dict];
            //启动这个通知
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    } else {
        [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound  categories:nil]];
    }
    
}


/**
 *  点击通知做出反应
 */

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self showMeteringVC];
    
}

- (void)showMeteringVC {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[[LoginViewController alloc] init] showDetailViewController:[[SingleViewController alloc] init] sender:nil];
}

- (void)initializePlat
{
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wx947dfa7241a19ca0" wechatCls:[WXApi class]];
    [ShareSDK connectWeChatWithAppId:@"wx947dfa7241a19ca0"
                           appSecret:@"bb3324d49d0466557eabf44cf3c7714f"
                           wechatCls:[WXApi class]];
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
//    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
//                     qqApiInterfaceCls:[QQApiInterface class]
//                       tencentOAuthCls:[TencentOAuth class]];
    
    //连接邮件
    [ShareSDK connectMail];
    
//    //连接打印
//    [ShareSDK connectAirPrint];
    
    //连接拷贝
    [ShareSDK connectCopy];
    
}

#pragma mark - 如果使用SSO（可以简单理解成跳客户端授权），以下方法是必要的

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -获取推送消息
- (void)getPushMessage {
    NSString *pushUrl = [NSString stringWithFormat:@"http://192.168.3.175:8080/Meter_Reading/Meter_areaServlet"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:pushUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray *dataArr = [NSMutableArray array];
        
        if (responseObject) {
            for (NSDictionary *dic in responseObject) {
                [dataArr addObject:[dic objectForKey:@"area_Name"]];
            }
        }
        if (dataArr.count > 0) {
            [weakSelf locationNotification:dataArr.count];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    [task resume];
}

@end
