//
//  EGRouteInformation.h
//  My_Navigator
//
//  Created by Евгений Гостев on 31.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMSMutablePath;


@interface EGRouteInformation : NSObject

@property (strong, nonatomic, readonly) NSString* durationText;
@property (strong, nonatomic, readonly) NSString* distanceText;
@property (strong, nonatomic, readonly) GMSMutablePath* path;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (id) initWithServerResponse:(NSDictionary*) responseObject;

@end
