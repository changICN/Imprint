//
//  FactoryMachineView.m
//  Imprint
//
//  Created by Geoff Baker on 10/12/2018.
//  Copyright © 2018 ICN. All rights reserved.
//

#import "FactoryMachineView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SWRevealViewController.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import "Reachability.h"
#import "MBProgressHUD.h"
//#import <Parse/Parse.h>
#import "Flurry.h"
#import "ImprintDatabase.h"

@interface FactoryMachineView ()

@end

@implementation FactoryMachineView {
    //Decide the orientation of the device
    UIDeviceOrientation Orientation;
    NSUserDefaults *defaults;
    
    UIView *overlay;
    UIView *overlayCont;
    UIWebView *webView;
    UIWebView *webViewExt;
    
    NSTimer *updateTimer;
    
    //Loading Animation
    MBProgressHUD *Hud;
    UIImageView *activityImageView;
    UIActivityIndicatorView *activityView;
    
    NSDictionary *operationCodes;
    UIView *graphBackground;
    UIScrollView *graphScroller;
    UIBezierPath *path;
    CAShapeLayer *shape;
    CAGradientLayer *gradientLayer;
    
    UILabel *ten;
    UILabel *twenty;
    UILabel *thirty;
    UILabel *forty;
    UILabel *fiddy;
    
    NSDate *add5Mins;
    int graphTimeGap;
    int graphMoveX;
    
    NSMutableArray *speedHistory;
    
    //Update UI Dynamic
    UILabel *jobMachineValue;
    UILabel *titleMachineValue;
    UILabel *sectionMachineValue;
    UILabel *speedMachineValue;
    UIView *progressCont;
}
@synthesize selectedData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    //Decide the orientation of the device
    Orientation = [[UIDevice currentDevice]orientation];
    
    /*
     Observer For App Background Handling
     */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    //Header
    [self.navigationController.navigationBar  setBarTintColor:[UIColor colorWithRed:172/255.0f
                                                                              green:200/255.0f
                                                                               blue:55/255.0f
                                                                              alpha:1.0f]];
    [_sidebarButton setEnabled:NO];
    [_sidebarButton setTintColor: [UIColor clearColor]];
    
    self.navigationController.navigationBarHidden = NO;
    
    UIImageView *navigationImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 110, 38)];
    if(Orientation == UIDeviceOrientationLandscapeRight || Orientation == UIDeviceOrientationLandscapeLeft){
        if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
        {
            [navigationImage setFrame:CGRectMake(25, 4, 100, 28)];
        }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
        {
            [navigationImage setFrame:CGRectMake(-30, -12, 170, 53)];
        }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
        {
            [navigationImage setFrame:CGRectMake(25, 4, 100, 28)];
        }else{
            [navigationImage setFrame:CGRectMake(25, 4, 100, 28)];
        }
        
    }
    navigationImage.image=[UIImage imageNamed:@"logo"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        workaroundImageView.frame = CGRectMake(0, 0, 110, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        workaroundImageView.frame = CGRectMake(0, 0, 110, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        workaroundImageView.frame = CGRectMake(0, 0, 110, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        workaroundImageView.frame = CGRectMake(0, 0, 110, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height >= 812) //iPhone X size
    {
        workaroundImageView.frame = CGRectMake(0, 0, 110, 40);
    } else {
        workaroundImageView.frame = CGRectMake(0, 0, 110, 40);
    }
    
    [workaroundImageView addSubview:navigationImage];
    self.navigationItem.titleView=workaroundImageView;
    self.navigationItem.titleView.center = self.view.center;
    
    // Build your regular UIBarButtonItem with Custom View
    UIImage *image = [UIImage imageNamed:@"ic_back"];
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0, 5, 5);
    leftBarButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 30);
    [leftBarButton addTarget:self action:@selector(popViewControllerWithAnimation) forControlEvents:UIControlEventTouchDown];
    [leftBarButton setImage:image forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //    BackgroundImage
    UIImageView *background = [[UIImageView alloc] init];
    background.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [background setBackgroundColor:[UIColor whiteColor]];
    background.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:background];
    
    [self loadParseContent];
}

-(void) loadParseContent{
    //Loading Animation UIImageView
    
    //Create the first status image and the indicator view
    UIImage *statusImage = [UIImage imageNamed:@"load_anim000"];
    activityImageView = [[UIImageView alloc]
                         initWithImage:statusImage];
    
    
    //Add more images which will be used for the animation
    activityImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"load_anim000"],
                                         [UIImage imageNamed:@"load_anim001"],
                                         [UIImage imageNamed:@"load_anim002"],
                                         [UIImage imageNamed:@"load_anim003"],
                                         [UIImage imageNamed:@"load_anim004"],
                                         [UIImage imageNamed:@"load_anim005"],
                                         [UIImage imageNamed:@"load_anim006"],
                                         [UIImage imageNamed:@"load_anim007"],
                                         [UIImage imageNamed:@"load_anim008"],
                                         [UIImage imageNamed:@"load_anim009"],
                                         nil];
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    activityImageView.animationDuration = 0.5;
    
    activityImageView.animationRepeatCount = 0;
    
    
    //Position the activity image view somewhere in
    //the middle of your current view
    activityImageView.frame = CGRectMake(
                                         self.view.frame.size.width/2
                                         -25,
                                         self.view.frame.size.height/2
                                         -25,
                                         50,
                                         50);
    
    //Start the animation
    [activityImageView startAnimating];
    
    if(Orientation == UIDeviceOrientationPortrait){
        [self loadUser];
    }else if(Orientation == UIDeviceOrientationLandscapeLeft || Orientation ==  UIDeviceOrientationLandscapeRight){
        [self loadUserHorizontal];
        
    } else {
        [self loadUser];
    }
    //[Hud removeFromSuperview];
    
}

-(void)loadUser {
    //Profile Group View
    UIView *header = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        header.frame = CGRectMake(0, 70, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    } else {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }
    [header setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                               green:29/255.0f
                                                blue:74/255.0f
                                               alpha:1.0f]];
    [self.view addSubview:header];
    
    UIImageView *headImg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        headImg.frame = CGRectMake(150, 5, 70, 70);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    } else {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    }
    headImg.image = [UIImage imageNamed:@"brand-logo"];
    [header addSubview:headImg];
    
    
    UILabel *LtdLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        LtdLable.frame = CGRectMake(140, 10, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        LtdLable.frame = CGRectMake(140, 10, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        LtdLable.frame = CGRectMake(140, 10, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        LtdLable.frame = CGRectMake(170, 10, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        LtdLable.frame = CGRectMake(250, 20, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        LtdLable.frame = CGRectMake(170, 10, self.view.frame.size.width, 50);
    } else {
        LtdLable.frame = CGRectMake(170, 10, self.view.frame.size.width, 50);
    }
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    LtdLable.textAlignment = NSTextAlignmentLeft;
    [LtdLable setFont:[UIFont boldSystemFontOfSize:16]];
    [data getCompanyDetails:nil completion:^(NSMutableArray *companyDetails, NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                LtdLable.text = [companyDetails objectAtIndex:0][@"CompanyName"];
            });
        }
    }];
    
    
    //LtdLable.text = @"Pretend Printers Ltd";
    LtdLable.textColor = [UIColor whiteColor];
    [header addSubview:LtdLable];
    
    UILabel *userLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        userLable.frame = CGRectMake(500, 20, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    } else {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    }
    userLable.text = [NSString stringWithFormat:@"Welcome %@", [defaults stringForKey:@"userEmail"]];
    [userLable setFont:[UIFont boldSystemFontOfSize:16]];
    userLable.textColor = [UIColor whiteColor];
    userLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:userLable];
    
    [self loadOperationCodes];
    [self loadMachine];
}

-(void)loadUserHorizontal{
    //Profile Group View
    UIView *header = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        header.frame = CGRectMake(0, 70, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    } else {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }
    [header setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                               green:29/255.0f
                                                blue:74/255.0f
                                               alpha:1.0f]];
    [self.view addSubview:header];
    
    UIImageView *headImg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        headImg.frame = CGRectMake(220, 5, 70, 70);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        headImg.frame = CGRectMake(220, 5, 70, 70);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        headImg.frame = CGRectMake(220, 5, 70, 70);
    } else {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    }
    headImg.image = [UIImage imageNamed:@"brand-logo"];
    [header addSubview:headImg];
    
    
    UILabel *LtdLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        LtdLable.frame = CGRectMake(140, 10, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        LtdLable.frame = CGRectMake(140, 10, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        LtdLable.frame = CGRectMake(140, 10, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        LtdLable.frame = CGRectMake(170, 10, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        LtdLable.frame = CGRectMake(350, 20, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        LtdLable.frame = CGRectMake(170, 10, self.view.frame.size.width, 50);
    } else {
        LtdLable.frame = CGRectMake(170, 10, self.view.frame.size.width, 50);
    }
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    LtdLable.textAlignment = NSTextAlignmentLeft;
    [LtdLable setFont:[UIFont boldSystemFontOfSize:16]];
    [data getCompanyDetails:nil completion:^(NSMutableArray *companyDetails, NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                LtdLable.text = [companyDetails objectAtIndex:0][@"CompanyName"];
            });
        }
    }];
    
    
    //LtdLable.text = @"Pretend Printers Ltd";
    LtdLable.textColor = [UIColor whiteColor];
    [header addSubview:LtdLable];
    
    UILabel *userLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        userLable.frame = CGRectMake(700, 20, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    } else {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    }
    userLable.text = [NSString stringWithFormat:@"Welcome %@", [defaults stringForKey:@"userEmail"]];
    [userLable setFont:[UIFont boldSystemFontOfSize:16]];
    userLable.textColor = [UIColor whiteColor];
    userLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:userLable];
    
    [self loadOperationCodes];
    [self loadMachineHorizontal];
}




