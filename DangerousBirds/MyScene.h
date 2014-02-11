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
}

typedef NS_OPTIONS(uint32_t, PCPhysicsCategory)
{
    PCBoundaryCategory  = 1 << 0,
    PCPlaneCategory     = 1 << 1,
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

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) SKNode *bgLayer;
@property (strong, nonatomic) SKSpriteNode *planeShadow;
@property Plane *plane;

@end
