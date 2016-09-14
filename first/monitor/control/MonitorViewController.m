//
//  MonitorViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MonitorViewController.h"
#import "CurrentReceiveViewController.h"
#import "MeterDataViewController.h"
#import "IntroductionViewController.h"
#import "LitMeterListViewController.h"
#import "CommProViewController.h"
//滚动视图
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"
#import "UIImageView+WebCache.h"


@interface MonitorViewController ()
<
NewPagedFlowViewDelegate,
NewPagedFlowViewDataSource,
UIWebViewDelegate
>
{
    UIButton *button;
    UIButton *litButton;
    NSMutableArray *arr;
    NSMutableArray *litBtnArr;
    UIWebView *_webView;
    UIImageView *loading;
    UISegmentedControl *segmentedCtl;
    BOOL isBigMeter;
    UIPageControl *pageControl;
}
@property (nonatomic, strong) NewPagedFlowView *pageFlowView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_server.jpg"]];
    
    isBigMeter = YES;
    
    [self setSegmentedCtl];
    
    [self addGesture];
}

- (void)addGesture {
    UISwipeGestureRecognizer *swipeToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLeftAction)];
    swipeToLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeToLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRightAction)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)gestureRightAction {
    segmentedCtl.selectedSegmentIndex = 0;
    isBigMeter = YES;
    if (_webView) {//webView没关的话退出
        [self backAction];
    }
    //移除小表
    for (int j = 200; j < 204; j++) {
        if (litButton) {
            litButton = nil;
        }
        [(UIButton *)litBtnArr[j-200] removeFromSuperview];
    }
    
    if (!_pageFlowView) {
        //添加大表及滚动视图
        [self _createButton];
        [self _createPicPlay];
        
        for (int i = 100; i < 104; i++) {
            
            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeScale(.01, .01);
        }
        
        for (int i = 100; i < 104; i++) {
            
            CGFloat duration = (i - 99) * 0.2;
            
            [UIView animateWithDuration:duration animations:^{
                
                ((UIButton *)arr[i-100]).transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    
    
}

- (void)gestureLeftAction {
    segmentedCtl.selectedSegmentIndex = 1;
    isBigMeter = NO;
    
    if (_webView) {//webView没关的话退出
        [self backAction];
    }
    
    //创建小表btn并添加animation
    if (!litButton) {
        //移除大表btn以及滚动视图
        for (int i = 100; i < 104; i++) {
            
            [UIView animateWithDuration:.5 animations:^{
                
                switch (i) {
                    case 100:
                        ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, -PanScreenWidth);
                        break;
                    case 101:
                        ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, PanScreenWidth);
                        break;
                    case 102:
                        ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, -PanScreenWidth);
                        break;
                    case 103:
                        ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, PanScreenWidth);
                        break;
                        
                    default:
                        break;
                }
                
                _pageFlowView.frame = CGRectMake(0, -[UIScreen mainScreen].bounds.size.height/3, PanScreenWidth, [UIScreen mainScreen].bounds.size.height/3);
                
            } completion:^(BOOL finished) {
                
                [(UIButton *)arr[i-100] removeFromSuperview];
                [_pageFlowView removeFromSuperview];
                _pageFlowView = nil;
                
            }];
        }
        
        //创建小表
        [self createLitBtn];
        for (int j = 200; j < 204; j++) {
            switch (j) {
                case 200:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, -PanScreenWidth);
                    break;
                case 201:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, PanScreenWidth);
                    break;
                case 202:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, -PanScreenWidth);
                    break;
                case 203:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, PanScreenWidth);
                    break;
                    
                default:
                    break;
            }
        }
        
        [UIView animateWithDuration:.5 animations:^{
            
            for (int j = 200; j < 204; j++) {
                
                ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformIdentity;
            }
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

- (void)setSegmentedCtl {
    segmentedCtl = [[UISegmentedControl alloc] initWithItems:@[@"大表监测",@"小表监测"]];
    segmentedCtl.frame = CGRectMake(0, 0, PanScreenWidth/3, 30);
    [segmentedCtl addTarget:self action:@selector(transMeters:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedCtl;
    segmentedCtl.selectedSegmentIndex = 0;
}

//选择大表还是小表
- (void)transMeters:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {//大表监测平台
        
        isBigMeter = YES;
        
        //移除小表
        for (int j = 200; j < 204; j++) {
            [((UIButton *)litBtnArr[j-200]) removeFromSuperview];
        }
        //添加大表及滚动视图
        [self _createButton];
        [self _createPicPlay];
        
        
        for (int i = 100; i < 104; i++) {
            
            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeScale(.01, .01);
        }
        
        for (int i = 100; i < 104; i++) {
            
            CGFloat duration = (i - 99) * 0.2;
            
            [UIView animateWithDuration:duration animations:^{
                
                ((UIButton *)arr[i-100]).transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
            }];
        }
        
        
    } else {//小表监测平台
        
        isBigMeter = NO;
        
        if (_webView) {//webView没关的话退出
            [self backAction];
        }
        if (button) {
            //移除大表btn以及滚动视图
            for (int i = 100; i < 104; i++) {
                
                [UIView animateWithDuration:.5 animations:^{
                    
                    switch (i) {
                        case 100:
                            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, -PanScreenWidth);
                            break;
                        case 101:
                            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, PanScreenWidth);
                            break;
                        case 102:
                            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, -PanScreenWidth);
                            break;
                        case 103:
                            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, PanScreenWidth);
                            break;
                            
                        default:
                            break;
                    }
                    
                    _pageFlowView.frame = CGRectMake(0, -[UIScreen mainScreen].bounds.size.height/3, PanScreenWidth, [UIScreen mainScreen].bounds.size.height/3);
                    
                } completion:^(BOOL finished) {
                    
                    [(UIButton *)arr[i-100] removeFromSuperview];
                    [self.imageArray removeAllObjects];
                    [pageControl removeFromSuperview];
                    pageControl = nil;
                    [_pageFlowView removeFromSuperview];
                    _pageFlowView = nil;
                    
                }];
            }
        }
        
        //创建小表btn并添加animation
        [self createLitBtn];
        for (int j = 200; j < 204; j++) {
            switch (j) {
                case 200:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, -PanScreenWidth);
                    break;
                case 201:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(-PanScreenWidth/4, PanScreenWidth);
                    break;
                case 202:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, -PanScreenWidth);
                    break;
                case 203:
                    ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformMakeTranslation(PanScreenWidth/4, PanScreenWidth);
                    break;
                    
                default:
                    break;
            }
        }
        
        [UIView animateWithDuration:.5 animations:^{
            
            for (int j = 200; j < 204; j++) {
                
                ((UIButton *)litBtnArr[j-200]).transform = CGAffineTransformIdentity;
            }
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_webView) {
        [self backAction];
    }
    if (isBigMeter) {
        
        if (!button) {
            
            [self _createButton];
        }
        [self _createPicPlay];
        
        for (int i = 100; i < 104; i++) {
            
            ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeScale(.01, .01);
        }
        
        for (int i = 100; i < 104; i++) {
            
            CGFloat duration = (i - 99) * 0.2;
            
            [UIView animateWithDuration:duration animations:^{
                
                ((UIButton *)arr[i-100]).transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    } else {
        
        if (!litButton) {
            
            [self createLitBtn];
        }
    }
    
}

//轮播图
- (void)_createPicPlay
{
    NSArray* urlsArray = @[
                           @"http://60.191.39.206:8000/waterweb/IMAGE/ios_image/04.png",
                           @"http://60.191.39.206:8000/waterweb/IMAGE/ios_image/03.png",
                           @"http://60.191.39.206:8000/waterweb/IMAGE/ios_image/02.png",
                           @"http://60.191.39.206:8000/waterweb/IMAGE/ios_image/01.png",
                           ];

    [self.imageArray addObjectsFromArray:urlsArray];
    
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height/2.7;
    if (!_pageFlowView) {
        
        _pageFlowView = [[NewPagedFlowView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-10, PanScreenWidth, viewHeight)];
        if (PanScreenHeight == 480) {
            _pageFlowView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, PanScreenWidth, viewHeight);
        }
        
        //初始化pageControl
        if (!pageControl) {
            pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _pageFlowView.frame.size.height*3.8/5, PanScreenWidth, 8)];
            _pageFlowView.pageControl = pageControl;
        }
        [_pageFlowView addSubview:pageControl];
        _pageFlowView.delegate = self;
        _pageFlowView.dataSource = self;
    }
    _pageFlowView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    _pageFlowView.layer.shadowRadius = 5;
    _pageFlowView.layer.shadowOffset = CGSizeMake(1, 1.25);
    _pageFlowView.layer.shadowOpacity = 0.8f;
    _pageFlowView.backgroundColor = [UIColor clearColor];
    _pageFlowView.minimumPageAlpha = 0.4;
    _pageFlowView.minimumPageScale = 0.83;
    _pageFlowView.orginPageCount = urlsArray.count;
    _pageFlowView.autoTime = 3.5f;
    
    [_pageFlowView startTimer];
    [self.view addSubview:_pageFlowView];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark NewPagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView {
    return CGSizeMake(PanScreenWidth - 84, (PanScreenWidth - 84) * 9 / 16);
}

//点击轮播图片做出的响应
- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex {
    
    NSLog(@"点击了第%ld张图",(long)subIndex + 1);
    
    UIButton *backBtn;
    if (subIndex == 0) {
        if (!_webView) {
            
            _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight-64-49)];
            _webView.delegate = self;
            backBtn = [[UIButton alloc] init];
        }
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:introduction]]];
        backBtn.tintColor = [UIColor redColor];
        [backBtn setImage:[UIImage imageNamed:@"close@2x"] forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_webView addSubview:backBtn];
        _webView.transform = CGAffineTransformMakeScale(.01, .01);
        [UIView animateWithDuration:.3 animations:^{
            _webView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
        
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_webView.mas_left);
            make.top.equalTo(_webView.mas_top);
            make.size.equalTo(CGSizeMake(50, 50));
        }];
        
        UIScreenEdgePanGestureRecognizer *gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(backAction)];
        [_webView addGestureRecognizer:gesture];
        
        [self.view addSubview:_webView];
    } else {
        IntroductionViewController *intrVC = [[IntroductionViewController alloc] init];
        [self.navigationController showViewController:intrVC sender:nil];
    }
}

