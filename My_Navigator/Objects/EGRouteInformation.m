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
        
//        self.travelTime = [responseObject objectForKey:@"travelTime"];
//        self.distance = [responseObject objectForKey:@"distance"];
//        self.points = [[responseObject objectForKey:@"points"] stringValue];

//        NSArray* dictsArray = [[[[responseObject objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0];
        
        self.points = [[[responseObject objectForKey:@"steps"] objectForKey:@"polyline"] objectForKey:@"points"];
        NSLog(@"points: %@", self.points);
        
    }
    return self;
}

@end
