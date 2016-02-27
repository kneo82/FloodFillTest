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

#import "UIImage+FloodFill.h"

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
    
    UIImage *image = [(self.fillImage ? : self.originalImage) floodFillFromPoint:point color:[UIColor blueColor]];
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

@end
