//
//  EGMarker.m
//  My_Navigator
//
//  Created by Евгений Гостев on 08.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGMarkers.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "EGServerManager.h"


@implementation EGMarkers {
    GMSMarker* _marker;
}

- (instancetype)initWithPlace:(GMSPlace *)place andMyLocation:(CLLocationCoordinate2D)myLocation {
    self = [super init];
    if (self) {
        [self _createMarkerFromPlace:place andMyLocation:myLocation];
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        [self _createMarkerFromCoordinate:coordinate];
    }
    return self;
}

- (GMSMarker*)marker {
    return _marker;
}

#pragma mark - Private Metods

- (void)_createMarkerFromPlace:(GMSPlace *)place
                 andMyLocation:(CLLocationCoordinate2D)myLocation {
    if (!place && myLocation.latitude != 0) {
        _marker = [GMSMarker markerWithPosition:myLocation];
        _marker.snippet = @"Мое местоположение";
    } else {
        _marker = [GMSMarker markerWithPosition:place.coordinate];
        _marker.snippet = [[place.formattedAddress componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
    }
}

- (void)_createMarkerFromCoordinate:(CLLocationCoordinate2D)coordinate {
    _marker = [GMSMarker markerWithPosition:coordinate];
    [[EGServerManager sharedManager]
     getAddressForCoordinate:coordinate
     onSuccess:^(NSString *address) {
         _marker.snippet = address;
     }
     onFailure:^(NSError *error, NSInteger state) {
         NSString* messageError = [NSString stringWithFormat:@"error = %@, code = %ld", [error localizedDescription], state];
         NSLog(@"ERROR: %@", messageError);
     }];
}

@end
