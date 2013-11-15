//
//  DDDrawingData.m
//  DDMultiPeerPainting
//
//  Created by Vasco d'Orey on 15/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDDrawingData.h"

@implementation DDDrawingData

+(instancetype)drawingDataWithPoint:(CGPoint)point state:(DDDrawingState)state
{
  DDDrawingData *data = [[self alloc] init];
  data.point = point;
  data.state = state;
  return data;
}

@end
