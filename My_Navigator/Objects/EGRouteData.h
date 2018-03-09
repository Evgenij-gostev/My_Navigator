//
//  EGPolyline.h
//  My_Navigator
//
//  Created by Евгений Гостев on 08.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>


@protocol EGRouteDataDelegate <NSObject>

- (void)getRouteDataWithPolyline:(GMSPolyline*)polyline
                       distance:(NSString*)distance
                       duration:(NSString*)duration
                   messageError:(NSString*)messageError;

@end


@interface EGRouteData : NSObject

@property (weak, nonatomic) id <EGRouteDataDelegate> delegate;

- (instancetype)initWithOrigin:(CLLocationCoordinate2D)originLocation
                   destination:(CLLocationCoordinate2D)destinationLocation;

@end
