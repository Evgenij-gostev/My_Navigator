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

@import GooglePlaces;
@import GooglePlacePicker;

@interface EGMapViewController () <CLLocationManagerDelegate, GMSAutocompleteResultsViewControllerDelegate>

@property (strong, nonatomic) GMSCameraPosition* position;

@property (strong, nonatomic) NSMutableArray* routeInformationArray;
@property (strong, nonatomic) GMSMutablePath *path;
@property (assign, nonatomic) CLLocationCoordinate2D originLocation;
@property (assign, nonatomic) CLLocationCoordinate2D destinationLocation;
@property (strong, nonatomic) EGServerManager* serverManager;

@property (strong, nonatomic) GMSAutocompleteResultsViewController* resultsViewController;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) UIView *searchView;
@property (strong, nonatomic) GMSPolyline *polyline;
@property (strong, nonatomic) NSString* distance;
@property (strong, nonatomic) NSString* duration;
@property (strong, nonatomic) NSString* nameLocation;

@end



@implementation EGMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.mapView.myLocationEnabled = YES;
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    

    self.mapView.camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:0.1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:12.0];
        self.mapView.camera = camera;
        self.originLocation = self.mapView.myLocation.coordinate;
    });
    

////////////////////////////////////////
    
    self.serverManager = [EGServerManager sharedManager];
    self.path = [GMSMutablePath path];
    
    self.resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    self.resultsViewController.delegate = self;
    
       
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Metods

- (void) getRouteInformationFromServer {
    [self.serverManager getRouteWithOffset:[self.routeInformationArray count]
                origin:self.originLocation
           destination:self.destinationLocation
             onSuccess:^(NSArray *routeInformationsArray) {
                 if (!routeInformationsArray) {
                     [self showSimpleAlertWithMessage:@"Маршрут невозможно построить:("];
                 } else {
                     for (EGRouteInformation* routeInformation in routeInformationsArray) {
//                         NSLog(@"Растояние: %@", routeInformation.distanceText);
//                         NSLog(@"Время: %@", routeInformation.durationText);
                         self.distance = routeInformation.distanceText;
                         self.duration = routeInformation.durationText;
                         self.path = routeInformation.path;
                     }
                 }
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
             }];
}


- (void) showSimpleAlertWithMessage:(NSString*) message {
    if (!message) {
        message = [NSString stringWithFormat:@"Расстояние: %@ \n Время: %@", self.distance, self.duration];
    }
//    NSString* message = [NSString stringWithFormat:@"Расстояние: %@ \n Время: %@", self.distance, self.duration];
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:self.nameLocation
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"ОК"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Отмена"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self.mapView clear];
                               }];

    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}



#pragma mark - Actions
// Масштабирование
- (IBAction)actionScaling:(UIButton *)sender {
    CGFloat zoom = self.position.zoom;
    if (sender.tag == 1) {
        zoom -= 1.0;
    } else {
        zoom += 1.0;
    }
    [self.mapView animateToZoom:zoom];
}

// Построить маршрут
- (IBAction)actionAddRoute:(UIButton *)sender {
    [self getRouteInformationFromServer];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"path: %@", self.path);
        self.polyline = [GMSPolyline polylineWithPath:self.path];
        self.polyline.strokeColor = [UIColor greenColor];
        self.polyline.strokeWidth = 5.f;
        self.polyline.map = self.mapView;
        
// Показать все маркеры на экране
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:self.originLocation
                                                                           coordinate:self.destinationLocation];
        UIEdgeInsets mapInsets = UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0);
        GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:mapInsets];
        self.mapView.camera = camera;
        
        NSLog(@"маршрут построен");
        [self showSimpleAlertWithMessage:nil];
    });
}


// Поиск места (предлагает варианты)
- (IBAction)actionSearchLocation:(UIButton*)sender {
    [self.mapView clear];
   
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsViewController];
    
    self.searchController.searchResultsUpdater = self.resultsViewController;
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 65.0, 250, 50)];
    
    [self.searchView addSubview:self.searchController.searchBar];
    [self.searchController.searchBar sizeToFit];
    [self.view addSubview:self.searchView];
    

    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
    self.definesPresentationContext = YES;
    
}



#pragma mark - GoogleMap

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    self.position = position;
}


// Ставим маркер сами
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.searchView removeFromSuperview];

    [self.mapView clear];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];

    marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;

    self.nameLocation = nil;
    self.destinationLocation = coordinate;
}



- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - API Google Places

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.searchView removeFromSuperview];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
    self.nameLocation = place.name;
    marker.snippet = [[place.formattedAddress componentsSeparatedByString:@", "]
                      componentsJoinedByString:@"\n"];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    self.destinationLocation = place.coordinate;
    
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:place.coordinate zoom:15.0];
    self.mapView.camera = camera;
}



- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}


// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}





@end
