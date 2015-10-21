//
//  Bubble.m
//  
//
//  Created by Cass Pangell on 7/6/15.
//
//

#import "Bubble.h"

@implementation Bubble

- (id)initWithFrame:(CGRect)frame andDiameter:(double)dmeter andLineWidth:(double)lWidth andColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        diameter = dmeter;
        lineWidth = lWidth;
        colorRef = color;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    const float* colors = CGColorGetComponents(colorRef.CGColor);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetRGBFillColor(contextRef, colors[0], colors[1], colors[2], colors[3]);
    CGRect circlePoint = (CGRectMake(0, 0, diameter, diameter));
    CGContextFillEllipseInRect(contextRef, circlePoint);
    
}

@end
