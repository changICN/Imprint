//
//  FactoryViewController.m
//  Imprint
//
//  Created by Geoff Baker on 30/11/2018.
//  Copyright © 2018 ICN. All rights reserved.
//

#import "FactoryViewController.h"
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

@interface FactoryViewController ()

@end

@implementation FactoryViewController {
    
    //Decide the orientation of the device
    UIDeviceOrientation Orientation;
    NSUserDefaults *defaults;
    
    UIScrollView *mainPart;
    UIButton *overlay;
    
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

-(void)loadUser{
    
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
    
    
    
    UIImageView *BILable = [[UIImageView alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 18);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        BILable.frame = CGRectMake(0, 150, self.view.frame.size.width, 20);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 20);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 20);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        BILable.frame = CGRectMake(0, 190, self.view.frame.size.width, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 20);
    } else {
        BILable.frame = CGRectMake(0, 170, self.view.frame.size.width, 20);
    }
    BILable.image = [UIImage imageNamed:@"title_factoryview"];
    [self.view addSubview:BILable];
    
    UIButton *selectCatagory = [[UIButton alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        selectCatagory.frame = CGRectMake(40, 180, 250, 40);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        selectCatagory.frame = CGRectMake(40, 180, 250, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        selectCatagory.frame = CGRectMake(40, 200, 280, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        selectCatagory.frame = CGRectMake(40, 200, 250, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        selectCatagory.frame = CGRectMake(200, 260, 370, 70);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        selectCatagory.frame = CGRectMake(40, 200, 250, 40);
    } else {
        selectCatagory.frame = CGRectMake(40, 200, 250, 40);
    }
    [selectCatagory setBackgroundImage:[UIImage imageNamed:@"btn_filter"] forState:UIControlStateNormal];
    [selectCatagory addTarget:self action:@selector(tapFilterBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectCatagory];
    
    UIButton *refreshMachines = [[UIButton alloc] init];
    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
    {
        refreshMachines.frame = CGRectMake(295, 177.5, 42.5, 42.5);
    }
    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
    {
        refreshMachines.frame = CGRectMake(300, 180, 40, 40);
    } else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
    {
        refreshMachines.frame = CGRectMake(300, 200, 40, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
    {
        refreshMachines.frame = CGRectMake(300, 200, 40, 40);
    }else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
    {
        refreshMachines.frame = CGRectMake(600, 260, 70, 70);
    }else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
    {
        refreshMachines.frame = CGRectMake(300, 200, 40, 40);
    } else {
        refreshMachines.frame = CGRectMake(300, 200, 40, 40);
    }
    [refreshMachines setBackgroundImage:[UIImage imageNamed:@"btn_refresh"] forState:UIControlStateNormal];
    [refreshMachines addTarget:self action:@selector(tapRefreshBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshMachines];
    
    [self loadMachines];
    
    //    [Hud removeFromSuperview];
}

-(void)loadMachines{
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
    
    /**
    ImprintDatabase *data2 = [[ImprintDatabase alloc]init];
    [data2 getMagicFilter:@"IMPBUS" completion:^(NSDictionary *magicFilter, NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            //CHANGE GUI IN HERE
        });
        //
        NSLog(@"--------------- %@", magicFilter);
        }
    }];
    **/
    
    ImprintDatabase *data1 = [[ImprintDatabase alloc]init];
    [data1 getLiveFactoryView:@"Imprint Business Systems Ltd" completion:^(NSMutableArray *factoryViewData, NSError *error) {
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //CHANGE GUI IN HERE
                int count = (int) [factoryViewData count];
                //count = count*2;
                NSLog(@"%d", count);
                
                self->mainPart = [[UIScrollView alloc] init];
                if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                {
                    self->mainPart.frame = CGRectMake(10, 225, self.view.frame.size.width-20, self.view.frame.size.height-235);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 200*count);
                }
                else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                {
                    self->mainPart.frame = CGRectMake(10, 225, self.view.frame.size.width-20, self.view.frame.size.height-235);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 200*count);
                }
                else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                {
                    self->mainPart.frame = CGRectMake(10, 245, self.view.frame.size.width-20, self.view.frame.size.height-265);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 200*count);
                }
                else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                {
                    self->mainPart.frame = CGRectMake(10, 225, self.view.frame.size.width-20, self.view.frame.size.height-235);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 200*count);
                }
                else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                {
                    self->mainPart.frame = CGRectMake(10, 355, self.view.frame.size.width-20, self.view.frame.size.height-235);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 300*count);
                }
                else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                {
                    self->mainPart.frame = CGRectMake(10, 225, self.view.frame.size.width-20, self.view.frame.size.height-235);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 200*count);
                } else {
                    self->mainPart.frame = CGRectMake(10, 225, self.view.frame.size.width-20, self.view.frame.size.height-235);
                    self->mainPart.contentSize = CGSizeMake(self.view.frame.size.width-20, 4 + 200*count);
                }
                self->mainPart.bounces = NO;
                [self->mainPart setShowsVerticalScrollIndicator:NO];
                [self.view addSubview:self->mainPart];
                
                int machineYValue = 0;
                /*NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:factoryViewData];
                for(NSDictionary* machine in tmp) {
                    [factoryViewData addObject:machine];
                }*/
                for (NSDictionary* machine in factoryViewData) {
                    NSString *status = [NSString stringWithFormat:@"%@", machine[@"ClassColour"]];
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
                    
                    UIView *machineContainer = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 190);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 190);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 190);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 190);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 390);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 190);
                    } else {
                        machineContainer.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 190);
                    }
                    [machineContainer setBackgroundColor:[UIColor whiteColor]];
                    machineContainer.layer.shadowOffset = CGSizeMake(2,2);
                    machineContainer.layer.shadowRadius = 2;
                    machineContainer.layer.shadowOpacity = 0.5;
                    [self->mainPart addSubview:machineContainer];
                    
                    UIView *machineHeaderCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 25);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 25);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 25);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 25);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 45);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 25);
                    } else {
                        machineHeaderCont.frame = CGRectMake(2, 2, machineContainer.frame.size.width - 4, 25);
                    }
                    CAShapeLayer * maskLayer = [CAShapeLayer layer];
                    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: machineHeaderCont.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
                    machineHeaderCont.layer.mask = maskLayer;
                    
                    //Gradient
                    CAGradientLayer *gradient = [CAGradientLayer layer];
                    gradient.frame = machineHeaderCont.bounds;
                    gradient.colors = @[(id)gradientStart.CGColor, (id)gradientEnd.CGColor];
                    [machineHeaderCont.layer insertSublayer:gradient atIndex:0];
                    
                    [machineContainer addSubview:machineHeaderCont];
                    
                    NSString *operation = [NSString stringWithFormat:@"%@", machine[@"Operation"]];
                    NSArray *items = [operation componentsSeparatedByString:@" "];
                    NSString *currentOp = [items objectAtIndex:0];
                    if ([currentOp isEqualToString:@"2"]) {
                        UIImageView *jobCompleted = [[UIImageView alloc] init];
                        jobCompleted.frame = CGRectMake(3.5,3.5,18,18);
                        jobCompleted.image = [UIImage imageNamed:@"check"];
                        jobCompleted.contentMode = UIViewContentModeScaleAspectFit;
                        [machineHeaderCont addSubview:jobCompleted];
                    }
                    
                    UILabel *machineTitle = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,22);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:14]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,22);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:14]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,22);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:14]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,22);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:14]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,42);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:24]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,22);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:14]];
                    } else {
                        machineTitle.frame = CGRectMake(0,0,machineHeaderCont.frame.size.width,22);
                        [machineTitle setFont:[UIFont boldSystemFontOfSize:14]];
                    }
                    [machineTitle setCenter:CGPointMake(machineHeaderCont.frame.size.width / 2, machineHeaderCont.frame.size.height / 2)];
                    machineTitle.text = [NSString stringWithFormat:@"%@", machine[@"MachineName"]];
                    machineTitle.textColor = [UIColor blackColor];
                    machineTitle.textAlignment = NSTextAlignmentCenter;
                    [machineHeaderCont addSubview:machineTitle];
                    
                    
                    UIView *operatorCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        operatorCont.frame = CGRectMake(5, 32, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        operatorCont.frame = CGRectMake(5, 32, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        operatorCont.frame = CGRectMake(5, 32, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        operatorCont.frame = CGRectMake(5, 32, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        operatorCont.frame = CGRectMake(5, 52, machineContainer.frame.size.width/3-10, 140);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        operatorCont.frame = CGRectMake(5, 32, 110, 60);
                    } else {
                        operatorCont.frame = CGRectMake(5, 32, 110, 60);
                    }
                    [operatorCont setBackgroundColor:[UIColor whiteColor]];
                    operatorCont.layer.cornerRadius = 5;
                    operatorCont.layer.masksToBounds = true;
                    [machineContainer addSubview:operatorCont];
                    
                    UIView *operatorIconCont = [[UIView alloc] init];
                    operatorIconCont.frame = CGRectMake(0, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    [operatorIconCont setBackgroundColor:midColor];
                    [operatorCont addSubview:operatorIconCont];
                    
                    UIImageView *operatorIcon = [[UIImageView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        operatorIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        operatorIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        operatorIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        operatorIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        operatorIcon.frame = CGRectMake(0,0,80,80);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        operatorIcon.frame = CGRectMake(0,0,30,30);
                    } else {
                        operatorIcon.frame = CGRectMake(0,0,30,30);
                    }
                    [operatorIcon setCenter:CGPointMake(operatorIconCont.frame.size.width / 2, operatorIconCont.frame.size.height / 2 - 5)];
                    operatorIcon.image = [UIImage imageNamed:@"ic_user"];
                    operatorIcon.contentMode = UIViewContentModeScaleAspectFit;
                    [operatorIconCont addSubview:operatorIcon];
                    
                    UILabel *operatorLabel = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    } else {
                        operatorLabel.frame = CGRectMake(0,0,operatorIconCont.frame.size.width-4,20);
                        [operatorLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    [operatorLabel setCenter:CGPointMake(operatorIconCont.frame.size.width / 2, operatorIconCont.frame.size.height - 10)];
                    operatorLabel.text = [NSString stringWithFormat:@"%@", machine[@"MachineOperator"]];
                    operatorLabel.textColor = [UIColor blackColor];
                    operatorLabel.textAlignment = NSTextAlignmentCenter;
                    operatorLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    operatorLabel.numberOfLines = 2;
                    [operatorIconCont addSubview:operatorLabel];
                    
                    UIView *operatorMachineCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    } else {
                        operatorMachineCont.frame = CGRectMake(operatorCont.frame.size.width / 2, 0, operatorCont.frame.size.width / 2, operatorCont.frame.size.height);
                    }
                    [operatorMachineCont setBackgroundColor:lightColor];
                    [operatorCont addSubview:operatorMachineCont];
                    
                    UIImageView *opImage = [[UIImageView alloc] init];
                    opImage.frame = CGRectMake(0,0,operatorMachineCont.frame.size.width,operatorMachineCont.frame.size.height);
                    [opImage setCenter:CGPointMake(operatorMachineCont.frame.size.width / 2, operatorMachineCont.frame.size.height / 2)];
                    opImage.image = [UIImage imageNamed:@"user"];
                    [operatorMachineCont addSubview:opImage];
                    
                    
                    UIView *jobCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        jobCont.frame = CGRectMake(120, 32, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        jobCont.frame = CGRectMake(120, 32, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        jobCont.frame = CGRectMake(120, 32, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        jobCont.frame = CGRectMake(120, 32, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        jobCont.frame = CGRectMake(machineContainer.frame.size.width/3, 52, machineContainer.frame.size.width/3-10, 140);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        jobCont.frame = CGRectMake(120, 32, 110, 60);
                    } else {
                        jobCont.frame = CGRectMake(120, 32, 110, 60);
                    }
                    [jobCont setBackgroundColor:[UIColor whiteColor]];
                    jobCont.layer.cornerRadius = 5;
                    jobCont.layer.masksToBounds = true;
                    [machineContainer addSubview:jobCont];
                    
                    UIView *jobIconCont = [[UIView alloc] init];
                    jobIconCont.frame = CGRectMake(0, 0, jobCont.frame.size.width / 2, jobCont.frame.size.height);
                    [jobIconCont setBackgroundColor:midColor];
                    [jobCont addSubview:jobIconCont];
                    
                    UIImageView *jobIcon = [[UIImageView alloc] init];
                    jobIcon.frame = CGRectMake(0,0,30,30);
                    [jobIcon setCenter:CGPointMake(jobIconCont.frame.size.width / 2, jobIconCont.frame.size.height / 2 - 5)];
                    jobIcon.image = [UIImage imageNamed:@"ic_job"];
                    jobIcon.contentMode = UIViewContentModeScaleAspectFit;
                    [jobIconCont addSubview:jobIcon];
                    
                    UILabel *jobLabel = [[UILabel alloc] init];
                    jobLabel.frame = CGRectMake(0,0,jobIconCont.frame.size.width-4,8);
                    [jobLabel setCenter:CGPointMake(jobIconCont.frame.size.width / 2, jobIconCont.frame.size.height - 10)];
                    jobLabel.text = [NSString stringWithFormat:@"Job No"];
                    [jobLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    jobLabel.textColor = [UIColor blackColor];
                    jobLabel.textAlignment = NSTextAlignmentCenter;
                    [jobIconCont addSubview:jobLabel];
                    
                    UIView *jobMachineCont = [[UIView alloc] init];
                    jobMachineCont.frame = CGRectMake(jobCont.frame.size.width / 2, 0, jobCont.frame.size.width / 2, jobCont.frame.size.height);
                    [jobMachineCont setBackgroundColor:lightColor];
                    [jobCont addSubview:jobMachineCont];
                    
                    UILabel *jobMachineValue = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    } else {
                        jobMachineValue.frame = CGRectMake(0,0,jobMachineCont.frame.size.width-4,16);
                        [jobMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    [jobMachineValue setCenter:CGPointMake(jobMachineCont.frame.size.width / 2, jobMachineCont.frame.size.height / 2)];
                    jobMachineValue.text = [NSString stringWithFormat:@"%@", machine[@"JobNo"]];
                    jobMachineValue.textColor = [UIColor blackColor];
                    jobMachineValue.textAlignment = NSTextAlignmentCenter;
                    [jobMachineCont addSubview:jobMachineValue];
                    
                    
                    UIView *stationCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        stationCont.frame = CGRectMake(235, 32, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        stationCont.frame = CGRectMake(235, 32, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        stationCont.frame = CGRectMake(235, 32, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        stationCont.frame = CGRectMake(235, 32, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        stationCont.frame = CGRectMake(machineContainer.frame.size.width/3*2, 52, machineContainer.frame.size.width/3-10, 140);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        stationCont.frame = CGRectMake(235, 32, 110, 60);
                    } else {
                        stationCont.frame = CGRectMake(235, 32, 110, 60);
                    }
                    [stationCont setBackgroundColor:[UIColor whiteColor]];
                    stationCont.layer.cornerRadius = 5;
                    stationCont.layer.masksToBounds = true;
                    [machineContainer addSubview:stationCont];
                    
                    UIView *stationIconCont = [[UIView alloc] init];
                    stationIconCont.frame = CGRectMake(0, 0, stationCont.frame.size.width / 2, stationCont.frame.size.height);
                    [stationIconCont setBackgroundColor:midColor];
                    [stationCont addSubview:stationIconCont];
                    
                    UIImageView *stationIcon = [[UIImageView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    } else {
                        stationIcon.frame = CGRectMake(0,0,30,30);
                    }
                    [stationIcon setCenter:CGPointMake(stationIconCont.frame.size.width / 2, stationIconCont.frame.size.height / 2 - 5)];
                    stationIcon.image = [UIImage imageNamed:@"ic_station"];
                    stationIcon.contentMode = UIViewContentModeScaleAspectFit;
                    [stationIconCont addSubview:stationIcon];
                    
                    UILabel *stationLabel = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    } else {
                        stationLabel.frame = CGRectMake(0,0,stationIconCont.frame.size.width-4,8);
                    }
                    [stationLabel setCenter:CGPointMake(stationIconCont.frame.size.width / 2, stationIconCont.frame.size.height - 10)];
                    stationLabel.text = [NSString stringWithFormat:@"Station"];
                    [stationLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    stationLabel.textColor = [UIColor blackColor];
                    stationLabel.textAlignment = NSTextAlignmentCenter;
                    [stationIconCont addSubview:stationLabel];
                    
                    UIView *stationMachineCont = [[UIView alloc] init];
                    stationMachineCont.frame = CGRectMake(stationCont.frame.size.width / 2, 0, stationCont.frame.size.width / 2, stationCont.frame.size.height);
                    [stationMachineCont setBackgroundColor:lightColor];
                    [stationCont addSubview:stationMachineCont];
                    
                    UILabel *stationMachineValue = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    } else {
                        stationMachineValue.frame = CGRectMake(0,0,stationMachineCont.frame.size.width-4,16);
                        [stationMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    [stationMachineValue setCenter:CGPointMake(stationMachineCont.frame.size.width / 2, stationMachineCont.frame.size.height / 2)];
                    stationMachineValue.text = [NSString stringWithFormat:@"%@", machine[@"ShopStation"]];
                    stationMachineValue.textColor = [UIColor blackColor];
                    stationMachineValue.textAlignment = NSTextAlignmentCenter;
                    [stationMachineCont addSubview:stationMachineValue];
                    
                    
                    UIView *sectionCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        sectionCont.frame = CGRectMake(5, 98, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        sectionCont.frame = CGRectMake(5, 98, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        sectionCont.frame = CGRectMake(5, 98, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        sectionCont.frame = CGRectMake(5, 98, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        sectionCont.frame = CGRectMake(5, 200, machineContainer.frame.size.width/3-10, 140);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        sectionCont.frame = CGRectMake(5, 98, 110, 60);
                    } else {
                        sectionCont.frame = CGRectMake(5, 98, 110, 60);
                    }
                    [sectionCont setBackgroundColor:[UIColor whiteColor]];
                    sectionCont.layer.cornerRadius = 5;
                    sectionCont.layer.masksToBounds = true;
                    [machineContainer addSubview:sectionCont];
                    
                    UIView *sectionIconCont = [[UIView alloc] init];
                    sectionIconCont.frame = CGRectMake(0, 0, sectionCont.frame.size.width / 2, sectionCont.frame.size.height);
                    [sectionIconCont setBackgroundColor:midColor];
                    [sectionCont addSubview:sectionIconCont];
                    
                    UIImageView *sectionIcon = [[UIImageView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    } else {
                        sectionIcon.frame = CGRectMake(0,0,30,30);
                    }
                    [sectionIcon setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, sectionIconCont.frame.size.height / 2 - 5)];
                    sectionIcon.image = [UIImage imageNamed:@"ic_section"];
                    sectionIcon.contentMode = UIViewContentModeScaleAspectFit;
                    [sectionIconCont addSubview:sectionIcon];
                    
                    UILabel *sectionLabel = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    } else {
                        sectionLabel.frame = CGRectMake(0,0,sectionIconCont.frame.size.width-4,8);
                        [sectionLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    [sectionLabel setCenter:CGPointMake(sectionIconCont.frame.size.width / 2, sectionIconCont.frame.size.height - 10)];
                    sectionLabel.text = [NSString stringWithFormat:@"Section"];
                    sectionLabel.textColor = [UIColor blackColor];
                    sectionLabel.textAlignment = NSTextAlignmentCenter;
                    [sectionIconCont addSubview:sectionLabel];
                    
                    UIView *sectionMachineCont = [[UIView alloc] init];
                    sectionMachineCont.frame = CGRectMake(sectionCont.frame.size.width / 2, 0, sectionCont.frame.size.width / 2, sectionCont.frame.size.height);
                    [sectionMachineCont setBackgroundColor:lightColor];
                    [sectionCont addSubview:sectionMachineCont];
                    
                    UILabel *sectionMachineValue = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    } else {
                        sectionMachineValue.frame = CGRectMake(0,0,sectionMachineCont.frame.size.width-4,16);
                        [sectionMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    [sectionMachineValue setCenter:CGPointMake(sectionMachineCont.frame.size.width / 2, sectionMachineCont.frame.size.height / 2)];
                    sectionMachineValue.text = [NSString stringWithFormat:@"%@", machine[@"SectionCode"]];
                    sectionMachineValue.textColor = [UIColor blackColor];
                    sectionMachineValue.textAlignment = NSTextAlignmentCenter;
                    [sectionMachineCont addSubview:sectionMachineValue];
                    
                    
                    UIView *titleCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        titleCont.frame = CGRectMake(120, 98, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        titleCont.frame = CGRectMake(120, 98, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        titleCont.frame = CGRectMake(120, 98, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        titleCont.frame = CGRectMake(120, 98, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        titleCont.frame = CGRectMake(machineContainer.frame.size.width/3, 200, machineContainer.frame.size.width/3-10, 140);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        titleCont.frame = CGRectMake(120, 98, 110, 60);
                    } else {
                        titleCont.frame = CGRectMake(120, 98, 110, 60);
                    }
                    [titleCont setBackgroundColor:[UIColor whiteColor]];
                    titleCont.layer.cornerRadius = 5;
                    titleCont.layer.masksToBounds = true;
                    [machineContainer addSubview:titleCont];
                    
                    UIView *titleIconCont = [[UIView alloc] init];
                    titleIconCont.frame = CGRectMake(0, 0, titleCont.frame.size.width / 2, titleCont.frame.size.height);
                    [titleIconCont setBackgroundColor:midColor];
                    [titleCont addSubview:titleIconCont];
                    
                    UIImageView *titleIcon = [[UIImageView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    } else {
                        titleIcon.frame = CGRectMake(0,0,30,30);
                    }
                    [titleIcon setCenter:CGPointMake(titleIconCont.frame.size.width / 2, titleIconCont.frame.size.height / 2 - 5)];
                    titleIcon.image = [UIImage imageNamed:@"ic_title"];
                    titleIcon.contentMode = UIViewContentModeScaleAspectFit;
                    [titleIconCont addSubview:titleIcon];
                    
                    UILabel *titleLabel = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    } else {
                        titleLabel.frame = CGRectMake(0,0,titleIconCont.frame.size.width-4,8);
                        [titleLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    }
                    [titleLabel setCenter:CGPointMake(titleIconCont.frame.size.width / 2, titleIconCont.frame.size.height - 10)];
                    titleLabel.text = [NSString stringWithFormat:@"Title"];
                    titleLabel.textColor = [UIColor blackColor];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [titleIconCont addSubview:titleLabel];
                    
                    UIView *titleMachineCont = [[UIView alloc] init];
                    titleMachineCont.frame = CGRectMake(titleCont.frame.size.width / 2, 0, titleCont.frame.size.width / 2, titleCont.frame.size.height);
                    [titleMachineCont setBackgroundColor:lightColor];
                    [titleCont addSubview:titleMachineCont];
                    
                    //Need to make it auto resize width, or font size
                    UILabel *titleMachineValue = [[UILabel alloc] init];
                    titleMachineValue.frame = CGRectMake(0,0,titleMachineCont.frame.size.width-4,titleMachineCont.frame.size.height);
                    [titleMachineValue setCenter:CGPointMake(titleMachineCont.frame.size.width / 2, titleMachineCont.frame.size.height / 2)];
                    //
                    [titleMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    titleMachineValue.textColor = [UIColor blackColor];
                    titleMachineValue.textAlignment = NSTextAlignmentCenter;
                    //titleMachineValue.adjustsFontSizeToFitWidth = true;
                    //titleMachineValue.lineBreakMode = NSLineBreakByWordWrapping;
                    //titleMachineValue.numberOfLines = 3;
                    [titleMachineCont addSubview:titleMachineValue];
                    
                    if([self widthOfString:[NSString stringWithFormat:@"%@", machine[@"JobTitle"]]:titleMachineValue.font] > titleMachineValue.frame.size.width) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                                   ^{
                                       [self animateLabelShowText:[NSString stringWithFormat:@"%@", machine[@"JobTitle"]]:0.2:titleMachineValue];
                                   });
                    } else {
                        titleMachineValue.text = [NSString stringWithFormat:@"%@", machine[@"JobTitle"]];
                    }
                    
                    
                    UIView *speedCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        speedCont.frame = CGRectMake(235, 98, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        speedCont.frame = CGRectMake(235, 98, 110, 60);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        speedCont.frame = CGRectMake(235, 98, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        speedCont.frame = CGRectMake(235, 98, 110, 60);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        speedCont.frame = CGRectMake(machineContainer.frame.size.width/3*2, 200, machineContainer.frame.size.width/3-10, 140);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        speedCont.frame = CGRectMake(235, 98, 110, 60);
                    } else {
                        speedCont.frame = CGRectMake(235, 98, 110, 60);
                    }
                    [speedCont setBackgroundColor:[UIColor whiteColor]];
                    speedCont.layer.cornerRadius = 5;
                    speedCont.layer.masksToBounds = true;
                    [machineContainer addSubview:speedCont];
                    
                    UIView *speedIconCont = [[UIView alloc] init];
                    speedIconCont.frame = CGRectMake(0, 0, speedCont.frame.size.width / 2, speedCont.frame.size.height);
                    [speedIconCont setBackgroundColor:midColor];
                    [speedCont addSubview:speedIconCont];
                    
                    UIImageView *speedIcon = [[UIImageView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    } else {
                        speedIcon.frame = CGRectMake(0,0,30,30);
                    }
                    [speedIcon setCenter:CGPointMake(speedIconCont.frame.size.width / 2, speedIconCont.frame.size.height / 2 - 5)];
                    speedIcon.image = [UIImage imageNamed:@"ic_speed"];
                    speedIcon.contentMode = UIViewContentModeScaleAspectFit;
                    [speedIconCont addSubview:speedIcon];
                    
                    UILabel *speedLabel = [[UILabel alloc] init];
                    speedLabel.frame = CGRectMake(0,0,speedIconCont.frame.size.width-4,8);
                    [speedLabel setCenter:CGPointMake(speedIconCont.frame.size.width / 2, speedIconCont.frame.size.height - 10)];
                    speedLabel.text = [NSString stringWithFormat:@"Speed"];
                    [speedLabel setFont:[UIFont boldSystemFontOfSize:8]];
                    speedLabel.textColor = [UIColor blackColor];
                    speedLabel.textAlignment = NSTextAlignmentCenter;
                    [speedIconCont addSubview:speedLabel];
                    
                    UIView *speedMachineCont = [[UIView alloc] init];
                    speedMachineCont.frame = CGRectMake(speedCont.frame.size.width / 2, 0, speedCont.frame.size.width / 2, sectionCont.frame.size.height);
                    [speedMachineCont setBackgroundColor:lightColor];
                    [speedCont addSubview:speedMachineCont];
                    
                    UILabel *speedMachineValue = [[UILabel alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    } else {
                        speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                        [speedMachineValue setFont:[UIFont boldSystemFontOfSize:16]];
                    }
                    speedMachineValue.frame = CGRectMake(0,0,speedMachineCont.frame.size.width-4,16);
                    [speedMachineValue setCenter:CGPointMake(speedMachineCont.frame.size.width / 2, speedMachineCont.frame.size.height / 2)];
                    speedMachineValue.text = [NSString stringWithFormat:@"%@", machine[@"Speed"]];
                    speedMachineValue.textColor = [UIColor blackColor];
                    speedMachineValue.textAlignment = NSTextAlignmentCenter;
                    [speedMachineCont addSubview:speedMachineValue];
                    
                    //Container for progress bar
                    UIView *progressCont = [[UIView alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        progressCont.frame = CGRectMake(5, 163, machineContainer.frame.size.width-10, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        progressCont.frame = CGRectMake(5, 163, machineContainer.frame.size.width-10, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        progressCont.frame = CGRectMake(5, 163, machineContainer.frame.size.width-10, 20);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        progressCont.frame = CGRectMake(5, 163, machineContainer.frame.size.width-10, 20);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        progressCont.frame = CGRectMake(5, 350, machineContainer.frame.size.width-10, 40);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        progressCont.frame = CGRectMake(5, 350, machineContainer.frame.size.width-10, 20);
                    } else {
                        progressCont.frame = CGRectMake(5, 163, machineContainer.frame.size.width-10, 20);
                    }
                    [progressCont setBackgroundColor:[UIColor blackColor]];
                    progressCont.layer.cornerRadius = 10;
                    progressCont.layer.masksToBounds = true;
                    [machineContainer addSubview:progressCont];
                    
                    NSString *goodAmount = [NSString stringWithFormat:@"%@", machine[@"GoodAmount"]];
                    NSString *requiredAmount = [NSString stringWithFormat:@"%@", machine[@"RequiredAmount"]];
                    
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
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width/2, 80);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
                    } else {
                        progressBar.frame = CGRectMake(0,0, progressCont.frame.size.width, 20);
                    }
                    [progressBar setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
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
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,45);
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:22]];
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
                    } else {
                        progressLabel.frame = CGRectMake(0,0,progressCont.frame.size.width-20,25);
                        [progressLabel setFont:[UIFont boldSystemFontOfSize:12]];
                    }
                    [progressLabel setCenter:CGPointMake(progressCont.frame.size.width / 2, progressCont.frame.size.height / 2)];
                    progressLabel.text = [NSString stringWithFormat:@"%@ / %@", goodAmount, requiredAmount];
                    progressLabel.textColor = [UIColor blackColor];
                    progressLabel.textAlignment = NSTextAlignmentCenter;
                    //[progressLabel setBackgroundColor:[UIColor blackColor]];
                    [progressCont addSubview:progressLabel];
                    
                    
                    UIButton *machineBtn = [[UIButton alloc] init];
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 195);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 195);
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 195);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 195);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 195);
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 395);
                    } else {
                        machineBtn.frame = CGRectMake(2, 4 + machineYValue, self->mainPart.frame.size.width-5, 195);
                    }
                    [machineBtn.layer setValue:machine[@"ShopStation"] forKey:@"ShopStation"];
                    [machineBtn addTarget:self action:@selector(tapMachine:) forControlEvents:UIControlEventTouchUpInside];
                    [self->mainPart addSubview:machineBtn];
                    
                    
                    
                    if ([[UIScreen mainScreen] bounds].size.height == 667) //iPhone 6 size
                    {
                        machineYValue += 200;
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 736) //iPhone 6+ size
                    {
                        machineYValue += 200;
                    }
                    else if ([[UIScreen mainScreen] bounds].size.height == 812) //iPhone X size
                    {
                        machineYValue += 200;
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1024)  //ipad Air/Mini
                    {
                        machineYValue += 200;
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1112)  //ipad pro 10.5
                    {
                        machineYValue += 430;
                    }
                    else if([[UIScreen mainScreen] bounds].size.height == 1366)  //ipad pro 12.9
                    {
                        machineYValue += 200;
                    } else {
                        machineYValue += 200;
                    }
                }
            });
            //
            NSLog(@"--------------- %@", factoryViewData);
        }
    }];
    
}
- (CGFloat)widthOfString:(NSString *)string:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (void)animateLabelShowText:(NSString*)newText: (NSTimeInterval)delay: (UILabel*) label
{
    NSString *displayedText = @"";
    BOOL isForward = YES;
    int i = 0;
    while(1)
    {
        displayedText = [newText substringWithRange:NSMakeRange (i, 4)];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [label setText:[NSString stringWithFormat:@"%@", displayedText]];
                       });
        
        

        if(i == 0) {
            isForward = YES;
            [NSThread sleepForTimeInterval:delay + 1];
        } else if(i == newText.length - 4) {
            isForward = NO;
            [NSThread sleepForTimeInterval:delay+ 0.2];
        } else {
            [NSThread sleepForTimeInterval:delay];
        }
        if(isForward) {
            i++;
        } else {
            i--;
        }
    }
}

-(void)tapRefreshBtn {
    //[self showLoading];
    [mainPart removeFromSuperview];
    [self loadMachines];
}

-(void)tapFilterBtn {
    UIColor *startGradient = [UIColor colorWithRed:194/255.0f
                            green:215/255.0f
                             blue:93/255.0f
                            alpha:1.0f];
    UIColor *endGradient = [UIColor colorWithRed:149/255.0f
                            green:182/255.0f
                             blue:37/255.0f
                            alpha:1.0f];
    
    overlay = [[UIButton alloc] init];
    overlay.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [overlay setBackgroundColor:[UIColor colorWithRed:26/255.0f
                                                green:26/255.0f
                                                 blue:26/255.0f
                                                alpha:0.95f]];
    [overlay addTarget:self action:@selector(exitOverlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:overlay];
    
    UIView *filterOverlay = [[UIView alloc] init];
    filterOverlay.frame = CGRectMake(0, 0, self.view.frame.size.width-40, 200);
    [filterOverlay setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    [filterOverlay setBackgroundColor:[UIColor whiteColor]];
    filterOverlay.layer.cornerRadius = 5;
    filterOverlay.layer.masksToBounds = true;
    [overlay addSubview:filterOverlay];
    
    UIView *filterHeader = [[UIView alloc] init];
    filterHeader.frame = CGRectMake(2, 2, filterOverlay.frame.size.width - 4, 20);
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: filterHeader.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){5.0, 5.0}].CGPath;
    filterHeader.layer.mask = maskLayer;
    
    //Gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = filterHeader.bounds;
    gradient.colors = @[(id)startGradient.CGColor, (id)endGradient.CGColor];
    [filterHeader.layer insertSublayer:gradient atIndex:0];
    
    [filterOverlay addSubview:filterHeader];
    
    UILabel *filterTitle = [[UILabel alloc] init];
    filterTitle.frame = CGRectMake(0,0,filterHeader.frame.size.width,filterHeader.frame.size.height);
    [filterTitle setCenter:CGPointMake(filterHeader.frame.size.width / 2, filterHeader.frame.size.height / 2)];
    filterTitle.text = [NSString stringWithFormat:@"Filter Machines"];
    [filterTitle setFont:[UIFont boldSystemFontOfSize:12]];
    filterTitle.textColor = [UIColor whiteColor];
    filterTitle.textAlignment = NSTextAlignmentCenter;
    [filterHeader addSubview:filterTitle];
    
    UIView *leftColumn = [[UIView alloc] init];
    leftColumn.frame = CGRectMake(2, 22, filterOverlay.frame.size.width / 2 - 2, 120);
    [leftColumn setCenter:CGPointMake(filterOverlay.frame.size.width / 4, filterOverlay.frame.size.height / 2 - 5)];
    [filterOverlay addSubview:leftColumn];
    
    //Printing Filter
    UIButton *printingCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [printingCheckbox setCenter:CGPointMake(leftColumn.frame.size.width/4, 20)];
    [printingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_on"]   forState:UIControlStateNormal];
    [printingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_off"]    forState:UIControlStateSelected];
    [printingCheckbox addTarget:(self) action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [leftColumn addSubview:printingCheckbox];
    
    UILabel *printingLabel = [[UILabel alloc] init];
    printingLabel.frame = CGRectMake(leftColumn.frame.size.width / 2.5, 10, leftColumn.frame.size.width / 2, 20);
    printingLabel.text = [NSString stringWithFormat:@"Printing"];
    [printingLabel setFont:[UIFont boldSystemFontOfSize:14]];
    printingLabel.textColor = [UIColor blackColor];
    [leftColumn addSubview:printingLabel];
    
    //Binding Filter
    UIButton *bindingCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [bindingCheckbox setCenter:CGPointMake(leftColumn.frame.size.width/4, 60)];
    [bindingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_off"]   forState:UIControlStateNormal];
    [bindingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_on"]    forState:UIControlStateSelected];
    [bindingCheckbox addTarget:(self) action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [leftColumn addSubview:bindingCheckbox];
    
    UILabel *bindingLabel = [[UILabel alloc] init];
    bindingLabel.frame = CGRectMake(leftColumn.frame.size.width / 2.5, 50, leftColumn.frame.size.width / 2, 20);
    bindingLabel.text = [NSString stringWithFormat:@"Binding"];
    [bindingLabel setFont:[UIFont boldSystemFontOfSize:14]];
    bindingLabel.textColor = [UIColor blackColor];
    [leftColumn addSubview:bindingLabel];
    
    //Other Filter
    UIButton *otherCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [otherCheckbox setCenter:CGPointMake(leftColumn.frame.size.width/4, 100)];
    [otherCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_off"]   forState:UIControlStateNormal];
    [otherCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_on"]    forState:UIControlStateSelected];
    otherCheckbox.tag = 1;
    [otherCheckbox addTarget:(self) action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [leftColumn addSubview:otherCheckbox];
    
    UILabel *otherLabel = [[UILabel alloc] init];
    otherLabel.frame = CGRectMake(leftColumn.frame.size.width / 2.5, 90, leftColumn.frame.size.width / 2, 20);
    otherLabel.text = [NSString stringWithFormat:@"Other"];
    [otherLabel setFont:[UIFont boldSystemFontOfSize:14]];
    otherLabel.textColor = [UIColor blackColor];
    [leftColumn addSubview:otherLabel];
    
    
    UIView *rightColumn = [[UIView alloc] init];
    rightColumn.frame = CGRectMake(2, 22, filterOverlay.frame.size.width / 2 - 2, 120);
    [rightColumn setCenter:CGPointMake(filterOverlay.frame.size.width - filterOverlay.frame.size.width / 4, filterOverlay.frame.size.height / 2 - 5)];
    [filterOverlay addSubview:rightColumn];
    
    //Finishing Filter
    UIButton *finishingCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [finishingCheckbox setCenter:CGPointMake(leftColumn.frame.size.width/4, 20)];
    [finishingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_off"]   forState:UIControlStateNormal];
    [finishingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_on"]    forState:UIControlStateSelected];
    [finishingCheckbox addTarget:(self) action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [rightColumn addSubview:finishingCheckbox];
    
    UILabel *finishingLabel = [[UILabel alloc] init];
    finishingLabel.frame = CGRectMake(rightColumn.frame.size.width / 2.5, 10, rightColumn.frame.size.width / 2, 20);
    finishingLabel.text = [NSString stringWithFormat:@"Finishing"];
    [finishingLabel setFont:[UIFont boldSystemFontOfSize:14]];
    finishingLabel.textColor = [UIColor blackColor];
    [rightColumn addSubview:finishingLabel];
    
    //Folding Filter
    UIButton *foldingCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [foldingCheckbox setCenter:CGPointMake(leftColumn.frame.size.width/4, 60)];
    [foldingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_off"]   forState:UIControlStateNormal];
    [foldingCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_on"]    forState:UIControlStateSelected];
    [foldingCheckbox addTarget:(self) action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [rightColumn addSubview:foldingCheckbox];
    
    UILabel *foldingLabel = [[UILabel alloc] init];
    foldingLabel.frame = CGRectMake(rightColumn.frame.size.width / 2.5, 50, rightColumn.frame.size.width / 2, 20);
    foldingLabel.text = [NSString stringWithFormat:@"Folding"];
    [foldingLabel setFont:[UIFont boldSystemFontOfSize:14]];
    foldingLabel.textColor = [UIColor blackColor];
    [rightColumn addSubview:foldingLabel];
    
    //All Filter
    UIButton *allCheckbox = [[UIButton alloc] initWithFrame:CGRectMake(0,0,20,20)];
    [allCheckbox setCenter:CGPointMake(leftColumn.frame.size.width/4, 100)];
    [allCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_off"]   forState:UIControlStateNormal];
    [allCheckbox setBackgroundImage:[UIImage imageNamed:@"checkbox_on"]    forState:UIControlStateSelected];
    [allCheckbox addTarget:(self) action:@selector(checkboxSelected:) forControlEvents:UIControlEventTouchUpInside];
    [rightColumn addSubview:allCheckbox];
    
    UILabel *allLabel = [[UILabel alloc] init];
    allLabel.frame = CGRectMake(rightColumn.frame.size.width / 2.5, 90, rightColumn.frame.size.width / 2, 20);
    allLabel.text = [NSString stringWithFormat:@"All"];
    [allLabel setFont:[UIFont boldSystemFontOfSize:14]];
    allLabel.textColor = [UIColor blackColor];
    [rightColumn addSubview:allLabel];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, 0, filterOverlay.frame.size.width / 2 - 10, 35);
    [cancelBtn setCenter:CGPointMake(filterOverlay.frame.size.width / 4, filterOverlay.frame.size.height - 20)];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_cancel"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(exitOverlay) forControlEvents:UIControlEventTouchUpInside];
    [filterOverlay addSubview:cancelBtn];
    
    UIButton *applyBtn = [[UIButton alloc] init];
    applyBtn.frame = CGRectMake(0, 0, filterOverlay.frame.size.width / 2 - 10, 35);
    [applyBtn setCenter:CGPointMake(filterOverlay.frame.size.width - filterOverlay.frame.size.width / 4, filterOverlay.frame.size.height - 20)];
    [applyBtn setBackgroundImage:[UIImage imageNamed:@"btn_apply"] forState:UIControlStateNormal];
    [applyBtn addTarget:self action:@selector(applyFilters) forControlEvents:UIControlEventTouchUpInside];
    [filterOverlay addSubview:applyBtn];
    
}

-(void)checkboxSelected:(id)sender
{
    UIButton *checkbox = sender;
    NSLog(@"%@", checkbox);
}

-(void)applyFilters {
    
}

-(void)exitOverlay {
    [overlay removeFromSuperview];
}

-(void)tapMachine:(UIButton*)sender {
    NSString *machineCode = [NSString stringWithFormat:@"%@", [sender.layer valueForKey:@"ShopStation"]];
    //NSLog(@"%@", machineCode);
    
    [self showLoading];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FactoryMachine"];
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
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"Home"];
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