-(void)loadMachine {
    NSMutableArray *darkColors = [NSMutableArray array];
    NSMutableArray *midColors = [NSMutableArray array];
    NSMutableArray *lightColors = [NSMutableArray array];
    NSMutableArray *gradientStartColors = [NSMutableArray array];
    NSMutableArray *gradientEndColors = [NSMutableArray array];
    
    //Blue
    UIColor *color = [UIColor colorWithRed:34/255.0f
                                     green:145/255.0f
                                      blue:237/255.0f
                                     alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:185/255.0f
                            green:217/255.0f
                             blue:244/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:12/255.0f
                            green:28/255.0f
                             blue:42/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:79/255.0f
                            green:185/255.0f
                             blue:245/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:28/255.0f
                            green:135/255.0f
                             blue:236/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Green
    color = [UIColor colorWithRed:172/255.0f
                            green:200/255.0f
                             blue:55/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:215/255.0f
                            green:237/255.0f
                             blue:123/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:37/255.0f
                            green:44/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:194/255.0f
                            green:215/255.0f
                             blue:93/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:149/255.0f
                            green:182/255.0f
                             blue:37/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Red
    color = [UIColor colorWithRed:226/255.0f
                            green:14/255.0f
                             blue:14/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:225/255.0f
                            green:160/255.0f
                             blue:160/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:50/255.0f
                            green:18/255.0f
                             blue:18/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:223/255.0f
                            green:27/255.0f
                             blue:27/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:212/255.0f
                            green:6/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Grey
    color = [UIColor colorWithRed:97/255.0f
                            green:97/255.0f
                             blue:97/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:205/255.0f
                            green:205/255.0f
                             blue:205/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:26/255.0f
                            green:26/255.0f
                             blue:26/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:124/255.0f
                            green:124/255.0f
                             blue:124/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:64/255.0f
                            green:64/255.0f
                             blue:64/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    NSString *status = [NSString stringWithFormat:@"%@", selectedData[@"ClassColour"]];
    UIColor *midColor;
    UIColor *lightColor;
    UIColor *darkColor;
    UIColor *gradientStart;
    UIColor *gradientEnd;
    
    if ([status isEqualToString:@"success"]) {
        midColor = [midColors objectAtIndex:1];
        lightColor = [lightColors objectAtIndex:1];
        darkColor = [darkColors objectAtIndex:1];
        gradientStart = [gradientStartColors objectAtIndex:1];
        gradientEnd = [gradientEndColors objectAtIndex:1];
    } else if ([status isEqualToString:@"info"]) {
        midColor = [midColors objectAtIndex:0];
        lightColor = [lightColors objectAtIndex:0];
        darkColor = [darkColors objectAtIndex:0];
        gradientStart = [gradientStartColors objectAtIndex:0];
        gradientEnd = [gradientEndColors objectAtIndex:0];
    } else if ([status isEqualToString:@"danger"]) {
        midColor = [midColors objectAtIndex:2];
        lightColor = [lightColors objectAtIndex:2];
        darkColor = [darkColors objectAtIndex:2];
        gradientStart = [gradientStartColors objectAtIndex:2];
        gradientEnd = [gradientEndColors objectAtIndex:2];
    } else if ([status isEqualToString:@"default"]) {
        midColor = [midColors objectAtIndex:3];
        lightColor = [lightColors objectAtIndex:3];
        darkColor = [darkColors objectAtIndex:3];
        gradientStart = [gradientStartColors objectAtIndex:3];
        gradientEnd = [gradientEndColors objectAtIndex:3];
    } else {
        midColor = [midColors objectAtIndex:3];
        lightColor = [lightColors objectAtIndex:3];
        darkColor = [darkColors objectAtIndex:3];
        gradientStart = [gradientStartColors objectAtIndex:3];
        gradientEnd = [gradientEndColors objectAtIndex:3];
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    UILabel *machineTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 40)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 60);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 200)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:52];
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    } else {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }
    machineTitle.textAlignment = NSTextAlignmentCenter;
    machineTitle.text = [NSString stringWithFormat:@"%@", selectedData[@"MachineName"]];
    machineTitle.textColor = [UIColor colorWithRed:102/255.0f
                                             green:102/255.0f
                                              blue:102/255.0f
                                             alpha:1.0f];
    //[operatorLabel setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:machineTitle];
    
    UIView *mainPart = [[UIView alloc] initWithFrame:CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        mainPart.frame = CGRectMake(10, 180, self.view.frame.size.width - 20, self.view.frame.size.height - 175);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        mainPart.frame = CGRectMake(10, 255, self.view.frame.size.width - 20, self.view.frame.size.height - 255);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    } else {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }
    //[mainPart setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:mainPart];
    
    /**
    UIButton *changeOperatorBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        changeOperatorBtn.frame = CGRectMake(0, 0, 120, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        changeOperatorBtn.frame = CGRectMake(0, 0, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        changeOperatorBtn.frame = CGRectMake(0, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        changeOperatorBtn.frame = CGRectMake(0, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        changeOperatorBtn.frame = CGRectMake(0, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        changeOperatorBtn.frame = CGRectMake(0, 0, 120, 50);
    } else {
        changeOperatorBtn.frame = CGRectMake(0, 0, 120, 50);
    }
    [changeOperatorBtn setBackgroundImage:[UIImage imageNamed:@"btn_changeoperator"] forState:UIControlStateNormal];
    [mainPart addSubview:changeOperatorBtn];
     **/
    
    /**
    UIButton *changeOperationBtn = [[UIButton alloc] initWithFrame:CGRectMake(117.5, 0, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        changeOperationBtn.frame = CGRectMake(117.5, 0, 120, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        changeOperationBtn.frame = CGRectMake(117.5, 0, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        changeOperationBtn.frame = CGRectMake(117.5, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        changeOperationBtn.frame = CGRectMake(117.5, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        changeOperationBtn.frame = CGRectMake(mainPart.frame.size.width/3, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        changeOperationBtn.frame = CGRectMake(117.5, 0, 120, 50);
    } else {
        changeOperationBtn.frame = CGRectMake(117.5, 0, 120, 50);
    }
    [changeOperationBtn setBackgroundImage:[UIImage imageNamed:@"btn_changeoperation"] forState:UIControlStateNormal];
    [mainPart addSubview:changeOperationBtn];
     **/
    
    UIButton *viewLinkedDocsBtn = [[UIButton alloc] initWithFrame:CGRectMake(235, 0, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        viewLinkedDocsBtn.frame = CGRectMake(mainPart.frame.size.width/2, 0, 125, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        viewLinkedDocsBtn.frame = CGRectMake(mainPart.frame.size.width/3 + 170, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    } else {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }
    [viewLinkedDocsBtn setBackgroundImage:[UIImage imageNamed:@"btn_linkeddocs"] forState:UIControlStateNormal];
    [viewLinkedDocsBtn addTarget:self action:@selector(viewDocuments) forControlEvents:UIControlEventTouchDown];
    [mainPart addSubview:viewLinkedDocsBtn];
    
    UIButton *viewDocketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 47.5, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        viewDocketBtn.frame = CGRectMake(mainPart.frame.size.width/2-125, 0, 125, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        viewDocketBtn.frame = CGRectMake(120, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    } else {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }
    [viewDocketBtn setBackgroundImage:[UIImage imageNamed:@"btn_viewdocket"] forState:UIControlStateNormal];
    [viewDocketBtn addTarget:self action:@selector(viewDockets) forControlEvents:UIControlEventTouchDown];
    [mainPart addSubview:viewDocketBtn];
    
    /**
    UIButton *workToListBtn = [[UIButton alloc] initWithFrame:CGRectMake(117.5, 47.5, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        workToListBtn.frame = CGRectMake(117.5, 47.5, 120, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        workToListBtn.frame = CGRectMake(117.5, 47.5, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        workToListBtn.frame = CGRectMake(117.5, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        workToListBtn.frame = CGRectMake(117.5, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        workToListBtn.frame = CGRectMake(mainPart.frame.size.width/3, 100, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        workToListBtn.frame = CGRectMake(117.5, 47.5, 120, 50);
    } else {
        workToListBtn.frame = CGRectMake(117.5, 47.5, 120, 50);
    }
    [workToListBtn setBackgroundImage:[UIImage imageNamed:@"btn_worktolist"] forState:UIControlStateNormal];
    [mainPart addSubview:workToListBtn];
     **/
    
    /**
    UIButton *commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(235, 47.5, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        commentBtn.frame = CGRectMake(235, 47.5, 120, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        commentBtn.frame = CGRectMake(235, 47.5, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        commentBtn.frame = CGRectMake(235, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        commentBtn.frame = CGRectMake(235, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        commentBtn.frame = CGRectMake((mainPart.frame.size.width/3)*2, 100, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        commentBtn.frame = CGRectMake(235, 47.5, 120, 50);
    } else {
        commentBtn.frame = CGRectMake(235, 47.5, 120, 50);
    }
    [commentBtn setBackgroundImage:[UIImage imageNamed:@"btn_comment"] forState:UIControlStateNormal];
    [mainPart addSubview:commentBtn];
     **/
    
    UIView *machineCont = [[UIView alloc] initWithFrame:CGRectMake(0, 55, mainPart.frame.size.width, 280)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        machineCont.frame = CGRectMake(0, 155, mainPart.frame.size.width, 380);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    [mainPart addSubview:machineCont];
    
    /**
    UIView *leftColumn = [[UIView alloc] initWithFrame:CGRectMake(0, 100, mainPart.frame.size.width / 2, 280)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        leftColumn.frame = CGRectMake(0, 100, mainPart.frame.size.width / 2, 280);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        leftColumn.frame = CGRectMake(0, 100, mainPart.frame.size.width / 2, 280);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        leftColumn.frame = CGRectMake(0, 100, mainPart.frame.size.width / 2, 280);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        leftColumn.frame = CGRectMake(0, 100, mainPart.frame.size.width / 2, 280);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        leftColumn.frame = CGRectMake(0, 200, mainPart.frame.size.width / 2, 280);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        leftColumn.frame = CGRectMake(0, 100, mainPart.frame.size.width / 2, 280);
    } else {
        leftColumn.frame = CGRectMake(0, 100, mainPart.frame.size.width / 2, 280);
    }
    //[leftColumn setBackgroundColor:[UIColor blackColor]];
    [mainPart addSubview:leftColumn];
    
    UIView *rightColumn = [[UIView alloc] initWithFrame:CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 200, mainPart.frame.size.width / 2, 280);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280);
    } else {
        rightColumn.frame = CGRectMake(mainPart.frame.size.width / 2, 100, mainPart.frame.size.width / 2, 280);
    }
    //[rightColumn setBackgroundColor:[UIColor whiteColor]];
    [mainPart addSubview:rightColumn];
    **/
    
    /**
    UIView *operatorCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    operatorCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 80);
    [operatorCont setBackgroundColor:[UIColor whiteColor]];
    operatorCont.layer.cornerRadius = 5;
    operatorCont.layer.masksToBounds = true;
    [machineCont addSubview:operatorCont];
    
    UIView *operatorIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    operatorIconCont.frame = CGRectMake(0, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
    [operatorIconCont setBackgroundColor:midColor];
    [operatorCont addSubview:operatorIconCont];
    
    UIImageView *operatorIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    operatorIcon.frame = CGRectMake(0,0,45,45);
    [operatorIcon setCenter:CGPointMake(operatorIconCont.frame.size.width / 2, operatorIconCont.frame.size.height / 2 - 5)];
    operatorIcon.image = [UIImage imageNamed:@"ic_user"];
    operatorIcon.contentMode = UIViewContentModeScaleAspectFit;
    [operatorIconCont addSubview:operatorIcon];
    
    UILabel *operatorLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,25);
    [operatorLabel setCenter:CGPointMake(operatorIconCont.frame.size.width / 2, 67.5)];
    operatorLabel.text = [NSString stringWithFormat:@"Elizar Golosino"];
    [operatorLabel setFont:[UIFont boldSystemFontOfSize:10]];
    operatorLabel.textColor = [UIColor blackColor];
    operatorLabel.textAlignment = NSTextAlignmentCenter;
    operatorLabel.lineBreakMode = NSLineBreakByWordWrapping;
    operatorLabel.numberOfLines = 2;
    //[operatorLabel setBackgroundColor:[UIColor whiteColor]];
    [operatorIconCont addSubview:operatorLabel];
    
    UIView *operatorMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
    [operatorMachineCont setBackgroundColor:lightColor];
    [operatorCont addSubview:operatorMachineCont];
    
    UIImageView *opImage = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    opImage.frame = CGRectMake(0,0,operatorMachineCont.frame.size.width,operatorMachineCont.frame.size.height);
    [opImage setCenter:CGPointMake(operatorMachineCont.frame.size.width / 2, operatorMachineCont.frame.size.height / 2)];
    opImage.image = [UIImage imageNamed:@"user"];
    [operatorMachineCont addSubview:opImage];
    **/
    
    UIView *titleCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        titleCont.frame = CGRectMake(5, 85, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    } else {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }
    
    [titleCont setBackgroundColor:[UIColor whiteColor]];
    titleCont.layer.cornerRadius = 5;
    titleCont.layer.masksToBounds = true;
    [machineCont addSubview:titleCont];
    
    UIView *titleIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleIconCont.frame = CGRectMake(0, 0, 55, titleCont.frame.size.height);
    [titleIconCont setBackgroundColor:midColor];
    [titleCont addSubview:titleIconCont];
    
    UIImageView *titleIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleIcon.frame = CGRectMake(0,0,30,30);
    [titleIcon setCenter:CGPointMake(titleIconCont.frame.size.width / 2, titleIconCont.frame.size.height / 2 - 5)];
    titleIcon.image = [UIImage imageNamed:@"ic_title"];
    titleIcon.contentMode = UIViewContentModeScaleAspectFit;
    [titleIconCont addSubview:titleIcon];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
    [titleLabel setCenter:CGPointMake(titleIconCont.frame.size.width / 2, titleIconCont.frame.size.height-10)];
    titleLabel.text = [NSString stringWithFormat:@"Title"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleIconCont addSubview:titleLabel];
    
    UIView *titleMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleMachineCont.frame = CGRectMake(55, 0, titleCont.frame.size.width-55, titleCont.frame.size.height);
    [titleMachineCont setBackgroundColor:lightColor];
    [titleCont addSubview:titleMachineCont];
    
    //Need to make it auto resize width, or font size
    titleMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleMachineValue.frame = CGRectMake(5,0,titleMachineCont.frame.size.width-10,titleMachineCont.frame.size.height);
    [titleMachineValue setCenter:CGPointMake(titleMachineCont.frame.size.width / 2, titleMachineCont.frame.size.height / 2)];
    titleMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"JobTitle"]];
    titleMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];;
    titleMachineValue.textColor = [UIColor blackColor];
    titleMachineValue.textAlignment = NSTextAlignmentLeft;
    titleMachineValue.adjustsFontSizeToFitWidth = true;
    //titleMachineValue.lineBreakMode = NSLineBreakByWordWrapping;
    //titleMachineValue.numberOfLines = 2;
    [titleMachineCont addSubview:titleMachineValue];
    
    
    UIView *jobCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    } else {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }
    [jobCont setBackgroundColor:[UIColor whiteColor]];
    jobCont.layer.cornerRadius = 5;
    jobCont.layer.masksToBounds = true;
    [machineCont addSubview:jobCont];
    
    UIView *jobIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobIconCont.frame = CGRectMake(0, 0, 55, jobCont.frame.size.height);
    [jobIconCont setBackgroundColor:midColor];
    [jobCont addSubview:jobIconCont];
    
    UIImageView *jobIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobIcon.frame = CGRectMake(0,0,30,30);
    [jobIcon setCenter:CGPointMake(jobIconCont.frame.size.width / 2, jobIconCont.frame.size.height / 2 - 5)];
    jobIcon.image = [UIImage imageNamed:@"ic_job"];
    jobIcon.contentMode = UIViewContentModeScaleAspectFit;
    [jobIconCont addSubview:jobIcon];
    
    UILabel *jobLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobLabel.frame = CGRectMake(0,0,jobIconCont.frame.size.width-4,8);
    [jobLabel setCenter:CGPointMake(jobIconCont.frame.size.width / 2, jobIconCont.frame.size.height - 10)];
    jobLabel.text = [NSString stringWithFormat:@"Job No"];
    [jobLabel setFont:[UIFont boldSystemFontOfSize:8]];
    jobLabel.textColor = [UIColor blackColor];
    jobLabel.textAlignment = NSTextAlignmentCenter;
    [jobIconCont addSubview:jobLabel];
    
    UIView *jobMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobMachineCont.frame = CGRectMake(55, 0, jobCont.frame.size.width-55, jobCont.frame.size.height);
    [jobMachineCont setBackgroundColor:lightColor];
    [jobCont addSubview:jobMachineCont];
    
    jobMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobMachineValue.frame = CGRectMake(5,0,jobMachineCont.frame.size.width-10,jobMachineCont.frame.size.height);
    [jobMachineValue setCenter:CGPointMake(jobMachineCont.frame.size.width / 2, jobMachineCont.frame.size.height / 2)];
    jobMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"JobNo"]];
    jobMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    jobMachineValue.textColor = [UIColor blackColor];
    jobMachineValue.textAlignment = NSTextAlignmentLeft;
    [jobMachineCont addSubview:jobMachineValue];
    
    /*
    UIView *stationCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    stationCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    [stationCont setBackgroundColor:[UIColor whiteColor]];
    stationCont.layer.cornerRadius = 5;
    stationCont.layer.masksToBounds = true;
    [machineCont addSubview:stationCont];
    
    UIView *stationIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    stationIconCont.frame = CGRectMake(0, 0, 55, stationCont.frame.size.height);
    [stationIconCont setBackgroundColor:midColor];
    [stationCont addSubview:stationIconCont];
    
    UIImageView *stationIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    stationIcon.frame = CGRectMake(0,0,30,30);
    [stationIcon setCenter:CGPointMake(stationIconCont.frame.size.width / 2, stationIconCont.frame.size.height / 2 - 5)];
    stationIcon.image = [UIImage imageNamed:@"ic_station"];
    stationIcon.contentMode = UIViewContentModeScaleAspectFit;
    [stationIconCont addSubview:stationIcon];
    
    UILabel *stationLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
    [stationLabel setCenter:CGPointMake(stationIconCont.frame.size.width / 2, stationIconCont.frame.size.height-10)];
    stationLabel.text = [NSString stringWithFormat:@"Station"];
    [stationLabel setFont:[UIFont boldSystemFontOfSize:8]];
    stationLabel.textColor = [UIColor blackColor];
    stationLabel.textAlignment = NSTextAlignmentCenter;
    [stationIconCont addSubview:stationLabel];
    
    UIView *stationMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    stationMachineCont.frame = CGRectMake(55, 0, stationCont.frame.size.width-55, stationCont.frame.size.height);
    [stationMachineCont setBackgroundColor:lightColor];
    [stationCont addSubview:stationMachineCont];
    
    UILabel *stationMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    stationMachineValue.frame = CGRectMake(5,0,stationMachineCont.frame.size.width-10,stationMachineCont.frame.size.height);
    [stationMachineValue setCenter:CGPointMake(stationMachineCont.frame.size.width / 2, stationMachineCont.frame.size.height / 2)];
    stationMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"ShopStation"]];
    stationMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    stationMachineValue.textColor = [UIColor blackColor];
    stationMachineValue.textAlignment = NSTextAlignmentLeft;
    [stationMachineCont addSubview:stationMachineValue];
    */
    
    UIView *sectionCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        sectionCont.frame = CGRectMake(5, 165, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    } else {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }
    [sectionCont setBackgroundColor:[UIColor whiteColor]];
    sectionCont.layer.cornerRadius = 5;
    sectionCont.layer.masksToBounds = true;
    [machineCont addSubview:sectionCont];
    
    UIView *sectionIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionIconCont.frame = CGRectMake(0, 0, 55, sectionCont.frame.size.height);
    [sectionIconCont setBackgroundColor:midColor];
    [sectionCont addSubview:sectionIconCont];
    
    UIImageView *sectionIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionIcon.frame = CGRectMake(0,0,30,30);
    [sectionIcon setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, sectionIconCont.frame.size.height / 2 - 5)];
    sectionIcon.image = [UIImage imageNamed:@"ic_section"];
    sectionIcon.contentMode = UIViewContentModeScaleAspectFit;
    [sectionIconCont addSubview:sectionIcon];
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
    [sectionLabel setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, sectionIconCont.frame.size.height-10)];
    sectionLabel.text = [NSString stringWithFormat:@"Section"];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
    sectionLabel.textColor = [UIColor blackColor];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    [sectionIconCont addSubview:sectionLabel];
    
    UIView *sectionMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionMachineCont.frame = CGRectMake(55, 0, sectionCont.frame.size.width-55, sectionCont.frame.size.height);
    [sectionMachineCont setBackgroundColor:lightColor];
    [sectionCont addSubview:sectionMachineCont];
    
    sectionMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionMachineValue.frame = CGRectMake(5,0,sectionMachineCont.frame.size.width-10,sectionMachineCont.frame.size.height);
    [sectionMachineValue setCenter:CGPointMake(sectionMachineCont.frame.size.width / 2, sectionMachineCont.frame.size.height / 2)];
    sectionMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"SectionCode"]];
    sectionMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    sectionMachineValue.textColor = [UIColor blackColor];
    sectionMachineValue.textAlignment = NSTextAlignmentLeft;
    [sectionMachineCont addSubview:sectionMachineValue];
    
    
    UIView *speedCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        speedCont.frame = CGRectMake(5, 245, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    } else {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }
    [speedCont setBackgroundColor:[UIColor whiteColor]];
    speedCont.layer.cornerRadius = 5;
    speedCont.layer.masksToBounds = true;
    [machineCont addSubview:speedCont];
    
    UIView *speedIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedIconCont.frame = CGRectMake(0, 0, 55, speedCont.frame.size.height);
    [speedIconCont setBackgroundColor:midColor];
    [speedCont addSubview:speedIconCont];
    
    UIImageView *speedIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedIcon.frame = CGRectMake(0,0,30,30);
    [speedIcon setCenter:CGPointMake(speedIconCont.frame.size.width / 2, speedIconCont.frame.size.height / 2 - 5)];
    speedIcon.image = [UIImage imageNamed:@"ic_speed"];
    speedIcon.contentMode = UIViewContentModeScaleAspectFit;
    [speedIconCont addSubview:speedIcon];
    
    UILabel *speedLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedLabel.frame = CGRectMake(0,0,speedIconCont.frame.size.width-4,10);
    [speedLabel setCenter:CGPointMake(speedIconCont.frame.size.width / 2, speedIconCont.frame.size.height-10)];
    speedLabel.text = [NSString stringWithFormat:@"Speed"];
    [speedLabel setFont:[UIFont boldSystemFontOfSize:8]];
    speedLabel.textColor = [UIColor blackColor];
    speedLabel.textAlignment = NSTextAlignmentCenter;
    [speedIconCont addSubview:speedLabel];
    
    UIView *speedMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedMachineCont.frame = CGRectMake(55, 0, speedCont.frame.size.width-55, sectionCont.frame.size.height);
    [speedMachineCont setBackgroundColor:lightColor];
    [speedCont addSubview:speedMachineCont];
    
    speedMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedMachineValue.frame = CGRectMake(5,0,speedMachineCont.frame.size.width-10,speedMachineCont.frame.size.height);
    [speedMachineValue setCenter:CGPointMake(speedMachineCont.frame.size.width / 2, speedMachineCont.frame.size.height / 2)];
    double speed = [[NSString stringWithFormat:@"%@", selectedData[@"Speed"]] integerValue];
    NSString *formattedSpeed = [formatter stringFromNumber:[NSNumber numberWithInteger:speed]];
    speedMachineValue.text = [NSString stringWithFormat:@"%@", formattedSpeed];
    speedMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    speedMachineValue.textColor = [UIColor blackColor];
    speedMachineValue.textAlignment = NSTextAlignmentLeft;
    [speedMachineCont addSubview:speedMachineValue];
    
    //Container for progress bar
    progressCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        progressCont.frame = CGRectMake(5, 305, mainPart.frame.size.width-10, 20);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        progressCont.frame = CGRectMake(5, 500, mainPart.frame.size.width-10, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    } else {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }
    
    progressCont.layer.cornerRadius = 10;
    progressCont.layer.masksToBounds = true;
    [mainPart addSubview:progressCont];
    
    //NSString *goodAmount = [NSString stringWithFormat:@"%@", selectedData[@"GoodAmount"]];
    //SString *requiredAmount = [NSString stringWithFormat:@"%@", selectedData[@"RequiredAmount"]];
    
    //Percentage Complete
    double progressCur = [[NSString stringWithFormat:@"%@", selectedData[@"GoodAmount"]] integerValue];
    double progressCom = [[NSString stringWithFormat:@"%@", selectedData[@"RequiredAmount"]] integerValue];
    //NSLog(@"%f %f", progressCom, progressCur);
    double progressVal = progressCur / progressCom;
    //NSLog(@"%f", progressVal);
    
    UIProgressView *progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 40);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 20.0)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    } else {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }
    
    progressBar.progressTintColor = midColor;
    progressBar.trackTintColor = lightColor;
    //progressBar.progressImage = [UIImage imageNamed:@"progbar_2"];
    //progressBar.trackImage = [UIImage imageNamed:@"progbar_1"];
    progressBar.progress = progressVal;
    
    progressBar.tag = 16;
    [progressCont addSubview:progressBar];
    
    UILabel *progressLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    } else {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }
    
    NSString *formattedGoodAmount = [formatter stringFromNumber:[NSNumber numberWithInteger:progressCur]];
    NSString *formattedRequiredAmount = [formatter stringFromNumber:[NSNumber numberWithInteger:progressCom]];
    

    progressLabel.text = [NSString stringWithFormat:@"%@ / %@", formattedGoodAmount, formattedRequiredAmount];
    [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
    progressLabel.textColor = [UIColor blackColor];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    //[progressLabel setBackgroundColor:[UIColor blackColor]];
    progressLabel.tag = 17;
    [progressCont addSubview:progressLabel];
    
    /*UIImageView *speedGraph = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 390, mainPart.frame.size.width-5, 90)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        speedGraph.frame = CGRectMake(2.5, 330, mainPart.frame.size.width-5, 90);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        speedGraph.frame = CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        speedGraph.frame = CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        speedGraph.frame = CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        speedGraph.frame = CGRectMake(2.5, 520, mainPart.frame.size.width-5, 180);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        speedGraph.frame = CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90);
    } else {
        speedGraph.frame = CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90);
    }
    speedGraph.image = [UIImage imageNamed:@"graph"];
    [mainPart addSubview:speedGraph];*/
    graphBackground = [[UIView alloc] init];
    graphScroller = [[UIScrollView alloc] init];
    ten = [[UILabel alloc] init];
    twenty = [[UILabel alloc] init];
    thirty = [[UILabel alloc] init];
    forty = [[UILabel alloc] init];
    fiddy = [[UILabel alloc] init];
    
    
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        graphBackground.frame = CGRectMake(0, 335, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        graphBackground.frame = CGRectMake(0, 580, mainPart.frame.size.width, 250);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 230);
        ten.frame = CGRectMake(40, 180, 50, 20);
        twenty.frame = CGRectMake(40, 140, 50, 20);
        thirty.frame = CGRectMake(40, 100, 50, 20);
        forty.frame = CGRectMake(40, 60, 50, 20);
        fiddy.frame = CGRectMake(40, 20, 50, 20);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:22];
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    } else {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    }
    
    ten.textAlignment = NSTextAlignmentRight;
    ten.textColor = [UIColor blackColor];
    
    
    twenty.textAlignment = NSTextAlignmentRight;
    twenty.textColor = [UIColor blackColor];
    
    
    thirty.textAlignment = NSTextAlignmentRight;
    thirty.textColor = [UIColor blackColor];
    
    
    forty.textAlignment = NSTextAlignmentRight;
    forty.textColor = [UIColor blackColor];
    
    
    fiddy.textAlignment = NSTextAlignmentRight;
    fiddy.textColor = [UIColor blackColor];

    
    //[graphBackground setBackgroundColor:[UIColor yellowColor]];
    //[graphScroller setBackgroundColor:[UIColor greenColor]];
    [mainPart addSubview:graphBackground];
    
    
    UIImageView *bg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 250);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    } else {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    
    bg.image = [UIImage imageNamed:@"catalogueBG"];
    [graphBackground addSubview:bg];
    
    UIImageView *fade = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        fade.frame = CGRectMake(15, 15, 100, 220);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    } else {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    
    fade.image = [UIImage imageNamed:@"yaxis"];
    [graphBackground addSubview:fade];
    [graphBackground addSubview:graphScroller];
    
    speedHistory = [[NSMutableArray alloc] init];
    
    
    CGMutablePathRef cgPath = CGPathCreateMutable();
    path = [UIBezierPath bezierPathWithCGPath:cgPath];
    
    [graphBackground addSubview:ten];
    [graphBackground addSubview:twenty];
    [graphBackground addSubview:thirty];
    [graphBackground addSubview:forty];
    [graphBackground addSubview:fiddy];
    
    add5Mins = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    graphTimeGap = 0;
    graphMoveX = 1;
    for(graphTimeGap; graphTimeGap < 4; graphTimeGap++) {
        UILabel *time = [[UILabel alloc] init];
        if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
        {
            time.frame = CGRectMake(30 + 200*graphTimeGap, 200, 50, 20);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        }
        else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        } else {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        
        time.textAlignment = NSTextAlignmentLeft;
        time.textColor = [UIColor blackColor];
        add5Mins = [add5Mins dateByAddingTimeInterval:(5*60)];
        time.text = [outputFormatter stringFromDate:add5Mins];
        [graphScroller addSubview:time];
    }
    
    [self dynamicallyUpdateMachines];
    [self startUpdateTimer];
}


