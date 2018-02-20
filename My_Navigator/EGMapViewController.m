//
//  EGMapViewController.m
//  My_Navigator
//
//  Created by Евгений Гостев on 03.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGMapViewController.h"
#import "EGServerManager.h"
#import "EGRouteInformation.h"
#import "EGFetcherSampleViewController.h"

@interface EGMapViewController () <CLLocationManagerDelegate, EGFetcherSampleViewControllerDelegate>

@end


@implementation EGMapViewController {
    GMSCameraPosition* _position;
    NSMutableArray* _routeInformationArray;
    GMSMutablePath* _path;
    CLLocationCoordinate2D _originLocation;
    CLLocationCoordinate2D _destinationLocation;
    GMSMarker* _originMarker;
    GMSMarker* _destinationMarker;
    GMSPolyline* _polyline;
    EGServerManager* _serverManager;
    NSString* _distance;
    NSString* _duration;
    NSString* _nameLocation;
    
    UIPopoverPresentationController* _popover;
    
    BOOL _isMyLocationEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.informationView setHidden:YES];

    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.mapView.myLocationEnabled = YES;
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.settings.compassButton = YES;
    self.mapView.delegate = self;

    _serverManager = [EGServerManager sharedManager];
    _path = [GMSMutablePath path];
    
    _originMarker = [[GMSMarker alloc] init];
    _destinationMarker = [[GMSMarker alloc] init];
}


#pragma mark - Metods

- (void) getRouteDataFromServerAndTheRoute {
    [_serverManager getRouteWithOffset:[_routeInformationArray count]
                origin:_originLocation
           destination:_destinationLocation
             onSuccess:^(NSArray *routeInformationsArray) {
                 if (!routeInformationsArray) {
                     [self showSimpleAlertOfTheRouteCannotBeBuilt];
                 } else {
                     for (EGRouteInformation* routeInformation in routeInformationsArray) {
                         _distance = routeInformation.distanceText;
                         _duration = routeInformation.durationText;
                         _path = routeInformation.path;
                     }
                     GMSPolyline *polyline = [GMSPolyline polylineWithPath:_path];
                     polyline.strokeColor = [UIColor greenColor];
                     polyline.strokeWidth = 5.f;
                     _polyline = polyline;
                     _polyline.map = self.mapView;
                     
                     self.nameRouteLabel.text = _nameLocation;
                     self.distanceRouteLabel.text = [NSString stringWithFormat:@"Расстояние: %@", _distance];
                     self.durationRouteLabel.text = [NSString stringWithFormat:@"Время: %@", _duration];
                     [self.informationView setHidden:NO];
                 }
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
             }];
}

- (void) showSimpleAlertOfTheRouteCannotBeBuilt {
    NSString* message = @"Маршрут невозможно построить:(";

    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Отмена"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) showSimpleAlertAddRoute {
    NSString* message = @"Построить маршрут?";
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"ОК"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self getRouteDataFromServerAndTheRoute];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Отмена"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Actions

- (IBAction)actionScaling:(UIButton *)sender {
    CGFloat zoom = _position.zoom;
    if (sender.tag == 1) {
        zoom -= 1.0;
    } else {
        zoom += 1.0;
    }
    [self.mapView animateToZoom:zoom];
}

- (IBAction)actionAddRoute:(UIButton *)sender {
    [self getRouteDataFromServerAndTheRoute];
    [self.view addSubview:self.informationView];
}

- (IBAction)actionCancelRoute:(UIButton *)sender {
    _polyline.map = nil;
    [self.informationView setHidden:YES];
}


#pragma mark - GoogleMap

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    _position = position;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.informationView setHidden:YES];
    [self.mapView clear];
    _destinationMarker= [GMSMarker markerWithPosition:coordinate];
    _destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    _destinationMarker.appearAnimation = kGMSMarkerAnimationPop;
    _destinationMarker.map = self.mapView;
    
    _nameLocation = nil;
    _destinationLocation = coordinate;
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_originLocation
                                                                       coordinate:_destinationLocation];
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0);
    GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:mapInsets];
    self.mapView.camera = camera;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:manager.location.coordinate zoom:12.0];
    self.mapView.camera = camera;
    self.mapView.settings.myLocationButton = YES;
    
    self.originLocationTextField.text = @"мое местоположение";
    _isMyLocationEnabled = YES;
    _originLocation = manager.location.coordinate;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.informationView setHidden:YES];
    _polyline.map = nil;
    
    EGFetcherSampleViewController* fetcherSampleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EGFetcherSampleViewController"];
    
    fetcherSampleVC.preferredContentSize = CGSizeMake(400, 350);
    fetcherSampleVC.modalPresentationStyle = UIModalPresentationFormSheet;
    fetcherSampleVC.isMyLocationEnabled = _isMyLocationEnabled;
    
    if (textField.tag == 0) {
        _originMarker.map = nil;
        fetcherSampleVC.isSelectedOriginLocation = YES;
    } else if (textField.tag == 1) {
        _destinationMarker.map = nil;
        fetcherSampleVC.isSelectedOriginLocation = NO;
    }
    
    [self presentViewController:fetcherSampleVC animated:YES completion:nil];
    [fetcherSampleVC setDelegate:self];
    UIPopoverPresentationController* popoverController = [fetcherSampleVC popoverPresentationController];
    [popoverController setPermittedArrowDirections:UIPopoverArrowDirectionAny];
    
    _popover = popoverController;
    
    return NO;
}


#pragma mark - EGFetcherSampleViewControllerDelegate

- (void)autocompleteWithPlace:(GMSPlace *)place
                 nameLocation:(NSString *)name
  andIsSelectedOriginLocation:(BOOL)isSelectedOriginLocation {
    if ([name isEqualToString:@"мое местоположение"]) {
        CLLocationCoordinate2D coordinate = self.mapView.myLocation.coordinate;
        if (isSelectedOriginLocation) {
            _originLocation = coordinate;
            _originLocationTextField.text = @"мое местоположение";
        } else {
            _destinationLocation = coordinate;
            _destinationLocationTextField.text = @"мое местоположение";
        }
        
        if (_originLocation.latitude && _destinationLocation.latitude) {
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_originLocation
                                                                               coordinate:_destinationLocation];
            UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0);
            GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:mapInsets];
            self.mapView.camera = camera;
        } else {
            GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:place.coordinate zoom:15.0];
            self.mapView.camera = camera;
        }
        
        
    } else {
        [self addMarkerWithPlace:place
                    nameLocation:name
     andIsSelectedOriginLocation:isSelectedOriginLocation];
    }
}

- (void) addMarkerWithPlace:(GMSPlace *)place
               nameLocation:(NSString *)name
andIsSelectedOriginLocation:(BOOL)isSelectedOriginLocation {
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = name;
    marker.snippet = [[place.formattedAddress componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    
    if (isSelectedOriginLocation) {
        self.originLocationTextField.text = name;
        _originLocation = place.coordinate;
        marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        _originMarker = marker;
        _originMarker.map = self.mapView;
    } else {
        _nameLocation = name;
        self.destinationLocationTextField.text = name;
        _destinationLocation = place.coordinate;
        marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        _destinationMarker = marker;
        _destinationMarker.map = self.mapView;
    }
    
    if (_originLocation.latitude && _destinationLocation.latitude) {
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_originLocation
                                                                           coordinate:_destinationLocation];
        UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0);
        GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:mapInsets];
        self.mapView.camera = camera;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSimpleAlertAddRoute];
        });
        
    } else {
        GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:place.coordinate zoom:15.0];
        self.mapView.camera = camera;
    }
}

@end
