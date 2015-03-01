//
//  LinearInterpView.m
//  FreehandDrawing
//
//  Created by Anton Bakulev on 08.02.15.
//  Copyright (c) 2015 Anton Bakulev. All rights reserved.
//

#import "LinearInterpView.h"
#import "LineObject.h"
//struct CGLine
//{
//    CGPoint a;
//    CGPoint b;
//};
//typedef struct CGLine CGLine;

@implementation LinearInterpView
{
    NSMutableSet *lines; // Set of lines on screen to read.
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
        
        // Set of lines on screen to read.
        CGLine *l1 = [[CGLine alloc] init]; l1.a = CGPointMake(100,200); l1.b = CGPointMake(400,200);
        CGLine *l2 = [[CGLine alloc] init]; l2.a = CGPointMake(600,200); l2.b = CGPointMake(1100,200);
        CGLine *l3 = [[CGLine alloc] init]; l3.a = CGPointMake(30,350); l3.b = CGPointMake(100,350);
        CGLine *l4 = [[CGLine alloc] init]; l4.a = CGPointMake(300,350); l4.b = CGPointMake(600,350);
        CGLine *l5 = [[CGLine alloc] init]; l5.a = CGPointMake(30,500); l5.b = CGPointMake(100,500);
        CGLine *l6 = [[CGLine alloc] init]; l6.a = CGPointMake(300,500); l6.b = CGPointMake(600,500);
        CGLine *l7 = [[CGLine alloc] init]; l7.a = CGPointMake(0,650); l7.b = CGPointMake(300,650);
        CGLine *l8 = [[CGLine alloc] init]; l8.a = CGPointMake(500,650); l8.b = CGPointMake(700,650);
        lines = [NSMutableSet setWithObjects: l1, l2, l3, l4, l5, l6, l7, l8, nil];
        
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
    // Draw region to switch
    [[UIColor blackColor] setStroke];
    CGRect r = CGRectMake(0,450,200,300);
    UIBezierPath* p = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(r,10,10) cornerRadius:10];
    [p stroke];
    CGPoint c = CGPointMake(r.origin.x + r.size.width / 2.0, r.origin.y + 1.0 * r.size.height / 4.0);
    p = [UIBezierPath bezierPath];
    [p moveToPoint:CGPointMake(c.x-60, c.y-50)];
    [p addLineToPoint:CGPointMake(c.x-60, c.y+50)];
    [p addLineToPoint:CGPointMake(c.x+60, c.y+50)];
    [p addLineToPoint:CGPointMake(c.x+60, c.y-50)];
    [p closePath];
    [p fill];
    c = CGPointMake(r.origin.x + r.size.width / 2.0, r.origin.y + 3.0 * r.size.height / 4.0);
    p = [UIBezierPath bezierPath];
    [p moveToPoint:CGPointMake(c.x-60, c.y-50)];
    [p addLineToPoint:CGPointMake(c.x-60, c.y+50)];
    [p addLineToPoint:CGPointMake(c.x+60, c.y+50)];
    [p addLineToPoint:CGPointMake(c.x+60, c.y-50)];
    [p closePath];
    //[p fill];
    [p stroke];
    
    // Draw lines to read
    [[UIColor blackColor] setStroke];
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 50; //IS_IPAD? 8: 4;
    path.lineCapStyle = kCGLineCapRound;
    for (CGLine *line in lines) {
        [path moveToPoint: line.a];
        [path addLineToPoint: line.b];
    }
    [path stroke];
    
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
    //AudioServicesPlaySystemSound();
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); // Vibrates or beeps.
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // Vibrate or silent if no vibrate.
    AudioServicesPlayAlertSound(1105); // play the less annoying tick noise
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