//
//  WIPCustomerTotals.m
//  Imprint
//
//  Created by Geoff Baker on 12/10/2018.
//  Copyright © 2018 ICN. All rights reserved.
//

#import "WIPCustomerTotals.h"
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
#import "CorePlot-CocoaTouch.h"
#import <CorePlot/CorePlot.h>

@interface WIPCustomerTotals ()

@property(retain,nonatomic)NSMutableArray *arrayPieGraph;

@property(retain,nonatomic)CPTXYGraph *pieGraph;

@property(retain,nonatomic)CPTPieChart *piePlot;

@end

@implementation WIPCustomerTotals{
    //Decide the orientation of the device
    UIDeviceOrientation Orientation;
    
    UIView *tmpView;
    UIView *popUpView;
    UIImageView *profilePicture;
    UIImage *selectedProfileImage;
    UIScrollView *sideScroller;
    UIScrollView *pageScroller;
    NSUserDefaults *defaults;
    //    CLLocationManager *locationManager;
    int iteration;
    bool refreshView;
    bool userIsOnOverlay;
    bool libraryPicked;
    bool viewHasFinishedLoading;
    bool isFindingNearestParkOn;
    int distanceMovedScroll;
    
    UIView *CustomersChart;
    UIScrollView *CustomerChartHorizontal;
    
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
    UIScrollView *legendScroller;
    
    NSMutableArray *globalWIPCustomers;
    CGFloat pieChartOffsetIndex;
    CGFloat sliceOffset;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    userIsOnOverlay = NO;
    viewHasFinishedLoading = NO;
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




-(void)loadParseContent{
    // Create the UI Scroll View
    
    Hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Hud.mode = MBProgressHUDModeCustomView;
    Hud.labelText = @"Loading";
    
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
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"userEmail"];
    NSString *password = [defaults stringForKey:@"userPassword"];
    
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
    }
    
}


