//
//  EGRouteInformation.m
//  My_Navigator
//
//  Created by Евгений Гостев on 31.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGRouteInformation.h"


@implementation EGRouteInformation

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    self = [super init];
    if (self) {
        
// Дистанция
//        self.distance = [[[responseObject objectForKey:@"distance"] objectForKey:@"value"] integerValue];
//        NSLog(@"distance: %ld м", self.distance);
        self.distanceText = [[responseObject objectForKey:@"distance"] objectForKey:@"text"];
//        NSLog(@"distance: %@", self.distanceText);
        
        
// Продолжительность
//        self.duration = [[[responseObject objectForKey:@"duration"] objectForKey:@"value"] integerValue];
//        NSLog(@"duration: %ld сек", self.duration);
        self.durationText = [[responseObject objectForKey:@"duration"] objectForKey:@"text"];
//        NSLog(@"duration: %@", self.durationText);
        
        
// Путь (маршрут)
        self.path = [GMSMutablePath path];
        NSArray* dictsArray = [responseObject objectForKey:@"steps"];
        for (NSDictionary* dict in dictsArray) {
            NSString* points = [[dict objectForKey:@"polyline"] objectForKey:@"points"];
            GMSPath *polyLinePath = [GMSPath pathFromEncodedPath:points];
//            NSLog(@"points: %@", points);
            for (int i = 0; i < polyLinePath.count; i++) {
                [self.path addCoordinate:[polyLinePath coordinateAtIndex:i]];
            }
        }
    }
    return self;
}

@end
