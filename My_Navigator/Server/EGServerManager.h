//
//  EGServerManager.h
//  My_Navigator
//
//  Created by Евгений Гостев on 30.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>


@interface EGServerManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;

+ (EGServerManager*)sharedManager;

- (void)getRouteWithOrigin:(CLLocationCoordinate2D)origin
               destination:(CLLocationCoordinate2D)destination
                 onSuccess:(void(^)(NSArray* routeInformationsArray))success
                 onFailure:(void(^)(NSError* error, NSInteger state))failure;

- (void)getAddressForCoordinate:(CLLocationCoordinate2D)coordinate
                      onSuccess:(void(^)(NSString* address))success
                      onFailure:(void(^)(NSError* error, NSInteger state))failure;
@end