-(void) loadMachineHorizontal{
    NSMutableArray *darkColors = [NSMutableArray array];
    NSMutableArray *midColors = [NSMutableArray array];
    NSMutableArray *lightColors = [NSMutableArray array];
    NSMutableArray *gradientStartColors = [NSMutableArray array];
    NSMutableArray *gradientEndColors = [NSMutableArray array];
    
    //Blue
    UIColor *color = [UIColor colorWithRed:34/255.0f
                                     green:145/255.0f
                                      blue:237/255.0f
                                     alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:185/255.0f
                            green:217/255.0f
                             blue:244/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:12/255.0f
                            green:28/255.0f
                             blue:42/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:79/255.0f
                            green:185/255.0f
                             blue:245/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:28/255.0f
                            green:135/255.0f
                             blue:236/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Green
    color = [UIColor colorWithRed:172/255.0f
                            green:200/255.0f
                             blue:55/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:215/255.0f
                            green:237/255.0f
                             blue:123/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:37/255.0f
                            green:44/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:194/255.0f
                            green:215/255.0f
                             blue:93/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:149/255.0f
                            green:182/255.0f
                             blue:37/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Red
    color = [UIColor colorWithRed:226/255.0f
                            green:14/255.0f
                             blue:14/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:225/255.0f
                            green:160/255.0f
                             blue:160/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:50/255.0f
                            green:18/255.0f
                             blue:18/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:223/255.0f
                            green:27/255.0f
                             blue:27/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:212/255.0f
                            green:6/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Grey
    color = [UIColor colorWithRed:97/255.0f
                            green:97/255.0f
                             blue:97/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:205/255.0f
                            green:205/255.0f
                             blue:205/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:26/255.0f
                            green:26/255.0f
                             blue:26/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:124/255.0f
                            green:124/255.0f
                             blue:124/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:64/255.0f
                            green:64/255.0f
                             blue:64/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    NSString *status = [NSString stringWithFormat:@"%@", selectedData[@"ClassColour"]];
    UIColor *midColor;
    UIColor *lightColor;
    UIColor *darkColor;
    UIColor *gradientStart;
    UIColor *gradientEnd;
    
    if ([status isEqualToString:@"success"]) {
        midColor = [midColors objectAtIndex:1];
        lightColor = [lightColors objectAtIndex:1];
        darkColor = [darkColors objectAtIndex:1];
        gradientStart = [gradientStartColors objectAtIndex:1];
        gradientEnd = [gradientEndColors objectAtIndex:1];
    } else if ([status isEqualToString:@"info"]) {
        midColor = [midColors objectAtIndex:0];
        lightColor = [lightColors objectAtIndex:0];
        darkColor = [darkColors objectAtIndex:0];
        gradientStart = [gradientStartColors objectAtIndex:0];
        gradientEnd = [gradientEndColors objectAtIndex:0];
    } else if ([status isEqualToString:@"danger"]) {
        midColor = [midColors objectAtIndex:2];
        lightColor = [lightColors objectAtIndex:2];
        darkColor = [darkColors objectAtIndex:2];
        gradientStart = [gradientStartColors objectAtIndex:2];
        gradientEnd = [gradientEndColors objectAtIndex:2];
    } else if ([status isEqualToString:@"default"]) {
        midColor = [midColors objectAtIndex:3];
        lightColor = [lightColors objectAtIndex:3];
        darkColor = [darkColors objectAtIndex:3];
        gradientStart = [gradientStartColors objectAtIndex:3];
        gradientEnd = [gradientEndColors objectAtIndex:3];
    } else {
        midColor = [midColors objectAtIndex:3];
        lightColor = [lightColors objectAtIndex:3];
        darkColor = [darkColors objectAtIndex:3];
        gradientStart = [gradientStartColors objectAtIndex:3];
        gradientEnd = [gradientEndColors objectAtIndex:3];
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    UILabel *machineTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 40)];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 60);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 200)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:52];
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    } else {
        machineTitle.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 40);
        [machineTitle setCenter:CGPointMake(self.view.frame.size.width / 2, 160)];
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    }
    machineTitle.textAlignment = NSTextAlignmentCenter;
    machineTitle.text = [NSString stringWithFormat:@"%@", selectedData[@"MachineName"]];
    machineTitle.textColor = [UIColor colorWithRed:102/255.0f
                                             green:102/255.0f
                                              blue:102/255.0f
                                             alpha:1.0f];
    //[operatorLabel setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:machineTitle];
    
    UIView *mainPart = [[UIView alloc] initWithFrame:CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180)];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        mainPart.frame = CGRectMake(10, 180, self.view.frame.size.width - 20, self.view.frame.size.height - 175);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        mainPart.frame = CGRectMake(10, 255, self.view.frame.size.width - 20, self.view.frame.size.height - 255);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    } else {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }
    //[mainPart setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:mainPart];
    
    
    UIButton *viewLinkedDocsBtn = [[UIButton alloc] initWithFrame:CGRectMake(235, 0, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        viewLinkedDocsBtn.frame = CGRectMake(mainPart.frame.size.width/2, 0, 125, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        viewLinkedDocsBtn.frame = CGRectMake(mainPart.frame.size.width/3 + 170, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    } else {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }
    [viewLinkedDocsBtn setBackgroundImage:[UIImage imageNamed:@"btn_linkeddocs"] forState:UIControlStateNormal];
    [viewLinkedDocsBtn addTarget:self action:@selector(viewDocuments) forControlEvents:UIControlEventTouchDown];
    [mainPart addSubview:viewLinkedDocsBtn];
    
    UIButton *viewDocketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 47.5, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        viewDocketBtn.frame = CGRectMake(mainPart.frame.size.width/2-125, 0, 125, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        viewDocketBtn.frame = CGRectMake(120, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    } else {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }
    [viewDocketBtn setBackgroundImage:[UIImage imageNamed:@"btn_viewdocket"] forState:UIControlStateNormal];
    [viewDocketBtn addTarget:self action:@selector(viewDockets) forControlEvents:UIControlEventTouchDown];
    [mainPart addSubview:viewDocketBtn];
    
    
    UIView *machineCont = [[UIView alloc] initWithFrame:CGRectMake(0, 55, mainPart.frame.size.width, 280)];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        machineCont.frame = CGRectMake(0, 155, mainPart.frame.size.width, 380);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    [mainPart addSubview:machineCont];
    
    
    UIView *titleCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        titleCont.frame = CGRectMake(5, 85, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    } else {
        titleCont.frame = CGRectMake(5, 65, machineCont.frame.size.width - 10, 55);
    }
    
    [titleCont setBackgroundColor:[UIColor whiteColor]];
    titleCont.layer.cornerRadius = 5;
    titleCont.layer.masksToBounds = true;
    [machineCont addSubview:titleCont];
    
    UIView *titleIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleIconCont.frame = CGRectMake(0, 0, 55, titleCont.frame.size.height);
    [titleIconCont setBackgroundColor:midColor];
    [titleCont addSubview:titleIconCont];
    
    UIImageView *titleIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleIcon.frame = CGRectMake(0,0,30,30);
    [titleIcon setCenter:CGPointMake(titleIconCont.frame.size.width / 2, titleIconCont.frame.size.height / 2 - 5)];
    titleIcon.image = [UIImage imageNamed:@"ic_title"];
    titleIcon.contentMode = UIViewContentModeScaleAspectFit;
    [titleIconCont addSubview:titleIcon];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
    [titleLabel setCenter:CGPointMake(titleIconCont.frame.size.width / 2, titleIconCont.frame.size.height-10)];
    titleLabel.text = [NSString stringWithFormat:@"Title"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleIconCont addSubview:titleLabel];
    
    UIView *titleMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleMachineCont.frame = CGRectMake(55, 0, titleCont.frame.size.width-55, titleCont.frame.size.height);
    [titleMachineCont setBackgroundColor:lightColor];
    [titleCont addSubview:titleMachineCont];
    
    //Need to make it auto resize width, or font size
    titleMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    titleMachineValue.frame = CGRectMake(5,0,titleMachineCont.frame.size.width-10,titleMachineCont.frame.size.height);
    [titleMachineValue setCenter:CGPointMake(titleMachineCont.frame.size.width / 2, titleMachineCont.frame.size.height / 2)];
    titleMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"JobTitle"]];
    titleMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];;
    titleMachineValue.textColor = [UIColor blackColor];
    titleMachineValue.textAlignment = NSTextAlignmentLeft;
    titleMachineValue.adjustsFontSizeToFitWidth = true;
    //titleMachineValue.lineBreakMode = NSLineBreakByWordWrapping;
    //titleMachineValue.numberOfLines = 2;
    [titleMachineCont addSubview:titleMachineValue];
    
    
    UIView *jobCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    } else {
        jobCont.frame = CGRectMake(5, 5, machineCont.frame.size.width - 10, 55);
    }
    [jobCont setBackgroundColor:[UIColor whiteColor]];
    jobCont.layer.cornerRadius = 5;
    jobCont.layer.masksToBounds = true;
    [machineCont addSubview:jobCont];
    
    UIView *jobIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobIconCont.frame = CGRectMake(0, 0, 55, jobCont.frame.size.height);
    [jobIconCont setBackgroundColor:midColor];
    [jobCont addSubview:jobIconCont];
    
    UIImageView *jobIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobIcon.frame = CGRectMake(0,0,30,30);
    [jobIcon setCenter:CGPointMake(jobIconCont.frame.size.width / 2, jobIconCont.frame.size.height / 2 - 5)];
    jobIcon.image = [UIImage imageNamed:@"ic_job"];
    jobIcon.contentMode = UIViewContentModeScaleAspectFit;
    [jobIconCont addSubview:jobIcon];
    
    UILabel *jobLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobLabel.frame = CGRectMake(0,0,jobIconCont.frame.size.width-4,8);
    [jobLabel setCenter:CGPointMake(jobIconCont.frame.size.width / 2, jobIconCont.frame.size.height - 10)];
    jobLabel.text = [NSString stringWithFormat:@"Job No"];
    [jobLabel setFont:[UIFont boldSystemFontOfSize:8]];
    jobLabel.textColor = [UIColor blackColor];
    jobLabel.textAlignment = NSTextAlignmentCenter;
    [jobIconCont addSubview:jobLabel];
    
    UIView *jobMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobMachineCont.frame = CGRectMake(55, 0, jobCont.frame.size.width-55, jobCont.frame.size.height);
    [jobMachineCont setBackgroundColor:lightColor];
    [jobCont addSubview:jobMachineCont];
    
    jobMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    jobMachineValue.frame = CGRectMake(5,0,jobMachineCont.frame.size.width-10,jobMachineCont.frame.size.height);
    [jobMachineValue setCenter:CGPointMake(jobMachineCont.frame.size.width / 2, jobMachineCont.frame.size.height / 2)];
    jobMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"JobNo"]];
    jobMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    jobMachineValue.textColor = [UIColor blackColor];
    jobMachineValue.textAlignment = NSTextAlignmentLeft;
    [jobMachineCont addSubview:jobMachineValue];
    
    UIView *sectionCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        sectionCont.frame = CGRectMake(5, 165, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    } else {
        sectionCont.frame = CGRectMake(5, 125, machineCont.frame.size.width - 10, 55);
    }
    [sectionCont setBackgroundColor:[UIColor whiteColor]];
    sectionCont.layer.cornerRadius = 5;
    sectionCont.layer.masksToBounds = true;
    [machineCont addSubview:sectionCont];
    
    UIView *sectionIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionIconCont.frame = CGRectMake(0, 0, 55, sectionCont.frame.size.height);
    [sectionIconCont setBackgroundColor:midColor];
    [sectionCont addSubview:sectionIconCont];
    
    UIImageView *sectionIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionIcon.frame = CGRectMake(0,0,30,30);
    [sectionIcon setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, sectionIconCont.frame.size.height / 2 - 5)];
    sectionIcon.image = [UIImage imageNamed:@"ic_section"];
    sectionIcon.contentMode = UIViewContentModeScaleAspectFit;
    [sectionIconCont addSubview:sectionIcon];
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
    [sectionLabel setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, sectionIconCont.frame.size.height-10)];
    sectionLabel.text = [NSString stringWithFormat:@"Section"];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
    sectionLabel.textColor = [UIColor blackColor];
    sectionLabel.textAlignment = NSTextAlignmentCenter;
    [sectionIconCont addSubview:sectionLabel];
    
    UIView *sectionMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionMachineCont.frame = CGRectMake(55, 0, sectionCont.frame.size.width-55, sectionCont.frame.size.height);
    [sectionMachineCont setBackgroundColor:lightColor];
    [sectionCont addSubview:sectionMachineCont];
    
    sectionMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    sectionMachineValue.frame = CGRectMake(5,0,sectionMachineCont.frame.size.width-10,sectionMachineCont.frame.size.height);
    [sectionMachineValue setCenter:CGPointMake(sectionMachineCont.frame.size.width / 2, sectionMachineCont.frame.size.height / 2)];
    sectionMachineValue.text = [NSString stringWithFormat:@"%@", selectedData[@"SectionCode"]];
    sectionMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    sectionMachineValue.textColor = [UIColor blackColor];
    sectionMachineValue.textAlignment = NSTextAlignmentLeft;
    [sectionMachineCont addSubview:sectionMachineValue];
    
    
    UIView *speedCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        speedCont.frame = CGRectMake(5, 245, machineCont.frame.size.width - 10, 75);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    } else {
        speedCont.frame = CGRectMake(5, 185, machineCont.frame.size.width - 10, 55);
    }
    [speedCont setBackgroundColor:[UIColor whiteColor]];
    speedCont.layer.cornerRadius = 5;
    speedCont.layer.masksToBounds = true;
    [machineCont addSubview:speedCont];
    
    UIView *speedIconCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedIconCont.frame = CGRectMake(0, 0, 55, speedCont.frame.size.height);
    [speedIconCont setBackgroundColor:midColor];
    [speedCont addSubview:speedIconCont];
    
    UIImageView *speedIcon = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedIcon.frame = CGRectMake(0,0,30,30);
    [speedIcon setCenter:CGPointMake(speedIconCont.frame.size.width / 2, speedIconCont.frame.size.height / 2 - 5)];
    speedIcon.image = [UIImage imageNamed:@"ic_speed"];
    speedIcon.contentMode = UIViewContentModeScaleAspectFit;
    [speedIconCont addSubview:speedIcon];
    
    UILabel *speedLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedLabel.frame = CGRectMake(0,0,speedIconCont.frame.size.width-4,10);
    [speedLabel setCenter:CGPointMake(speedIconCont.frame.size.width / 2, speedIconCont.frame.size.height-10)];
    speedLabel.text = [NSString stringWithFormat:@"Speed"];
    [speedLabel setFont:[UIFont boldSystemFontOfSize:8]];
    speedLabel.textColor = [UIColor blackColor];
    speedLabel.textAlignment = NSTextAlignmentCenter;
    [speedIconCont addSubview:speedLabel];
    
    UIView *speedMachineCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedMachineCont.frame = CGRectMake(55, 0, speedCont.frame.size.width-55, sectionCont.frame.size.height);
    [speedMachineCont setBackgroundColor:lightColor];
    [speedCont addSubview:speedMachineCont];
    
    speedMachineValue = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        
    } else {
        
    }
    speedMachineValue.frame = CGRectMake(5,0,speedMachineCont.frame.size.width-10,speedMachineCont.frame.size.height);
    [speedMachineValue setCenter:CGPointMake(speedMachineCont.frame.size.width / 2, speedMachineCont.frame.size.height / 2)];
    double speed = [[NSString stringWithFormat:@"%@", selectedData[@"Speed"]] integerValue];
    NSString *formattedSpeed = [formatter stringFromNumber:[NSNumber numberWithInteger:speed]];
    speedMachineValue.text = [NSString stringWithFormat:@"%@", formattedSpeed];
    speedMachineValue.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
    speedMachineValue.textColor = [UIColor blackColor];
    speedMachineValue.textAlignment = NSTextAlignmentLeft;
    [speedMachineCont addSubview:speedMachineValue];
    
    //Container for progress bar
    progressCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        progressCont.frame = CGRectMake(5, 305, mainPart.frame.size.width-10, 20);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        progressCont.frame = CGRectMake(5, 500, mainPart.frame.size.width-10, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    } else {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }
    
    progressCont.layer.cornerRadius = 10;
    progressCont.layer.masksToBounds = true;
    [mainPart addSubview:progressCont];
    
    //NSString *goodAmount = [NSString stringWithFormat:@"%@", selectedData[@"GoodAmount"]];
    //SString *requiredAmount = [NSString stringWithFormat:@"%@", selectedData[@"RequiredAmount"]];
    
    //Percentage Complete
    double progressCur = [[NSString stringWithFormat:@"%@", selectedData[@"GoodAmount"]] integerValue];
    double progressCom = [[NSString stringWithFormat:@"%@", selectedData[@"RequiredAmount"]] integerValue];
    //NSLog(@"%f %f", progressCom, progressCur);
    double progressVal = progressCur / progressCom;
    //NSLog(@"%f", progressVal);
    
    UIProgressView *progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 40);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 20.0)];
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    } else {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
        [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
    }
    
    progressBar.progressTintColor = midColor;
    progressBar.trackTintColor = lightColor;
    //progressBar.progressImage = [UIImage imageNamed:@"progbar_2"];
    //progressBar.trackImage = [UIImage imageNamed:@"progbar_1"];
    progressBar.progress = progressVal;
    
    progressBar.tag = 16;
    [progressCont addSubview:progressBar];
    
    UILabel *progressLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    } else {
        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
        [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }
    
    NSString *formattedGoodAmount = [formatter stringFromNumber:[NSNumber numberWithInteger:progressCur]];
    NSString *formattedRequiredAmount = [formatter stringFromNumber:[NSNumber numberWithInteger:progressCom]];
    
    
    progressLabel.text = [NSString stringWithFormat:@"%@ / %@", formattedGoodAmount, formattedRequiredAmount];
    [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
    progressLabel.textColor = [UIColor blackColor];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    //[progressLabel setBackgroundColor:[UIColor blackColor]];
    progressLabel.tag = 17;
    [progressCont addSubview:progressLabel];
    graphBackground = [[UIView alloc] init];
    graphScroller = [[UIScrollView alloc] init];
    ten = [[UILabel alloc] init];
    twenty = [[UILabel alloc] init];
    thirty = [[UILabel alloc] init];
    forty = [[UILabel alloc] init];
    fiddy = [[UILabel alloc] init];
    
    
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        graphBackground.frame = CGRectMake(0, 335, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        graphBackground.frame = CGRectMake(0, 580, mainPart.frame.size.width, 250);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 230);
        ten.frame = CGRectMake(40, 180, 50, 20);
        twenty.frame = CGRectMake(40, 140, 50, 20);
        thirty.frame = CGRectMake(40, 100, 50, 20);
        forty.frame = CGRectMake(40, 60, 50, 20);
        fiddy.frame = CGRectMake(40, 20, 50, 20);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:22];
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    } else {
        graphBackground.frame = CGRectMake(0, 410, mainPart.frame.size.width, 150);
        graphScroller.frame = CGRectMake(70, 10, graphBackground.frame.size.width - 90, 130);
        
        ten.frame = CGRectMake(10, 110, 50, 10);
        twenty.frame = CGRectMake(10, 85, 50, 10);
        thirty.frame = CGRectMake(10, 60, 50, 10);
        forty.frame = CGRectMake(10, 35, 50, 10);
        fiddy.frame = CGRectMake(10, 10, 50, 10);
        
        ten.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        twenty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        thirty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        forty.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:12];
    }
    
    ten.textAlignment = NSTextAlignmentRight;
    ten.textColor = [UIColor blackColor];
    
    
    twenty.textAlignment = NSTextAlignmentRight;
    twenty.textColor = [UIColor blackColor];
    
    
    thirty.textAlignment = NSTextAlignmentRight;
    thirty.textColor = [UIColor blackColor];
    
    
    forty.textAlignment = NSTextAlignmentRight;
    forty.textColor = [UIColor blackColor];
    
    
    fiddy.textAlignment = NSTextAlignmentRight;
    fiddy.textColor = [UIColor blackColor];
    
    
    //[graphBackground setBackgroundColor:[UIColor yellowColor]];
    //[graphScroller setBackgroundColor:[UIColor greenColor]];
    [mainPart addSubview:graphBackground];
    
    
    UIImageView *bg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 250);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    } else {
        bg.frame = CGRectMake(0, 0, graphBackground.frame.size.width, 150);
    }
    
    bg.image = [UIImage imageNamed:@"catalogueBG"];
    [graphBackground addSubview:bg];
    
    UIImageView *fade = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        fade.frame = CGRectMake(15, 15, 100, 220);
    }
    else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        fade.frame = CGRectMake(10, 10, 70, 130);
    } else {
        fade.frame = CGRectMake(10, 10, 70, 130);
    }
    
    fade.image = [UIImage imageNamed:@"yaxis"];
    [graphBackground addSubview:fade];
    [graphBackground addSubview:graphScroller];
    
    speedHistory = [[NSMutableArray alloc] init];
    
    
    CGMutablePathRef cgPath = CGPathCreateMutable();
    path = [UIBezierPath bezierPathWithCGPath:cgPath];
    
    [graphBackground addSubview:ten];
    [graphBackground addSubview:twenty];
    [graphBackground addSubview:thirty];
    [graphBackground addSubview:forty];
    [graphBackground addSubview:fiddy];
    
    add5Mins = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    graphTimeGap = 0;
    graphMoveX = 1;
    for(graphTimeGap; graphTimeGap < 4; graphTimeGap++) {
        UILabel *time = [[UILabel alloc] init];
        if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
        {
            time.frame = CGRectMake(30 + 200*graphTimeGap, 200, 50, 20);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:22];
        }
        else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
        {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        } else {
            time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
            time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
        }
        
        time.textAlignment = NSTextAlignmentLeft;
        time.textColor = [UIColor blackColor];
        add5Mins = [add5Mins dateByAddingTimeInterval:(5*60)];
        time.text = [outputFormatter stringFromDate:add5Mins];
        [graphScroller addSubview:time];
    }
    
    [self dynamicallyUpdateMachines];
    [self startUpdateTimer];
    
}





