//
//  EGRouteInformation.m
//  My_Navigator
//
//  Created by Евгений Гостев on 31.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGRouteInformation.h"
#import <GoogleMaps/GoogleMaps.h>


@implementation EGRouteInformation

- (id)initWithServerResponse:(NSDictionary*) responseObject {
    self = [super init];
    if (self) {
        
        _distanceText = responseObject[@"distance"][@"text"];
        _durationText = responseObject[@"duration"][@"text"];

        _path = [GMSMutablePath path];
        NSArray* dictsArray = responseObject[@"steps"];
        for (NSDictionary* dict in dictsArray) {
            NSString* points = dict[@"polyline"][@"points"];
            GMSPath *polyLinePath = [GMSPath pathFromEncodedPath:points];

            for (int i = 0; i < polyLinePath.count; i++) {
                [self.path addCoordinate:[polyLinePath coordinateAtIndex:i]];
            }
        }
    }
    return self;
}

@end
