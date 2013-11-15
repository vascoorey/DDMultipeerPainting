//
//  DDDrawingData.m
//  DDMultiPeerPainting
//
//  Created by Vasco d'Orey on 15/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDDrawingData.h"

static NSString *const PointKey = @"com.deltadog.multipeerpainting.point";
static NSString *const StateKey = @"com.deltadog.multipeerpainting.state";

@implementation DDDrawingData

-(id)initWithCoder:(NSCoder *)aDecoder
{
  if((self = [super init]))
  {
    NSValue *value = [aDecoder decodeObjectForKey:PointKey];
    _point = value.CGPointValue;
    _state = [aDecoder decodeIntegerForKey:StateKey];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:[NSValue valueWithCGPoint:self.point] forKey:PointKey];
  [aCoder encodeInteger:self.state forKey:StateKey];
}

+(instancetype)dataWithPoint:(CGPoint)point state:(DDDrawingState)state
{
  DDDrawingData *data = [[self alloc] init];
  data.point = point;
  data.state = state;
  return data;
}

@end
