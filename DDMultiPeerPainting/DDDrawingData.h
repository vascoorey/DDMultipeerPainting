//
//  DDDrawingData.h
//  DDMultiPeerPainting
//
//  Created by Vasco d'Orey on 15/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DDDrawingState)
{
  DDDrawingStateInvalid = -1,
  DDDrawingStateBegan,
  DDDrawingStateMoved,
  DDDrawingStateEnded
};

@import MultipeerConnectivity;

@interface DDDrawingData : NSObject
@property (nonatomic) CGPoint point;
@property (nonatomic) DDDrawingState state;
+(instancetype)drawingDataWithPoint:(CGPoint)point state:(DDDrawingState)state;
@end
