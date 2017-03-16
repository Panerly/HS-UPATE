//
//  NewHomeViewController.m
//  first
//
//  Created by HS on 15/03/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "NewHomeViewController.h"
#import "TLCityPickerController.h"

//判定方向距离
#define touchDistance 100
//偏移
#define touchPy 10

@interface NewHomeViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSDictionary *areaidDic;

@property (assign) CGPoint beginPoint;
@property (assign) CGPoint movePoint;

@end

@implementation NewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%f", PanScreenWidth);
    [self setTitleLabel];
    
    [self setScroll];
    
    [self setNavColor];//设置导航栏颜色
    
    [self _requestWeatherData:@"杭州"];
    
    //适配4寸
    if (PanScreenWidth == 320) {
        
        [self performSelector:@selector(modifyConstant) withObject:nil afterDelay:0.1];
        
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg"]];
    
    //检测升级
    [self checkVersion];
}

-(void)checkVersion
{
    NSString *newVersion;
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/cn/lookup?id=1193445551"];//这个URL地址是该app在iTunes connect里面的相关配置信息。其中id是该app在app store唯一的ID编号。
    NSString *jsonResponseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSData *data = [jsonResponseString dataUsingEncoding:NSUTF8StringEncoding];
    
    //    解析json数据
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *array = json[@"results"];
    
    for (NSDictionary *dic in array) {
        
        newVersion = [dic valueForKey:@"version"];
    }
    
    [self compareVesionWithServerVersion:newVersion];
}

-(BOOL)compareVesionWithServerVersion:(NSString *)version{
    NSArray *versionArray = [version componentsSeparatedByString:@"."];//服务器返回版
    //获取本地软件的版本号
    NSString *APP_VERSION = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray *currentVesionArray = [APP_VERSION componentsSeparatedByString:@"."];//当前版本
    NSInteger a = (versionArray.count> currentVesionArray.count)?currentVesionArray.count : versionArray.count;
    NSLog(@"当前版本：%@ ---appstoreVersion:%@",currentVesionArray, versionArray);
    
    for (int i = 0; i< a; i++) {
        int new = [[versionArray objectAtIndex:i] intValue];
        int now = [[currentVesionArray objectAtIndex:i] intValue];
        if (new > now) {//appstore版本大于当前版本，提示更新
            NSLog(@"有新版本 new%ld-----now%ld", (long)new, (long)now);
            NSString *msg = [NSString stringWithFormat:@"发现新版本，是否下载新版本？"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"升级提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yi-ka-tongbic-ban/id1139094792?l=en&mt=8"]];//这里写的URL地址是该app在app store里面的下载链接地址，其中ID是该app在app store对应的唯一的ID编号。
                NSLog(@"点击现在升级按钮");
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击下次再说按钮");
            }]];
            
            return YES;
        }else if (new < now){//appStore版本小于当前版本
            return YES;
        }
    }
    return NO;
}

- (void)modifyConstant {
    
    self.weatherTodayImageViewWidth.constant = 120;
    self.weatherTodayImageViewHeight.constant = 100;
}

- (void)setTitleLabel {
    
    UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor       = [UIColor whiteColor];
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [titleLabel setText:@"移动互联抄表系统"];
    self.navigationItem.titleView = titleLabel;
}

- (void)setScroll {
    
    self.scrollView.contentSize = CGSizeMake(500, 0);
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
}

/**
 *  设置导航栏的颜色，返回按钮和标题为白色
 */
