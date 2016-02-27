//
//  ViewController.m
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/27/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#import "ViewController.h"

#import "FFView.h"

#import "IDPPropertyMacros.h"

@interface ViewController ()
@property (nonatomic, readonly) FFView  *rootView;
@property (nonatomic, strong)   UIImage *originalImage;
@property (nonatomic, strong)   UIImage *fillImage;

@end

@implementation ViewController

#pragma mark -
#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"3457.gif"];
    self.rootView.imageView.image = image;
    self.originalImage = image;
}

#pragma mark -
#pragma mark Accessors

IDPViewControllerViewOfClassGetterSynthesize(FFView, rootView);

- (void)setFillImage:(UIImage *)fillImage {
    if (_fillImage != fillImage) {
        _fillImage = fillImage;
        self.rootView.imageView.image = fillImage;
    }
}

#pragma mark -
#pragma mark User Handler

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInView:self.rootView.imageView];
    
    CGPoint point = [self pointInImageFromImageViewPoint:touchLocation];
    
    UIImage *image = [self drawPoint:point];
    self.fillImage = image;
}

#pragma mark -
#pragma mark Private

- (CGPoint)pointInImageFromImageViewPoint:(CGPoint)point {
    UIImage *image = self.originalImage;
    CGSize imageSize = image.size;
    
    CGSize imageViewSize = self.rootView.imageView.bounds.size;
    
    CGFloat deltaX = imageSize.width / imageViewSize.width;
    CGFloat deltaY = imageSize.height / imageViewSize.height;
    
    return CGPointMake(point.x * deltaX, point.y * deltaY);
}

- (UIImage *)imageByDrawingCircleByPoint:(CGPoint)point {
    UIImage *image = self.fillImage ? : self.originalImage;
    
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // set stroking color and draw circle
    [[UIColor redColor] setStroke];
    
    // make circle rect 5 px from border
    CGRect circleRect = CGRectMake(point.x-1,
                                   point.y-1,
                                   2,
                                   2);

    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path stroke];
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}

- (UIImage *)drawPoint:(CGPoint)point {
    UIColor *newColor = [UIColor redColor];
    UIImage *image = self.fillImage ? : self.originalImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = [image CGImage];
    
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
    
    //Get color at start point
    unsigned int byteIndex = (bytesPerRow * roundf(point.y)) + roundf(point.x) * bytesPerPixel;
    
    unsigned int ocolor = getColorCode(byteIndex, imageData);
    
    int newRed, newGreen, newBlue, newAlpha;
    
    const CGFloat *components = CGColorGetComponents(newColor.CGColor);
    
    if(CGColorGetNumberOfComponents(newColor.CGColor) == 2)
    {
        newRed   = newGreen = newBlue = components[0] * 255;
        newAlpha = components[1] * 255;
    }
    else if (CGColorGetNumberOfComponents(newColor.CGColor) == 4)
    {
        if ((bitmapInfo&kCGBitmapByteOrderMask) == kCGBitmapByteOrder32Little)
        {
            newRed   = components[2] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[0] * 255;
            newAlpha = 255;
        }
        else
        {
            newRed   = components[0] * 255;
            newGreen = components[1] * 255;
            newBlue  = components[2] * 255;
            newAlpha = 255;
        }
    }

    unsigned int ncolor = (newRed << 24) | (newGreen << 16) | (newBlue << 8) | newAlpha;
    
    int x = roundf(point.x);
    int y = roundf(point.y);

    byteIndex = (bytesPerRow * roundf(y)) + roundf(x) * bytesPerPixel;
    
    imageData[byteIndex + 0] = newRed;
    imageData[byteIndex + 1] = newGreen;
    imageData[byteIndex + 2] = newBlue;
    imageData[byteIndex + 3] = newAlpha;

    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    UIImage *result = [UIImage imageWithCGImage:newCGImage scale:[image scale] orientation:UIImageOrientationUp];
    
    CGImageRelease(newCGImage);
    
    CGContextRelease(context);
    
    free(imageData);
    
    return result;
}

unsigned int getColorCode (unsigned int byteIndex, unsigned char *imageData)
{
    unsigned int red   = imageData[byteIndex];
    unsigned int green = imageData[byteIndex + 1];
    unsigned int blue  = imageData[byteIndex + 2];
    unsigned int alpha = imageData[byteIndex + 3];
    
    return (red << 24) | (green << 16) | (blue << 8) | alpha;
}

@end
