//
//  CLLocation+EGCLLocationNoNullCoordinate.h
//  My_Navigator
//
//  Created by Евгений Гостев on 10.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (EGCheckCLLocationCoordinate2D)

+ (BOOL)EGCLLocationNoNullCoordinate:(CLLocationCoordinate2D)location;

@end
