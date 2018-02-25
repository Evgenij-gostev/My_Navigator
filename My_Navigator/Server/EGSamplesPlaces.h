//
//  EGSamplesPlaces.h
//  My_Navigator
//
//  Created by Евгений Гостев on 24.02.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGSamplesPlaces : NSObject 

+ (EGSamplesPlaces*)sharedSamplesPlaces;

- (void)setRequest:(NSString*)request;
- (NSArray*)getSamplesPlaces;

@end
