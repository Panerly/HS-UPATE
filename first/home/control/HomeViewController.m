//
//  HomeViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "HomeViewController.h"
#import "City.h"
#import "WeatherModel.h"
#import "MeteringViewController.h"
#import "FTPopOverMenu.h"
#import "TLCityPickerController.h"
#import "FBShimmeringView.h"

@interface HomeViewController ()

<
CLLocationManagerDelegate,
UITableViewDelegate,
UITableViewDataSource
>

{
    NSTimer *timer;
    int litMeterCount;
    int bigMeterCount;
}

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSDictionary *areaidDic;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor       = [UIColor whiteColor];
    titleLabel.textAlignment   = NSTextAlignmentCenter;
    [titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [titleLabel setText:@"移动互联抄表系统"];
    self.navigationItem.titleView = titleLabel;
    
    [self setNavColor];//设置导航栏颜色
    //适配3.5寸
    if (PanScreenHeight == 480) {
        
        [self performSelector:@selector(modifyConstant) withObject:nil afterDelay:0.1];
        
    }
    
    self.weatherDetailEffectView.clipsToBounds = YES;
    self.weatherDetailEffectView.layer.cornerRadius = 10;
 
    
    self.dataArray = [NSMutableArray array];

    //请求天气信息
    //给个默认城市：杭州
    [self _requestWeatherData:@"杭州"];
//    [self locationCurrentCity];

    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"find_purview"] isEqualToString:@"00"]) {
        
        [self _createTableView];
    }else{
        self.tableView.hidden = YES;
    }
    
    //检测升级
    [self checkVersion];
}


-(void)checkVersion
{
    NSString *newVersion;
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/cn/lookup?id=1193445551"];//这个URL地址是该app在iTunes connect里面的相关配置信息。其中id是该app在app store唯一的ID编号。
    NSString *jsonResponseString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"通过appStore获取的数据信息：%@",jsonResponseString);
    
    NSData *data = [jsonResponseString dataUsingEncoding:NSUTF8StringEncoding];
    
    //    解析json数据
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSArray *array = json[@"results"];
    
    for (NSDictionary *dic in array) {
        
        
        newVersion = [dic valueForKey:@"version"];
        
    }
    
    NSLog(@"通过appStore获取的版本号是：%@",newVersion);
    
    //获取本地软件的版本号
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *msg = [NSString stringWithFormat:@"你当前的版本是V%@，发现新版本V%@，是否下载新版本？",localVersion,newVersion];

    //对比发现的新版本和本地的版本
    if (![newVersion isEqualToString:localVersion])
    {
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"升级提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
        [alert addAction:[UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yi-ka-tongbic-ban/id1139094792?l=en&mt=8"]];//这里写的URL地址是该app在app store里面的下载链接地址，其中ID是该app在app store对应的唯一的ID编号。
            NSLog(@"点击现在升级按钮");
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击下次再说按钮");
        }]];
        
        
    }
}

/**
 *  设置导航栏的颜色，返回按钮和标题为白色
 */