#pragma mark NewPagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    
    return self.imageArray.count;
    
}

- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth - 50, (PanScreenWidth - 50) * 9 / 10)];
        bannerView.layer.cornerRadius = 4;
        bannerView.layer.masksToBounds = YES;
    }
    //在这里下载网络图片
    NSInteger currentIndex;
    currentIndex = index;
    if (self.imageArray.count != 0) {
        if (currentIndex>(self.imageArray.count-1)) {
            currentIndex = 3;
        }
        
        [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[currentIndex]] placeholderImage:[UIImage imageNamed:@"lunchImage.jpg"]];
    }
    
    return bannerView;
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(NewPagedFlowView *)flowView {
    
//    NSLog(@"ViewController 滚动到了第%ld页",pageNumber);
}

#pragma mark --懒加载
- (NSMutableArray *)imageArray {
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}


//webview返回btn
- (void)backAction
{
    [UIView animateWithDuration:.3 animations:^{
        _webView.transform = CGAffineTransformMakeScale(.01, .01);
        loading.transform = CGAffineTransformMakeScale(.01, .01);
    } completion:^(BOOL finished) {
        [_webView removeFromSuperview];
        [loading removeFromSuperview];
    }];
}

#pragma mark - UIWebViewdelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //刷新控件
    loading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    loading.center = self.view.center;
    
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SCToastView showInView:_webView text:@"加载失败！请稍后重试" duration:2.0f autoHide:YES];
    [loading removeFromSuperview];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loading removeFromSuperview];
}

