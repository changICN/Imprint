//
//  Top10Customers.m
//  Imprint
//
//  Created by Geoff Baker on 12/10/2018.
//  Copyright © 2018 ICN. All rights reserved.
//

#import "Top10Customers.h"
#import "BusinessIntelligenceViewController.h"
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

@interface Top10Customers ()

@end

@implementation Top10Customers{
    //Deside the orientation of the device
    UIDeviceOrientation Orientation;
    
    UIView *tmpView;
    UIView *popUpView;
    UIImageView *profilePicture;
    UIImage *selectedProfileImage;
    UIScrollView *sideScroller;
    UIScrollView *pageScroller;
    NSUserDefaults *user;
    //    CLLocationManager *locationManager;
    int iteration;
    bool refreshView;
    bool userIsOnOverlay;
    bool libraryPicked;
    bool viewHasFinishedLoading;
    bool isFindingNearestParkOn;
    int distanceMovedScroll;
    
    UIView *CustomersChart;
    UIScrollView *CustomersChartHorizontal;
    
    //Loading Animation
    MBProgressHUD *Hud;
    UIImageView *activityImageView;
    UIActivityIndicatorView *activityView;
    
    UIImageView *activePageView;
    
    //PFObjects
    //    PFObject *selectedMatchObject;
    //    PFObject *selectedOpponent;
    //    PFObject *achievementsObject;
    //    NSMutableArray *locationsObj;
    
    //AnimationImage
    UIImageView *glowImageView;
    
    //NEW
    NSString *URLString;
    
    int videoCount;
    
    //Graph
    
    int x;
    
    UIScrollView *graphScroller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userIsOnOverlay = NO;
    viewHasFinishedLoading = NO;
    // Do any additional setup after loading the view.
    
    user = [NSUserDefaults standardUserDefaults];
    
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
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
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
    //
    
    
    [self loadParseContent];
    
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


-(void)loadParseContent{
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
    
    
    //Add your custom activity indicator to your current view
    [self.view addSubview:activityImageView];
    
    // Add stuff to view here
    Hud.customView = activityImageView;
    
    
    user = [NSUserDefaults standardUserDefaults];
    NSString *username = [user stringForKey:@"userEmail"];
    NSString *password = [user stringForKey:@"userPassword"];
    // Create the UI Scroll View
//    [self showLoading];
    
    if(username == nil){
        [self showLoginView];
    }else{
        if(Orientation == UIDeviceOrientationPortrait){
            [self loadUser];
        }else if(Orientation == UIDeviceOrientationLandscapeLeft || Orientation ==  UIDeviceOrientationLandscapeRight){
            [self loadUserHorizontal];
            
        }
        else {
            [self loadUser];
        }
//        [Hud removeFromSuperview];
    }
    
}


-(void)showLoginView{
    SWRevealViewController *LoginControl = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"InitialLogin"];
    
    [self.navigationController pushViewController:LoginControl animated:NO];
}

//-(void)checkForLoginDate{
//    if(Orientation == UIDeviceOrientationPortrait){
//        [self loadUser];
//    }else if(Orientation == UIDeviceOrientationLandscapeLeft || Orientation ==  UIDeviceOrientationLandscapeRight){
//        [self loadUserHorizontal];
//
//    }
//}