-(void) drawGraph: (double) speed {
    NSLog(@"-------------- %f", speed);
    // min X = 0, max X = 280, gap X = 70 (every 5 mins), min Y = 10, max Y = 110, gap Y = 25
    NSNumber *numSpeed = [NSNumber numberWithDouble:speed];
    [speedHistory addObject:numSpeed];
    [path removeAllPoints];
    [shape removeFromSuperlayer];
    [gradientLayer removeFromSuperlayer];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    if([speedHistory count] > 20) {
        graphScroller.contentSize = CGSizeMake(self.view.frame.size.width + ([speedHistory count] - 20) * 15, graphScroller.frame.size.height);
        int tmp = graphTimeGap;
        for(graphTimeGap; graphTimeGap < 4 + tmp; graphTimeGap++) {
            UILabel *time = [[UILabel alloc] init];
            if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
            {
                time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
            {
                time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
            {
                time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
            {
                time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
            {
                time.frame = CGRectMake(30 + 200*graphTimeGap, 200, 50, 20);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
            {
                time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            } else {
                time.frame = CGRectMake(0 + 70*graphTimeGap, 120, 50, 10);
                time.font = [UIFont fontWithName:@"Bebas Neue" size:12];
            }
            
            time.textAlignment = NSTextAlignmentLeft;
            time.textColor = [UIColor blackColor];
            add5Mins = [add5Mins dateByAddingTimeInterval:(5*60)];
            time.text = [outputFormatter stringFromDate:add5Mins];
            [graphScroller addSubview:time];
        }
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            graphScroller.contentOffset = CGPointMake(15*graphMoveX, 0);
        } completion:NULL];
        graphMoveX++;
    }
    
    double max = 0;
    double min = DBL_MAX;
    
    for (NSNumber *sp in speedHistory) {
        double tmp = [sp doubleValue];
        if (tmp > max) {
            max = tmp;
        }
        if (tmp < min) {
            min = tmp;
        }
    }
    
    double upperbound = (ceil(max/10)) * 10;
    double lowerbound = (floor(min/10) * 10);
    if(lowerbound == upperbound) {
        upperbound = lowerbound + 10;
    }
    double gap = (upperbound-lowerbound)/4;
    
    int i = 0;
    for (NSNumber *sp in speedHistory) {
        double tmp = [sp doubleValue];
        if(i == 0) {
            if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
            {
                [path moveToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
            {
                [path moveToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
            {
                [path moveToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
            {
                [path moveToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
            {
                [path moveToPoint:CGPointMake(30 + 200*i/5, 180 - 160*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
            {
                [path moveToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            } else {
                [path moveToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            
        } else {
            if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
            {
                [path addLineToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
            {
                [path addLineToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
            {
                [path addLineToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
            {
                [path addLineToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
            {
                [path addLineToPoint:CGPointMake(30 + 200*i/5, 180 - 160*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
            {
                [path addLineToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            } else {
                [path addLineToPoint:CGPointMake(0 + 70*i/5, 110 - 100*((tmp-lowerbound)/(upperbound - lowerbound)))];
            }
            
        }
        i++;
    }
    
    
    
    ten.text = [NSString stringWithFormat:@"%.1f", lowerbound];
    twenty.text = [NSString stringWithFormat:@"%.1f", lowerbound + gap];
    thirty.text = [NSString stringWithFormat:@"%.1f", lowerbound + gap * 2];
    forty.text = [NSString stringWithFormat:@"%.1f", lowerbound + gap * 3];
    fiddy.text = [NSString stringWithFormat:@"%.1f", upperbound];
    
    
    shape = [CAShapeLayer layer];
    shape.path = path.CGPath;
    shape.lineCap = @"round";
    shape.lineJoin = @"round";
    //shape.fillColor = [[UIColor colorWithRed:0 green:0 blue:255 alpha:0.1] CGColor];
    shape.fillColor = nil;
    shape.strokeColor = [[UIColor colorWithRed:0.00 green:0.59 blue:0.86 alpha:1.0] CGColor];//[UIColor blueColor].CGColor;
    shape.lineWidth = 2;
    //shape.fillColor = [UIColor colorWithRed:255/255.0 green:20/255.0 blue:147/255.0 alpha:1].CGColor;
    [graphScroller.layer addSublayer:shape];
    
    // Gradient of progress bar
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.frame;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.00 green:0.59 blue:0.86 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:0.00 green:0.59 blue:0.86 alpha:1.0].CGColor];
    //gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:253.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:220.0/255.0 green:20.0/255.0 blue:60.0/255.0 alpha:1.0].CGColor];
    gradientLayer.startPoint = CGPointMake(0.155,0.1);
    gradientLayer.endPoint = CGPointMake(1.0,0.1);
    gradientLayer.mask = shape;
    [graphScroller.layer addSublayer:gradientLayer];
}

-(void) startUpdateTimer
{
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                   target:self
                                                 selector:@selector(dynamicallyUpdateMachines)
                                                 userInfo:nil
                                                  repeats:YES];
}

-(void) stopUpdateTimer
{
    [updateTimer invalidate];
}

-(void) dynamicallyUpdateMachines {
    NSLog(@"Update every 60s...");
        ImprintDatabase *data = [[ImprintDatabase alloc]init];
        [data getLiveFactoryView:@"Imprint Business Systems Ltd" completion:^(NSMutableArray *factoryViewData, NSError *error) {
            if(!error)
            {
                bool changed = false;
                NSNumberFormatter *formatter = [NSNumberFormatter new];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                for (NSDictionary* machineNew in factoryViewData) {
                    if([machineNew[@"ShopStation"] isEqualToString:self->selectedData[@"ShopStation"]]) {
                            if(![machineNew[@"JobTitle"] isEqualToString:self->selectedData[@"JobTitle"]]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //update UI
                                    self->titleMachineValue.text = [NSString stringWithFormat:@"%@", machineNew[@"JobTitle"]];
                                });
                                changed = true;
                            }
                            if(![machineNew[@"JobNo"] isEqualToString:self->selectedData[@"JobNo"]]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //update UI
                                    self->jobMachineValue.text = [NSString stringWithFormat:@"%@", machineNew[@"JobNo"]];

                                });
                                changed = true;
                            }
                            if(![machineNew[@"SectionCode"] isEqualToString:self->selectedData[@"SectionCode"]]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //update UI
                                    self->sectionMachineValue.text = [NSString stringWithFormat:@"%@", machineNew[@"SectionCode"]];
                                });
                                changed = true;
                            }
                            
                            NSString *speedNew = [NSString stringWithFormat:@"%@", machineNew[@"Speed"]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self drawGraph:[speedNew doubleValue]];
                            });
                            
                            NSString *speedOld = [NSString stringWithFormat:@"%@", self->selectedData[@"Speed"]];
                            if(![speedNew isEqualToString:speedOld]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //update UI
                                    double speed = [[NSString stringWithFormat:@"%@", speedNew] integerValue];
                                    NSString *formattedSpeed = [formatter stringFromNumber:[NSNumber numberWithInteger:speed]];
                                    self->speedMachineValue.text = [NSString stringWithFormat:@"%@", formattedSpeed];
                                });
                                changed = true;
                            }
                            
                            //Progress bar update
                            NSString *goodAmountNew = [NSString stringWithFormat:@"%@", machineNew[@"GoodAmount"]];
                            NSString *goodAmountOld = [NSString stringWithFormat:@"%@", self->selectedData[@"GoodAmount"]];
                            if(![goodAmountNew isEqualToString:goodAmountOld]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //update UI
                                    //Percentage Complete
                                    double progressCur = [[NSString stringWithFormat:@"%@", machineNew[@"GoodAmount"]] integerValue];
                                    double progressCom = [[NSString stringWithFormat:@"%@", machineNew[@"RequiredAmount"]] integerValue];
                                    //NSLog(@"%f %f", progressCom, progressCur);
                                    double progressVal = progressCur / progressCom;
                                    
                                    UIProgressView *progressBar = (UIProgressView *)[self->progressCont viewWithTag:16];
                                    progressBar.progress = progressVal;
                                    
                                    NSString *formattedGoodAmount = [formatter stringFromNumber:[NSNumber numberWithInteger:progressCur]];
                                    NSString *formattedRequiredAmount = [formatter stringFromNumber:[NSNumber numberWithInteger:progressCom]];
                                    UILabel *progressLabel = (UILabel *)[self->progressCont viewWithTag:17];
                                    progressLabel.text = [NSString stringWithFormat:@"%@ / %@", formattedGoodAmount, formattedRequiredAmount];
                                });
                                changed = true;
                            }
                        }
                    
                }
                if (changed) {
                    //
                }
                NSLog(@"Data changed: %s", changed ? "true" : "false");
            }
        }];
}

-(void) viewDockets {
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:26/255.0f
                                                      green:26/255.0f
                                                       blue:26/255.0f
                                                      alpha:0.95f]];
    [self.view addSubview:overlay];
    
    overlayCont = [[UIView alloc] init];
    overlayCont.frame = CGRectMake(5, 100, overlay.frame.size.width-10, overlay.frame.size.height-120);
    [overlayCont setBackgroundColor:[UIColor whiteColor]];
    overlayCont.layer.cornerRadius = 5;
    overlayCont.layer.masksToBounds = true;
    [overlay addSubview:overlayCont];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    [title setCenter:CGPointMake(overlayCont.frame.size.width/2, 20)];
    title.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"Dockets";
    title.textColor = [UIColor colorWithRed:102/255.0f
                                             green:102/255.0f
                                              blue:102/255.0f
                                             alpha:1.0f];
    [overlayCont addSubview:title];
    
    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(overlayCont.frame.size.width-30, 12, 18, 18)];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(tapExitDockets) forControlEvents:UIControlEventTouchDown];
    [overlayCont addSubview:exitBtn];
    
    [self showLoading];
    [self loadDockets];
}

-(void) loadDockets {
    NSMutableArray *darkColors = [NSMutableArray array];
    NSMutableArray *midColors = [NSMutableArray array];
    NSMutableArray *lightColors = [NSMutableArray array];
    NSMutableArray *gradientStartColors = [NSMutableArray array];
    NSMutableArray *gradientEndColors = [NSMutableArray array];
    
    //Blue
    UIColor *color = [UIColor colorWithRed:34/255.0f
                                     green:145/255.0f
                                      blue:237/255.0f
                                     alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:185/255.0f
                            green:217/255.0f
                             blue:244/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:12/255.0f
                            green:28/255.0f
                             blue:42/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:79/255.0f
                            green:185/255.0f
                             blue:245/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:28/255.0f
                            green:135/255.0f
                             blue:236/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Green
    color = [UIColor colorWithRed:172/255.0f
                            green:200/255.0f
                             blue:55/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:215/255.0f
                            green:237/255.0f
                             blue:123/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:37/255.0f
                            green:44/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:194/255.0f
                            green:215/255.0f
                             blue:93/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:149/255.0f
                            green:182/255.0f
                             blue:37/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Red
    color = [UIColor colorWithRed:226/255.0f
                            green:14/255.0f
                             blue:14/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:225/255.0f
                            green:160/255.0f
                             blue:160/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:50/255.0f
                            green:18/255.0f
                             blue:18/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:223/255.0f
                            green:27/255.0f
                             blue:27/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:212/255.0f
                            green:6/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    //Grey
    color = [UIColor colorWithRed:97/255.0f
                            green:97/255.0f
                             blue:97/255.0f
                            alpha:1.0f];
    [midColors addObject:color];
    color = [UIColor colorWithRed:205/255.0f
                            green:205/255.0f
                             blue:205/255.0f
                            alpha:1.0f];
    [lightColors addObject:color];
    color = [UIColor colorWithRed:26/255.0f
                            green:26/255.0f
                             blue:26/255.0f
                            alpha:1.0f];
    [darkColors addObject:color];
    color = [UIColor colorWithRed:124/255.0f
                            green:124/255.0f
                             blue:124/255.0f
                            alpha:1.0f];
    [gradientStartColors addObject:color];
    color = [UIColor colorWithRed:64/255.0f
                            green:64/255.0f
                             blue:64/255.0f
                            alpha:1.0f];
    [gradientEndColors addObject:color];
    
    NSString *shopStation = [NSString stringWithFormat:@"%@",selectedData[@"ShopStation"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [NSDate date];
    NSString *endDate = [NSString stringWithFormat:@"%@T%@",[dateFormatter stringFromDate:now],[timeFormatter stringFromDate:now]];
    //NSLog(@"endDateString %@", endDate);
   
    //Date minus 12hours (3600*12)
    NSDate *newDate = [[NSDate alloc] initWithTimeInterval:-3600*12 sinceDate:now];
    NSString *startDate = [NSString stringWithFormat:@"%@T%@",[dateFormatter stringFromDate:newDate],[timeFormatter stringFromDate:newDate]];
    //NSLog(@"startDateString %@", startDate);
    
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getDockets:shopStation: startDate: endDate completion:^(NSDictionary *docketsList, NSError *error) {
        if(!error)
        {
            NSDictionary *docketList = docketsList[@"DocketEntries"];
            dispatch_async(dispatch_get_main_queue(), ^{
                //CHANGE GUI IN HERE
                int count = (int) [docketList count];
                //count = count*2;
                NSLog(@"%d", count);
                
                if(count != 0) {
                    UIScrollView *mainPart = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 40, self->overlayCont.frame.size.width-10, self->overlayCont.frame.size.height-45)];
                    mainPart.contentSize = CGSizeMake(mainPart.frame.size.width, 110*count);
                    mainPart.bounces = NO;
                    [mainPart setShowsVerticalScrollIndicator:NO];
                    
                    int machineYValue = 0;
                    /*NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:factoryViewData];
                     for(NSDictionary* machine in tmp) {
                     [factoryViewData addObject:machine];
                     }*/
                    for (NSDictionary* docket in docketList) {
                        UIColor *midColor;
                        UIColor *lightColor;
                        UIColor *darkColor;
                        UIColor *gradientStart;
                        UIColor *gradientEnd;
                        
                        NSString *docketCode = [NSString stringWithFormat:@"%@", docket[@"OperationCode"]];
                        NSString *operationCode;
                        NSString *operationDescription;
                        for (NSDictionary* operationIndex in self->operationCodes) {
                            NSString *opCode = [NSString stringWithFormat:@"%@", operationIndex[@"OperationCode"]];
                            
                            if([opCode isEqualToString:docketCode]) {
                                operationCode = [NSString stringWithFormat:@"%@", operationIndex[@"OperationState"]];
                                operationDescription = [NSString stringWithFormat:@"%@", operationIndex[@"Description"]];
                            }
                        }
                        
                        if ([operationCode isEqualToString:@"2"]) {
                            midColor = [midColors objectAtIndex:1];
                            lightColor = [lightColors objectAtIndex:1];
                            darkColor = [darkColors objectAtIndex:1];
                            gradientStart = [gradientStartColors objectAtIndex:1];
                            gradientEnd = [gradientEndColors objectAtIndex:1];
                        } else if ([operationCode isEqualToString:@"1"]) {
                            midColor = [midColors objectAtIndex:0];
                            lightColor = [lightColors objectAtIndex:0];
                            darkColor = [darkColors objectAtIndex:0];
                            gradientStart = [gradientStartColors objectAtIndex:0];
                            gradientEnd = [gradientEndColors objectAtIndex:0];
                        } else if ([operationCode isEqualToString:@"5"]) {
                            midColor = [midColors objectAtIndex:2];
                            lightColor = [lightColors objectAtIndex:2];
                            darkColor = [darkColors objectAtIndex:2];
                            gradientStart = [gradientStartColors objectAtIndex:2];
                            gradientEnd = [gradientEndColors objectAtIndex:2];
                        } else if ([operationCode isEqualToString:@"4"]) {
                            midColor = [midColors objectAtIndex:3];
                            lightColor = [lightColors objectAtIndex:3];
                            darkColor = [darkColors objectAtIndex:3];
                            gradientStart = [gradientStartColors objectAtIndex:3];
                            gradientEnd = [gradientEndColors objectAtIndex:3];
                        } else {
                            midColor = [midColors objectAtIndex:3];
                            lightColor = [lightColors objectAtIndex:3];
                            darkColor = [darkColors objectAtIndex:3];
                            gradientStart = [gradientStartColors objectAtIndex:3];
                            gradientEnd = [gradientEndColors objectAtIndex:3];
                        }
                        
                        
                        UIView *docketContainer = [[UIView alloc] init];
                        if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 95);
                        }
                        else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 210);
                        }
                        else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 210);
                        }
                        else if ([[UIScreen mainScreen] bounds].size.height == 896) //iPhone XR size
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 210);
                        }
                        else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 190);
                        }
                        else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 390);
                        }
                        else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                        {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 190);
                        } else {
                            docketContainer.frame = CGRectMake(2, 4 + machineYValue, mainPart.frame.size.width-5, 210);
                        }
                        [docketContainer setBackgroundColor:[UIColor whiteColor]];
                        // border radius
                        [docketContainer.layer setCornerRadius:10.0f];
                        
                        // drop shadow
                        [docketContainer.layer setShadowColor:[UIColor blackColor].CGColor];
                        [docketContainer.layer setShadowOpacity:0.8];
                        [docketContainer.layer setShadowRadius:3.0];
                        [docketContainer.layer setShadowOffset:CGSizeMake(2.0, 2.0)];

                        [mainPart addSubview:docketContainer];
                        
                        UIView *jobNoDocketCont = [[UIView alloc] init];
                        jobNoDocketCont.frame = CGRectMake(5, 5, docketContainer.frame.size.width/2-7, 25);
                        jobNoDocketCont.layer.cornerRadius = 5;
                        jobNoDocketCont.layer.masksToBounds = true;
                        [docketContainer addSubview:jobNoDocketCont];
                        
                        UIView *iconJobCont = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, jobNoDocketCont.frame.size.height)];
                        [iconJobCont setBackgroundColor:midColor];
                        [jobNoDocketCont addSubview:iconJobCont];
                        
                        UIImageView *jobNoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
                        [jobNoIcon setCenter:CGPointMake(10, iconJobCont.frame.size.height/2)];
                        jobNoIcon.image = [UIImage imageNamed:@"ic_job_white"];
                        [iconJobCont addSubview:jobNoIcon];
                        
                        UILabel *jobNotitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, iconJobCont.frame.size.width-20, iconJobCont.frame.size.height)];
                        [jobNotitle setFont:[UIFont boldSystemFontOfSize:7]];
                        jobNotitle.textColor = [UIColor colorWithRed:226/255.0f
                                                               green:226/255.0f
                                                                blue:226/255.0f
                                                               alpha:1.0f];
                        jobNotitle.textAlignment = NSTextAlignmentLeft;
                        jobNotitle.text = @"Job No";
                        [iconJobCont addSubview:jobNotitle];
                        
                        UIView *jobNoValueCont = [[UIView alloc] initWithFrame:CGRectMake(60, 0, jobNoDocketCont.frame.size.width-60, jobNoDocketCont.frame.size.height)];
                        [jobNoValueCont setBackgroundColor:lightColor];
                        [jobNoDocketCont addSubview:jobNoValueCont];
                        
                        //Need to make it auto resize width, or font size
                        UILabel *jobNoValue = [[UILabel alloc] init];
                        jobNoValue.frame = CGRectMake(0,0,jobNoValueCont.frame.size.width,jobNoValueCont.frame.size.height);
                        [jobNoValue setCenter:CGPointMake(jobNoValueCont.frame.size.width / 2, jobNoValueCont.frame.size.height / 2)];
                        jobNoValue.text = [NSString stringWithFormat:@"%@", docket[@"JobNo"]];
                        jobNoValue.textColor = [UIColor blackColor];
                        jobNoValue.textAlignment = NSTextAlignmentCenter;
                        [jobNoValue setFont:[UIFont boldSystemFontOfSize:10]];
                        //titleMachineValue.adjustsFontSizeToFitWidth = true;
                        //[titleMachineValue setBackgroundColor:[UIColor blackColor]];
                        [jobNoValueCont addSubview:jobNoValue];
                        
                        
                        
                        UIView *sectionDocketCont = [[UIView alloc] init];
                        sectionDocketCont.frame = CGRectMake(docketContainer.frame.size.width/2+2, 5, docketContainer.frame.size.width/2-7, 25);
                        sectionDocketCont.layer.cornerRadius = 5;
                        sectionDocketCont.layer.masksToBounds = true;
                        [docketContainer addSubview:sectionDocketCont];
                        
                        UIView *iconSectCont = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, sectionDocketCont.frame.size.height)];
                        [iconSectCont setBackgroundColor:midColor];
                        [sectionDocketCont addSubview:iconSectCont];
                        
                        UIImageView *sectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
                        [sectIcon setCenter:CGPointMake(10, iconSectCont.frame.size.height/2)];
                        sectIcon.image = [UIImage imageNamed:@"ic_job_white"];
                        [iconSectCont addSubview:sectIcon];
                        
                        UILabel *secTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, iconSectCont.frame.size.width-20, iconSectCont.frame.size.height)];
                        [secTitle setFont:[UIFont boldSystemFontOfSize:7]];
                        secTitle.textColor = [UIColor colorWithRed:226/255.0f
                                                             green:226/255.0f
                                                              blue:226/255.0f
                                                             alpha:1.0f];
                        secTitle.textAlignment = NSTextAlignmentLeft;
                        secTitle.text = @"Section";
                        [iconSectCont addSubview:secTitle];
                        
                        UIView *secValueCont = [[UIView alloc] initWithFrame:CGRectMake(60, 0, sectionDocketCont.frame.size.width-60, sectionDocketCont.frame.size.height)];
                        [secValueCont setBackgroundColor:lightColor];
                        [sectionDocketCont addSubview:secValueCont];
                        
                        //Need to make it auto resize width, or font size
                        UILabel *secValue = [[UILabel alloc] init];
                        secValue.frame = CGRectMake(0,0,secValueCont.frame.size.width,secValueCont.frame.size.height);
                        [secValue setCenter:CGPointMake(secValueCont.frame.size.width / 2, secValueCont.frame.size.height / 2)];
                        secValue.text = [NSString stringWithFormat:@"%@", docket[@"Section"]];
                        secValue.textColor = [UIColor blackColor];
                        secValue.textAlignment = NSTextAlignmentCenter;
                        [secValue setFont:[UIFont boldSystemFontOfSize:10]];
                        //titleMachineValue.adjustsFontSizeToFitWidth = true;
                        //[titleMachineValue setBackgroundColor:[UIColor blackColor]];
                        [secValueCont addSubview:secValue];
                        
                        
                        
                        UIView *opDocketCont = [[UIView alloc] init];
                        opDocketCont.frame = CGRectMake(5, 35, docketContainer.frame.size.width/3-7, 25);
                        opDocketCont.layer.cornerRadius = 5;
                        opDocketCont.layer.masksToBounds = true;
                        [docketContainer addSubview:opDocketCont];
                        
                        UIView *iconOpCont = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, opDocketCont.frame.size.height)];
                        [iconOpCont setBackgroundColor:midColor];
                        [opDocketCont addSubview:iconOpCont];
                        
                        UIImageView *opIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
                        [opIcon setCenter:CGPointMake(10, iconOpCont.frame.size.height/2)];
                        opIcon.image = [UIImage imageNamed:@"ic_user_white"];
                        [iconOpCont addSubview:opIcon];
                        
                        UILabel *opTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, iconOpCont.frame.size.width-20, iconOpCont.frame.size.height)];
                        [opTitle setFont:[UIFont boldSystemFontOfSize:7]];
                        opTitle.textColor = [UIColor colorWithRed:226/255.0f
                                                            green:226/255.0f
                                                             blue:226/255.0f
                                                            alpha:1.0f];
                        opTitle.textAlignment = NSTextAlignmentLeft;
                        opTitle.text = @"Operator Code";
                        opTitle.numberOfLines = 2;
                        opTitle.lineBreakMode = NSLineBreakByWordWrapping;
                        [iconOpCont addSubview:opTitle];
                        
                        UIView *opValueCont = [[UIView alloc] initWithFrame:CGRectMake(60, 0, opDocketCont.frame.size.width-60, opDocketCont.frame.size.height)];
                        [opValueCont setBackgroundColor:lightColor];
                        [opDocketCont addSubview:opValueCont];
                        
                        //Need to make it auto resize width, or font size
                        UILabel *opValue = [[UILabel alloc] init];
                        opValue.frame = CGRectMake(0,0,opValueCont.frame.size.width,opValueCont.frame.size.height);
                        [opValue setCenter:CGPointMake(opValueCont.frame.size.width / 2, opValueCont.frame.size.height / 2)];
                        opValue.text = [NSString stringWithFormat:@"%@", docket[@"OperatorCode"]];
                        opValue.textColor = [UIColor blackColor];
                        opValue.textAlignment = NSTextAlignmentCenter;
                        [opValue setFont:[UIFont boldSystemFontOfSize:10]];
                        //titleMachineValue.adjustsFontSizeToFitWidth = true;
                        //[titleMachineValue setBackgroundColor:[UIColor blackColor]];
                        [opValueCont addSubview:opValue];
                        
                        
                        
                        UIView *operationDocketCont = [[UIView alloc] init];
                        operationDocketCont.frame = CGRectMake(docketContainer.frame.size.width/3+2, 35, docketContainer.frame.size.width/3*2-7, 25);
                        operationDocketCont.layer.cornerRadius = 5;
                        operationDocketCont.layer.masksToBounds = true;
                        [docketContainer addSubview:operationDocketCont];
                        
                        UIView *iconOperationCont = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, operationDocketCont.frame.size.height)];
                        [iconOperationCont setBackgroundColor:midColor];
                        [operationDocketCont addSubview:iconOperationCont];
                        
                        UIImageView *operationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
                        [operationIcon setCenter:CGPointMake(10, iconOperationCont.frame.size.height/2)];
                        operationIcon.image = [UIImage imageNamed:@"ic_job_white"];
                        [iconOperationCont addSubview:operationIcon];
                        
                        UILabel *operationTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, iconOperationCont.frame.size.width-20, iconOperationCont.frame.size.height)];
                        [operationTitle setFont:[UIFont boldSystemFontOfSize:7]];
                        operationTitle.textColor = [UIColor colorWithRed:226/255.0f
                                                                   green:226/255.0f
                                                                    blue:226/255.0f
                                                                   alpha:1.0f];
                        operationTitle.textAlignment = NSTextAlignmentLeft;
                        operationTitle.text = @"Operation";
                        [iconOperationCont addSubview:operationTitle];
                        
                        UIView *operationValueCont = [[UIView alloc] initWithFrame:CGRectMake(60, 0, operationDocketCont.frame.size.width-60, operationDocketCont.frame.size.height)];
                        [operationValueCont setBackgroundColor:lightColor];
                        [operationDocketCont addSubview:operationValueCont];
                        
                        UILabel *operationValue = [[UILabel alloc] init];
                        operationValue.frame = CGRectMake(0,0,operationValueCont.frame.size.width,operationValueCont.frame.size.height);
                        [operationValue setCenter:CGPointMake(operationValueCont.frame.size.width / 2, operationValueCont.frame.size.height / 2)];
                        operationValue.text = operationDescription;
                        operationValue.textColor = [UIColor blackColor];
                        operationValue.textAlignment = NSTextAlignmentCenter;
                        [operationValue setFont:[UIFont boldSystemFontOfSize:10]];
                        //titleMachineValue.adjustsFontSizeToFitWidth = true;
                        //[titleMachineValue setBackgroundColor:[UIColor blackColor]];
                        [operationValueCont addSubview:operationValue];
                        
                        
                        
                        NSDateFormatter *ISO8601DateFormatter = [[NSDateFormatter alloc] init];
                        ISO8601DateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                        ISO8601DateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
                        ISO8601DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
                        [dateFormatter setLocalizedDateFormatFromTemplate:@"E MMM d yyyy HH:mm:ss"];
                        
                        UIView *dateDocketCont = [[UIView alloc] init];
                        dateDocketCont.frame = CGRectMake(5, 65, docketContainer.frame.size.width-10, 25);
                        dateDocketCont.layer.cornerRadius = 5;
                        dateDocketCont.layer.masksToBounds = true;
                        [docketContainer addSubview:dateDocketCont];
                        
                        UIView *iconDateCont = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, dateDocketCont.frame.size.height)];
                        [iconDateCont setBackgroundColor:midColor];
                        [dateDocketCont addSubview:iconDateCont];
                        
                        UIImageView *dateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
                        [dateIcon setCenter:CGPointMake(10, iconDateCont.frame.size.height/2)];
                        dateIcon.image = [UIImage imageNamed:@"ic_speed_white"];
                        [iconDateCont addSubview:dateIcon];
                        
                        UILabel *dateTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, iconDateCont.frame.size.width-20, iconDateCont.frame.size.height)];
                        [dateTitle setFont:[UIFont boldSystemFontOfSize:7]];
                        dateTitle.textColor = [UIColor colorWithRed:226/255.0f
                                                              green:226/255.0f
                                                               blue:226/255.0f
                                                              alpha:1.0f];
                        dateTitle.textAlignment = NSTextAlignmentLeft;
                        dateTitle.text = @"Date Entered";
                        dateTitle.numberOfLines = 2;
                        dateTitle.lineBreakMode = NSLineBreakByWordWrapping;
                        [iconDateCont addSubview:dateTitle];
                        
                        UIView *dateValueCont = [[UIView alloc] initWithFrame:CGRectMake(60, 0, dateDocketCont.frame.size.width-60, dateDocketCont.frame.size.height)];
                        [dateValueCont setBackgroundColor:lightColor];
                        [dateDocketCont addSubview:dateValueCont];
                        
                        //Need to make it auto resize width, or font size
                        UILabel *dateValue = [[UILabel alloc] init];
                        dateValue.frame = CGRectMake(0,0,dateValueCont.frame.size.width,dateValueCont.frame.size.height);
                        [dateValue setCenter:CGPointMake(dateValueCont.frame.size.width / 2, dateValueCont.frame.size.height / 2)];
                        NSDate *date =  [ISO8601DateFormatter dateFromString:docket[@"DateEntered"]];
                        dateValue.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
                        dateValue.textColor = [UIColor blackColor];
                        dateValue.textAlignment = NSTextAlignmentCenter;
                        [dateValue setFont:[UIFont boldSystemFontOfSize:10]];
                        //titleMachineValue.adjustsFontSizeToFitWidth = true;
                        //[titleMachineValue setBackgroundColor:[UIColor blackColor]];
                        [dateValueCont addSubview:dateValue];
                        
                        machineYValue += 110;
                    }
                    [self->Hud removeFromSuperview];
                    [self->overlayCont addSubview:mainPart];
                } else {
                    UILabel *noDocketsMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
                    [noDocketsMsg setCenter:CGPointMake(self->overlayCont.frame.size.width/2, 70)];
                    noDocketsMsg.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
                    noDocketsMsg.textAlignment = NSTextAlignmentCenter;
                    noDocketsMsg.numberOfLines = 2;
                    noDocketsMsg.text = @"No Dockets Found\n(In Last 12 Hours)";
                    noDocketsMsg.textColor = [UIColor colorWithRed:102/255.0f
                                                      green:102/255.0f
                                                       blue:102/255.0f
                                                      alpha:1.0f];
                    [self->overlayCont addSubview:noDocketsMsg];
                    [self->Hud removeFromSuperview];
                }
            });
            //NSLog(@"%@",docketsList);
        }
    }];
}