-(void)setNavColor{
    
    self.navigationController.navigationBar.barStyle        = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barTintColor    = COLORRGB(226, 107, 16);
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self  = [[UIStoryboard storyboardWithName:@"NewHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"NewHome"];
    }
    return self;
}
- (IBAction)selectCity:(id)sender {
    
    self.selectCityBtn.showsTouchWhenHighlighted = YES;
    __weak typeof(self)weakSelf = self;
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"选择城市",@"当前城市",@"刷新"] imageArray:@[@"icon_city",@"icon_loca",@"icon_refresh"] doneBlock:^(NSInteger selectedIndex) {
        
        if (selectedIndex == 0) {
            
            TLCityPickerController *cityPickerVC = [[TLCityPickerController alloc] init];
            
            [cityPickerVC setDelegate:(id)weakSelf];
            
            cityPickerVC.locationCityID  = [weakSelf transCityNameIntoCityCode:weakSelf.cityLabel.text];
            
//            cityPickerVC.commonCitys     = [[NSMutableArray alloc] initWithArray: @[@"1400010000", @"100010000"]];        // 最近访问城市，如果不设置，将自动管理
            cityPickerVC.hotCitys        = @[@"100010000", @"200010000", @"300210000", @"600010000", @"300110000",@"2000010000"];
            
            [weakSelf presentViewController:[[UINavigationController alloc] initWithRootViewController:cityPickerVC] animated:YES completion:^{
                
            }];
            
            
        }else if (selectedIndex == 1) {
            
            [weakSelf locationCurrentCity];
        }else if (selectedIndex == 2) {
            
            [weakSelf _requestWeatherData:weakSelf.cityLabel.text];
        }

        
    } dismissBlock:^{
        
    }];
}

//请求天气信息
- (void)_requestWeatherData:(NSString *)cityName
{
    self.cityLabel.text   = [NSString stringWithFormat:@"%@",cityName];
    
    [self loadingInfo];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager     = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSString *cityNameStr             = [self transform:cityName];
    
    NSString *replacedCityNameStr     = [cityNameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *httpArg                 = [NSString stringWithFormat:@"city=%@",replacedCityNameStr];
    
    
    NSMutableURLRequest *requestHistory  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",weatherAPI,httpArg]]];
    requestHistory.HTTPMethod = @"GET";
    
    requestHistory.timeoutInterval       = 10;
    
    [requestHistory addValue:weatherAPIkey forHTTPHeaderField:@"apikey"];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes    = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf         = self;
    
    NSURLSessionTask *hisTask = [manager dataTaskWithRequest:requestHistory uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        if (error) {
            NSLog(@"错误信息：%@",error);
        }
        
        if (responseObject) {
            
            if ([responseObject objectForKey:@"HeWeather data service 3.0"] ) {
                
                [SVProgressHUD showInfoWithStatus:@"加载成功"];
                
                NSDictionary *responseDic = [responseObject objectForKey:@"HeWeather data service 3.0"];
                
                for (NSDictionary *arr in responseDic) {
                    
                    if ([[arr objectForKey:@"status"] isEqualToString:@"unknown city"]) {
                        [SVProgressHUD showErrorWithStatus:@"未知或错误城市"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"invalid key"]){
                        [SVProgressHUD showErrorWithStatus:@"错误的key"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"no more requests"]){
                        [SVProgressHUD showErrorWithStatus:@"超过访问次数"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"param invalid"]){
                        [SVProgressHUD showErrorWithStatus:@"参数错误"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"vip over"]){
                        [SVProgressHUD showErrorWithStatus:@"付费账号过期"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"anr"]){
                        [SVProgressHUD showErrorWithStatus:@"无响应或超时"];
                        [weakSelf weatherLoadfailed];
                    } else if ([[arr objectForKey:@"status"] isEqualToString:@"permission denied"]){
                        [SVProgressHUD showErrorWithStatus:@"无访问权限"];
                        [weakSelf weatherLoadfailed];
                    }else if ([[arr objectForKey:@"status"] isEqualToString:@"ok"]){
                        
                        //风力
                        weakSelf.windDirLabel.text     = [NSString stringWithFormat:@"%@",[[[arr objectForKey:@"now"] objectForKey:@"wind"] objectForKey:@"dir"]];
                        //湿度
                        weakSelf.hunLabel.text = [NSString stringWithFormat:@"%@％",[[arr objectForKey:@"now"] objectForKey:@"hum"]];
                        //降水概率
                        weakSelf.popLabel.text = [NSString stringWithFormat:@"%@％", [[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"pop"]];
                        //现在温度
                        weakSelf.tmpLabel.text          = [NSString stringWithFormat:@"%@",[[arr objectForKey:@"now"] objectForKey:@"tmp"]];
                        //最高温度
                        weakSelf.maxTmpLabel.text = [NSString stringWithFormat:@"%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max" ]];
                        //最低温度
                        weakSelf.minTmpLabel.text = [NSString stringWithFormat:@"%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"]];
                        //更新时间
                        weakSelf.updateLabel.text              = [NSString stringWithFormat:@"%@",[[[arr objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"]];
                        //风力
                        weakSelf.windDirLabel.text    = [NSString stringWithFormat:@"%@级",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"wind"] objectForKey:@"sc"]];
                        //未来一周天气
                        weakSelf.day1TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day2TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day3TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day4TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day5TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day6TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        weakSelf.day7TmpLabel.text   = [NSString stringWithFormat:@"%@~%@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"tmp"] objectForKey:@"min"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max"]];
                        
                        //未来一周时间
                        weakSelf.day1Label.text  = [weakSelf GetTime:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"]]];
                        
                        weakSelf.day2Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"date"]]];
                        
                        weakSelf.day3Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"date"]]];
                        
                        weakSelf.day4Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"date"]]];
                        
                        weakSelf.day5Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"date"]]];
                        
                        weakSelf.day6Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"date"]]];
                        
                        weakSelf.day7Label.text  = [weakSelf GetTime2:[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"date"]]];
                        
                        weakSelf.day1WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day2WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day3WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day4WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day5WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day6WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day7WeatherImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.weatherTodayImageView.image = [UIImage imageNamed:[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                    }
                }
                