-(void)loadUser{
    //Profile Group View
    UIView *header = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 80);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
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
        header.frame = CGRectMake(0, 70, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        header.frame = CGRectMake(0, 70, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        header.frame = CGRectMake(0, 70, self.view.frame.size.width, 80);
    }else {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
    }
    [header setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                               green:29/255.0f
                                                blue:74/255.0f
                                               alpha:1.0f]];
    [self.view addSubview:header];
    
    UIImageView *headImg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        headImg.frame = CGRectMake(100, 20, 50, 50);
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
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        LtdLable.frame = CGRectMake(140, 20, 200, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        LtdLable.frame = CGRectMake(140, 20, 200, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        LtdLable.frame = CGRectMake(140, 20, 200, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        LtdLable.frame = CGRectMake(170, 20, 200, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        LtdLable.frame = CGRectMake(170, 20, 200, 50);
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
        LtdLable.frame = CGRectMake(170, 20, 200, 50);
    }
    //LtdLable.text = @"Pretend Printers Ltd";
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    LtdLable.textAlignment = NSTextAlignmentLeft;
    [LtdLable setFont:[UIFont boldSystemFontOfSize:16]];
    LtdLable.lineBreakMode = NSLineBreakByWordWrapping;
    LtdLable.numberOfLines = 2;
    [data getCompanyDetails:nil completion:^(NSMutableArray *companyDetails, NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                LtdLable.text = [companyDetails objectAtIndex:0][@"CompanyName"];
            });
        }
    }];
    LtdLable.textColor = [UIColor whiteColor];
    [header addSubview:LtdLable];
    
    
    
    UILabel *userLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        userLable.frame = CGRectMake(140, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        userLable.frame = CGRectMake(170, 30, self.view.frame.size.width, 50);
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
    userLable.text = [NSString stringWithFormat:@"Welcome %@", [user stringForKey:@"userEmail"]];
    [userLable setFont:[UIFont boldSystemFontOfSize:16]];
    userLable.textColor = [UIColor whiteColor];
    userLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:userLable];
    
    
    
    
    UILabel *BILable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        BILable.frame = CGRectMake(0, 180, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:35]];
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    } else {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
        [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    }
    BILable.text = @"TOP 10 CUSTOMERS";
    BILable.textAlignment = NSTextAlignmentCenter;
//    [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:25]];
    BILable.textColor = [UIColor colorWithRed:102/255.0f
                                        green:102/255.0f
                                         blue:102/255.0f
                                        alpha:1.0f];
    [self.view addSubview:BILable];
    
    
    
    
    CustomersChart = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        CustomersChart.frame = CGRectMake(0, 250, self.view.frame.size.width, self.view.frame.size.height-250);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    } else {
        CustomersChart.frame = CGRectMake(0, 200, self.view.frame.size.width, 350);
    }
    CustomersChart.layer.shadowColor = [UIColor blackColor].CGColor;
    CustomersChart.layer.shadowRadius = 5.0;
    CustomersChart.layer.shadowOpacity = 0.5;
    [CustomersChart setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:CustomersChart];
    
    
    
    UISwitch *switchBtn = [[UISwitch alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2-50, 25, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    } else {
        switchBtn.frame = CGRectMake(160, 25, 100, 40);
    }
    
    [switchBtn addTarget:self action:@selector(switchToggled:) forControlEvents: UIControlEventTouchUpInside];
    [CustomersChart addSubview:switchBtn];
    
    
    
    UIButton *SendReportBtn = [[UIButton alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-150, 670, 300, 50);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    } else {
        SendReportBtn.frame = CGRectMake(40, 570, 300, 50);
    }
    [SendReportBtn setBackgroundImage:[UIImage imageNamed:@"btn_sendreport"] forState:UIControlStateNormal];
    [self.view addSubview:SendReportBtn];
    
    /*// Create the UI Side Scroll View
     graphScroller = [[UIScrollView alloc] init];
     
     if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
     {
     graphScroller.frame = CGRectMake(50, 50, self.view.frame.size.width*2, 300); //Position of the scroller
     }
     else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
     {
     graphScroller.frame = CGRectMake(50, 50, self.view.frame.size.width*2, 300); //Position of the scroller
     }
     else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
     {
     graphScroller.frame = CGRectMake(50, 50, self.view.frame.size.width*2, 300); //Position of the scroller
     }
     else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
     {
     graphScroller.frame = CGRectMake(50, 50, self.view.frame.size.width*2, 300); //Position of the scroller
     } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
     {
     graphScroller.frame = CGRectMake(50, 50, self.view.frame.size.width*2, 300); //Position of the scroller
     } else {
     graphScroller.frame = CGRectMake(50, 50, self.view.frame.size.width*2, 300); //Position of the scroller
     }
     
     // Declare the size of the content that will be inside the scroll view
     // This will let the system know how much they can scroll inside
     graphScroller.bounces = YES;
     graphScroller.delegate = self;
     graphScroller.scrollEnabled = YES;
     graphScroller.userInteractionEnabled = YES;
     [graphScroller setShowsHorizontalScrollIndicator:NO];
     [graphScroller setShowsVerticalScrollIndicator:NO];
     //[graphScroller setBackgroundColor:[UIColor yellowColor]];
     [CustomersChart addSubview:graphScroller];*/
    
    [self showTop10Customers: 2018];
}


