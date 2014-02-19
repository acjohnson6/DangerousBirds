//
//  SKSpriteNode+DebugDraw.h
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/12/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)

- (void)attachDebugRectWithSize:(CGSize)s;
- (void)attachDebugFrameFromPath:(CGPathRef)pathRef;

@end