-(void)showLoginView{
    SWRevealViewController *LoginControl = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"InitialLogin"];
    
    [self.navigationController pushViewController:LoginControl animated:NO];
}

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
    } else {
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
    userLable.text = [NSString stringWithFormat:@"Welcome %@", [defaults stringForKey:@"userEmail"]];
    [userLable setFont:[UIFont boldSystemFontOfSize:16]];
    userLable.textColor = [UIColor whiteColor];
    userLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:userLable];
    
    
    
    
    UILabel *BILable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
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
    }
    BILable.text = @"CUSTOMERS WITH WIP";
    BILable.textAlignment = NSTextAlignmentCenter;
    [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22]];
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
        CustomersChart.frame = CGRectMake(0, 250, self.view.frame.size.width, 550);
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
    
    UIButton *SendReportBtn = [[UIButton alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 780, 240, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    } else {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    [SendReportBtn setBackgroundImage:[UIImage imageNamed:@"btn_sendreport"] forState:UIControlStateNormal];
    [self.view addSubview:SendReportBtn];
    
    // Create the UI Side Scroll View
    graphScroller = [[UIScrollView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 750); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    } else {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
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
    [CustomersChart addSubview:graphScroller];
    
    // Create the UI Side Scroll View
    legendScroller = [[UIScrollView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) //iPhone 4S size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 120); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 568) //iPhone 5 size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 120); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 120); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        legendScroller.frame = CGRectMake(0, 800, self.view.frame.size.width, 200); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    } else {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    }
    
    // Declare the size of the content that will be inside the scroll view
    // This will let the system know how much they can scroll inside
    legendScroller.bounces = YES;
    legendScroller.delegate = self;
    legendScroller.scrollEnabled = YES;
    legendScroller.userInteractionEnabled = YES;
    [legendScroller setShowsHorizontalScrollIndicator:NO];
    [legendScroller setShowsVerticalScrollIndicator:NO];
    //[legendScroller setBackgroundColor:[UIColor yellowColor]];
    legendScroller.contentSize = CGSizeMake(120, 300);
    [self.view addSubview:legendScroller];
    
    [self showWIPCustomerTotals:10];
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

-(void)showWIPCustomerTotals: (int) count {
    [self showLoading];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    for (UIView *subview in CustomersChart.subviews)
    {
        if(![subview isKindOfClass:[UISwitch class]] && ![subview isKindOfClass:[UIScrollView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    for (UIView *subview in graphScroller.subviews)
    {
        [subview removeFromSuperview];
    }
    
    self.arrayPieGraph = [[NSMutableArray alloc]init];
    globalWIPCustomers = [[NSMutableArray alloc] init];
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getWIPCustomerTotals:count completion:^(NSDictionary *WIPCustomerTotals, NSError *error) {
        if(!error)
        {
            int i = 0;
            for (NSDictionary *wipCustomer in WIPCustomerTotals) {
                [globalWIPCustomers addObject:wipCustomer];
                [self.arrayPieGraph addObject:wipCustomer[@"Value"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *colorBox = [[UIImageView alloc] init];
                    UILabel *legend = [[UILabel alloc] init];
                    colorBox.frame = CGRectMake(30, 10 + i*22, 30, 15);
                    legend.frame = CGRectMake(65, 10 + i*22, self.view.frame.size.width - 30, 15);
                    legend.textAlignment = NSTextAlignmentLeft;
                    [legend setFont:[UIFont systemFontOfSize:12]];
                    if(i == 0) {colorBox.backgroundColor = [UIColor colorWithRed:0.40 green:0.72 blue:0.86 alpha:1.0];}
                    if(i == 1) {colorBox.backgroundColor = [UIColor colorWithRed:0.99 green:0.83 blue:0.00 alpha:1.0];}
                    if(i == 2) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.63 blue:0.20 alpha:1.0];}
                    if(i == 3) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.57 blue:0.84 alpha:1.0];}
                    if(i == 4) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.63 blue:0.84 alpha:1.0];}
                    if(i == 5) {colorBox.backgroundColor = [UIColor colorWithRed:0.41 green:0.20 blue:0.20 alpha:1.0];}
                    if(i == 6) {colorBox.backgroundColor = [UIColor colorWithRed:0.42 green:0.30 blue:0.20 alpha:1.0];}
                    if(i == 7) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.30 blue:0.30 alpha:1.0];}
                    if(i == 8) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.31 blue:0.42 alpha:1.0];}
                    if(i == 9) {colorBox.backgroundColor = [UIColor colorWithRed:0.31 green:0.52 blue:0.41 alpha:1.0];}
                    /*if(i == 10) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.63 blue:0.20 alpha:1.0]}
                     if(i == 11) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.57 blue:0.84 alpha:1.0]; legend.text = @"Estimated Material Cost";}
                     if(i == 12) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.63 blue:0.84 alpha:1.0]; legend.text = @"Estimated Material Handling Cost";}
                     if(i == 13) {colorBox.backgroundColor = [UIColor colorWithRed:0.41 green:0.20 blue:0.20 alpha:1.0]; legend.text = @"Estimated Misc Material Cost";}
                     if(i == 14) {colorBox.backgroundColor = [UIColor colorWithRed:0.42 green:0.30 blue:0.20 alpha:1.0]; legend.text = @"Estimated Misc Material Handling Cost";}
                     if(i == 15) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.30 blue:0.30 alpha:1.0]; legend.text = @"Estimated Outwork Cost";}
                     if(i == 16) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.31 blue:0.42 alpha:1.0]; legend.text = @"Estimated Outwork Handling Cost";}
                     if(i == 17) {colorBox.backgroundColor = [UIColor colorWithRed:0.31 green:0.52 blue:0.41 alpha:1.0]; legend.text = @"Estimated Delivery Cost";}*/
                    NSString *formattedValue = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"Value"] doubleValue]]];
                    legend.text = [NSString stringWithFormat:@"%@: £%@", wipCustomer[@"CustomerName"], formattedValue];
                    [legendScroller addSubview:colorBox];
                    [legendScroller addSubview:legend];
                });
                i++;
            }
            //////////// PIE CHART ///////////////
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //self.arrayPieGraph = [[NSMutableArray alloc]initWithObjects:@"0.2",@"0.3",@"0.1",@"0.2",@"0.2",nil];
                self.pieGraph = [[CPTXYGraph alloc]initWithFrame:self.view.bounds];
                //Set the canvas theme
                CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
                [self.pieGraph applyTheme:theme];
                //The canvas and the distance around
                self.pieGraph.paddingBottom =0;
                self.pieGraph.paddingLeft =0;
                self.pieGraph.paddingRight =0;
                self.pieGraph.paddingTop =0;
                //The coordinate axis of the canvas is set to null
                self.pieGraph.axisSet =nil;
                self.pieGraph.plotAreaFrame.borderLineStyle = nil;
                self.pieGraph.plotAreaFrame.masksToBorder = NO;
                
                //Create a drawing board
                CPTGraphHostingView *hostView;
                if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                {
                    hostView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
                }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                {
                    hostView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 550)];
                }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                {
                    hostView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
                } else {
                    hostView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 350)];
                }
                hostView.backgroundColor = [UIColor whiteColor];
                //Set the drawing canvas
                hostView.hostedGraph =self.pieGraph;
                //Set the canvas Title Style
                /*CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
                 whiteText.color = [CPTColor blackColor];
                 whiteText.fontSize =18;
                 whiteText.fontName =@"Helvetica-Bold";
                 self.pieGraph.titleTextStyle = whiteText;
                 /self.pieGraph.title =@"The pie chart";*/
                
                
                //Create a pie chart object
                
                self.piePlot = [[CPTPieChart alloc]initWithFrame:self.view.bounds];
                [CPTAnimation animate:self.piePlot
                             property:@"endAngle"
                                 from:-M_PI/2
                                   to:M_PI/2
                             duration:1];
                //Set the data source
                self.piePlot.dataSource =self;    //Set the pie chart radius
                
                if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                {
                    self.piePlot.pieRadius =150.0;
                }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                {
                    self.piePlot.pieRadius =250.0;
                }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                {
                    self.piePlot.pieRadius =150.0;
                } else {
                    self.piePlot.pieRadius =150.0;
                }
                
                
                //Set the pie chart representation
                self.piePlot.identifier =@"pie chart";
                //The pie chart began drawing location
                self.piePlot.startAngle =M_PI/2;
                //self.piePlot.endAngle =M_PI/2;
                //The pie chart drawing direction (clockwise or anticlockwise)
                self.piePlot.sliceDirection = CPTPieDirectionClockwise;
                //Center of gravity pie
                self.piePlot.centerAnchor =CGPointMake(0.5,0.51);
                //The pie chart line style
                self.piePlot.borderLineStyle = nil;
                //Set the proxy
                self.piePlot.delegate =self;
                //The pie chart to the canvas
                [self.pieGraph addPlot:self.piePlot];
                //The palette to view
                
                /*
                 //Create a legend
                 CPTLegend *theLegeng = [CPTLegend legendWithGraph:self.pieGraph];
                 theLegeng.numberOfColumns =1;
                 theLegeng.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
                 theLegeng.borderLineStyle = [CPTLineStyle lineStyle];
                 theLegeng.cornerRadius =5.0;
                 theLegeng.delegate =self;
                 self.pieGraph.legend = theLegeng;
                 self.pieGraph.legendAnchor = CPTRectAnchorRight;
                 self.pieGraph.legendDisplacement =CGPointMake(-10,100);
                 */
                [graphScroller addSubview:hostView];
            });
            //////////////////////////////////////////////////
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [Hud removeFromSuperview];
        });
    }];
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.arrayPieGraph.count;
}