-(void)showTop10Customers: (int) year {
    [self showLoading];
    for (UIView *subview in CustomersChart.subviews)
    {
        if(![subview isKindOfClass:[UISwitch class]]) {
            [subview removeFromSuperview];
        }
    }
    //[CustomersChart.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    UILabel *thisyearLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2-130, 20, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    } else {
        thisyearLabel.frame = CGRectMake(50, 20, 100, 40);
    }
    [thisyearLabel setText:@"This Year"];
    [thisyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [thisyearLabel setTextColor:[UIColor blackColor]];
    [CustomersChart addSubview:thisyearLabel];
    
    
    
    UILabel *lastyearLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2+20, 20, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    } else {
        lastyearLabel.frame = CGRectMake(250, 20, 100, 40);
    }
    [lastyearLabel setText:@"Last Year"];
    [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [lastyearLabel setTextColor:[UIColor blackColor]];
    [CustomersChart addSubview:lastyearLabel];
    
    UIImageView *divider = [[UIImageView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    } else {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    
    divider.image = [UIImage imageNamed:@"divider"];
    [CustomersChart addSubview:divider];
    
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getTopCustomerInvoices:10 :year completion:^(NSDictionary *topCustomerInvoices, NSError *error) {
        if(!error)
        {
            double upperbound = 0;
            for (NSDictionary *customerInvoice in topCustomerInvoices) {
                if([customerInvoice[@"InvoiceTotal"] doubleValue] > upperbound) {
                    upperbound = [customerInvoice[@"InvoiceTotal"] doubleValue];
                }
            }
            upperbound = (ceil(upperbound/10)) * 10;
            int gap = upperbound/5;
            
            
            
            UILabel *ten = [[UILabel alloc] init];
            UILabel *twenty = [[UILabel alloc] init];
            UILabel *thirty = [[UILabel alloc] init];
            UILabel *forty = [[UILabel alloc] init];
            UILabel *fiddy = [[UILabel alloc] init];
            ten.font = [UIFont fontWithName:@"Bebas Neue" size:14];
            ten.textAlignment = NSTextAlignmentRight;
            ten.textColor = [UIColor blackColor];
            
            twenty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
            twenty.textAlignment = NSTextAlignmentRight;
            twenty.textColor = [UIColor blackColor];
            
            thirty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
            thirty.textAlignment = NSTextAlignmentRight;
            thirty.textColor = [UIColor blackColor];
            
            forty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
            forty.textAlignment = NSTextAlignmentRight;
            forty.textColor = [UIColor blackColor];
            
            fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:14];
            fiddy.textAlignment = NSTextAlignmentRight;
            fiddy.textColor = [UIColor blackColor];
            
            if(gap >= 1000000.0) {
                gap = ceil(gap/1000000.0);
                upperbound = gap*1000000*5;
                ten.text = [NSString stringWithFormat:@"£%dm", gap];
                twenty.text = [NSString stringWithFormat:@"£%dm", gap * 2];
                thirty.text = [NSString stringWithFormat:@"£%dm", gap * 3];
                forty.text = [NSString stringWithFormat:@"£%dm", gap * 4];
                fiddy.text = [NSString stringWithFormat:@"£%dm", gap * 5];
            } else if (gap >= 1000.0) {
                gap = ceil(gap/1000.0);
                upperbound = gap*1000*5;
                ten.text = [NSString stringWithFormat:@"£%dk", gap];
                twenty.text = [NSString stringWithFormat:@"£%dk", gap * 2];
                thirty.text = [NSString stringWithFormat:@"£%dk", gap * 3];
                forty.text = [NSString stringWithFormat:@"£%dk", gap * 4];
                fiddy.text = [NSString stringWithFormat:@"£%dk", gap * 5];
            } else {
                ten.text = [NSString stringWithFormat:@"£%d", gap];
                twenty.text = [NSString stringWithFormat:@"£%d", gap * 2];
                thirty.text = [NSString stringWithFormat:@"£%d", gap * 3];
                forty.text = [NSString stringWithFormat:@"£%d", gap * 4];
                fiddy.text = [NSString stringWithFormat:@"£%d", gap * 5];
            }
            
            
            int count = 0;
            int totalTopCustomers = [topCustomerInvoices count];
            for (NSDictionary *customerInvoice in topCustomerInvoices) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", customerInvoice);
                    UILabel *label = [[UILabel alloc] init];
                    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
                    [UIView animateWithDuration:2.0f animations:^{
                        [progressView setProgress:[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound animated:YES];
                    }];
                    UIButton *clickableProgressBar = [[UIButton alloc] init];
                    clickableProgressBar.backgroundColor = [UIColor clearColor];
                    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        //label.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, (self.view.frame.size.width - 70)/totalTopCustomers, 20);
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        //label.backgroundColor = [UIColor yellowColor];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    } else {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    label.text = [NSString stringWithFormat:@"%@", customerInvoice[@"CustomerCode"]];
                    label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = [UIColor blackColor];
                    progressView.progressTintColor = [UIColor colorWithRed:0.83 green:0.87 blue:0.24 alpha:1.0];
                    progressView.backgroundColor = [UIColor colorWithRed:0.89 green:0.91 blue:0.42 alpha:0.0];
                    progressView.layer.masksToBounds = TRUE;
                    progressView.clipsToBounds = TRUE;
                    progressView.transform = CGAffineTransformMakeScale(9.0f*totalTopCustomers/totalTopCustomers,1.0f);
                    progressView.transform = CGAffineTransformRotate(progressView.transform,270.0/180*M_PI);
                    progressView.tag = 100000 + count;
                    [clickableProgressBar addTarget:self action:@selector(tapProgressBar:) forControlEvents:UIControlEventTouchUpInside];
                    //[clickableProgressBar setTitle:[NSString stringWithFormat:@"%f",[customerInvoice[@"InvoiceTotal"] doubleValue]] forState:UIControlStateNormal];
                    //clickableProgressBar.titleLabel.layer.opacity = 0.0f;
                    clickableProgressBar.tag = [customerInvoice[@"InvoiceTotal"] doubleValue];
                    [CustomersChart addSubview:ten];
                    [CustomersChart addSubview:twenty];
                    [CustomersChart addSubview:thirty];
                    [CustomersChart addSubview:forty];
                    [CustomersChart addSubview:fiddy];
                    [CustomersChart addSubview:label];
                    [CustomersChart addSubview: progressView];
                    [CustomersChart addSubview: clickableProgressBar];
                });
                count++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [Hud removeFromSuperview];
        });
    }];
}