//                if ([UIImage imageNamed:[NSString stringWithFormat:@"bg_%@.jpg",self.day1Label.text]] == nil) {
//                    [weakSelf.weather_bg setImage:[UIImage imageNamed:@"bg_weather3.jpg"]];
//                }else {
//
//                    [_weather_bg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_%@.jpg",self.day1Label.text]]];
//                    CATransition *trans = [[CATransition alloc] init];
//                    trans.type = @"rippleEffect";
//                    trans.duration = .5;
//                    [_weather_bg.layer addAnimation:trans forKey:@"transition"];
//                }
                
                CATransition *transition = [[CATransition alloc] init];
                transition.type          = @"rippleEffect";
                transition.duration      = .5;
                [weakSelf.weatherTodayImageView.layer addAnimation:transition forKey:@"transition"];
                
                weakSelf.scrollView.transform = CGAffineTransformTranslate(self.scrollView.transform, PanScreenWidth, 1);
                [UIView animateWithDuration:.5 animations:^{
                    weakSelf.scrollView.transform = CGAffineTransformIdentity;
                }];
            }
        }
        else{
            [weakSelf weatherLoadfailed];
        }
        
    }];
    
    [hisTask resume];
}

//根据时间字符串获得当前星期几
-(NSString *)GetTime :(NSString *)timeStr
{
    //根据字符串转换成一种时间格式 供下面解析
//    NSString* string = @"2017-03-18 13:21";
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* inputDate = [inputFormatter dateFromString:timeStr];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:inputDate];
    NSInteger week = [comps weekday];
    NSString *strWeek = [self getweek:week];
    return strWeek;
}
-(NSString *)GetTime2 :(NSString *)timeStr
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:timeStr];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitDay |
    NSCalendarUnitWeekday |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond;
    
    comps = [calendar components:unitFlags fromDate:inputDate];
    NSInteger week = [comps weekday];
    NSString *strWeek = [self getweek:week];
    return strWeek;
}

-(NSString*)getweek:(NSInteger)week
{
    NSString*weekStr=nil;
    if(week==1)
    {
        weekStr=@"星期天";
    }else if(week==2){
        weekStr=@"星期一";
        
    }else if(week==3){
        weekStr=@"星期二";
        
    }else if(week==4){
        weekStr=@"星期三";
        
    }else if(week==5){
        weekStr=@"星期四";
        
    }else if(week==6){
        weekStr=@"星期五";
        
    }else if(week==7){
        weekStr=@"星期六";
        
    }
    return weekStr;
}