-(void) tapExitDockets {
    [overlay removeFromSuperview];
}

-(void) loadOperationCodes {
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getOperationCodes:nil completion:^(NSDictionary *OperationCodes, NSError *error) {
        if(!error)
        {
            self->operationCodes = OperationCodes;
            //NSLog(@"%@",self->operationCodes);
        }
    }];
}

-(void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            [Hud removeFromSuperview];
            [self viewDidLoad];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [Hud removeFromSuperview];
            [self viewDidLoad];
            break;
        case UIDeviceOrientationLandscapeRight:
            [Hud removeFromSuperview];
            [self viewDidLoad];
            break;
            
        default:
            break;
    };
}

-(void) viewDocuments {
    //Display overlay of documents available, then allow user to either view or download documents based on what Geoff says.
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:26/255.0f
                                                green:26/255.0f
                                                 blue:26/255.0f
                                                alpha:0.95f]];
    [self.view addSubview:overlay];
    
    overlayCont = [[UIView alloc] init];
    overlayCont.frame = CGRectMake(5, 100, overlay.frame.size.width-10, overlay.frame.size.height-120);
    [overlayCont setBackgroundColor:[UIColor whiteColor]];
    overlayCont.layer.cornerRadius = 5;
    overlayCont.layer.masksToBounds = true;
    [overlay addSubview:overlayCont];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    [title setCenter:CGPointMake(overlayCont.frame.size.width/2, 20)];
    title.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:22];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"Linked Documents";
    title.textColor = [UIColor colorWithRed:102/255.0f
                                      green:102/255.0f
                                       blue:102/255.0f
                                      alpha:1.0f];
    [overlayCont addSubview:title];
    
    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(overlayCont.frame.size.width-30, 12, 18, 18)];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(tapExitDockets) forControlEvents:UIControlEventTouchDown];
    [overlayCont addSubview:exitBtn];
    
    [self loadDocuments];
}

