//
//  SingleViewController.h
//  first
//
//  Created by HS on 16/6/22.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleViewController : UIViewController

<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CLLocationManagerDelegate
>
//SingleViewController.xib
- (IBAction)takePhoto:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)savePhoto:(id)sender;
- (IBAction)uploadPhoto:(id)sender;


//上期抄表度数
@property (weak, nonatomic) IBOutlet UITextField *previousReading;
//上期抄表时间
@property (weak, nonatomic) IBOutlet UITextField *previousSettle;
//本期抄表值
@property (weak, nonatomic) IBOutlet UITextField *thisPeriodValue;
//抄表情况
@property (weak, nonatomic) IBOutlet UITextField *meteringSituation;
//抄表说明
@property (weak, nonatomic) IBOutlet UITextField *meteringExplain;


//表样拍照
@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
//初始示值照片
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
//表号、条码照片
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;


@property (nonatomic, strong) UIView *scanView;

//用户信息
@property (nonatomic, strong) NSString *ipLabel;
@property (nonatomic, strong) NSString *dbLabel;
@property (nonatomic, strong) NSString *userNameLabel;
@property (nonatomic, strong) NSString *passWordLabel;

@property (nonatomic, strong) CLLocationManager* locationManager;

//经纬度
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

@property (weak, nonatomic) IBOutlet UILabel *comm_Id;

@property (weak, nonatomic) IBOutlet UILabel *install_Addr;

@property (nonatomic, strong) NSMutableArray *dataArr;


#pragma mark - 测试第二版样张
//用户名
//@property (weak, nonatomic) IBOutlet UILabel *userName;

























@end
