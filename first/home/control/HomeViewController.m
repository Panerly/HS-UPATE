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

@interface HomeViewController ()<CLLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource>
{
    NSTimer *timer;
}
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSDictionary *areaidDic;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //适配3.5寸
    if (PanScreenHeight == 480) {
        
        [self performSelector:@selector(modifyConstant) withObject:nil afterDelay:0.1];
        
    }
    //适配6以上机型
    [self performSelector:@selector(modifyWeatherConstant) withObject:nil afterDelay:0.001];
    
    
    self.weatherDetailEffectView.clipsToBounds = YES;
    self.weatherDetailEffectView.layer.cornerRadius = 10;
 
    
    self.dataArray = [NSMutableArray array];

    //请求天气信息
    //给个默认城市：杭州
    [self _requestWeatherData:@"杭州"];
//    [self locationCurrentCity];

    [self _createTableView];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}



/**
 *  适配6以上机型
 */
- (void)modifyWeatherConstant {
    [UIView animateWithDuration:.001 animations:^{
        
        self.yestodayLeftConstraint.constant = PanScreenWidth/6;
        self.tommoRightConstraint.constant = PanScreenWidth/6;
    } completion:^(BOOL finished) {
        
    }];
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
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
#warning mark - disappear tableView
//    _tableView.alpha = 0;
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
    self.weather.text = [NSString stringWithFormat:@"天气:  正在加载"];
    self.temLabel.text = [NSString stringWithFormat:@"气温:  正在加载"];
    self.windDriection.text = [NSString stringWithFormat:@"风向:  正在加载"];
    self.windForceScale.text = [NSString stringWithFormat:@"风力:  正在加载"];
    self.time.text = [NSString stringWithFormat:@"日期:  正在加载"];
    self.yestodayWeather.text = [NSString stringWithFormat:@"正在加载"];
    self.todayWeatherInfo.text = [NSString stringWithFormat:@"正在加载"];
    self.tomorrowWeather.text = [NSString stringWithFormat:@"正在加载"];
}

//请求天气信息
- (void)_requestWeatherData:(NSString *)cityName
{
    self.city.text = [NSString stringWithFormat:@"城市:  %@市",cityName];
    self.locaCity = cityName;
    
    [self loadingInfo];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        
    NSString *cityNameStr = [cityName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",cityNameStr];
    
    NSMutableURLRequest *requestHistory = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",hisWeatherAPI,httpArg]]];
    
    requestHistory.HTTPMethod = @"GET";
    
    requestHistory.timeoutInterval = 10;
    
    [requestHistory addValue:weatherAPIkey forHTTPHeaderField:@"apikey"];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];

    NSURLSessionTask *hisTask = [manager dataTaskWithRequest:requestHistory uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [timer invalidate];
        _refreshBtn.transform = CGAffineTransformIdentity;
        _positionBtn.transform = CGAffineTransformIdentity;
        
        if (responseObject) {
            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            NSDictionary *responseDic = [responseObject objectForKey:@"retData"];
            
            self.windDriection.text = [NSString stringWithFormat:@"风向:  %@",[[responseDic objectForKey:@"today"] objectForKey:@"fengxiang"]];
            self.temLabel.text = [NSString stringWithFormat:@"气温:  最高%@   最低%@",[[responseDic objectForKey:@"today"] objectForKey:@"hightemp"],[[responseDic objectForKey:@"today"] objectForKey:@"lowtemp"]];
            self.time.text = [NSString stringWithFormat:@"日期:  %@",[[responseDic objectForKey:@"today"] objectForKey:@"week"]];
            self.windForceScale.text = [NSString stringWithFormat:@"风力:  %@",[[responseDic objectForKey:@"today"] objectForKey:@"fengli"]];
            self.yestodayWeather.text = [NSString stringWithFormat:@"%@",[[[responseDic objectForKey:@"history"] objectAtIndex:6] objectForKey:@"type"]];
            self.tomorrowWeather.text = [NSString stringWithFormat:@"%@",[[[responseDic objectForKey:@"forecast"] objectAtIndex:0] objectForKey:@"type"]];
            self.todayWeatherInfo.text = [NSString stringWithFormat:@"%@",[[responseDic objectForKey:@"today"] objectForKey:@"type"]];
            self.weather.text  = [NSString stringWithFormat:@"天气:  %@",self.todayWeatherInfo.text];
            
            if ([UIImage imageNamed:[NSString stringWithFormat:@"bg_%@.jpg",self.todayWeatherInfo.text]] == nil) {
                [self.weather_bg setImage:[UIImage imageNamed:@"bg_weather3.jpg"]];
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
                [_weather_bg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg_%@.jpg",self.todayWeatherInfo.text]]];
                CATransition *trans = [[CATransition alloc] init];
                trans.type = @"rippleEffect";
                trans.duration = .5;
                [_weather_bg.layer addAnimation:trans forKey:@"transition"];
            }
            
            NSLog(@"今日天气：%@",self.todayWeatherInfo.text);
            
            self.yesterdayImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.yestodayWeather.text]];
            self.tomorrowImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.tomorrowWeather.text]];
            self.weatherPicImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.todayWeatherInfo.text]];
            self.todayImage.image = self.weatherPicImage.image;
            
            
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
            CATransition *transition2 = [[CATransition alloc] init];
            transition.type = @"rippleEffect";
            transition2.type = @"cube";
            transition.duration = .5;
            transition2.duration = .5;
            [_weatherPicImage.layer addAnimation:transition forKey:@"transition"];
            [_yesterdayImage.layer addAnimation:transition2 forKey:@"transition"];
            [_todayImage.layer addAnimation:transition2 forKey:@"transition"];
            [_tomorrowImage.layer addAnimation:transition2 forKey:@"transition"];

        }
        else{
            [timer invalidate];
            [SVProgressHUD showErrorWithStatus:@"天气加载失败"];
            self.weather.text = [NSString stringWithFormat:@"天气:  加载失败^_^!"];
            self.temLabel.text = [NSString stringWithFormat:@"气温:  加载失败^_^!"];
            self.windDriection.text = [NSString stringWithFormat:@"风向:  加载失败^_^!"];
            self.windForceScale.text = [NSString stringWithFormat:@"风力:  加载失败^_^!"];
            self.time.text = [NSString stringWithFormat:@"日期:  加载失败^_^!"];
            self.yestodayWeather.text = [NSString stringWithFormat:@"加载失败!"];
            self.todayWeatherInfo.text = [NSString stringWithFormat:@"加载失败!"];
            self.tomorrowWeather.text = [NSString stringWithFormat:@"加载失败!"];
            
        }
        
    }];
    
    [hisTask resume];
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
    
    if (timer) {
        
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(locatStatue) userInfo:nil repeats:YES];
    
    [self locationCurrentCity];
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
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)]];
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
                cityName = [cityName substringToIndex:index];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
#warning mark - disappear tableViewCell
    cell.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"待抄收 10 家"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

/**
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

