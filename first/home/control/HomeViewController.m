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
    UIImageView *loading;
    NSTimer *timer;
}
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSDictionary *areaidDic;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weatherDetailEffectView.clipsToBounds = YES;
    self.weatherDetailEffectView.layer.cornerRadius = 10;
    
    self.dataArray = [NSMutableArray array];

    //请求天气信息
    //给个默认城市：杭州
    [self _requestWeatherData:@"杭州"];
//    [self locationCurrentCity];

    [self _createTableView];
}


- (void)_createTableView
{
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
#warning mark - disappear tableView
    _tableView.alpha = 0;
}

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
        [self.view addSubview:loading];
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
//    [SVProgressHUD showWithStatus:@"正在加载天气信息"];
    
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
            [SVProgressHUD showErrorWithStatus:@"天气加载失败"];
//            self.city.text = [NSString stringWithFormat:@"城市:  加载失败^_^!"];
            self.weather.text = [NSString stringWithFormat:@"天气:  加载失败^_^!"];
            self.temLabel.text = [NSString stringWithFormat:@"温度:  加载失败^_^!"];
            self.windDriection.text = [NSString stringWithFormat:@"风向:  加载失败^_^!"];
            self.windForceScale.text = [NSString stringWithFormat:@"风力:  加载失败^_^!"];
            self.time.text = [NSString stringWithFormat:@"日期:  加载失败^_^!"];
            self.yestodayWeather.text = [NSString stringWithFormat:@"加载失败!"];
            self.todayWeatherInfo.text = [NSString stringWithFormat:@"加载失败!"];
            self.tomorrowWeather.text = [NSString stringWithFormat:@"加载失败!"];
            
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"天气信息加载失败，请重新定位^_^!" preferredStyle:UIAlertControllerStyleAlert];
//            
//            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                
//            }];
//            
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//                
//            }];
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
    
//    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"定位中..." duration:2 autoHide:YES];
    
//    //设置加载圆点转圈动画
//    if (!loading) {
//        
//        loading = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//    }
//    loading.center = self.view.center;
    
//    UIImage *image = [UIImage sd_animatedGIFNamed:@"定位图"];
    
//    [loading setImage:image];

    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(locatStatue) userInfo:nil repeats:YES];
    
    [self locationCurrentCity];
}
- (void)locatStatue {
    [UIView animateWithDuration:.5 animations:^{
        _positionBtn.transform = CGAffineTransformMakeScale(.5, .5);
    } completion:^(BOOL finished) {
        _positionBtn.transform = CGAffineTransformIdentity;
    }];
}

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
    [SVProgressHUD showErrorWithStatus:@"定位失败!"];
}

#pragma mark Geocoder
//反地理编码
- (void)reverseGeocoder:(CLLocation *)currentLocation {
    
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error || placemarks.count == 0){
            [SVProgressHUD showErrorWithStatus:@"定位失败"];
        }else{
            [SVProgressHUD showInfoWithStatus:@"定位成功"];
            
            if ([loading isKindOfClass:[self.view class]]) {
                
                [loading removeFromSuperview];
            }
            CLPlacemark* placemark = placemarks.firstObject;
            
            NSLog(@"定位城市:%@",[[placemark addressDictionary] objectForKey:@"City"]);
            
            self.city.text = [NSString stringWithFormat:@"城市:  %@",[[placemark addressDictionary] objectForKey:@"City"]];
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"你的位置" message:[[placemark addressDictionary] objectForKey:@"City"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
#warning mark - disappear tableViewCell
    cell.backgroundColor = [UIColor colorWithWhite:.5 alpha:.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"待抄收 10 家"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeteringViewController *meteringVC = [[MeteringViewController alloc] init];
    [self.navigationController showViewController:meteringVC sender:nil];
}


- (IBAction)refresh:(UIButton *)sender {
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(refreshStatus) userInfo:nil repeats:YES];
    
    [self _requestWeatherData:self.locaCity];
}

- (void)refreshStatus {
    
    [UIView animateWithDuration:.1 animations:^{
        
        _refreshBtn.transform = CGAffineTransformRotate(_refreshBtn.transform, M_PI_4);
        
    } completion:^(BOOL finished) {
        
    }];
}

@end

