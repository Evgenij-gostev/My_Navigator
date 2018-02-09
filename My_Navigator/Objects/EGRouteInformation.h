//
//  EGRouteInformation.h
//  My_Navigator
//
//  Created by Евгений Гостев on 31.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>



@interface EGRouteInformation : NSObject

//@property (assign, nonatomic) NSInteger duration;
@property (strong, nonatomic) NSString* durationText;
//@property (assign, nonatomic) NSInteger distance;
@property (strong, nonatomic) NSString* distanceText;
@property (strong, nonatomic) GMSMutablePath* path;


- (id) initWithServerResponse:(NSDictionary*) responseObject;


@end