-(CAShapeLayer*) createCornerMaskLayer:(CGFloat)topLeftRadius: (CGFloat)topRightRadius: (CGFloat)bottomRightRadius: (CGFloat)bottomLeftRadius: (CGRect)bounds {
    
    CGFloat minx = CGRectGetMinX(bounds);
    CGFloat miny = CGRectGetMinY(bounds);
    CGFloat maxx = CGRectGetMaxX(bounds);
    CGFloat maxy = CGRectGetMaxY(bounds);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(minx + topLeftRadius, miny)];
    [path addLineToPoint:CGPointMake(maxx - topRightRadius, miny)];
    [path addArcWithCenter:CGPointMake(maxx - topRightRadius, miny + topRightRadius) radius: topRightRadius startAngle: 3 * M_PI_2 endAngle: 0 clockwise: YES];
    [path addLineToPoint:CGPointMake(maxx, maxy - bottomRightRadius)];
    [path addArcWithCenter:CGPointMake(maxx - bottomRightRadius, maxy - bottomRightRadius) radius: bottomRightRadius startAngle: 0 endAngle: M_PI_2 clockwise: YES];
    [path addLineToPoint:CGPointMake(minx + bottomLeftRadius, maxy)];
    [path addArcWithCenter:CGPointMake(minx + bottomLeftRadius, maxy - bottomLeftRadius) radius: bottomLeftRadius startAngle: M_PI_2 endAngle:M_PI clockwise: YES];
    [path addLineToPoint:CGPointMake(minx, miny + topLeftRadius)];
    [path addArcWithCenter:CGPointMake(minx + topLeftRadius, miny + topLeftRadius) radius: topLeftRadius startAngle: M_PI endAngle:3 * M_PI_2 clockwise: YES];
    [path closePath];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = path.CGPath;

    return maskLayer;
}

