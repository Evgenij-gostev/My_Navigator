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

@property (strong, nonatomic) NSString* durationText;
@property (strong, nonatomic) NSString* distanceText;
@property (strong, nonatomic) GMSMutablePath* path;

- (id) initWithServerResponse:(NSDictionary*) responseObject;

@end