//天气加载失败
- (void)weatherLoadfailed {
    
    NSString *loadFail  = @"N/A";
    
    self.tmpLabel.text    = loadFail;
    self.maxTmpLabel.text = loadFail;
    self.minTmpLabel.text = loadFail;
    self.updateLabel.text = loadFail;
    
    self.day1TmpLabel.text = loadFail;
    self.day2TmpLabel.text = loadFail;
    self.day3TmpLabel.text = loadFail;
    self.day4TmpLabel.text = loadFail;
    self.day5TmpLabel.text = loadFail;
    self.day6TmpLabel.text = loadFail;
    self.day7TmpLabel.text = loadFail;
    
    self.day1Label.text = loadFail;
    self.day2Label.text = loadFail;
    self.day3Label.text = loadFail;
    self.day4Label.text = loadFail;
    self.day5Label.text = loadFail;
    self.day6Label.text = loadFail;
    self.day7Label.text = loadFail;
}
/**
 *  天气加载期间
 */
- (void)loadingInfo
{
    NSString *loadingStr = @"loading";
    self.tmpLabel.text      = [NSString stringWithFormat:@"🔍"];
    self.maxTmpLabel.text   = [NSString stringWithFormat:@"%@",loadingStr];
    self.minTmpLabel.text   = [NSString stringWithFormat:@"%@",loadingStr];
    self.updateLabel.text   = [NSString stringWithFormat:@"%@",loadingStr];
    
    self.day1Label.text = loadingStr;
    self.day2Label.text = loadingStr;
    self.day3Label.text = loadingStr;
    self.day4Label.text = loadingStr;
    self.day5Label.text = loadingStr;
    self.day6Label.text = loadingStr;
    self.day7Label.text = loadingStr;
}

//将汉字转换成拼音
- (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}
//将城市名转换成城市代码
- (NSString *)transCityNameIntoCityCode:(NSString *)cityNameString {
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CityData" ofType:@"plist"]];
    for (NSDictionary *groupDic in array) {
        TLCityGroup *group = [[TLCityGroup alloc] init];
        group.groupName    = [groupDic objectForKey:@"initial"];
        for (NSDictionary *dic in [groupDic objectForKey:@"citys"]) {
            if (cityNameString == [dic objectForKey:@"city_name"]) {
                return [dic objectForKey:@"city_key"];
            }
        }
    }
    return @"600010000";
}

/**
 *  定位当前城市🏙
 */