-(void) loadDocuments {
    UIScrollView *docsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, overlayCont.frame.size.width, overlayCont.frame.size.height-50)];
    
    [self showLoading];
    
    UIView *workInstructionsShadow = [[UIView alloc] initWithFrame:CGRectMake(8, 0, docsScroll.frame.size.width-16, 44)];
    [workInstructionsShadow setBackgroundColor:[UIColor colorWithRed:200/255.0f
                                                                      green:200/255.0f
                                                                       blue:200/255.0f
                                                                      alpha:0.5f]];
    
    [workInstructionsShadow.layer setMask:[self createCornerMaskLayer:5 :22 :22 :5 :workInstructionsShadow.bounds]];
    
    [docsScroll addSubview:workInstructionsShadow];
    
    UIView *workInstructionsCont = [[UIView alloc] initWithFrame:CGRectMake(2, 2, workInstructionsShadow.frame.size.width-4, 40)];
    [workInstructionsCont setBackgroundColor:[UIColor whiteColor]];
    
    [workInstructionsCont.layer setMask:[self createCornerMaskLayer:5 :20 :20 :5 :workInstructionsCont.bounds]];
    
    [workInstructionsShadow addSubview:workInstructionsCont];
    
    UIButton *workInstructionsBtn = [[UIButton alloc] initWithFrame:CGRectMake(workInstructionsCont.frame.size.width-100, 2, 98, 36)];
    [workInstructionsBtn setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                                             green:29/255.0f
                                                              blue:74/255.0f
                                                             alpha:0.95f]];
    
    [workInstructionsBtn.layer setMask:[self createCornerMaskLayer:5 :18 :18 :5 :workInstructionsBtn.bounds]];
    
    [workInstructionsBtn addTarget:self action:@selector(tapWorkInstructions) forControlEvents:UIControlEventTouchDown];
    [workInstructionsCont addSubview:workInstructionsBtn];
    
    UILabel *workInstructionsBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, workInstructionsBtn.frame.size.width, workInstructionsBtn.frame.size.height)];
    workInstructionsBtnLabel.text = [NSString stringWithFormat:@"View"];
    workInstructionsBtnLabel.font = [UIFont fontWithName:@"OpenSans-ExtraBold" size:16];
    workInstructionsBtnLabel.textColor = [UIColor whiteColor];
    workInstructionsBtnLabel.textAlignment = NSTextAlignmentCenter;
    [workInstructionsBtn addSubview:workInstructionsBtnLabel];
    
    UILabel *workInstructionsTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, workInstructionsCont.frame.size.width-120, workInstructionsCont.frame.size.height)];
    workInstructionsTitle.text = [NSString stringWithFormat:@"Work Instructions"];
    workInstructionsTitle.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    workInstructionsTitle.textColor = [UIColor blackColor];
    workInstructionsTitle.textAlignment = NSTextAlignmentLeft;
    [workInstructionsCont addSubview:workInstructionsTitle];
    
    NSString *jobNo = [NSString stringWithFormat:@"%@", selectedData[@"JobNo"]];
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getJobCollections:jobNo completion:^(NSDictionary *jobCollections, NSError *error) {
        if(!error)
        {
            if([jobCollections[@"ExternalDocuments"] count]!= 0) {
                NSDictionary *externalDocs = jobCollections[@"ExternalDocuments"];
                int count = 0;
                int Ycount = 0;
                for (NSDictionary *doc in externalDocs) {
                    //NSLog(@"%@",doc);
                    count++;
                    NSString *exePath = [NSString stringWithFormat:@"%@", doc[@"ExePath"]];
                    NSLog(@"%@",exePath);
                    NSString *fileExt = [exePath substringFromIndex: [exePath length] - 4];
                    if ([fileExt isEqualToString:@".pdf"]) {
                        Ycount++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIView *docShadow = [[UIView alloc] initWithFrame:CGRectMake(8, 50*Ycount, docsScroll.frame.size.width-16, 44)];
                            [docShadow setBackgroundColor:[UIColor colorWithRed:200/255.0f
                                                                                       green:200/255.0f
                                                                                        blue:200/255.0f
                                                                                       alpha:0.5f]];
                            
                            [docShadow.layer setMask:[self createCornerMaskLayer:5 :22 :22 :5 :workInstructionsShadow.bounds]];
                            
                            [docsScroll addSubview:docShadow];
                            
                            UIView *extDocCont = [[UIView alloc] initWithFrame:CGRectMake(2, 2, workInstructionsShadow.frame.size.width-4, 40)];
                            [extDocCont setBackgroundColor:[UIColor whiteColor]];
                            
                            [extDocCont.layer setMask:[self createCornerMaskLayer:5 :20 :20 :5 :workInstructionsCont.bounds]];
                            
                            [docShadow addSubview:extDocCont];
                            
                            UIButton *extDocBtn = [[UIButton alloc] initWithFrame:CGRectMake(workInstructionsCont.frame.size.width-100, 2, 98, 36)];
                            [extDocBtn setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                                                                    green:29/255.0f
                                                                                    blue:74/255.0f
                                                                                    alpha:0.95f]];
                            
                            [extDocBtn.layer setMask:[self createCornerMaskLayer:5 :18 :18 :5 :extDocBtn.bounds]];
                            
                            [extDocBtn.layer setValue:exePath forKey:@"ExePath"];
                            [extDocBtn addTarget:self action:@selector(tapViewDoc:) forControlEvents:UIControlEventTouchDown];
                            [extDocCont addSubview:extDocBtn];
                            
                            UILabel *extDocBtnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, extDocBtn.frame.size.width, workInstructionsBtn.frame.size.height)];
                            extDocBtnLabel.text = [NSString stringWithFormat:@"View"];
                            extDocBtnLabel.font = [UIFont fontWithName:@"OpenSans-ExtraBold" size:16];
                            extDocBtnLabel.textColor = [UIColor whiteColor];
                            extDocBtnLabel.textAlignment = NSTextAlignmentCenter;
                            [extDocBtn addSubview:extDocBtnLabel];
                            
                            UILabel *extDocTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, extDocCont.frame.size.width-120, extDocCont.frame.size.height)];
                            extDocTitle.text = [NSString stringWithFormat:@"%@", doc[@"Header"]];
                            extDocTitle.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
                            extDocTitle.textColor = [UIColor blackColor];
                            extDocTitle.textAlignment = NSTextAlignmentLeft;
                            [extDocCont addSubview:extDocTitle];
                            
                            if(count == [externalDocs count]) {
                                [self->Hud removeFromSuperview];
                                [self->overlayCont addSubview:docsScroll];
                            }
                        });
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->Hud removeFromSuperview];
                    [self->overlayCont addSubview:docsScroll];
                });
            }
            //NSLog(@"---------- %@", jobCollections);
        }
    }];
}