- (void) switchToggled:(id)sender {
    UISwitch *mSwitch = (UISwitch *)sender;
    if ([mSwitch isOn]) {
        [self showTop10Customers:2017];
    } else {
        [self showTop10Customers:2018];
    }
}

- (void) switchToggledHorizontal:(id)sender {
    UISwitch *mSwitch = (UISwitch *)sender;
    if ([mSwitch isOn]) {
        [self showTop10CustomersHorizontal:2017];
    } else {
        [self showTop10CustomersHorizontal:2018];
    }
}

-(IBAction)tapProgressBar: (UIButton*)sender {
    for (UIView *subview in CustomersChart.subviews)
    {
        if([subview isKindOfClass:[UITextView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
    double value = sender.tag;//[sender.titleLabel.text doubleValue];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    NSString *formattedValue = [formatter stringFromNumber:[NSNumber numberWithDouble:value]];
    
    //NSLog(@"--------------------- %@", formattedValue);
    
    
    UITextView* txt = [[UITextView alloc] init];
    CGPoint progressBarButtonLocation = [txt convertPoint:CustomersChart.frame.origin toView:sender];
    //NSLog(@"--------------------- %@", NSStringFromCGPoint(progressBarButtonLocation));
    [UIView animateWithDuration:0.2f animations:^{
        txt.frame = CGRectMake(progressBarButtonLocation.x * -1 - 30, (progressBarButtonLocation.y * -1) - 40, 80, 30);
    }];
    txt.layer.borderColor = [UIColor blackColor].CGColor;
    txt.layer.borderWidth = 0.5;
    txt.layer.cornerRadius = 5;
    txt.editable = NO;
    txt.backgroundColor = [UIColor clearColor];
    txt.text = [NSString stringWithFormat:@"£%@",formattedValue];
    txt.font = [UIFont fontWithName:@"Open Sans" size:12];
    txt.textColor = [UIColor blackColor];
    txt.textAlignment = NSTextAlignmentCenter;
    [CustomersChart addSubview:txt];
    
}

-(void)popViewControllerWithAnimation{
//    NSLog(@"Back");
//
//    [Hud removeFromSuperview];
//
//    SWRevealViewController *homeControl = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"BusinessIntelligence"];
//
//    [self.navigationController popViewControllerAnimated:homeControl];
    [self showLoading];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"BusinessIntelligence"];
    [self.navigationController pushViewController:vc animated:NO];
    [Hud removeFromSuperview];
}


-(void)loadUserHorizontal{
    //Profile Group View
    UIView *header = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 4S size
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 5 size
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone 6 size
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 414) //iPhone 6+ size
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    } else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone X size
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        header.frame = CGRectMake(0, 70, self.view.frame.size.width, 80);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    } else {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }
    [header setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                               green:29/255.0f
                                                blue:74/255.0f
                                               alpha:1.0f]];
    [self.view addSubview:header];
    
    UIImageView *headImg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 4S size
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 5 size
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone 6 size
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 414) //iPhone 6+ size
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone X size
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        headImg.frame = CGRectMake(220, 5, 70, 70);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }  else {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }
    headImg.image = [UIImage imageNamed:@"brand-logo"];
    [header addSubview:headImg];
    
    
    UILabel *LtdLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 4S size
    {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 5 size
    {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone 6 size
    {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 414) //iPhone 6+ size
    {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone X size
    {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        LtdLable.frame = CGRectMake(200, 5, 300, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        LtdLable.frame = CGRectMake(350, 20, self.view.frame.size.width-350, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        LtdLable.frame = CGRectMake(200, 5, 300, 50);
    }  else {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    }
    /*if([[user stringForKey:@"userEmail"] isEqualToString:@"NBourne"]){
     LtdLable.text = @"Imprint Business Systems Ltd";
     }else{
     LtdLable.text = @"Pretend Printers Ltd";
     }*/
    
    //    LtdLable.text = @"Pretend Printers Ltd";
    LtdLable.textColor = [UIColor whiteColor];
    [LtdLable setFont:[UIFont boldSystemFontOfSize:16]];
    LtdLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:LtdLable];
    
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getCompanyDetails:nil completion:^(NSMutableArray *companyDetails, NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                LtdLable.text = [companyDetails objectAtIndex:0][@"CompanyName"];
                [Hud removeFromSuperview];
            });
        }
    }];
    
    UILabel *userLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 4S size
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 320) //iPhone 5 size
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone 6 size
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 414) //iPhone 6+ size
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    } else if ([[UIScreen mainScreen] bounds].size.height == 375) //iPhone X size
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        userLable.frame = CGRectMake(700, 20, self.view.frame.size.width, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    } else {
        userLable.frame = CGRectMake(300, 30, self.view.frame.size.width, 50);
    }
    userLable.text = [NSString stringWithFormat:@"Welcome %@", [user stringForKey:@"userEmail"]];
    [userLable setFont:[UIFont boldSystemFontOfSize:16]];
    userLable.textColor = [UIColor whiteColor];
    userLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:userLable];
    
    
    
    CustomersChartHorizontal = [[UIScrollView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height-150);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    } else {
        CustomersChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    CustomersChartHorizontal.layer.shadowColor = [UIColor blackColor].CGColor;
    CustomersChartHorizontal.layer.shadowRadius = 5.0;
    CustomersChartHorizontal.layer.shadowOpacity = 0.5;
    [CustomersChartHorizontal setBackgroundColor:[UIColor whiteColor]];
    CustomersChartHorizontal.contentSize = CGSizeMake(self.view.frame.size.width, 500);
    [self.view addSubview:CustomersChartHorizontal];
    
    UIImageView *BILable = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        BILable.frame = CGRectMake(350, 190, self.view.frame.size.width-700, 30);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }  else {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }
    BILable.image = [UIImage imageNamed:@"title_top10"];
    [self.view addSubview:BILable];
    
    UISwitch *switchBtn = [[UISwitch alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 10, 550, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }  else {
        switchBtn.frame = CGRectMake(self.view.frame.size.width/2 - 20, 250, 100, 40);
    }
    
    [switchBtn addTarget:self action:@selector(switchToggledHorizontal:) forControlEvents: UIControlEventTouchUpInside];
    [CustomersChartHorizontal addSubview:switchBtn];
    
    
    
    UIButton *SendReportBtn = [[UIButton alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-105, 610, 250, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    } else {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }
    [SendReportBtn setBackgroundImage:[UIImage imageNamed:@"btn_sendreport"] forState:UIControlStateNormal];
    [CustomersChartHorizontal addSubview:SendReportBtn];
    
    [self showTop10CustomersHorizontal: 2018];
    
    
    //[Hud removeFromSuperview];
    
}
-(void)showTop10CustomersHorizontal: (int) year {
    [self showLoading];
    for (UIView *subview in CustomersChartHorizontal.subviews)
    {
        if(![subview isKindOfClass:[UISwitch class]] && ![subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
    //[CustomersChart.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    UILabel *thisyearLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 545, 100, 40);
        [thisyearLabel setFont:[UIFont boldSystemFontOfSize:23]];
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 545, 100, 40);
        [thisyearLabel setFont:[UIFont boldSystemFontOfSize:23]];
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
        [thisyearLabel setFont:[UIFont boldSystemFontOfSize:23]];
    } else {
        thisyearLabel.frame = CGRectMake(self.view.frame.size.width/2 - 110, 245, 100, 40);
        [thisyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    [thisyearLabel setText:@"This Year"];
    [thisyearLabel setTextColor:[UIColor blackColor]];
    [CustomersChartHorizontal addSubview:thisyearLabel];
    
    
    
    UILabel *lastyearLabel = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 245, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 245, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 245, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 245, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 245, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 545, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:23]];
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 545, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:23]];
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 545, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:23]];
    } else {
        lastyearLabel.frame = CGRectMake(self.view.frame.size.width/2 + 50, 245, 100, 40);
        [lastyearLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    [lastyearLabel setText:@"Last Year"];
    [lastyearLabel setTextColor:[UIColor blackColor]];
    [CustomersChartHorizontal addSubview:lastyearLabel];
    
    UIImageView *divider = [[UIImageView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        divider.frame = CGRectMake(20, 200, self.view.frame.size.width - 20, 3);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        divider.frame = CGRectMake(20, 470, self.view.frame.size.width - 20, 3);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        divider.frame = CGRectMake(20, 470, self.view.frame.size.width - 20, 3);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        divider.frame = CGRectMake(20, 470, self.view.frame.size.width - 20, 3);
    } else {
        divider.frame = CGRectMake(20, 300, self.view.frame.size.width - 20, 3);
    }
    
    divider.image = [UIImage imageNamed:@"divider"];
    [CustomersChartHorizontal addSubview:divider];
    
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getTopCustomerInvoices:10 :year completion:^(NSDictionary *topCustomerInvoices, NSError *error) {
        if(!error)
        {
            double upperbound = 0;
            for (NSDictionary *customerInvoice in topCustomerInvoices) {
                if([customerInvoice[@"InvoiceTotal"] doubleValue] > upperbound) {
                    upperbound = [customerInvoice[@"InvoiceTotal"] doubleValue];
                }
            }
            upperbound = (ceil(upperbound/10)) * 10;
            int gap = upperbound/5;
            
            
            
            UILabel *ten = [[UILabel alloc] init];
            UILabel *twenty = [[UILabel alloc] init];
            UILabel *thirty = [[UILabel alloc] init];
            UILabel *forty = [[UILabel alloc] init];
            UILabel *fiddy = [[UILabel alloc] init];
            
            if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
            {
                ten.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                ten.textAlignment = NSTextAlignmentRight;
                ten.textColor = [UIColor blackColor];
                
                twenty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                twenty.textAlignment = NSTextAlignmentRight;
                twenty.textColor = [UIColor blackColor];
                
                thirty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                thirty.textAlignment = NSTextAlignmentRight;
                thirty.textColor = [UIColor blackColor];
                
                forty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                forty.textAlignment = NSTextAlignmentRight;
                forty.textColor = [UIColor blackColor];
                
                fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                fiddy.textAlignment = NSTextAlignmentRight;
                fiddy.textColor = [UIColor blackColor];
            }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
            {
                ten.font = [UIFont fontWithName:@"Bebas Neue" size:23];
                ten.textAlignment = NSTextAlignmentRight;
                ten.textColor = [UIColor blackColor];
                
                twenty.font = [UIFont fontWithName:@"Bebas Neue" size:23];
                twenty.textAlignment = NSTextAlignmentRight;
                twenty.textColor = [UIColor blackColor];
                
                thirty.font = [UIFont fontWithName:@"Bebas Neue" size:23];
                thirty.textAlignment = NSTextAlignmentRight;
                thirty.textColor = [UIColor blackColor];
                
                forty.font = [UIFont fontWithName:@"Bebas Neue" size:23];
                forty.textAlignment = NSTextAlignmentRight;
                forty.textColor = [UIColor blackColor];
                
                fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:23];
                fiddy.textAlignment = NSTextAlignmentRight;
                fiddy.textColor = [UIColor blackColor];
            }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
            {
                ten.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                ten.textAlignment = NSTextAlignmentRight;
                ten.textColor = [UIColor blackColor];
                
                twenty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                twenty.textAlignment = NSTextAlignmentRight;
                twenty.textColor = [UIColor blackColor];
                
                thirty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                thirty.textAlignment = NSTextAlignmentRight;
                thirty.textColor = [UIColor blackColor];
                
                forty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                forty.textAlignment = NSTextAlignmentRight;
                forty.textColor = [UIColor blackColor];
                
                fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                fiddy.textAlignment = NSTextAlignmentRight;
                fiddy.textColor = [UIColor blackColor];
            } else {
                ten.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                ten.textAlignment = NSTextAlignmentRight;
                ten.textColor = [UIColor blackColor];
                
                twenty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                twenty.textAlignment = NSTextAlignmentRight;
                twenty.textColor = [UIColor blackColor];
                
                thirty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                thirty.textAlignment = NSTextAlignmentRight;
                thirty.textColor = [UIColor blackColor];
                
                forty.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                forty.textAlignment = NSTextAlignmentRight;
                forty.textColor = [UIColor blackColor];
                
                fiddy.font = [UIFont fontWithName:@"Bebas Neue" size:14];
                fiddy.textAlignment = NSTextAlignmentRight;
                fiddy.textColor = [UIColor blackColor];
            }
            
            if(gap >= 1000000.0) {
                gap = ceil(gap/1000000.0);
                upperbound = gap*1000000*5;
                ten.text = [NSString stringWithFormat:@"£%dm", gap];
                twenty.text = [NSString stringWithFormat:@"£%dm", gap * 2];
                thirty.text = [NSString stringWithFormat:@"£%dm", gap * 3];
                forty.text = [NSString stringWithFormat:@"£%dm", gap * 4];
                fiddy.text = [NSString stringWithFormat:@"£%dm", gap * 5];
            } else if (gap >= 1000.0) {
                gap = ceil(gap/1000.0);
                upperbound = gap*1000*5;
                ten.text = [NSString stringWithFormat:@"£%dk", gap];
                twenty.text = [NSString stringWithFormat:@"£%dk", gap * 2];
                thirty.text = [NSString stringWithFormat:@"£%dk", gap * 3];
                forty.text = [NSString stringWithFormat:@"£%dk", gap * 4];
                fiddy.text = [NSString stringWithFormat:@"£%dk", gap * 5];
            } else {
                ten.text = [NSString stringWithFormat:@"£%d", gap];
                twenty.text = [NSString stringWithFormat:@"£%d", gap * 2];
                thirty.text = [NSString stringWithFormat:@"£%d", gap * 3];
                forty.text = [NSString stringWithFormat:@"£%d", gap * 4];
                fiddy.text = [NSString stringWithFormat:@"£%d", gap * 5];
            }
            
            
            int count = 0;
            int totalTopCustomers = [topCustomerInvoices count];
            for (NSDictionary *customerInvoice in topCustomerInvoices) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", customerInvoice);
                    UILabel *label = [[UILabel alloc] init];
                    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
                    [UIView animateWithDuration:2.0f animations:^{
                        [progressView setProgress:[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound animated:YES];
                    }];
                    UIButton *clickableProgressBar = [[UIButton alloc] init];
                    clickableProgressBar.backgroundColor = [UIColor clearColor];
                    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(9.0f*totalTopCustomers/totalTopCustomers,1.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(9.0f*totalTopCustomers/totalTopCustomers,1.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
                    {
                        //label.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, (self.view.frame.size.width - 70)/totalTopCustomers, 20);
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 210, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        //label.backgroundColor = [UIColor yellowColor];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 200, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(9.0f*totalTopCustomers/totalTopCustomers,1.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound) - 100, 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40 - 100, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80 - 100, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120 - 100, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160 - 100, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200 - 100, 50, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(9.0f*totalTopCustomers/totalTopCustomers,1.0f);
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(9.0f*totalTopCustomers/totalTopCustomers,1.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(19.0f*totalTopCustomers/totalTopCustomers,2.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
                    {
                        label.frame = CGRectMake(55 + count*(self.view.frame.size.width - 85)/totalTopCustomers, 480, 75, 30);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:23];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 370 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(19.0f*totalTopCustomers/totalTopCustomers,2.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 470-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 470 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 470 - 130, 50, 20);
                        thirty.frame = CGRectMake(0, 470 - 220, 50, 20);
                        forty.frame = CGRectMake(0, 470 - 310, 50, 20);
                        fiddy.frame = CGRectMake(0, 470 - 400, 50, 20);
                    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
                    {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        progressView.transform = CGAffineTransformMakeScale(19.0f*totalTopCustomers/totalTopCustomers,2.0f);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    } else {
                        label.frame = CGRectMake(65 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 310, 30, 20);
                        label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                        progressView.frame = CGRectMake(50 + count*(self.view.frame.size.width - 70)/totalTopCustomers - 70, 300 - 100, 200, 0);
                        //NSLog(@"--------------- %f",300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound));
                        clickableProgressBar.frame = CGRectMake(70 + count*(self.view.frame.size.width - 70)/totalTopCustomers, 300-(200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound), 20, 200*[customerInvoice[@"InvoiceTotal"] doubleValue]/upperbound);
                        ten.frame = CGRectMake(0, 300 - 40, 50, 20);
                        twenty.frame = CGRectMake(0, 300 - 80, 50, 20);
                        thirty.frame = CGRectMake(0, 300 - 120, 50, 20);
                        forty.frame = CGRectMake(0, 300 - 160, 50, 20);
                        fiddy.frame = CGRectMake(0, 300 - 200, 50, 20);
                    }
                    label.text = [NSString stringWithFormat:@"%@", customerInvoice[@"CustomerCode"]];
//                    label.font = [UIFont fontWithName:@"Bebas Neue" size:12];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = [UIColor blackColor];
                    progressView.progressTintColor = [UIColor colorWithRed:0.83 green:0.87 blue:0.24 alpha:1.0];
                    progressView.backgroundColor = [UIColor colorWithRed:0.89 green:0.91 blue:0.42 alpha:0.0];
                    progressView.layer.masksToBounds = TRUE;
                    progressView.clipsToBounds = TRUE;
                    progressView.transform = CGAffineTransformRotate(progressView.transform,270.0/180*M_PI);
                    progressView.tag = 100000 + count;
                    [clickableProgressBar addTarget:self action:@selector(tapProgressBar:) forControlEvents:UIControlEventTouchUpInside];
                    //[clickableProgressBar setTitle:[NSString stringWithFormat:@"%f",[customerInvoice[@"InvoiceTotal"] doubleValue]] forState:UIControlStateNormal];
                    //clickableProgressBar.titleLabel.layer.opacity = 0.0f;
                    clickableProgressBar.tag = [customerInvoice[@"InvoiceTotal"] doubleValue];
                    [CustomersChartHorizontal addSubview:ten];
                    [CustomersChartHorizontal addSubview:twenty];
                    [CustomersChartHorizontal addSubview:thirty];
                    [CustomersChartHorizontal addSubview:forty];
                    [CustomersChartHorizontal addSubview:fiddy];
                    [CustomersChartHorizontal addSubview:label];
                    [CustomersChartHorizontal addSubview: progressView];
                    [CustomersChartHorizontal addSubview: clickableProgressBar];
                });
                count++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [Hud removeFromSuperview];
        });
    }];
}

-(void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            [self viewDidLoad];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [self viewDidLoad];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self viewDidLoad];
            break;
            
        default:
            break;
    };
}


@end
