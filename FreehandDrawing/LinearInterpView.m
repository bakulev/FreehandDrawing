//
//  LinearInterpView.m
//  FreehandDrawing
//
//  Created by Anton Bakulev on 08.02.15.
//  Copyright (c) 2015 Anton Bakulev. All rights reserved.
//

#import "LinearInterpView.h"

@implementation LinearInterpView
{
    NSMutableArray *strokes;
    NSMutableDictionary *touchPaths;
    //UIBezierPath *path; // (3)
}

- (id)initWithCoder:(NSCoder *)aDecoder // (1)
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:YES]; // (2)
        [self setBackgroundColor:[UIColor whiteColor]];
        strokes = [NSMutableArray array];
        touchPaths = [NSMutableDictionary dictionary];
        //path = [UIBezierPath bezierPath];
        //[path setLineWidth:10.0];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect // (5)
{
    // Draw existing strokes in dark purple, in-progress ones in light
    [[UIColor purpleColor] setStroke];
    for (UIBezierPath *path in strokes)
        [path stroke];
    
    //[[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.5f] set];
    [[UIColor yellowColor] setStroke];
    for (UIBezierPath *path in [touchPaths allValues])
        [path stroke];
    
    // Drawing code
    //[[UIColor blackColor] setStroke];
    //[path stroke];
}

// On clear remove all existing strokes, but not in-progress drawing
- (void) clear
{
    [strokes removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"began called touches: %lu; events: %lu.", (unsigned long)touches.count, (unsigned long)event.allTouches.count);
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        CGPoint pt = [touch locationInView:self];
        //NSLog(@"touch: %d; coord: (%f, %f).", (int)touch, pt.x, pt.y);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 10; //IS_IPAD? 8: 4;
        path.lineCapStyle = kCGLineCapRound;
        [path moveToPoint:pt];
        
        [touchPaths setObject:path forKey:key];
    }
    //UITouch *touch = [touches anyObject];
    //CGPoint p = [touch locationInView:self];
    //[path moveToPoint:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"moved called touches: %lu; events: %lu.", (unsigned long)touches.count, (unsigned long)event.allTouches.count);
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        CGPoint pt = [touch locationInView:self];
        //NSLog(@"touch: %d; coord: (%f, %f).", (int)touch, pt.x, pt.y);
        UIBezierPath *path = [touchPaths objectForKey:key];
        if (!path) break;
        [path addLineToPoint:pt];
    }
    //UITouch *touch = [touches anyObject];
    //CGPoint p = [touch locationInView:self];
    //[path addLineToPoint:p]; // (4)
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"ended called touches: %lu; events: %lu.", (unsigned long)touches.count, (unsigned long)event.allTouches.count);
    for (UITouch *touch in touches)
    {
        NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        //NSLog(@"touch: %d; coord: (%f, %f).", (int)touch, p.x, p.y);
        UIBezierPath *path = [touchPaths objectForKey:key];
        if (path) [strokes addObject:path];
        [touchPaths removeObjectForKey:key];
        
        //UITouch *touch = [touches anyObject];
        //CGPoint p = [touch locationInView:self];
        
    }
    [self touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"cancelled called touches: %lu; events: %lu.", (unsigned long)touches.count, (unsigned long)event.allTouches.count);
    for (UITouch *touch in touches)
    {
        //NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
        //UITouch *touch = [touches anyObject];
        //CGPoint p = [touch locationInView:self];
        //NSLog(@"touch: %d; coord: (%f, %f).", (int)touch, p.x, p.y);
    }

    [self touchesEnded:touches withEvent:event];
}
@end