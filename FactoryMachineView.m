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
    
    //Loading Animation
    MBProgressHUD *Hud;
    UIImageView *activityImageView;
    UIActivityIndicatorView *activityView;
}

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
        //[self loadUserHorizontal];
        
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
    
    [self loadMachine];
}

-(void)loadMachine {
    UIColor *midColor = [UIColor colorWithRed:172/255.0f
                            green:200/255.0f
                             blue:55/255.0f
                            alpha:1.0f];
    UIColor *lightColor = [UIColor colorWithRed:215/255.0f
                            green:237/255.0f
                             blue:123/255.0f
                            alpha:1.0f];
    UIColor *darkColor = [UIColor colorWithRed:37/255.0f
                            green:44/255.0f
                             blue:6/255.0f
                            alpha:1.0f];
    UIColor *gradientStart = [UIColor colorWithRed:194/255.0f
                            green:215/255.0f
                             blue:93/255.0f
                            alpha:1.0f];
    UIColor *gradientEnd = [UIColor colorWithRed:149/255.0f
                            green:182/255.0f
                             blue:37/255.0f
                            alpha:1.0f];
    
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
        machineTitle.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:32];
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
    machineTitle.text = [NSString stringWithFormat:@"SPEEDMASTER-4"];
    machineTitle.textColor = [UIColor colorWithRed:102/255.0f
                                             green:102/255.0f
                                              blue:102/255.0f
                                             alpha:1.0f];
    //[operatorLabel setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:machineTitle];
    
    UIView *mainPart = [[UIView alloc] initWithFrame:CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
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
        mainPart.frame = CGRectMake(10, 235, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    } else {
        mainPart.frame = CGRectMake(10, 175, self.view.frame.size.width - 20, self.view.frame.size.height - 180);
    }
    //[mainPart setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:mainPart];
    
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
      
    UIButton *viewLinkedDocsBtn = [[UIButton alloc] initWithFrame:CGRectMake(235, 0, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
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
        viewLinkedDocsBtn.frame = CGRectMake((mainPart.frame.size.width/3)*2, 0, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    } else {
        viewLinkedDocsBtn.frame = CGRectMake(235, 0, 120, 50);
    }
    [viewLinkedDocsBtn setBackgroundImage:[UIImage imageNamed:@"btn_linkeddocs"] forState:UIControlStateNormal];
    [mainPart addSubview:viewLinkedDocsBtn];
    
    UIButton *viewDocketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 47.5, 120, 50)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
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
        viewDocketBtn.frame = CGRectMake(0, 100, mainPart.frame.size.width/3, 100);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    } else {
        viewDocketBtn.frame = CGRectMake(0, 47.5, 120, 50);
    }
    [viewDocketBtn setBackgroundImage:[UIImage imageNamed:@"btn_viewdocket"] forState:UIControlStateNormal];
    [mainPart addSubview:viewDocketBtn];
    
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
    operatorCont.frame = CGRectMake(5, 5, leftColumn.frame.size.width - 10, 80);
    [operatorCont setBackgroundColor:[UIColor whiteColor]];
    operatorCont.layer.cornerRadius = 5;
    operatorCont.layer.masksToBounds = true;
    [leftColumn addSubview:operatorCont];
    
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
    
    
    UIView *jobCont = [[UIView alloc] init];
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
    jobCont.frame = CGRectMake(5, 5, leftColumn.frame.size.width - 10, 80);
    [jobCont setBackgroundColor:[UIColor whiteColor]];
    jobCont.layer.cornerRadius = 5;
    jobCont.layer.masksToBounds = true;
    [rightColumn addSubview:jobCont];
    
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
    jobIconCont.frame = CGRectMake(0, 0, jobCont.frame.size.width / 2, jobCont.frame.size.height);
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
    jobIcon.frame = CGRectMake(0,0,45,45);
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
    jobLabel.frame = CGRectMake(0,0,jobIconCont.frame.size.width-4,10);
    [jobLabel setCenter:CGPointMake(jobIconCont.frame.size.width / 2, 67.5)];
    jobLabel.text = [NSString stringWithFormat:@"Job No"];
    [jobLabel setFont:[UIFont boldSystemFontOfSize:10]];
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
    jobMachineCont.frame = CGRectMake(jobCont.frame.size.width / 2, 0, jobCont.frame.size.width / 2, jobCont.frame.size.height);
    [jobMachineCont setBackgroundColor:lightColor];
    [jobCont addSubview:jobMachineCont];
    
    UILabel *jobMachineValue = [[UILabel alloc] init];
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
    jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,jobMachineCont.frame.size.height);
    [jobMachineValue setCenter:CGPointMake(jobMachineCont.frame.size.width / 2, jobMachineCont.frame.size.height / 2)];
    jobMachineValue.text = [NSString stringWithFormat:@"245"];
    [jobMachineValue setFont:[UIFont boldSystemFontOfSize:22]];
    jobMachineValue.textColor = [UIColor blackColor];
    jobMachineValue.textAlignment = NSTextAlignmentCenter;
    [jobMachineCont addSubview:jobMachineValue];
    
    
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
    stationCont.frame = CGRectMake(5, 195, leftColumn.frame.size.width - 10, 80);
    [stationCont setBackgroundColor:[UIColor whiteColor]];
    stationCont.layer.cornerRadius = 5;
    stationCont.layer.masksToBounds = true;
    [leftColumn addSubview:stationCont];
    
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
    stationIconCont.frame = CGRectMake(0, 0, stationCont.frame.size.width / 2, stationCont.frame.size.height);
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
    stationIcon.frame = CGRectMake(0,0,45,45);
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
    stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,10);
    [stationLabel setCenter:CGPointMake(stationIconCont.frame.size.width / 2, 67.5)];
    stationLabel.text = [NSString stringWithFormat:@"Station"];
    [stationLabel setFont:[UIFont boldSystemFontOfSize:10]];
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
    stationMachineCont.frame = CGRectMake(stationCont.frame.size.width / 2, 0, stationCont.frame.size.width / 2, stationCont.frame.size.height);
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
    stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,stationMachineCont.frame.size.height);
    [stationMachineValue setCenter:CGPointMake(stationMachineCont.frame.size.width / 2, stationMachineCont.frame.size.height / 2)];
    stationMachineValue.text = [NSString stringWithFormat:@"0803"];
    [stationMachineValue setFont:[UIFont boldSystemFontOfSize:22]];
    stationMachineValue.textColor = [UIColor blackColor];
    stationMachineValue.textAlignment = NSTextAlignmentCenter;
    [stationMachineCont addSubview:stationMachineValue];
    
    
    UIView *sectionCont = [[UIView alloc] init];
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
    sectionCont.frame = CGRectMake(5, 100, leftColumn.frame.size.width - 10, 80);
    [sectionCont setBackgroundColor:[UIColor whiteColor]];
    sectionCont.layer.cornerRadius = 5;
    sectionCont.layer.masksToBounds = true;
    [leftColumn addSubview:sectionCont];
    
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
    sectionIconCont.frame = CGRectMake(0, 0, sectionCont.frame.size.width / 2, sectionCont.frame.size.height);
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
    sectionIcon.frame = CGRectMake(0,0,45,45);
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
    sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,10);
    [sectionLabel setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, 67.5)];
    sectionLabel.text = [NSString stringWithFormat:@"Section"];
    [sectionLabel setFont:[UIFont boldSystemFontOfSize:10]];
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
    sectionMachineCont.frame = CGRectMake(sectionCont.frame.size.width / 2, 0, sectionCont.frame.size.width / 2, sectionCont.frame.size.height);
    [sectionMachineCont setBackgroundColor:lightColor];
    [sectionCont addSubview:sectionMachineCont];
    
    UILabel *sectionMachineValue = [[UILabel alloc] init];
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
    sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,sectionMachineCont.frame.size.height);
    [sectionMachineValue setCenter:CGPointMake(sectionMachineCont.frame.size.width / 2, sectionMachineCont.frame.size.height / 2)];
    sectionMachineValue.text = [NSString stringWithFormat:@"Text 5"];
    [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:22]];
    sectionMachineValue.textColor = [UIColor blackColor];
    sectionMachineValue.textAlignment = NSTextAlignmentCenter;
    [sectionMachineCont addSubview:sectionMachineValue];
    
    
    UIView *titleCont = [[UIView alloc] init];
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
    titleCont.frame = CGRectMake(5, 100, leftColumn.frame.size.width - 10, 80);
    [titleCont setBackgroundColor:[UIColor whiteColor]];
    titleCont.layer.cornerRadius = 5;
    titleCont.layer.masksToBounds = true;
    [rightColumn addSubview:titleCont];
    
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
    titleIconCont.frame = CGRectMake(0, 0, titleCont.frame.size.width / 2, titleCont.frame.size.height);
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
    titleIcon.frame = CGRectMake(0,0,45,45);
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
    titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,10);
    [titleLabel setCenter:CGPointMake(titleIconCont.frame.size.width / 2, 67.5)];
    titleLabel.text = [NSString stringWithFormat:@"Title"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
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
    titleMachineCont.frame = CGRectMake(titleCont.frame.size.width / 2, 0, titleCont.frame.size.width / 2, titleCont.frame.size.height);
    [titleMachineCont setBackgroundColor:lightColor];
    [titleCont addSubview:titleMachineCont];
    
    //Need to make it auto resize width, or font size
    UILabel *titleMachineValue = [[UILabel alloc] init];
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
    titleMachineValue.frame = CGRectMake(0,0,titleMachineCont.frame.size.width-4,titleMachineCont.frame.size.height);
    [titleMachineValue setCenter:CGPointMake(titleMachineCont.frame.size.width / 2, titleMachineCont.frame.size.height / 2)];
    titleMachineValue.text = [NSString stringWithFormat:@"EP52"];
    [titleMachineValue setFont:[UIFont boldSystemFontOfSize:22]];
    titleMachineValue.textColor = [UIColor blackColor];
    titleMachineValue.textAlignment = NSTextAlignmentCenter;
    titleMachineValue.adjustsFontSizeToFitWidth = true;
    //titleMachineValue.lineBreakMode = NSLineBreakByWordWrapping;
    //titleMachineValue.numberOfLines = 2;
    [titleMachineCont addSubview:titleMachineValue];
    
    
    UIView *speedCont = [[UIView alloc] init];
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
    speedCont.frame = CGRectMake(5, 195, leftColumn.frame.size.width - 10, 80);
    [speedCont setBackgroundColor:[UIColor whiteColor]];
    speedCont.layer.cornerRadius = 5;
    speedCont.layer.masksToBounds = true;
    [rightColumn addSubview:speedCont];
    
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
    speedIconCont.frame = CGRectMake(0, 0, speedCont.frame.size.width / 2, speedCont.frame.size.height);
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
    speedIcon.frame = CGRectMake(0,0,45,45);
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
    speedLabel.frame = CGRectMake(0,0,speedIconCont.frame.size.width-4,12);
    [speedLabel setCenter:CGPointMake(speedIconCont.frame.size.width / 2, 67.5)];
    speedLabel.text = [NSString stringWithFormat:@"Speed"];
    [speedLabel setFont:[UIFont boldSystemFontOfSize:10]];
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
    speedMachineCont.frame = CGRectMake(speedCont.frame.size.width / 2, 0, speedCont.frame.size.width / 2, sectionCont.frame.size.height);
    [speedMachineCont setBackgroundColor:lightColor];
    [speedCont addSubview:speedMachineCont];
    
    UILabel *speedMachineValue = [[UILabel alloc] init];
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
    speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,speedMachineCont.frame.size.height);
    [speedMachineValue setCenter:CGPointMake(speedMachineCont.frame.size.width / 2, speedMachineCont.frame.size.height / 2)];
    speedMachineValue.text = [NSString stringWithFormat:@"6982"];
    [speedMachineValue setFont:[UIFont boldSystemFontOfSize:22]];
    speedMachineValue.textColor = [UIColor blackColor];
    speedMachineValue.textAlignment = NSTextAlignmentCenter;
    [speedMachineCont addSubview:speedMachineValue];
    
    //Container for progress bar
    UIView *progressCont = [[UIView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
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
        progressCont.frame = CGRectMake(5, 500, mainPart.frame.size.width-10, 20);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    } else {
        progressCont.frame = CGRectMake(5, 380, mainPart.frame.size.width-10, 20);
    }
    
    progressCont.layer.cornerRadius = 10;
    progressCont.layer.masksToBounds = true;
    [mainPart addSubview:progressCont];
    
    //NSString *goodAmount = [NSString stringWithFormat:@"%@", machine[@"GoodAmount"]];
    //NSString *requiredAmount = [NSString stringWithFormat:@"%@", machine[@"RequiredAmount"]];
    NSString *goodAmount = [NSString stringWithFormat:@"74532"];
    NSString *requiredAmount = [NSString stringWithFormat:@"150000"];
    
    //Percentage Complete
    double progressCur = [goodAmount integerValue];
    double progressCom = [requiredAmount integerValue];
    //NSLog(@"%f %f", progressCom, progressCur);
    double progressVal = progressCur / progressCom;
    //NSLog(@"%f", progressVal);
    
    UIProgressView *progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    } else {
        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
        [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
    }
    
    progressBar.progressTintColor = midColor;
    progressBar.trackTintColor = lightColor;
    //progressBar.progressImage = [UIImage imageNamed:@"progbar_2"];
    //progressBar.trackImage = [UIImage imageNamed:@"progbar_1"];
    progressBar.progress = progressVal;
    [progressBar setTransform:CGAffineTransformMakeScale(1.0, 10.0)];
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
    
    progressLabel.text = [NSString stringWithFormat:@"%@ / %@", goodAmount, requiredAmount];
    [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
    progressLabel.textColor = [UIColor blackColor];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    //[progressLabel setBackgroundColor:[UIColor blackColor]];
    [progressCont addSubview:progressLabel];
    
    UIImageView *speedGraph = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90)];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        speedGraph.frame = CGRectMake(2.5, 400, mainPart.frame.size.width-5, 90);
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
    [mainPart addSubview:speedGraph];
    
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
