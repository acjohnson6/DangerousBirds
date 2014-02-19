//
//  Plane.h
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/10/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "AnimatingSprite.h"
#import "Engines.h"

@interface Plane : AnimatingSprite
@property(assign, nonatomic) NSInteger engine1Hit;
@property(assign, nonatomic) NSInteger engine2Hit;
@property(assign, nonatomic) NSInteger engine3Hit;
@property(assign, nonatomic) NSInteger engine4Hit;

-(instancetype)initWithScreenWidth:(CGFloat)screenWidth;
-(void)crashPlane;
-(void)engineSmokeEngineNumber:(EngineNumber)engineNumber;

@end