-(void)setNavColor{
//    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
//    if ([[ver objectAtIndex:0] intValue] >= 7) {
//        // iOS 7.0 or later
//        [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor colorFromHexString:@"12baaa"]];
//        
//        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//        
//        
//        self.navigationController.navigationBar.translucent = YES;
//        
//        
//    }else {
//        // iOS 6.1 or earlier
//        self.navigationController.navigationBar.tintColor =[UIColor colorFromHexString:@"12baaa"];
//        
//    }
    self.navigationController.navigationBar.barStyle     = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.barTintColor = COLORRGB(226, 107, 16);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

#pragma mark - setScrollView & setUI
- (void)setScrollView {
    _scrollView.contentSize                    = CGSizeMake(610, 0);
    _scrollView.scrollEnabled                  = YES;
    _scrollView.alwaysBounceHorizontal         = YES;
    _scrollView.pagingEnabled                  = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor                = [UIColor clearColor];
    
//    NSArray *labelArr = [NSArray arrayWithObjects:_day1Label,_day2Label,_day3Label,_day4Label,_day5Label,_day6Label,_day7Label, nil];
//    NSArray *imageViewArr = [NSArray arrayWithObjects:_day1Image,_day2Image,_day3Image,_day4Image,_day5Image,_day6Image,_day7Image, nil];
//    
//    for (int i = 1; i<8; i++) {
//        (UILabel *)labelArr[i] = [[UILabel alloc] init];
//        (UIImageView *)imageViewArr[i] = [[UIImageView alloc] init];
//    }
    if (!_day1Label) {
        _day1Label = [[UILabel alloc] init];
        _day2Label = [[UILabel alloc] init];
        _day3Label = [[UILabel alloc] init];
        _day4Label = [[UILabel alloc] init];
        _day5Label = [[UILabel alloc] init];
        _day6Label = [[UILabel alloc] init];
        _day7Label = [[UILabel alloc] init];
        _day1Label.textAlignment = NSTextAlignmentCenter;
        _day2Label.textAlignment = NSTextAlignmentCenter;
        _day3Label.textAlignment = NSTextAlignmentCenter;
        _day4Label.textAlignment = NSTextAlignmentCenter;
        _day5Label.textAlignment = NSTextAlignmentCenter;
        _day6Label.textAlignment = NSTextAlignmentCenter;
        _day7Label.textAlignment = NSTextAlignmentCenter;
        _day1Label.textColor = [UIColor whiteColor];
        _day2Label.textColor = [UIColor whiteColor];
        _day3Label.textColor = [UIColor whiteColor];
        _day4Label.textColor = [UIColor whiteColor];
        _day5Label.textColor = [UIColor whiteColor];
        _day6Label.textColor = [UIColor whiteColor];
        _day7Label.textColor = [UIColor whiteColor];
        [_scrollView addSubview:_day1Label];
        [_scrollView addSubview:_day2Label];
        [_scrollView addSubview:_day3Label];
        [_scrollView addSubview:_day4Label];
        [_scrollView addSubview:_day5Label];
        [_scrollView addSubview:_day6Label];
        [_scrollView addSubview:_day7Label];
        
        _day1Image = [[UIImageView alloc] init];
        _day2Image = [[UIImageView alloc] init];
        _day3Image = [[UIImageView alloc] init];
        _day4Image = [[UIImageView alloc] init];
        _day5Image = [[UIImageView alloc] init];
        _day6Image = [[UIImageView alloc] init];
        _day7Image = [[UIImageView alloc] init];
        [_scrollView addSubview:_day1Image];
        [_scrollView addSubview:_day2Image];
        [_scrollView addSubview:_day3Image];
        [_scrollView addSubview:_day4Image];
        [_scrollView addSubview:_day5Image];
        [_scrollView addSubview:_day6Image];
        [_scrollView addSubview:_day7Image];
        
        _time1Label = [[UILabel alloc] init];
        _time2Label = [[UILabel alloc] init];
        _time3Label = [[UILabel alloc] init];
        _time4Label = [[UILabel alloc] init];
        _time5Label = [[UILabel alloc] init];
        _time6Label = [[UILabel alloc] init];
        _time7Label = [[UILabel alloc] init];
        _time1Label.textAlignment = NSTextAlignmentCenter;
        _time2Label.textAlignment = NSTextAlignmentCenter;
        _time3Label.textAlignment = NSTextAlignmentCenter;
        _time4Label.textAlignment = NSTextAlignmentCenter;
        _time5Label.textAlignment = NSTextAlignmentCenter;
        _time6Label.textAlignment = NSTextAlignmentCenter;
        _time7Label.textAlignment = NSTextAlignmentCenter;
        _time1Label.textColor = [UIColor whiteColor];
        _time2Label.textColor = [UIColor whiteColor];
        _time3Label.textColor = [UIColor whiteColor];
        _time4Label.textColor = [UIColor whiteColor];
        _time5Label.textColor = [UIColor whiteColor];
        _time6Label.textColor = [UIColor whiteColor];
        _time7Label.textColor = [UIColor whiteColor];
        [_scrollView addSubview:_time1Label];
        [_scrollView addSubview:_time2Label];
        [_scrollView addSubview:_time3Label];
        [_scrollView addSubview:_time4Label];
        [_scrollView addSubview:_time5Label];
        [_scrollView addSubview:_time6Label];
        [_scrollView addSubview:_time7Label];
    }
    
    [_day1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollView.mas_left).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day1Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day1Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day1Label.centerX);
        make.top.equalTo(_day1Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    [_day2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_day1Label.mas_right).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day2Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day2Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day2Label.centerX);
        make.top.equalTo(_day2Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    [_day3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_day2Label.mas_right).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day3Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day3Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time3Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day3Label.centerX);
        make.top.equalTo(_day2Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    [_day4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_day3Label.mas_right).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day4Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day4Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time4Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day4Label.centerX);
        make.top.equalTo(_day2Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    [_day5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_day4Label.mas_right).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day5Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day5Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time5Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day5Label.centerX);
        make.top.equalTo(_day2Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    [_day6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_day5Label.mas_right).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day6Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day6Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time6Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day6Label.centerX);
        make.top.equalTo(_day2Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    [_day7Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_day6Label.mas_right).with.offset(20);
        make.top.equalTo(_scrollView.mas_top).with.offset(-50);
        make.size.equalTo(CGSizeMake(65, 20));
    }];
    [_day7Image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day7Label.centerX);
        make.top.equalTo(_day1Label.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [_time7Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_day7Label.centerX);
        make.top.equalTo(_day2Image.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(100, 20));
    }];
    
    
    self.scrollView.transform = CGAffineTransformTranslate(self.scrollView.transform, PanScreenWidth, 1);
    [UIView animateWithDuration:.5 animations:^{
        self.scrollView.transform = CGAffineTransformIdentity;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"find_purview"] isEqualToString:@"00"]) {
        
        [self _createTableView];
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
        FMDatabase *db = [FMDatabase databaseWithPath:fileName];
        
        if ([db open]) {
            
            FMResultSet *restultSet = [db executeQuery:@"select * from litMeter_info"];
            int litMeterCountNum = 0;
            int bigMeterCountNum = 0;
            while ([restultSet next]) {
                if (![[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
                    litMeterCountNum++;
                }
                if ([[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
                    bigMeterCountNum++;
                }
            }
            litMeterCount = litMeterCountNum;
            bigMeterCount = bigMeterCountNum;
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    }

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}


/**
 *  3.5寸
 */
- (void)modifyConstant {
    self.widthC.constant = 80;
    self.heightC.constant = 60;
}


- (void)_createTableView
{
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.scrollEnabled   = NO;
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
 *  天气加载期间
 */
- (void)loadingInfo
{
    NSString *loadingStr = @"loading";
    self.weather.text        = [NSString stringWithFormat:@"天气:  %@",loadingStr];
    self.temLabel.text       = [NSString stringWithFormat:@"气温:  %@",loadingStr];
    self.windDriection.text  = [NSString stringWithFormat:@"风向:  %@",loadingStr];
    self.windForceScale.text = [NSString stringWithFormat:@"风力:  %@",loadingStr];
    self.time.text           = [NSString stringWithFormat:@"日期:  %@",loadingStr];
    
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

//请求天气信息
- (void)_requestWeatherData:(NSString *)cityName
{
    self.city.text   = [NSString stringWithFormat:@"城市:  %@",cityName];
    self.locaCity    = cityName;
    
    [self loadingInfo];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager     = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSString *cityNameStr             = [self transform:cityName];
    
    NSString *replacedCityNameStr     = [cityNameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *httpArg                 = [NSString stringWithFormat:@"city=%@",replacedCityNameStr];
    
    
    NSMutableURLRequest *requestHistory  = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",weatherAPI,httpArg]]];
    NSLog(@"天气请求URL：%@",[NSString stringWithFormat:@"%@?%@",weatherAPI,httpArg]);
    requestHistory.HTTPMethod = @"GET";
    
    requestHistory.timeoutInterval       = 10;
    
    [requestHistory addValue:weatherAPIkey forHTTPHeaderField:@"apikey"];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes    = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf         = self;

    NSURLSessionTask *hisTask = [manager dataTaskWithRequest:requestHistory uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [timer invalidate];
        _refreshBtn.transform = CGAffineTransformIdentity;
        _positionBtn.transform = CGAffineTransformIdentity;
        
        if (error) {
            NSLog(@"错误信息：%@",error);
        }
        
        if (responseObject) {
        
            [weakSelf setScrollView];
            
            if ([responseObject objectForKey:@"HeWeather data service 3.0"] ) {
                [SVProgressHUD showInfoWithStatus:@"加载成功"];

                NSDictionary *responseDic = [responseObject objectForKey:@"HeWeather data service 3.0"];
                
                for (NSDictionary *arr in responseDic) {
                    
                    if ([[arr objectForKey:@"status"] isEqualToString:@"unknown city"]) {
                        
                        [self weatherLoadfailed];
                    } else {
                        
                        weakSelf.windDriection.text     = [NSString stringWithFormat:@"风向:  %@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"wind"] objectForKey:@"dir"]];
                        weakSelf.temLabel.text          = [NSString stringWithFormat:@"气温:  %@℃ ~ %@℃",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"min"],[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"tmp"] objectForKey:@"max" ]];
                        weakSelf.time.text              = [NSString stringWithFormat:@"更新时间:  %@",[[[arr objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"]];
                        weakSelf.windForceScale.text    = [NSString stringWithFormat:@"风力:  %@级",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"wind"] objectForKey:@"sc"]];
                        //今天
                        weakSelf.weather.text   = [NSString stringWithFormat:@"天气:  %@     夜间: %@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"], [[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_n"]];
                        //明天
                        weakSelf.day2Label.text   = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        //后天
                        weakSelf.day3Label.text   = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day4Label.text   = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day5Label.text   = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day6Label.text   = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day7Label.text   = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        weakSelf.day1Label.text     = [NSString stringWithFormat:@"%@",[[[[arr objectForKey:@"daily_forecast"] objectAtIndex:0] objectForKey:@"cond"] objectForKey:@"txt_d"]];
                        
                        weakSelf.time1Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"]] substringWithRange:NSMakeRange(5, 6)];
                        weakSelf.time2Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:1] objectForKey:@"date"]]substringWithRange:NSMakeRange(5, 5)];
                        weakSelf.time3Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:2] objectForKey:@"date"]]substringWithRange:NSMakeRange(5, 5)];
                        weakSelf.time4Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:3] objectForKey:@"date"]]substringWithRange:NSMakeRange(5, 5)];
                        weakSelf.time5Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:4] objectForKey:@"date"]]substringWithRange:NSMakeRange(5, 5)];
                        weakSelf.time6Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:5] objectForKey:@"date"]]substringWithRange:NSMakeRange(5, 5)];
                        weakSelf.time7Label.text  = [[NSString stringWithFormat:@"%@",[[[arr objectForKey:@"daily_forecast"] objectAtIndex:6] objectForKey:@"date"]]substringWithRange:NSMakeRange(5, 5)];
                    }
                }
                
                
                                if ([UIImage imageNamed:[NSString stringWithFormat:@"bg_%@.jpg",self.day1Label.text]] == nil) {
                                    [weakSelf.weather_bg setImage:[UIImage imageNamed:@"bg_weather3.jpg"]];
                                }else {
                                    //此张图为深色背景 将文字颜色变为白色
                                    //                if ([[NSString stringWithFormat:@"bg_%@.jpg",self.todayWeatherInfo.text] isEqualToString:@"bg_小到中雨.jpg"]) {
                                    //                    _yestodayWeather.textColor = [UIColor whiteColor];
                                    //                    _todayWeatherInfo.textColor = [UIColor whiteColor];
                                    //                    _tomorrowWeather.textColor = [UIColor whiteColor];
                                    //                    _yesLabel.textColor = [UIColor whiteColor];
                                    //                    _todLabel.textColor = [UIColor whiteColor];
                                    //                    _tomLabel.textColor = [UIColor whiteColor];
                                    //                }
                                    //                else {
                                    //                    _yestodayWeather.textColor = [UIColor blackColor];
                                    //                    _todayWeatherInfo.textColor = [UIColor blackColor];
                                    //                    _tomorrowWeather.textColor = [UIColor blackColor];
                                    //                    _yesLabel.textColor = [UIColor blackColor];
                                    //                    _todLabel.textColor = [UIColor blackColor];
                                    //                    _tomLabel.textColor = [UIColor blackColor];
                                    //                }
                                    [_weather_bg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_%@.jpg",self.day1Label.text]]];
                                    CATransition *trans = [[CATransition alloc] init];
                                    trans.type = @"rippleEffect";
                                    trans.duration = .5;
                                    [_weather_bg.layer addAnimation:trans forKey:@"transition"];
                                }
                                NSLog(@"今日天气：%@",self.day1Label.text);
                
                                weakSelf.day1Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day1Label.text]];
                                weakSelf.day2Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day2Label.text]];
                                weakSelf.day3Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day3Label.text]];
                                weakSelf.day4Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day4Label.text]];
                                weakSelf.day5Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day5Label.text]];
                                weakSelf.day6Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day6Label.text]];
                                weakSelf.day7Image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day7Label.text]];
                                weakSelf.weatherPicImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.day1Label.text]];
