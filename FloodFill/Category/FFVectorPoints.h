//
//  FFVector.h
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/28/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FFVectorPoints : NSObject
@property (nonatomic, readonly) BOOL isEmpty;

- (CGPoint)popPoint;
- (BOOL)pushPoint:(CGPoint)point;

@end
