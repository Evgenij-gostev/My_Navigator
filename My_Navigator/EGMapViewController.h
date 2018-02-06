//
//  EGMapViewController.h
//  My_Navigator
//
//  Created by Евгений Гостев on 03.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface EGMapViewController : UIViewController <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager* locationManager;

- (IBAction)actionScaling:(UIButton *)sender;
- (IBAction)actionAddRoute:(UIBarButtonItem *)sender;
- (IBAction)actionSearchLocation:(UIBarButtonItem *)sender;
- (IBAction)actionCleanerMapView:(UIBarButtonItem *)sender;



@end
