//
//  UIImage+FloodFill.h
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/27/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FloodFill)

- (UIImage *)floodFillFromPoint:(CGPoint)point color:(UIColor *)color;

@end
