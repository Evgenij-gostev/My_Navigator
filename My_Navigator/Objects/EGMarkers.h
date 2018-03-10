//
//  EGMarker.h
//  My_Navigator
//
//  Created by Евгений Гостев on 08.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GMSPlace;
@class GMSMarker;


@interface EGMarkers : NSObject

- (instancetype)initWithPlace:(GMSPlace *)place andMyLocation:(CLLocationCoordinate2D)myLocation;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (GMSMarker*)marker;

@end