//The proportion of each sector returns

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    return [self.arrayPieGraph objectAtIndex:idx];
}

//Where the return of each sector of the title

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    /*CPTTextLayer *label = [[CPTTextLayer alloc]initWithText:[NSString stringWithFormat:@"hello,%@",[self.arrayPieGraph objectAtIndex:idx]]];
     CPTMutableTextStyle *text = [ label.textStyle mutableCopy];
     text.color = [CPTColor whiteColor];
     return label;*/
    return nil;
}

//Select a sector of operation

- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    for (UIView *subview in graphScroller.subviews)
    {
        if([subview isKindOfClass:[UITextView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
    /*self.pieGraph.title = [NSString stringWithFormat:@"Proportion:%@",[self.arrayPieGraph objectAtIndex:idx]];*/
    
    NSDictionary *wipCustomer = [globalWIPCustomers objectAtIndex:idx];
    UITextView* txt = [[UITextView alloc] init];
    [UIView animateWithDuration:0.2f animations:^{
        txt.frame = CGRectMake(self.view.frame.size.width/2-100, 175, 200, 125);
    }];
    [txt setBackgroundColor: [[UIColor whiteColor] colorWithAlphaComponent:0.90f]];
    txt.layer.borderColor = [UIColor blackColor].CGColor;
    txt.layer.borderWidth = 0.5;
    txt.layer.cornerRadius = 5;
    txt.editable = NO;
    NSString *formattedValue1 = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"Value"] doubleValue]]];
    NSString *formattedValue2 = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"NumberofJobs"] doubleValue]]];
    NSString *formattedValue3 = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"AverageValue"] doubleValue]]];
    NSString *formattedValue4 = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"HighestValue"] doubleValue]]];
    NSString *formattedValue5 = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"LowestValue"] doubleValue]]];
    txt.text = [NSString stringWithFormat:@"%@\n\nTotal: £%@\nAverage: £%@\nNumber of jobs: £%@\nHighest Value: £%@\nLowest Value: £%@",wipCustomer[@"CustomerName"],formattedValue1,formattedValue2,formattedValue3,formattedValue4,formattedValue5];
    txt.font = [UIFont fontWithName:@"Open Sans" size:11];
    txt.textColor = [UIColor blackColor];
    txt.textAlignment = NSTextAlignmentCenter;
    [graphScroller addSubview:txt];
    
    
    
    pieChartOffsetIndex = idx;
    
    [CPTAnimation animate:self
                 property:@"sliceOffset"
                     from:0.0
                       to:35.0
                 duration:0.5
           animationCurve:CPTAnimationCurveCubicOut
                 delegate:nil];
    

}



