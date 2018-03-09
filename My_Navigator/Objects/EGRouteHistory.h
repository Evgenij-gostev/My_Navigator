//
//  EGRouteHistory.h
//  My_Navigator
//
//  Created by Евгений Гостев on 03.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"
#import <GoogleMaps/GoogleMaps.h>

@interface EGRouteHistory : RLMObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSDate* date;

// Origin Marker
@property (assign, nonatomic) double originLocationLatitude;
@property (assign, nonatomic) double originLocationLongitude;
@property (strong, nonatomic) NSString* originSnippet;
// Destination Marker
@property (assign, nonatomic) double destinationLocationLatitude;
@property (assign, nonatomic) double destinationLocationLongitude;
@property (strong, nonatomic) NSString* destinationSnippet;


- (void)setOriginMarker:(GMSMarker*)marker;

- (GMSMarker*)getOriginMarker;

- (void)setDestinationMarker:(GMSMarker*)marker;

- (GMSMarker*)getDestinationMarker;

@end
