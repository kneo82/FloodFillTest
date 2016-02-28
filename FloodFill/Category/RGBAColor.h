//
//  RGBAColor.h
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/28/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#ifndef RGBAColor_h
#define RGBAColor_h

typedef struct {
    unsigned int red;
    unsigned int green;
    unsigned int blue;
    unsigned int alpha;
} RGBAColor;

BOOL compareRGBAColor(RGBAColor color1, RGBAColor color2, NSInteger tolerance) {
    int red1   = color1.red;
    int green1 = color1.green;
    int blue1  = color1.blue;
    int alpha1 =  color1.alpha;
    
    int red2   = color2.red;
    int green2 = color2.green;
    int blue2  = color2.blue;
    int alpha2 =  color2.alpha;
    
    if (red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2) {
        return YES;
    }
    
    int diffRed   = abs(red2   - red1);
    int diffGreen = abs(green2 - green1);
    int diffBlue  = abs(blue2  - blue1);
    int diffAlpha = abs(alpha2 - alpha1);
    
    if(diffRed   > tolerance || diffGreen > tolerance || diffBlue  > tolerance || diffAlpha > tolerance) {
        return NO;
    }
    
    return YES;
}

RGBAColor RGBAColorMake(unsigned int red, unsigned int green, unsigned int blue, unsigned int alpha) {
    RGBAColor color;
    color.red = red;
    color.blue = blue;
    color.green = green;
    color.alpha = alpha;
    
    return color;
}

#endif /* RGBAColor_h */
