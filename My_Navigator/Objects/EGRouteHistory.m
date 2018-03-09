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
    self.originLocationLatitude = marker.position.latitude;
    self.originLocationLongitude = marker.position.longitude;
    self.originSnippet = marker.snippet;
}

- (GMSMarker*)getOriginMarker {
    GMSMarker *marker =
    [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.originLocationLatitude, self.originLocationLongitude)];
    marker.snippet = self.originSnippet;
    return marker;
}

#pragma mark - Destination Marker

- (void)setDestinationMarker:(GMSMarker*)marker {
    self.destinationLocationLatitude = marker.position.latitude;
    self.destinationLocationLongitude = marker.position.longitude;
    self.destinationSnippet = marker.snippet;
}

- (GMSMarker*)getDestinationMarker {
    GMSMarker *marker =
    [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(self.destinationLocationLatitude, self.destinationLocationLongitude)];
    marker.snippet = self.destinationSnippet;
    return marker;
}

@end
