//
//  Bubble.h
//  
//
//  Created by Cass Pangell on 7/6/15.
//
//

#import <UIKit/UIKit.h>

@interface Bubble : UIView
{
    CGRect rectangle;
    float diameter;
    float lineWidth;
    UIColor *colorRef;
}

- (id)initWithFrame:(CGRect)frame andDiameter:(double)dmeter andLineWidth:(double)lWidth andColor:(UIColor*)color;
@end