-(void)loadUserHorizontal{
    //Profile Group View
    UIView *header = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 70);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 70);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 60);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        header.frame = CGRectMake(0, 60, self.view.frame.size.width, 70);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        header.frame = CGRectMake(0, 80, self.view.frame.size.width, 80);
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
        header.frame = CGRectMake(0, 30, self.view.frame.size.width, 80);
    }
    [header setBackgroundColor:[UIColor colorWithRed:192/255.0f
                                               green:29/255.0f
                                                blue:74/255.0f
                                               alpha:1.0f]];
    [self.view addSubview:header];
    
    UIImageView *headImg = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        headImg.frame = CGRectMake(70, 20, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        headImg.frame = CGRectMake(220, 5, 70, 70);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        headImg.frame = CGRectMake(120, 5, 50, 50);
    } else {
        headImg.frame = CGRectMake(100, 20, 50, 50);
    }
    headImg.image = [UIImage imageNamed:@"brand-logo"];
    [header addSubview:headImg];
    
    
    UILabel *LtdLable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        LtdLable.frame = CGRectMake(140, 20, 200, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        LtdLable.frame = CGRectMake(140, 20, 200, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        LtdLable.frame = CGRectMake(200, 5, self.view.frame.size.width, 50);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        LtdLable.frame = CGRectMake(170, 20, 200, 50);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        LtdLable.frame = CGRectMake(170, 20, 200, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        LtdLable.frame = CGRectMake(200, 5, 300, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        LtdLable.frame = CGRectMake(350, 20, self.view.frame.size.width-350, 50);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        LtdLable.frame = CGRectMake(200, 5, 300, 50);
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
    userLable.text = [NSString stringWithFormat:@"Welcome %@", [defaults stringForKey:@"userEmail"]];
    [userLable setFont:[UIFont boldSystemFontOfSize:16]];
    userLable.textColor = [UIColor whiteColor];
    userLable.textAlignment = NSTextAlignmentLeft;
    [header addSubview:userLable];
    
    
    
    
    CustomerChartHorizontal = [[UIScrollView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height-150);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    } else {
        CustomerChartHorizontal.frame = CGRectMake(0, 140, self.view.frame.size.width, 350);
    }
    CustomerChartHorizontal.layer.shadowColor = [UIColor blackColor].CGColor;
    CustomerChartHorizontal.layer.shadowRadius = 5.0;
    CustomerChartHorizontal.layer.shadowOpacity = 0.5;
    [CustomerChartHorizontal setBackgroundColor:[UIColor whiteColor]];
    CustomerChartHorizontal.contentSize = CGSizeMake(self.view.frame.size.width, 550);
    [self.view addSubview:CustomerChartHorizontal];
    
    
    UILabel *BILable = [[UILabel alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        BILable.frame = CGRectMake(350, 190, self.view.frame.size.width-700, 30);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        BILable.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    } else {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 30);
    }
    BILable.text = @"CUSTOMERS WITH WIP";
    BILable.textAlignment = NSTextAlignmentCenter;
    [BILable setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:22]];
    BILable.textColor = [UIColor colorWithRed:102/255.0f
                                        green:102/255.0f
                                         blue:102/255.0f
                                        alpha:1.0f];
    [self.view addSubview:BILable];
    
    
    
    UIButton *SendReportBtn = [[UIButton alloc] init];
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 350, 250, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/4*3-105, 580, 250, 40);
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-125, 310, 250, 40);
    } else {
        SendReportBtn.frame = CGRectMake(self.view.frame.size.width/2-120, 530, 240, 40);
    }
    [SendReportBtn setBackgroundImage:[UIImage imageNamed:@"btn_sendreport"] forState:UIControlStateNormal];
    [CustomerChartHorizontal addSubview:SendReportBtn];
    
    
    
    
    // Create the UI Side Scroll View
    graphScroller = [[UIScrollView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        graphScroller.frame = CGRectMake(0, 100, self.view.frame.size.width*2, 550); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
    } else {
        graphScroller.frame = CGRectMake(0, 0, self.view.frame.size.width*2, 350); //Position of the scroller
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
    [CustomerChartHorizontal addSubview:graphScroller];
    
    // Create the UI Side Scroll View
    legendScroller = [[UIScrollView alloc] init];
    
    if ([[UIScreen mainScreen] bounds].size.width == 480) //iPhone 4S size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 120); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 568) //iPhone 5 size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 120); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 667) //iPhone 6 size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 120); //Position of the scroller
    }
    else if ([[UIScreen mainScreen] bounds].size.width == 736) //iPhone 6+ size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    } else if ([[UIScreen mainScreen] bounds].size.width == 812) //iPhone X size
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
    {
        legendScroller.frame = CGRectMake(0, 670, self.view.frame.size.width, 150); //Position of the scroller
    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
    {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    } else {
        legendScroller.frame = CGRectMake(0, 570, self.view.frame.size.width, 200); //Position of the scroller
    }
    
    // Declare the size of the content that will be inside the scroll view
    // This will let the system know how much they can scroll inside
    legendScroller.bounces = YES;
    legendScroller.delegate = self;
    legendScroller.scrollEnabled = YES;
    legendScroller.userInteractionEnabled = YES;
    [legendScroller setShowsHorizontalScrollIndicator:NO];
    [legendScroller setShowsVerticalScrollIndicator:NO];
    //[legendScroller setBackgroundColor:[UIColor yellowColor]];
    legendScroller.contentSize = CGSizeMake(120, 300);
    [self.view addSubview:legendScroller];
    
    [self showWIPCustomerTotalsHorizontal:10];
}



-(void)showWIPCustomerTotalsHorizontal: (int) count{
//    [self showLoading];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    for (UIView *subview in CustomerChartHorizontal.subviews)
    {
        if(![subview isKindOfClass:[UISwitch class]] && ![subview isKindOfClass:[UIScrollView class]] && ![subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
    
    for (UIView *subview in graphScroller.subviews)
    {
        [subview removeFromSuperview];
    }
    
    self.arrayPieGraph = [[NSMutableArray alloc]init];
    globalWIPCustomers = [[NSMutableArray alloc] init];
    ImprintDatabase *data = [[ImprintDatabase alloc]init];
    [data getWIPCustomerTotals:count completion:^(NSDictionary *WIPCustomerTotals, NSError *error) {
        if(!error)
        {
            int i = 0;
            for (NSDictionary *wipCustomer in WIPCustomerTotals) {
                [globalWIPCustomers addObject:wipCustomer];
                [self.arrayPieGraph addObject:wipCustomer[@"Value"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *colorBox = [[UIImageView alloc] init];
                    UILabel *legend = [[UILabel alloc] init];
                    
                    if([[UIScreen mainScreen] bounds].size.width == 1024)  //ipad Air/Mini
                    {
                        colorBox.frame = CGRectMake(30, 10 + i*22, 30, 15);
                        legend.frame = CGRectMake(65, 10 + i*22, self.view.frame.size.width - 30, 15);
                        [legend setFont:[UIFont systemFontOfSize:12]];
                    }else if([[UIScreen mainScreen] bounds].size.width == 1112)  //ipad pro 10.5
                    {
                        colorBox.frame = CGRectMake(30, 10 + i*37, 60, 30);
                        legend.frame = CGRectMake(95, 10 + i*37, self.view.frame.size.width - 30, 30);
                        [legend setFont:[UIFont systemFontOfSize:23]];
                    }else if([[UIScreen mainScreen] bounds].size.width == 1366)  //ipad pro 12.9
                    {
                        colorBox.frame = CGRectMake(30, 10 + i*22, 30, 15);
                        legend.frame = CGRectMake(65, 10 + i*22, self.view.frame.size.width - 30, 15);
                        [legend setFont:[UIFont systemFontOfSize:12]];
                    }else{
                        colorBox.frame = CGRectMake(30, 10 + i*22, 30, 15);
                        legend.frame = CGRectMake(65, 10 + i*22, self.view.frame.size.width - 30, 15);
                        [legend setFont:[UIFont systemFontOfSize:12]];
                    }
                    
                    
                    legend.textAlignment = NSTextAlignmentLeft;
                    if(i == 0) {colorBox.backgroundColor = [UIColor colorWithRed:0.40 green:0.72 blue:0.86 alpha:1.0];}
                    if(i == 1) {colorBox.backgroundColor = [UIColor colorWithRed:0.99 green:0.83 blue:0.00 alpha:1.0];}
                    if(i == 2) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.63 blue:0.20 alpha:1.0];}
                    if(i == 3) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.57 blue:0.84 alpha:1.0];}
                    if(i == 4) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.63 blue:0.84 alpha:1.0];}
                    if(i == 5) {colorBox.backgroundColor = [UIColor colorWithRed:0.41 green:0.20 blue:0.20 alpha:1.0];}
                    if(i == 6) {colorBox.backgroundColor = [UIColor colorWithRed:0.42 green:0.30 blue:0.20 alpha:1.0];}
                    if(i == 7) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.30 blue:0.30 alpha:1.0];}
                    if(i == 8) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.31 blue:0.42 alpha:1.0];}
                    if(i == 9) {colorBox.backgroundColor = [UIColor colorWithRed:0.31 green:0.52 blue:0.41 alpha:1.0];}
                    /*if(i == 10) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.63 blue:0.20 alpha:1.0]}
                     if(i == 11) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.57 blue:0.84 alpha:1.0]; legend.text = @"Estimated Material Cost";}
                     if(i == 12) {colorBox.backgroundColor = [UIColor colorWithRed:0.77 green:0.63 blue:0.84 alpha:1.0]; legend.text = @"Estimated Material Handling Cost";}
                     if(i == 13) {colorBox.backgroundColor = [UIColor colorWithRed:0.41 green:0.20 blue:0.20 alpha:1.0]; legend.text = @"Estimated Misc Material Cost";}
                     if(i == 14) {colorBox.backgroundColor = [UIColor colorWithRed:0.42 green:0.30 blue:0.20 alpha:1.0]; legend.text = @"Estimated Misc Material Handling Cost";}
                     if(i == 15) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.30 blue:0.30 alpha:1.0]; legend.text = @"Estimated Outwork Cost";}
                     if(i == 16) {colorBox.backgroundColor = [UIColor colorWithRed:0.20 green:0.31 blue:0.42 alpha:1.0]; legend.text = @"Estimated Outwork Handling Cost";}
                     if(i == 17) {colorBox.backgroundColor = [UIColor colorWithRed:0.31 green:0.52 blue:0.41 alpha:1.0]; legend.text = @"Estimated Delivery Cost";}*/
                    NSString *formattedValue = [formatter stringFromNumber:[NSNumber numberWithDouble:[wipCustomer[@"Value"] doubleValue]]];
                    legend.text = [NSString stringWithFormat:@"%@: £%@", wipCustomer[@"CustomerName"], formattedValue];
                    [legendScroller addSubview:colorBox];
                    [legendScroller addSubview:legend];
                });
                i++;
            }
            //////////// PIE CHART ///////////////
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //self.arrayPieGraph = [[NSMutableArray alloc]initWithObjects:@"0.2",@"0.3",@"0.1",@"0.2",@"0.2",nil];
                self.pieGraph = [[CPTXYGraph alloc]initWithFrame:self.view.bounds];
                //Set the canvas theme
                CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
                [self.pieGraph applyTheme:theme];
                //The canvas and the distance around
                self.pieGraph.paddingBottom =0;
                self.pieGraph.paddingLeft =0;
                self.pieGraph.paddingRight =0;
                self.pieGraph.paddingTop =0;
                //The coordinate axis of the canvas is set to null
                self.pieGraph.axisSet =nil;
                self.pieGraph.plotAreaFrame.borderLineStyle = nil;
                self.pieGraph.plotAreaFrame.masksToBorder = NO;
                
                //Create a drawing board
                CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc]initWithFrame:CGRectMake(0, -70, self.view.frame.size.width, 550)];
                hostView.backgroundColor = [UIColor whiteColor];
                //Set the drawing canvas
                hostView.hostedGraph =self.pieGraph;
                //Set the canvas Title Style
                /*CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
                 whiteText.color = [CPTColor blackColor];
                 whiteText.fontSize =18;
                 whiteText.fontName =@"Helvetica-Bold";
                 self.pieGraph.titleTextStyle = whiteText;
                 /self.pieGraph.title =@"The pie chart";*/
                
                
                //Create a pie chart object
                
                self.piePlot = [[CPTPieChart alloc]initWithFrame:self.view.bounds];
                [CPTAnimation animate:self.piePlot
                             property:@"endAngle"
                                 from:-M_PI/2
                                   to:M_PI/2
                             duration:1];
                //Set the data source
                self.piePlot.dataSource =self;    //Set the pie chart radius
                self.piePlot.pieRadius =200.0;
                //Set the pie chart representation
                self.piePlot.identifier =@"pie chart";
                //The pie chart began drawing location
                self.piePlot.startAngle =M_PI/2;
                //self.piePlot.endAngle =M_PI/2;
                //The pie chart drawing direction (clockwise or anticlockwise)
                self.piePlot.sliceDirection = CPTPieDirectionClockwise;
                //Center of gravity pie
                self.piePlot.centerAnchor =CGPointMake(0.5,0.51);
                //The pie chart line style
                self.piePlot.borderLineStyle = nil;
                //Set the proxy
                self.piePlot.delegate =self;
                //The pie chart to the canvas
                [self.pieGraph addPlot:self.piePlot];
                //The palette to view
                
                /*
                 //Create a legend
                 CPTLegend *theLegeng = [CPTLegend legendWithGraph:self.pieGraph];
                 theLegeng.numberOfColumns =1;
                 theLegeng.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
                 theLegeng.borderLineStyle = [CPTLineStyle lineStyle];
                 theLegeng.cornerRadius =5.0;
                 theLegeng.delegate =self;
                 self.pieGraph.legend = theLegeng;
                 self.pieGraph.legendAnchor = CPTRectAnchorRight;
                 self.pieGraph.legendDisplacement =CGPointMake(-10,100);
                 */
                [graphScroller addSubview:hostView];
            });
            //////////////////////////////////////////////////
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [Hud removeFromSuperview];
        });
    }];
}




