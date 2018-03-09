//
//  EGServerManager.m
//  My_Navigator
//
//  Created by Евгений Гостев on 30.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "AppDelegate.h"
#import "EGServerManager.h"
#import "AFNetworking.h"
#import "EGRouteInformation.h"


@interface EGServerManager ()

@property (strong, nonatomic) AFHTTPSessionManager* sessionManager;

@end


@implementation EGServerManager

+ (EGServerManager*)sharedManager {
    static EGServerManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EGServerManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL* url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/"];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    return self;
}

- (void)getRouteWithOrigin:(CLLocationCoordinate2D)origin
               destination:(CLLocationCoordinate2D)destination
                 onSuccess:(void(^)(NSArray* routeInformationsArray))success
                 onFailure:(void(^)(NSError* error, NSInteger state))failure {
    
    NSString* originCoordinate = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString* destinationCoordinate = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     originCoordinate,                              @"origin",
     destinationCoordinate,                         @"destination",
     @"driving",                                    @"mode",
     @"now",                                        @"departure_time",
     @"pessimistic",                                @"traffic_model",
     @"AIzaSyDbPMpz5YN6DbntQcX6XN3mwSee-HeRHIQ",    @"key", nil];
    
    [self.sessionManager
                 GET:@"directions/json"
          parameters:params
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 if (![[responseObject objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
                     NSArray* dictsArray = [responseObject[@"routes"] firstObject][@"legs"];
                     
                     NSMutableArray* objectsArray = [NSMutableArray array];
                     for (NSDictionary* dict in dictsArray) {
                         EGRouteInformation* routeInformation = [[EGRouteInformation alloc] initWithServerResponse:dict];
                         [objectsArray addObject:routeInformation];
                     }
                     
                     if (success) {
                         success(objectsArray);
                     }
                 } else {
                     success(nil);
                 }
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 if (failure) {
                     failure(error, task.state);
                 }
             }];
}

- (void)getAddressForCoordinate:(CLLocationCoordinate2D)coordinate
                      onSuccess:(void(^)(NSString* address))success
                      onFailure:(void(^)(NSError* error, NSInteger state))failure {
    
    NSString* coordinateStr = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    
    NSDictionary* params =
    [NSDictionary dictionaryWithObjectsAndKeys:
     coordinateStr,                                 @"latlng",
     @"AIzaSyAuzyI7se6hI1jNVS_V-RRZlVEW3AXZNsE",    @"key", nil];
    
    [self.sessionManager
                 GET:@"geocode/json"
                 parameters:params
                 progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                     NSString* address = [responseObject[@"results"] firstObject][@"formatted_address"];
                         if (success) {
                             success(address);
                         }
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     if (failure) {
                         failure(error, task.state);
                     }
                 }];
}

@end
