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

+ (EGServerManager*) sharedManager;

- (void) getRouteWithOffset:(NSInteger) offset
                     origin:(CLLocationCoordinate2D) origin
                destination:(CLLocationCoordinate2D) destination
                  onSuccess:(void(^)(NSArray* routeInformationsArray)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


//- (void) getGroupWall:(NSString*) groupID
//           withOffset:(NSInteger) offset
//                count:(NSInteger) count
//            onSuccess:(void(^)(NSArray* posts)) success
//            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


@end
