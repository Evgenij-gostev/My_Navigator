//
//  EGFetcherSampleViewController.h
//  My_Navigator
//
//  Created by Евгений Гостев on 15.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class GMSMarker;


typedef enum {
    EGOriginLocationType,
    EGDestinationLocationType
} EGLocationType;


@protocol EGFetcherSampleViewControllerDelegate <NSObject>

- (void)autocompleteWithMarker:(GMSMarker*)marker andLocationType:(EGLocationType)locationType;

@end

    
@interface EGFetcherSampleViewController : UIViewController

@property (assign, nonatomic) BOOL isMyLocationEnabled;
@property (assign, nonatomic) CLLocationCoordinate2D myLocation;
@property (assign, nonatomic) EGLocationType locationType;
@property (weak, nonatomic) id <EGFetcherSampleViewControllerDelegate> delegate;

@end