-(void) tapWorkInstructions {
    [self showLoading];
    NSLog(@"View Doc");
    NSString *jobNo = [NSString stringWithFormat:@"%@", selectedData[@"JobNo"]];
    
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getWorkDocument:jobNo completion:^(NSData *PDFData, NSError *error) {
        if(!error)
        {
            //NSLog(@"%@",PDFData);
            [self mimeTypeForData:PDFData];
            NSString* pdfString = [[NSString alloc] initWithData:PDFData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",pdfString);
            if([pdfString length] != 0) {
                NSLog(@"String: %@",pdfString);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->webView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 80, self->overlay.frame.size.width-10, self->overlay.frame.size.height-100)];
                    
                    [self->webView loadData:PDFData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
                    
                    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(self->webView.frame.size.width-30, 12, 18, 18)];
                    [exitBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
                    [exitBtn addTarget:self action:@selector(closePDF) forControlEvents:UIControlEventTouchDown];
                    [self->webView addSubview:exitBtn];
                    
                    [self->Hud removeFromSuperview];
                    [self->overlay addSubview:self->webView];
                });
            }
        }
    }];
}
-(NSMutableData*) convertData: (NSData*) data{
    NSMutableData *tmp = [NSMutableData dataWithData:data];
    int value = 37;
    [tmp replaceBytesInRange:NSMakeRange(0, 1) withBytes:&value];
    return tmp;
    
}
- (NSString *)mimeTypeForData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    NSLog(@"First Byte: %d",c);
    
    /*const char* fileBytes = (const char*)[data bytes];
    NSUInteger length = [data length];
    NSUInteger index;
    
    for (index = 0; index<length; index++)
    {
        char aByte = fileBytes[index];
        NSLog(@"------------------------ %d",aByte);
    }*/
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
    
}-(void) tapViewDoc:(UIButton*)sender {
    [self showLoading];
    NSLog(@"View Ext");
    NSString *jobNo = [NSString stringWithFormat:@"%@", selectedData[@"JobNo"]];
    NSString *exePath = [NSString stringWithFormat:@"%@", [sender.layer valueForKey:@"ExePath"]];
    NSLog(@"%@",exePath);
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getExtDocument:jobNo: exePath completion:^(NSData *PDFData, NSError *error) {
        if(!error)
        {
            NSString *dataType = [self mimeTypeForData:PDFData];//[[NSString alloc] initWithData:PDFData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",dataType);
            NSString* pdfData = [[NSString alloc] initWithData:PDFData encoding:NSUTF8StringEncoding];

            if([pdfData isEqualToString:@"Could not find the external document on the system"]) {
                //Error warning insert here
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->webViewExt = [[UIWebView alloc] initWithFrame:CGRectMake(5, 80, self->overlay.frame.size.width-10, self->overlay.frame.size.height-100)];
                    
                    [self->webViewExt loadData:PDFData MIMEType:dataType textEncodingName:@"utf-8" baseURL:nil];
                    
                    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(self->webViewExt.frame.size.width-30, 12, 18, 18)];
                    [exitBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
                    [exitBtn addTarget:self action:@selector(closeExtPDF) forControlEvents:UIControlEventTouchDown];
                    [self->webViewExt addSubview:exitBtn];
                    
                    [self->Hud removeFromSuperview];
                    [self->overlay addSubview:self->webViewExt];
                });
            }
        }
    }];
    
    //[self loadPDF:URL];
}

/*
 -(void) tapWorkInstructions {
 NSString *jobNo = [NSString stringWithFormat:@"%@", selectedData[@"JobNo"]];
 NSString *URL = [NSString stringWithFormat:@"http://mail.imprint-mis.co.uk:9092/API_deploy/api/Internal/Job/GetPDF?jobNo=%@", jobNo];
 [self loadPDF:URL];
 }
 
-(void) loadPDF:(NSString*)URL {
    NSLog(@"View Doc");
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 80, overlay.frame.size.width-10, overlay.frame.size.height-100)];
    
    NSString *ImprintID = @"WBun2S88Pb2edjd1jpBUosKL5+sAb+5D4tx5ua2rdcU=";
    NSString *ImprintSecret = @"/6r292chpZ2UAMKmbs7CWaGLMGZ8ke3Wa6QmGfwj4BA=";
    
    NSURL *targetURL = [NSURL URLWithString:URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:targetURL];
    [request addValue:ImprintID forHTTPHeaderField:@"ImprintID"];
    [request addValue:ImprintSecret forHTTPHeaderField:@"ImprintSecret"];
    [webView loadRequest:request];
    
    [overlay addSubview:webView];
    
    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(webView.frame.size.width-30, 12, 18, 18)];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(closePDF) forControlEvents:UIControlEventTouchDown];
    [webView addSubview:exitBtn];
}

-(void) loadExtPDF:(NSData*)URL {
    webViewExt = [[UIWebView alloc] initWithFrame:CGRectMake(5, 80, overlay.frame.size.width-10, overlay.frame.size.height-100)];
    [webViewExt loadData:URL MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    
    [overlay addSubview:webViewExt];
    
    UIButton *exitBtn = [[UIButton alloc] initWithFrame:CGRectMake(webViewExt.frame.size.width-30, 12, 18, 18)];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(closeExtPDF) forControlEvents:UIControlEventTouchDown];
    [webViewExt addSubview:exitBtn];
}
 */

-(void) closePDF {
    [webView removeFromSuperview];
}

-(void) closeExtPDF {
    [webViewExt removeFromSuperview];
}

-(void)showLoading
{
    Hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Hud.mode = MBProgressHUDModeCustomView;
    Hud.labelText = NSLocalizedString(@"Loading", nil);
    //Start the animation
    [activityImageView startAnimating];
    
    
    //Add your custom activity indicator to your current view
    [self.view addSubview:activityImageView];
    Hud.customView = activityImageView;
}

-(void)popViewControllerWithAnimation{
    [self stopUpdateTimer];
    //    NSLog(@"Back");
    //
    //    [Hud removeFromSuperview];
    //
    //    SWRevealViewController *homeControl = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Home"];
    //
    //    [self.navigationController popViewControllerAnimated:homeControl];
    //have to re-load every page because of the oritation
    [self showLoading];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FactoryView"];
    [self.navigationController pushViewController:vc animated:NO];
    [Hud removeFromSuperview];
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
