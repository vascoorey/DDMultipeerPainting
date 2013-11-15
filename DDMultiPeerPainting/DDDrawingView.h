//
//  DDDrawingView.h
//  DDMultiPeerPainting
//
//  Created by Vasco d'Orey on 14/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDDrawingData.h"

@class DDDrawingView;
@protocol Drawing <NSObject>
-(void)drawingView:(DDDrawingView *)drawingView didDrawPoint:(CGPoint)point withState:(DDDrawingState)state;
@optional
-(void)drawingView:(DDDrawingView *)drawingView didAddPath:(UIBezierPath *)path;
@end

@interface DDDrawingView : UIView
@property (nonatomic, weak) id <Drawing> delegate;
-(void)addPath:(UIBezierPath *)path;
-(void)updatePathWithKey:(id)key state:(DDDrawingState)state point:(CGPoint)point;
-(void)updatePathWithKey:(id)key state:(DDDrawingState)state points:(NSArray *)points;
@end
