//
//  EGRouteInformation.h
//  My_Navigator
//
//  Created by Евгений Гостев on 31.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGRouteInformation : NSObject

@property (strong, nonatomic) NSInteger* duration;
@property (strong, nonatomic) NSString* distance;
@property (strong, nonatomic) NSString* points;


- (id) initWithServerResponse:(NSDictionary*) responseObject;


@end
