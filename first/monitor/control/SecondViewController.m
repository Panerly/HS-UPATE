//
//  SecondViewController.m
//  first
//
//  Created by HS on 16/7/12.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "SecondViewController.h"
#import "FirstCollectionViewController.h"
#import "MagicMoveInverseTransition.h"
#import "AMWaveTransition.h"
@interface SecondViewController ()<UINavigationControllerDelegate>
{
     BOOL _isHide;
}
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;
@property (strong, nonatomic) AMWaveTransition *interactive;
@end

@implementation SecondViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[UIStoryboard storyboardWithName:@"ImageBrowser" bundle:nil] instantiateViewControllerWithIdentifier:@"secondVC"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.delegate = self;
    UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(edgePanGesture:)];
    //设置从什么边界滑入
    edgePanGestureRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePanGestureRecognizer];
    
    _imageViewForSecond.userInteractionEnabled = NO;
    
    _interactive = [[AMWaveTransition alloc] init];
    
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleAction:)];
//    [self.view addGestureRecognizer:pinch];

}
//- (void)scaleAction :(UIPinchGestureRecognizer *)pinchs
//{
////    if (pinchs.velocity>0) {
//    
//        _imageViewForSecond.frame = CGRectMake(_imageViewForSecond.frame.origin.x, _imageViewForSecond.frame.origin.y, _imageViewForSecond.frame.size.width*pinchs.scale, _imageViewForSecond.frame.size.height*pinchs.scale);
//        [_imageViewForSecond setNeedsDisplay];
////    }
//}

-(void)edgePanGesture:(UIScreenEdgePanGestureRecognizer *)recognizer{
    //计算手指滑的物理距离（滑了多远，与起始位置无关）
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));//把这个百分比限制在0~1之间
    
    //当手势刚刚开始，我们创建一个 UIPercentDrivenInteractiveTransition 对象
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc]init];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
        //当手慢慢划入时，我们把总体手势划入的进度告诉 UIPercentDrivenInteractiveTransition 对象。
        [self.percentDrivenTransition updateInteractiveTransition:progress];
    }else if (recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded){
        //当手势结束，我们根据用户的手势进度来判断过渡是应该完成还是取消并相应的调用 finishInteractiveTransition 或者 cancelInteractiveTransition 方法.
        if (progress > 0.5) {
            [self.percentDrivenTransition finishInteractiveTransition];
        }else{
            [self.percentDrivenTransition cancelInteractiveTransition];
        }
        self.percentDrivenTransition = nil;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
    
    [self.navigationController setDelegate:self];
    [self.interactive attachInteractiveGestureToNavigationController:self.navigationController];
}

#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    
    if (operation != UINavigationControllerOperationNone) {
        return [AMWaveTransition transitionWithOperation:operation];
    }
    //    if ([toVC isKindOfClass:[FirstCollectionViewController class]]) {
    //        MagicMoveInverseTransition *inverseTransition = [[MagicMoveInverseTransition alloc]init];
    //        return inverseTransition;
    //    }else{
    return nil;
    //    }
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController{
    if ([animationController isKindOfClass:[MagicMoveInverseTransition class]]) {
        return self.percentDrivenTransition;
    }else{
        return nil;
    }
}


- (IBAction)tapAction:(id)sender {
    
//    _isHide = !_isHide;
//    [self.navigationController setNavigationBarHidden:_isHide animated:YES];
//    self.tabBarController.tabBar.hidden = _isHide;
    
}

- (IBAction)PanPopAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
