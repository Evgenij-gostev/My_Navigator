//
//  EGMapViewController.h
//  My_Navigator
//
//  Created by Евгений Гостев on 03.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "EGFetcherSampleViewController.h"

@class CLLocationManager;
@class GMSMapView;

@interface EGMapViewController : UIViewController <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *originLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationLocationTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameRouteLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceRouteLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationRouteLabel;

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) GMSPlace *place;

- (IBAction)actionScaling:(UIButton *)sender;
- (IBAction)actionAddRoute:(UIButton *)sender;
- (IBAction)actionCancelRoute:(UIButton *)sender;


@end
