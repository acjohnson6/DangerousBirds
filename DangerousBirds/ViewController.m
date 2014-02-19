//
//  ViewController.m
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/7/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
@import iAd;

@interface ViewController() <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, assign) BOOL adLoaded;

@end

@implementation ViewController{
    MyScene *_scene;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        MyScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        //self.canDisplayBannerAds = YES;
        // Present the scene.
        [skView presentScene:scene];
        
        self.bannerView = [[ADBannerView alloc]initWithAdType:ADAdTypeBanner];
        self.bannerView.delegate = self;
        
        _adView = [[UIView alloc]initWithFrame:CGRectMake(0, 2, self.view.bounds.size.width, 50.0f)];
        [_adView addSubview:self.bannerView];
        [skView addSubview:_adView];
        
        _scene = scene;
        __weak ViewController *weakSelf = self;
        _scene.gameStartBlock = ^(BOOL didStart){
            if (didStart)
                [weakSelf.adView removeFromSuperview];
            else
                [skView addSubview:weakSelf.adView];
        };
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"did load");
    self.adLoaded = YES;
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"error in loading banner");
    self.adLoaded = NO;
}


@end
