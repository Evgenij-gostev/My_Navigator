//
//  EGPolyline.m
//  My_Navigator
//
//  Created by Евгений Гостев on 08.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGRouteData.h"
#import "EGServerManager.h"
#import "EGRouteInformation.h"

@implementation EGRouteData {
    GMSPolyline* _polyline;
    NSString* _distance;
    NSString* _duration;
    NSString* _messageError;
}

- (instancetype)initWithOrigin:(CLLocationCoordinate2D)originLocation destination:(CLLocationCoordinate2D)destinationLocation {
    self = [super init];
    if (self) {
        [self routeDataFromServerAndTheRouteWithOrigin:originLocation
                                           destination:destinationLocation];
    }
    return self;
}

#pragma mark - Private Metods

- (void)routeDataFromServerAndTheRouteWithOrigin:(CLLocationCoordinate2D)originLocation
                                     destination:(CLLocationCoordinate2D)destinationLocation {
    [[EGServerManager sharedManager]
     getRouteWithOrigin:originLocation
     destination:destinationLocation
     onSuccess:^(NSArray *routeInformationsArray) {
         if (!routeInformationsArray) {
             _messageError = @"Маршрут невозможно построить:(";
         } else {
             GMSMutablePath* path;
             for (EGRouteInformation* routeInformation in routeInformationsArray) {
                 _distance = routeInformation.distanceText;
                 _duration = routeInformation.durationText;
                 path = routeInformation.path;
             }
             [self createPolylineFromPath:path];
         }
     }
     onFailure:^(NSError *error, NSInteger state) {
         _messageError = [NSString stringWithFormat:@"error = %@, code = %ld", [error localizedDescription], state];
     }];
}

- (void)createPolylineFromPath:(GMSMutablePath*)path {
    _polyline = [GMSPolyline polylineWithPath:path];
    _polyline.strokeColor = [UIColor orangeColor];
    _polyline.strokeWidth = 5.f;
    
    [self.delegate getRouteDataWithPolyline:_polyline
                                   distance:_distance
                                   duration:_duration
                               messageError:_messageError];
}

@end
