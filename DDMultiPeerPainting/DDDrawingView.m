//
//  DDDrawingView.m
//  DDMultiPeerPainting
//
//  Created by Vasco d'Orey on 14/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDDrawingView.h"

@interface DDDrawingView ()
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableDictionary *livePaths;
@property (nonatomic, strong) UIBezierPath *currentPath;
@end

@implementation DDDrawingView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    _paths = [NSMutableArray array];
    _livePaths = [NSMutableDictionary dictionary];
  }
  return self;
}

-(void)addPath:(UIBezierPath *)path
{
  [self.paths addObject:path];
  [self setNeedsDisplay];
}

-(void)setPathWithKey:(id)key state:(DDDrawingState)state point:(CGPoint)point
{
  switch (state) {
    case DDDrawingStateBegan:
    {
      UIBezierPath *newPath = [UIBezierPath bezierPath];
      [newPath moveToPoint:point];
      self.livePaths[key] = newPath;
      break;
    }
    case DDDrawingStateMoved:
    {
      UIBezierPath *path = self.livePaths[key];
      [path addLineToPoint:point];
      break;
    }
    case DDDrawingStateEnded:
    {
      UIBezierPath *path = self.livePaths[key];
      if(path)
      {
        [path addLineToPoint:point];
        [self.paths addObject:path];
        [self.livePaths removeObjectForKey:key];
      }
      break;
    }
    default:
      break;
  }
  [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
  for(UIBezierPath *path in self.livePaths.allValues)
  {
    [path stroke];
  }
  for(UIBezierPath *path in self.paths)
  {
    [path stroke];
  }
}

#pragma mark - Touch Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint point = [[touches anyObject] locationInView:self];
  self.currentPath = [UIBezierPath bezierPath];
  [self.currentPath moveToPoint:point];
  [self.paths addObject:self.currentPath];
  [self setNeedsDisplay];
  [self.delegate drawingView:self didDrawPoint:point withState:DDDrawingStateBegan];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint point = [[touches anyObject] locationInView:self];
  [self.currentPath addLineToPoint:point];
  [self setNeedsDisplay];
  [self.delegate drawingView:self didDrawPoint:point withState:DDDrawingStateMoved];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint point = [[touches anyObject] locationInView:self];
  [self.currentPath addLineToPoint:point];
  [self setNeedsDisplay];
  [self.delegate drawingView:self didDrawPoint:point withState:DDDrawingStateEnded];
}

@end