//                                self.todayImage.image = self.weatherPicImage.image;
                                //typedef enum : NSUInteger {
                                //    Fade = 1,                   //淡入淡出
                                //    Push,                       //推挤
                                //    Reveal,                     //揭开
                                //    MoveIn,                     //覆盖
                                //    Cube,                       //立方体
                                //    SuckEffect,                 //吮吸
                                //    OglFlip,                    //翻转
                                //    RippleEffect,               //波纹
                                //    PageCurl,                   //翻页
                                //    PageUnCurl,                 //反翻页
                                //    CameraIrisHollowOpen,       //开镜头
                                //    CameraIrisHollowClose,      //关镜头
                                //    CurlDown,                   //下翻页
                                //    CurlUp,                     //上翻页
                                //    FlipFromLeft,               //左翻转
                                //    FlipFromRight,              //右翻转
                                //
                                //} AnimationType;
                                
                                CATransition *transition = [[CATransition alloc] init];
                                transition.type          = @"rippleEffect";
                                transition.duration      = .5;
                                [_weatherPicImage.layer addAnimation:transition forKey:@"transition"];
            }
        }
        else{
            [timer invalidate];
            
            [weakSelf weatherLoadfailed];
        }
        
    }];
    
    [hisTask resume];
}

- (void)weatherLoadfailed {
    
    [SVProgressHUD showErrorWithStatus:@"天气加载失败"];
    self.weather.text        = [NSString stringWithFormat:@"天气:  N/A"];
    self.temLabel.text       = [NSString stringWithFormat:@"气温:  N/A"];
    self.windDriection.text  = [NSString stringWithFormat:@"风向:  N/A"];
    self.windForceScale.text = [NSString stringWithFormat:@"风力:  N/A"];
    self.time.text           = [NSString stringWithFormat:@"日期:  N/A"];
    
    NSString *loadFail  = @"N/A";
    self.day1Label.text = loadFail;
    self.day2Label.text = loadFail;
    self.day3Label.text = loadFail;
    self.day4Label.text = loadFail;
    self.day5Label.text = loadFail;
    self.day6Label.text = loadFail;
    self.day7Label.text = loadFail;
}

