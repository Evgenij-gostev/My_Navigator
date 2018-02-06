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

@interface EGMapViewController () <CLLocationManagerDelegate, GMSPlacePickerViewControllerDelegate, GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate>

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
    
//    self.origin = CLLocationCoordinate2DMake(55.439505, 37.769421);

    self.mapView.camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:0.1];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:12.0];
        self.mapView.camera = camera;
        self.originLocation = self.mapView.myLocation.coordinate;
    });
    
    
//    self.placesClient = [GMSPlacesClient sharedClient];
    self.serverManager = [EGServerManager sharedManager];
    self.path = [GMSMutablePath path];
    
    
////////////////////////////////////////
    
    self.resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    self.resultsViewController.delegate = self;
    
    
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) getRouteInformationFromServer {
    GMSMutablePath* locationPath = [GMSMutablePath path];
    [self.serverManager getRouteWithOffset:[self.routeInformationArray count]
                origin:self.originLocation
           destination:self.destinationLocation
             onSuccess:^(NSArray *routeInformationsArray) {
                 for (EGRouteInformation* routeInformation in routeInformationsArray) {
                     GMSPath *polyLinePath = [GMSPath pathFromEncodedPath:routeInformation.points];
//                     NSLog(@"points: %@", routeInformation.points);
                     for (int i = 0; i < polyLinePath.count; i++) {
                         [locationPath addCoordinate:[polyLinePath coordinateAtIndex:i]];
                     }
                 }
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
             }];
    self.path = locationPath;
}



#pragma mark - Actions

- (IBAction)actionScaling:(UIButton *)sender {
    CGFloat zoom = self.position.zoom;
    if (sender.tag == 1) {
        zoom -= 1.0;
    } else {
        zoom += 1.0;
    }
    [self.mapView animateToZoom:zoom];
}


- (IBAction)actionAddRoute:(UIBarButtonItem *)sender {
    [self getRouteInformationFromServer];
//    self.polyline = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.originLocation zoom:12.0];
//        NSLog(@"path: %@", self.path);
        self.polyline = [GMSPolyline polylineWithPath:self.path];
        self.polyline.strokeColor = [UIColor greenColor];
        self.polyline.strokeWidth = 5.f;
        self.polyline.map = self.mapView;
        self.mapView.camera = camera;
        
        NSLog(@"маршрут построен");
    });
}



- (IBAction)actionSearchLocation:(UIBarButtonItem *)sender {
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



- (IBAction)actionCleanerMapView:(UIBarButtonItem *)sender {
     [self.mapView clear];
//    self.polyline = nil;
//    self.path = nil;
}




#pragma mark - GoogleMap

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    self.position = position;
}



- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
//    NSLog(@"didTapAtCoordinate - %d %d", (int)coordinate.latitude, (int)coordinate.longitude);
    
    [self.searchView removeFromSuperview];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
//    marker.title = place.name;
//    marker.snippet = [[place.formattedAddress componentsSeparatedByString:@", "]
//                      componentsJoinedByString:@"\n"];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
    self.destinationLocation = coordinate;
    
}


- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


#pragma mark - API Google Places

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.searchView removeFromSuperview];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = place.name;
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