- (void)locationCurrentCity
{
    //检测定位功能是否开启
    if([CLLocationManager locationServicesEnabled]){
        if(!_locationManager){
            self.locationManager = [[CLLocationManager alloc] init];
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
        }
        [SVProgressHUD showWithStatus:@"定位中"];
        //设置代理
        self.locationManager.delegate = self;
        //设置定位精度
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置距离筛选
        [self.locationManager setDistanceFilter:5];
        //开始定位
        [self.locationManager startUpdatingLocation];
        //设置开始识别方向
        [self.locationManager startUpdatingHeading];
    }else{
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
}

/**
 *  超时操作
 */
static int timesOut = 0;
- (void)locatStatue {
    
    timesOut ++;
    if (timesOut >= 10 && _locationManager) {
        
        [_locationManager stopUpdatingLocation];
        
        _locationManager = nil;
        
        [self timesOut];
        
        timesOut = 0;
    }
    [self animationWithView:self.selectCityBtn duration:.5];
}

#pragma mark - TLCityPickerDelegate
- (void) cityPickerController:(TLCityPickerController *)cityPickerViewController didSelectCity:(TLCity *)city
{
    //去除“市” 百度天气不允许带市、自治区等后缀
    if ([city.cityName rangeOfString:@"市"].location != NSNotFound) {
        NSInteger index = [city.cityName rangeOfString:@"市"].location;
        city.cityName = [city.cityName substringToIndex:index];
    }
    if ([city.cityName rangeOfString:@"县"].location != NSNotFound) {
        NSInteger index = [city.cityName rangeOfString:@"县"].location;
        city.cityName = [city.cityName substringToIndex:index];
    }
    [self _requestWeatherData:city.cityName];
    
    [cityPickerViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) cityPickerControllerDidCancel:(TLCityPickerController *)cityPickerViewController
{
    [cityPickerViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 *  缩放动画
 *
 *  @param view     button
 *  @param duration 0.5s
 */
- (void)animationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation                     = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration            = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode            = kCAFillModeForwards;
    
    NSMutableArray *values        = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(.5, .5, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(.9, .9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    [view.layer addAnimation:animation forKey:nil];
}

/**
 *  定位超时
 */
- (void)timesOut{
    [SVProgressHUD showErrorWithStatus:@"定位超时！"];
    [_locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManangerDelegate
//定位成功以后调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [self.locationManager stopUpdatingLocation];
    CLLocation* location = locations.lastObject;
    [self reverseGeocoder:location];
    
}
//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
    
    if (_locationManager) {
        
        [_locationManager stopUpdatingLocation];
        _locationManager = nil;
    }
    [SVProgressHUD showErrorWithStatus:@"定位失败!"];
}

#pragma mark Geocoder
//反地理编码
- (void)reverseGeocoder:(CLLocation *)currentLocation {
    
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error || placemarks.count == 0){
            [SVProgressHUD showErrorWithStatus:@"定位失败"];
        }else {
            
            [SVProgressHUD showInfoWithStatus:@"定位成功"];
            
            CLPlacemark* placemark = placemarks.firstObject;
            
            NSLog(@"当前城市:%@",[[placemark addressDictionary] objectForKey:@"City"]);
            
            self.cityLabel.text = [NSString stringWithFormat:@"城市:  %@",[[placemark addressDictionary] objectForKey:@"City"]];
            
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"当前城市：%@",[[placemark addressDictionary] objectForKey:@"City"]]];
            
            NSString *cityName = [[placemark addressDictionary] objectForKey:@"City"];
            
            //去除“市” 百度天气不允许带市、自治区等后缀
            if ([cityName rangeOfString:@"市"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"市"].location;
                cityName = [cityName substringToIndex:index];
            }
            if ([cityName rangeOfString:@"自治区"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"自治区"].location;
                cityName  = [cityName substringToIndex:index];
            }
            if ([cityName rangeOfString:@"自治洲"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"自治洲"].location;
                cityName  = [cityName substringToIndex:index];
            }
            if ([cityName rangeOfString:@"县"].location != NSNotFound) {
                NSInteger index = [cityName rangeOfString:@"县"].location;
                cityName  = [cityName substringToIndex:index];
            }
            [self _requestWeatherData:cityName];
            
        }
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch=[touches anyObject];
    
    self.beginPoint=[touch locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSInteger touchCount = [touches count];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%ld",(long)touchCount]);
    
    UITouch *touch = [touches anyObject];
    
    self.movePoint = [touch locationInView:self.view];
    // 计算偏移值，取绝对值
    
    int deltaX = fabs(self.movePoint.x - self.beginPoint.x);
    
    int deltaY = fabs(self.movePoint.y - self.beginPoint.y);
    
    if (deltaX > touchDistance && deltaY <= touchPy)    {
        
        NSLog(@"横扫");
    }
    
    if (deltaY > touchDistance && deltaX <= touchPy)
        
    {
        NSLog(@"竖扫");
        
    }
    int changeX = self.movePoint.x - self.beginPoint.x;
    
    if (changeX > 0) {
        
        NSLog(@"右划");
        
        if (deltaX > touchDistance && deltaY <= touchPy)
            
        {
            NSLog(@"右划横扫");
        }
        
    }else
        
    {
        
        NSLog(@"左划");
        
        if (deltaX > touchDistance && deltaY<=touchPy)
            
        {
            NSLog(@"左划横扫");
            
        }}
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