//从storyboard中加载
- (instancetype)init
{
    self = [super init];
    if (self) {
        self  = [[UIStoryboard storyboardWithName:@"HomeSB" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeSB"];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

//定位当前城市
- (IBAction)position:(id)sender {
    
    [FTPopOverMenu showForSender:sender
                        withMenu:@[@"选择城市",@"定位当前城市"]
                  imageNameArray:@[@"icon_city",@"定位2"]
                       doneBlock:^(NSInteger selectedIndex) {
                           if (selectedIndex == 0) {
                               TLCityPickerController *cityPickerVC = [[TLCityPickerController alloc] init];
                               [cityPickerVC setDelegate:(id)self];
                               
                               cityPickerVC.locationCityID  = [self transCityNameIntoCityCode:self.city.text];
                               cityPickerVC.commonCitys     = [[NSMutableArray alloc] initWithArray: @[@"1400010000", @"100010000"]];        // 最近访问城市，如果不设置，将自动管理
                               cityPickerVC.hotCitys        = @[@"100010000", @"200010000", @"300210000", @"600010000", @"300110000"];
                               
                               [self presentViewController:[[UINavigationController alloc] initWithRootViewController:cityPickerVC] animated:YES completion:^{
                                   
                               }];
                               
                               
                           }else if (selectedIndex == 1) {
                               if (timer) {
                                   
                                   [timer invalidate];
                               }
                               timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(locatStatue) userInfo:nil repeats:YES];
                               
                               [self locationCurrentCity];
                           }
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
    
    
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

#pragma mark - TLCityPickerDelegate
- (void) cityPickerController:(TLCityPickerController *)cityPickerViewController didSelectCity:(TLCity *)city
{
    if (timer) {
        
        [timer invalidate];
    }
    
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
 *  超时操作
 */
static int timesOut = 0;
- (void)locatStatue {
    timesOut ++;
    if (timesOut >= 10 && _locationManager) {
        [timer invalidate];
        [_locationManager stopUpdatingLocation];
        _locationManager = nil;
        [self timesOut];
        timesOut = 0;
    }
    [self animationWithView:_positionBtn duration:.5];
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
    [timer invalidate];
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
        if (timer) {
            [timer invalidate];
        }
        
        if(error || placemarks.count == 0){
            [SVProgressHUD showErrorWithStatus:@"定位失败"];
        }else {
            
            [SVProgressHUD showInfoWithStatus:@"定位成功"];
            
            CLPlacemark* placemark = placemarks.firstObject;
            
            NSLog(@"当前城市:%@",[[placemark addressDictionary] objectForKey:@"City"]);
            
            self.city.text = [NSString stringWithFormat:@"城市:  %@",[[placemark addressDictionary] objectForKey:@"City"]];
            
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
            self.locaCity = cityName;
            [self _requestWeatherData:cityName];
            
        }
    }];
}

#pragma mark - UITableViewDelegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"find_purview"] isEqualToString:@"00"]) {
        
        return 0;
    }else{
        
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor  = [UIColor colorWithWhite:.5 alpha:0];
    cell.selectionStyle   = UITableViewCellSelectionStyleNone;
    if (litMeterCount == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"大表待抄收 %d 个", bigMeterCount];
    }
    if (bigMeterCount == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"小表待抄收 %d 户", litMeterCount];
    }
    if (litMeterCount == 0 && bigMeterCount == 0) {
        _tableView.hidden = YES;
        cell.backgroundColor = [UIColor clearColor];
    }else {
        _tableView.hidden = NO;
    }
    cell.textLabel.text          = [NSString stringWithFormat:@"小表待抄收 %d 户     大表待抄收 %d 个",litMeterCount, bigMeterCount];
    cell.textLabel.textColor     = [UIColor whiteColor];
    cell.textLabel.font          = [UIFont systemFontOfSize:17];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    FBShimmeringView *shimmeringView           = [[FBShimmeringView alloc] initWithFrame:cell.bounds];
    shimmeringView.shimmering                  = YES;
    shimmeringView.shimmeringBeginFadeDuration = 0.4;
    shimmeringView.shimmeringOpacity           = 0.4f;
    shimmeringView.shimmeringAnimationOpacity  = 1.f;
    [self.view addSubview:shimmeringView];
    shimmeringView.center                      = self.view.center;
    shimmeringView.contentView                 = cell;
    shimmeringView.multipleTouchEnabled        = NO;
    return cell;
}

/*
 *  转跳至抄表界面
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeteringViewController *meteringVC = [[MeteringViewController alloc] init];
    [self.navigationController showViewController:meteringVC sender:nil];
}


- (IBAction)refresh:(UIButton *)sender {
    if (timer) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(refreshStatus) userInfo:nil repeats:YES];
    
    [self _requestWeatherData:self.locaCity];
}

/**
 *  刷新时btn转圈
 */
- (void)refreshStatus {
    
    [UIView animateWithDuration:.1 animations:^{
        
        _refreshBtn.transform = CGAffineTransformRotate(_refreshBtn.transform, M_PI_4);
        
    } completion:^(BOOL finished) {
        
    }];
}

@end

