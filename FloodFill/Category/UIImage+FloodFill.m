//
//  UIImage+FloodFill.m
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/27/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#import "UIImage+FloodFill.h"

typedef struct {
    unsigned int red;
    unsigned int green;
    unsigned int blue;
    unsigned int alpha;
} RGBAColor;

RGBAColor RGBAColorMake(unsigned int red, unsigned int green, unsigned int blue, unsigned int alpha) {
    RGBAColor color;
    color.red = red;
    color.blue = blue;
    color.green = green;
    color.alpha = alpha;
    
    return color;
}

RGBAColor getColorCode (unsigned int byteIndex, unsigned char *imageData) {
    unsigned int red   = imageData[byteIndex];
    unsigned int green = imageData[byteIndex + 1];
    unsigned int blue  = imageData[byteIndex + 2];
    unsigned int alpha = imageData[byteIndex + 3];
    
    return RGBAColorMake(red, green, blue, alpha);
}

RGBAColor convertColorToRGBAColor(UIColor *newColor, CGBitmapInfo bitmapInfo) {
    int newRed = 0, newGreen = 0, newBlue = 0, newAlpha = 0;
    
    const CGFloat *components = CGColorGetComponents(newColor.CGColor);
    
    if(CGColorGetNumberOfComponents(newColor.CGColor) == 2) {
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    } else if (CGColorGetNumberOfComponents(newColor.CGColor) == 4) {
        if ((bitmapInfo&kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little) {
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        } else {
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }
    
    return RGBAColorMake(newRed, newGreen, newBlue, newAlpha);
}

@implementation UIImage (FloodFill)

- (UIImage *)floodFillFromPoint:(CGPoint)point color:(UIColor *)color {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = [self CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    unsigned char *imageData = malloc(height * width * 4);
    
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / 8;
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    if (kCGImageAlphaLast == (uint32_t)bitmapInfo || kCGImageAlphaFirst == (uint32_t)bitmapInfo) {
        bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
    }
    
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    unsigned int byteIndex = (bytesPerRow * roundf(point.y)) + roundf(point.x) * bytesPerPixel;
    
    RGBAColor ocolor = getColorCode(byteIndex, imageData);
    
    RGBAColor newColor = convertColorToRGBAColor(color, bitmapInfo);
    
    int x = roundf(point.x);
    int y = roundf(point.y);
    
    [self setRGBAColor:newColor toImageData:imageData forPoint:CGPointMake(x, y) withBytesPerRow:bytesPerRow bytesPerPixel:bytesPerPixel];

    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *result = [UIImage imageWithCGImage:newCGImage scale:[self scale] orientation:UIImageOrientationUp];
    
    CGImageRelease(newCGImage);
    
    CGContextRelease(context);
    
    free(imageData);
    
    return result;
}

- (void)setRGBAColor:(RGBAColor)color
         toImageData:(unsigned char *)imageData
            forPoint:(CGPoint)point
     withBytesPerRow:(NSUInteger)bytesPerRow
       bytesPerPixel:(NSUInteger)bytesPerPixel
{
    unsigned int byteIndex = (bytesPerRow * roundf(point.y)) + roundf(point.x) * bytesPerPixel;
    
    imageData[byteIndex + 0] = color.red;
    imageData[byteIndex + 1] = color.green;
    imageData[byteIndex + 2] = color.blue;
    imageData[byteIndex + 3] = color.alpha;

}

@end
