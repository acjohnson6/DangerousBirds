//
//  MyScene.h
//  DangerousBirds
//

//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Plane.h"

@interface MyScene : SKScene<UIAccelerometerDelegate>{
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    double currentMaxAccelX;
    //NEW* Moving Y
    double currentMaxAccelY;
}

typedef NS_OPTIONS(uint32_t, PCPhysicsCategory)
{
    PCBoundaryCategory  = 1 << 0,
    PCCockPitCategory     = 1 << 1,
    PCBirdCategory      = 1 << 2,
    PCEngine1Category   = 1 << 3,
    PCEngine2Category   = 1 << 4,
};

typedef NS_ENUM(int32_t, PCGameState)
{
    PCGameStateStartingLevel,
    PCGameStatePlaying,
    PCGameStateInReloadMenu,
};

@property (nonatomic, copy) void (^gameStartBlock)(BOOL didStart);
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) SKNode *bgLayer;
@property (strong, nonatomic) SKSpriteNode *planeShadow;
@property Plane *plane;

@end
