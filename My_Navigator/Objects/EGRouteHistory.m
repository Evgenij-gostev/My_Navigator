//
//  EGRouteHistory.m
//  My_Navigator
//
//  Created by Евгений Гостев on 03.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGRouteHistory.h"

@implementation EGRouteHistory

- (instancetype)init {
    self = [super init];
    if (self) {
        _date = [NSDate date];
    }
    return self;
}

#pragma mark - Origin Marker

- (void)setOriginMarker:(GMSMarker*)marker {
    _originLocationLatitude = marker.position.latitude;
    _originLocationLongitude = marker.position.longitude;
    _originSnippet = marker.snippet;
//    _originIcon = marker.icon;
}

- (GMSMarker*)getOriginMarker {
    GMSMarker *marker =
            [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.originLocationLatitude, self.originLocationLongitude)];
    marker.snippet = self.originSnippet;
//    marker.icon = _originIcon;
    return marker;
}

#pragma mark - Destination Marker

- (void)setDestinationMarker:(GMSMarker*)marker {
    _destinationLocationLatitude = marker.position.latitude;
    _destinationLocationLongitude = marker.position.longitude;
    _destinationSnippet = marker.snippet;
//    _destinationIcon = marker.icon;
}

- (GMSMarker*)getDestinationMarker {
    GMSMarker *marker =
    [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.destinationLocationLatitude, self.destinationLocationLongitude)];
    marker.snippet = self.destinationSnippet;
//    marker.icon = _destinationIcon;
    return marker;
}

@end