//大表监测平台btn
- (void)_createButton
{
    CGFloat width = self.view.frame.size.width/5+15;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];//button的类型;
    arr = [[NSMutableArray alloc] init];
    [arr removeAllObjects];
    
    NSArray *titleArr = @[@"实时抄见",@"历史抄见",@"水表数据",@"水表修改"];
    NSArray *imageArr = @[@"now",@"his",@"message",@"edit"];
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height/3.5;
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            if (j == 0) {
                button = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth/2 * i + PanScreenWidth/8, 59 + viewHeight, width, width)];
            } else
                
                button = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth/2 * i + PanScreenWidth/8, width * (j+1) + j*35+viewHeight-15, width, width)];
            
            [button setBackgroundImage:[UIImage imageNamed:imageArr[i+i+j]] forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(5,13,21,button.titleLabel.bounds.size.width);//设置image在button上的位置（上top，左left，下bottom，右right）这里可以写负值，对上写－5，那么image就象上移动5个像素
            
            [button setTitle:titleArr[i+i+j] forState:UIControlStateNormal];//设置button的title
            button.titleLabel.font = [UIFont systemFontOfSize:16];//title字体大小
            button.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
            button.titleEdgeInsets = UIEdgeInsetsMake(110, -button.titleLabel.bounds.size.width, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
            
            button.tag = 100 + i+j+i;
            
            [arr addObject:button];
            
            [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:button];
        }
        
    }
}