//Returns the legend

- (NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    /*NSAttributedString *title = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"hi:%i",idx]];
     return title;*/
    return nil;
}
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)i {
    
    CPTFill *sliceFill ;
    
    if(i == 0) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.40 green:0.72 blue:0.86 alpha:1.0]];}
    if(i == 1) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.99 green:0.83 blue:0.00 alpha:1.0]];}
    if(i == 2) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.20 green:0.63 blue:0.20 alpha:1.0]];}
    if(i == 3) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.77 green:0.57 blue:0.84 alpha:1.0]];}
    if(i == 4) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.77 green:0.63 blue:0.84 alpha:1.0]];}
    if(i == 5) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.41 green:0.20 blue:0.20 alpha:1.0]];}
    if(i == 6) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.42 green:0.30 blue:0.20 alpha:1.0]];}
    if(i == 7) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.20 green:0.30 blue:0.30 alpha:1.0]];}
    if(i == 8) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.20 green:0.31 blue:0.42 alpha:1.0]];}
    if(i == 9) {sliceFill = [CPTFill fillWithColor:[UIColor colorWithRed:0.31 green:0.52 blue:0.41 alpha:1.0]];}
    
    return sliceFill;
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return index == pieChartOffsetIndex ? sliceOffset:0.0;
}

-(void)setSliceOffset:(CGFloat)newOffset
{
    if ( newOffset != sliceOffset ) {
        sliceOffset = newOffset;
        
        [self.arrayPieGraph[0] reloadData];
    }
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


@end
