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
@property (nonatomic, strong) UIBezierPath *currentPath;
@end

@implementation DDDrawingView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    _paths = [NSMutableArray array];
  }
  return self;
}

-(void)addPath:(UIBezierPath *)path
{
  [self.paths addObject:path];
  [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
  for(UIBezierPath *path in self.paths)
  {
    [path stroke];
  }
}

#pragma mark - Touch Handling

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  self.currentPath = [UIBezierPath bezierPath];
  self.currentPath.lineWidth = 5.f;
  [self.currentPath moveToPoint:[[touches anyObject] locationInView:self]];
  [self.paths addObject:self.currentPath];
  [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self.currentPath addLineToPoint:[[touches anyObject] locationInView:self]];
  [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self.currentPath addLineToPoint:[[touches anyObject] locationInView:self]];
  [self.delegate drawingView:self didAddPath:self.currentPath];
  [self setNeedsDisplay];
}

@end