//小表监测平台btn
- (void)createLitBtn
{
    CGFloat width = PanScreenWidth/5;
    
    litButton = [UIButton buttonWithType:UIButtonTypeCustom];//button的类型;
    
    litBtnArr = [[NSMutableArray alloc] init];
    [litBtnArr removeAllObjects];
    
    NSArray *titleArr = @[@"用户浏览",@"小区概览",@"数据查询",@"历史查询"];
    NSArray *imageArr = @[@"userScan",@"日盘点",@"光电直读",@"数据交换"];
    
    CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height/5;
    
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            
            litButton = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth/2 * i + PanScreenWidth/8, width * j+ j*80+viewHeight-15, width, width)];
            
            [litButton setBackgroundImage:[UIImage imageNamed:imageArr[i+i+j]] forState:UIControlStateNormal];
            //设置image在button上的位置（上top，左left，下bottom，右right）这里可以写负值，对上写－5，那么image就象上移动5个像素
            litButton.imageEdgeInsets = UIEdgeInsetsMake(5,13,21,button.titleLabel.bounds.size.width);
            //加阴影
            litButton.layer.shadowOffset = CGSizeMake(1, 1.5);
            litButton.layer.shadowColor = [[UIColor darkGrayColor]CGColor];
            litButton.layer.shadowOpacity = .80f;
            
            [litButton setTitle:titleArr[i+i+j] forState:UIControlStateNormal];//设置button的title
            //            litButton.titleLabel.font = [UIFont systemFontOfSize:16];//title字体大小
            litButton.titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:16];
            litButton.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
            [litButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
            [litButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
            litButton.titleEdgeInsets = UIEdgeInsetsMake(110, 0, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
            
            litButton.tag = 200 + i+j+i;
            
            [litBtnArr addObject:litButton];
            
            [litButton addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:litButton];
        }
        
    }
}

- (void)clicked:(UIButton *)sender
{
    CurrentReceiveViewController *currentReceiveVC = [[CurrentReceiveViewController alloc] init];
    MeterDataViewController *dataVC = [[MeterDataViewController alloc] init];
    LitMeterListViewController *litMeterVC = [[LitMeterListViewController alloc] init];
    CommProViewController *communProfVC = [[CommProViewController alloc] init];

    GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"提示" message:@"此功能暂未推出" buttonTitle:@"确定" buttonTouchedAction:^{
        
    } dismissAction:^{
        
    }];
    
    switch (sender.tag) {//100-103大表监测   200-203小表监测
            
        case 100:
            currentReceiveVC.isRealTimeOrHis = 0;
            [self.navigationController showViewController:currentReceiveVC sender:nil];
            
            break;
        case 101:
            currentReceiveVC.isRealTimeOrHis = 1;
            [self.navigationController showViewController:currentReceiveVC sender:nil];
            
            break;
        case 102:
            dataVC.isBigMeter = YES;
            [self.navigationController showViewController:dataVC sender:nil];
            
            break;
        case 103:
            currentReceiveVC.isRealTimeOrHis = 2;
            [self.navigationController showViewController:currentReceiveVC sender:nil];
            
            break;
        case 200://小表列表
            [self.navigationController showViewController:litMeterVC sender:nil];
            
            break;
        case 201:
            communProfVC.hidesBottomBarWhenPushed = YES;
            communProfVC.view.backgroundColor = [UIColor whiteColor];
            
            [self.navigationController showViewController:communProfVC sender:nil];
            
            break;
        case 202:
            dataVC.isBigMeter = NO;
            [self.navigationController showViewController:dataVC sender:nil];
            
            break;
        case 203:
            [alertView show];
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (self.view.window == nil && [self isViewLoaded]) {
        self.view = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.pageFlowView stopTimer];
}
- (void)dealloc {
    
    /****************************
     在dealloc或者返回按钮里停止定时器
     ****************************/
    NSLog(@"停止定时器");
    [self.pageFlowView stopTimer];
}
@end
