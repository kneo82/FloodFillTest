//
//  FFVector.m
//  FloodFill
//
//  Created by Vitaliy Voronok on 2/28/16.
//  Copyright © 2016 Vitaliy Voronok. All rights reserved.
//

#import "FFVectorPoints.h"

#include <vector>

static const size_t kFFReserveSize    = 5000000;

@interface FFVectorPoints () {
    std::vector<CGPoint> points;
}

@end

@implementation FFVectorPoints

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    points.clear();
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        points.reserve(kFFReserveSize);
    }
    
    return self;
}

#pragma mark -
#pragma mark Public

- (BOOL)pushPoint:(CGPoint)point {
    unsigned long max = points.capacity();
    unsigned long size = points.size();
    
    if (size >= max) {
        return NO;
    }
    
    points.push_back(point);
    return YES;
}

- (CGPoint)popPoint {
    if (points.empty()) {
        return CGPointZero;
    }
    
    auto point = points.back();
    
    points.pop_back();
    
    return point;
}

- (BOOL)isEmpty {
    return points.empty();
}

@end
