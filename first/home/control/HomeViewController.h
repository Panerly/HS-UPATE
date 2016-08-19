//
//  HomeViewController.h
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherModel.h"

@interface HomeViewController : UIViewController

@property (nonatomic, strong) NSString *yestoday;
@property (nonatomic, strong) NSString *tomorrow;

@property (weak, nonatomic) IBOutlet UIImageView *weatherPicImage;
@property (weak, nonatomic) IBOutlet UIImageView *yesterdayImage;
@property (weak, nonatomic) IBOutlet UIImageView *todayImage;
@property (weak, nonatomic) IBOutlet UIImageView *tomorrowImage;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *weatherDetailEffectView;

@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *weather;

@property (weak, nonatomic) IBOutlet UILabel *temLabel;
@property (weak, nonatomic) IBOutlet UILabel *windDriection;
@property (weak, nonatomic) IBOutlet UILabel *windForceScale;
@property (weak, nonatomic) IBOutlet UILabel *time;

- (IBAction)position:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *positionBtn;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (weak, nonatomic) IBOutlet UILabel *yestodayWeather;
@property (weak, nonatomic) IBOutlet UILabel *tomorrowWeather;
@property (weak, nonatomic) IBOutlet UILabel *todayWeatherInfo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *weather_bg;
@property (weak, nonatomic) IBOutlet UILabel *yesLabel;
@property (weak, nonatomic) IBOutlet UILabel *todLabel;
@property (weak, nonatomic) IBOutlet UILabel *tomLabel;

@property (nonatomic, strong) NSString *locaCity;

- (IBAction)refresh:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;

@end
