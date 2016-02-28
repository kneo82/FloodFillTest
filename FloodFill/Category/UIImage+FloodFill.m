//
//  UIImage+FloodFill.m
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/27/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#import "UIImage+FloodFill.h"

#import "RGBAColor.h"
#import "FFVectorPoints.h"

typedef struct {
    NSUInteger bytesPerPixel;
    NSUInteger bytesPerRow;
    NSUInteger bitsPerComponent;
    CGBitmapInfo bitmapInfo;
} FFImageInfo;

FFImageInfo FFImageInfoMake(NSUInteger bytesPerPixel, NSUInteger bytesPerRow, NSUInteger bitsPerComponent, CGBitmapInfo bitmapInfo) {
    FFImageInfo info;
    info.bytesPerPixel = bytesPerPixel;
    info.bytesPerRow = bytesPerRow;
    info.bitsPerComponent = bitsPerComponent;
    info.bitmapInfo = bitmapInfo;
    
    return info;
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
//    FFVectorPoints *points = [FFVectorPoints new];
//    [points pushPoint:CGPointMake(10, 10)];
//    [points pushPoint:CGPointMake(20, 20)];
//    [points pushPoint:CGPointMake(30, 30)];
//    
//    NSLog(@"- 1 - %@", NSStringFromCGPoint([points popPoint]));
//    NSLog(@"- IsEmpty : %d", points.isEmpty);
//    NSLog(@"- 1 - %@", NSStringFromCGPoint([points popPoint]));
//    NSLog(@"- IsEmpty : %d", points.isEmpty);
//    NSLog(@"- 1 - %@", NSStringFromCGPoint([points popPoint]));
//    NSLog(@"- IsEmpty : %d", points.isEmpty);
//    NSLog(@"- 1 - %@", NSStringFromCGPoint([points popPoint]));
//    NSLog(@"- IsEmpty : %d", points.isEmpty);
    
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
    
    FFImageInfo info = FFImageInfoMake(bytesPerPixel, bytesPerRow, bitsPerComponent, bitmapInfo);
    
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
    
    RGBAColor oldColor = getColorCode(byteIndex, imageData);
    
    RGBAColor newColor = convertColorToRGBAColor(color, bitmapInfo);
    
    int x = roundf(point.x);
    int y = roundf(point.y);
    
    [self floodFill8StackWithPoint:CGPointMake(x, y) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];

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
           imageInfo:(FFImageInfo)info
{
    unsigned int byteIndex = (info.bytesPerRow * roundf(point.y)) + roundf(point.x) * info.bytesPerPixel;
    
    imageData[byteIndex + 0] = color.red;
    imageData[byteIndex + 1] = color.green;
    imageData[byteIndex + 2] = color.blue;
    imageData[byteIndex + 3] = color.alpha;

}

- (void)floodFill4WithPoint:(CGPoint)point
                   newColor:(RGBAColor)newColor
                   oldColor:(RGBAColor)oldColor
                  imageData:(unsigned char *)imageData
                  imageInfo:(FFImageInfo)info
{
    NSInteger x = point.x;
    NSInteger y = point.y;
    
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    unsigned int byteIndex = (info.bytesPerRow * roundf(point.y)) + roundf(point.x) * info.bytesPerPixel;
    
    RGBAColor color = getColorCode(byteIndex, imageData);
    
    if(x >= 0
       && x < width
       && y >= 0
       && y < height
       && compareRGBAColor(color, oldColor, 1)
       && !compareRGBAColor(color, newColor, 1))
    {
        [self setRGBAColor:newColor toImageData:imageData forPoint:point imageInfo:info];
        
        [self floodFill4WithPoint:CGPointMake(x + 1, y) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x - 1, y) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x, y + 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x, y - 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
    }   
}

- (void)floodFill8WithPoint:(CGPoint)point
                   newColor:(RGBAColor)newColor
                   oldColor:(RGBAColor)oldColor
                  imageData:(unsigned char *)imageData
                  imageInfo:(FFImageInfo)info
{
    NSInteger x = point.x;
    NSInteger y = point.y;
    
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    unsigned int byteIndex = (info.bytesPerRow * roundf(point.y)) + roundf(point.x) * info.bytesPerPixel;
    
    RGBAColor color = getColorCode(byteIndex, imageData);
    
    if(x >= 0
       && x < width
       && y >= 0
       && y < height
       && compareRGBAColor(color, oldColor, 1)
       && !compareRGBAColor(color, newColor, 1))
    {
        [self setRGBAColor:newColor toImageData:imageData forPoint:point imageInfo:info];
        
        [self floodFill4WithPoint:CGPointMake(x + 1, y) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x - 1, y) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x, y + 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x, y - 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        
        [self floodFill4WithPoint:CGPointMake(x + 1, y + 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x + 1, y - 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x - 1, y + 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
        [self floodFill4WithPoint:CGPointMake(x - 1, y - 1) newColor:newColor oldColor:oldColor imageData:imageData imageInfo:info];
    }
}

- (void)floodFill4StackWithPoint:(CGPoint)point
                        newColor:(RGBAColor)newColor
                        oldColor:(RGBAColor)oldColor
                       imageData:(unsigned char *)imageData
                       imageInfo:(FFImageInfo)info
{
    if (compareRGBAColor(newColor, oldColor, 0)) {
        return;
    }
    
    FFVectorPoints *points = [FFVectorPoints new];
    
    static const int dx[4] = {0, 1, 0, -1}; // relative neighbor x coordinates
    static const int dy[4] = {-1, 0, 1, 0}; // relative neighbor y coordinates
    
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if (![points pushPoint:point]) {
        return;
    }
    
    while (!points.isEmpty) {
        CGPoint newPoint = points.popPoint;
        [self setRGBAColor:newColor toImageData:imageData forPoint:newPoint imageInfo:info];
        
        for (int i = 0; i < 4; i++) {
            int nx = newPoint.x + dx[i];
            int ny = newPoint.y + dy[i];
            
            unsigned int byteIndex = (info.bytesPerRow * roundf(ny)) + roundf(nx) * info.bytesPerPixel;
            
            RGBAColor color = getColorCode(byteIndex, imageData);
            
            if(nx > 0 && nx < width && ny > 0 && ny < height && compareRGBAColor(color, oldColor, 0)) {
                if(![points pushPoint:CGPointMake(nx, ny)]) {
                    return;
                }
            }
        }
    }
}

- (void)floodFill8StackWithPoint:(CGPoint)point
                        newColor:(RGBAColor)newColor
                        oldColor:(RGBAColor)oldColor
                       imageData:(unsigned char *)imageData
                       imageInfo:(FFImageInfo)info
{
    if (compareRGBAColor(newColor, oldColor, 0)) {
        return;
    }
    
    FFVectorPoints *points = [FFVectorPoints new];
    
    static const int dx[8] = {0, 1, 1, 1, 0, -1, -1, -1}; // relative neighbor x coordinates
    static const int dy[8] = {-1, -1, 0, 1, 1, 1, 0, -1}; // relative neighbor y coordinates
    
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if (![points pushPoint:point]) {
        return;
    }
    
    while (!points.isEmpty) {
        CGPoint newPoint = points.popPoint;
        [self setRGBAColor:newColor toImageData:imageData forPoint:newPoint imageInfo:info];
        
        for (int i = 0; i < 8; i++) {
            int nx = newPoint.x + dx[i];
            int ny = newPoint.y + dy[i];
            
            unsigned int byteIndex = (info.bytesPerRow * roundf(ny)) + roundf(nx) * info.bytesPerPixel;
            
            RGBAColor color = getColorCode(byteIndex, imageData);
            
            if(nx > 0 && nx < width && ny > 0 && ny < height && compareRGBAColor(color, oldColor, 0)) {
                if(![points pushPoint:CGPointMake(nx, ny)]) {
                    return;
                }
            }
        }
    }
}

- (void)floodFillScanlineStackWithPoint:(CGPoint)point
                               newColor:(RGBAColor)newColor
                               oldColor:(RGBAColor)oldColor
                              imageData:(unsigned char *)imageData
                              imageInfo:(FFImageInfo)info
{
    NSInteger x = point.x;
    NSInteger y = point.y;
    
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    unsigned int byteIndex = (info.bytesPerRow * roundf(point.y)) + roundf(point.x) * info.bytesPerPixel;
    
    RGBAColor color = getColorCode(byteIndex, imageData);
}

- (void)floodFillScanlineWithPoint:(CGPoint)point
                          newColor:(RGBAColor)newColor
                          oldColor:(RGBAColor)oldColor
                         imageData:(unsigned char *)imageData
                         imageInfo:(FFImageInfo)info
{
    NSInteger x = point.x;
    NSInteger y = point.y;
    
    CGSize size = self.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    unsigned int byteIndex = (info.bytesPerRow * roundf(point.y)) + roundf(point.x) * info.bytesPerPixel;
    
    RGBAColor color = getColorCode(byteIndex, imageData);
}

@end
