//
//  ViewController.h
//  My_Navigator
//
//  Created by Евгений Гостев on 28.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>


@interface ViewController : UIViewController <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) CLLocationManager* locationManager;


- (IBAction)actionAdd:(UIBarButtonItem *)sender;
- (IBAction)actionScaling:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *attributionsLabel;


@end

