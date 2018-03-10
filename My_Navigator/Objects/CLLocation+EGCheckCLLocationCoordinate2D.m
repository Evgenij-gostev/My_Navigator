//
//  CLLocation+EGCLLocationNoNullCoordinate.m
//  My_Navigator
//
//  Created by Евгений Гостев on 10.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "CLLocation+EGCheckCLLocationCoordinate2D.h"

@implementation CLLocation (EGCheckCLLocationCoordinate2D)

+ (BOOL)EGCLLocationNoNullCoordinate:(CLLocationCoordinate2D)location {
    if (location.latitude != 0 && location.longitude != 0) {
        return YES;
    }
    return NO;
}

@end
