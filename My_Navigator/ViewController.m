//
//  ViewController.m
//  My_Navigator
//
//  Created by Евгений Гостев on 28.01.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "ViewController.h"
#import "EGServerManager.h"

#import "EGRouteInformation.h"


@import GooglePlaces;
@import GooglePlacePicker;


@interface ViewController () <CLLocationManagerDelegate, GMSPlacePickerViewControllerDelegate, GMSAutocompleteViewControllerDelegate>

@property (strong, nonatomic) GMSCameraPosition* position;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonatomic) GMSPlacePicker *placesPicker;


@property (strong, nonatomic) GMSAutocompleteViewController *acController;
@property (strong, nonatomic) GMSAutocompleteResultsViewController *_resultsViewController;


@property (strong, nonatomic) NSMutableArray* routeInformationArray;
@property (strong, nonatomic) GMSMutablePath *path;
@property (assign, nonatomic) CLLocationCoordinate2D origin;
@property (assign, nonatomic) CLLocationCoordinate2D destination;
@property (strong, nonatomic) EGServerManager* serverManager;



@end




@implementation ViewController

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
    
    self.origin = CLLocationCoordinate2DMake(55.439505, 37.769421);
    
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(55.439505, 37.769421) zoom:12.0];
    self.mapView.camera = camera;
    
    self.placesClient = [GMSPlacesClient sharedClient];
    
    
//    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
//    GMSPlacePickerViewController *placePicker =
//    [[GMSPlacePickerViewController alloc] initWithConfig:config];
//    placePicker.delegate = self;
//
//    [self presentViewController:placePicker animated:YES completion:nil];

    self.definesPresentationContext = YES;
    
    self.path = [GMSMutablePath path];
    self.routeInformationArray = [NSMutableArray array];
    

//        [self getRouteInformationFromServer];
    self.serverManager = [EGServerManager sharedManager];
    
    

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) getRouteInformationFromServer {
    [self.serverManager getRouteWithOffset:[self.routeInformationArray count]
                     origin:self.origin
                destination:self.destination
                  onSuccess:^(NSArray *routeInformationsArray) {
                      for (EGRouteInformation* routeInformation in routeInformationsArray) {
                          GMSPath *polyLinePath = [GMSPath pathFromEncodedPath:routeInformation.points];
                          NSLog(@"points: %@", routeInformation.points);
                          for (int i = 0; i < polyLinePath.count; i++) {
                              [self.path addCoordinate:[polyLinePath coordinateAtIndex:i]];
                          }
                      }
                  }
                  onFailure:^(NSError *error, NSInteger statusCode) {
                      NSLog(@"error = %@, code = %ld", [error localizedDescription], statusCode);
                  }];
}



#pragma mark - Actions

- (IBAction)actionScale:(UIButton *)sender {
    CGFloat zoom = self.position.zoom;
    if (sender.tag == 1) {
        zoom -= 1.0;
    } else {
        zoom += 1.0;
    }
    [self.mapView animateToZoom:zoom];
}



- (IBAction)getCurrentPlace:(UIButton *)sender {
    [self.placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        self.nameLabel.text = @"No current place";
        self.addressLabel.text = @"";
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                self.nameLabel.text = place.name;
                self.addressLabel.text = [[place.formattedAddress componentsSeparatedByString:@", "]
                                          componentsJoinedByString:@"\n"];
//                NSLog(@"%@", place.attributions.string);
//                self.attributionsLabel.text = place.attributions.string;
            }
        }
    }];
}

- (IBAction)actionAdd:(UIBarButtonItem *)sender {
     [self getRouteInformationFromServer];
//         [self getRouteInformationFromServer];
    
//    GMSCameraPosition *camera =
//    [GMSCameraPosition cameraWithLatitude:55.605
//                                longitude:37.716
//                                     zoom:17.5
//                                  bearing:30
//                             viewingAngle:40];
//
//    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//    self.view = mapView;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:self.origin zoom:12.0];
    
    NSLog(@"path: %@", self.path);
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:self.path];
    polyline.strokeColor = [UIColor greenColor];
    polyline.strokeWidth = 5.f;
    polyline.map = self.mapView;
    self.mapView.camera = camera;
    
    NSLog(@"Start");

}


- (IBAction)actionScaling:(UIBarButtonItem *)sender {
    CGFloat zoom = self.position.zoom;
    if (sender.tag == 0) {
        zoom -= 0.5;
    } else {
        zoom += 0.5;
    }
    [self.mapView animateToZoom:zoom];
}


- (IBAction)actionOnLaunchClicked:(UIBarButtonItem *)sender {
    self.acController = [[GMSAutocompleteViewController alloc] init];
    self.acController.delegate = self;
    [self presentViewController:self.acController animated:YES completion:nil];
    
}


- (IBAction)actionPolilyne:(UIBarButtonItem *)sender {
    [self getRouteInformationFromServer];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(-33.85, 151.20) zoom:12.0];
    
    if (!self.path) {
        self.path = [GMSMutablePath path];
        [self.path addCoordinate:CLLocationCoordinate2DMake(-33.85, 151.20)];
        [self.path addCoordinate:CLLocationCoordinate2DMake(-33.70, 151.40)];
        [self.path addCoordinate:CLLocationCoordinate2DMake(-33.73, 151.41)];
        NSLog(@"NILL");
    }
    
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:self.path];
    polyline.strokeColor = [UIColor greenColor];
    polyline.strokeWidth = 5.f;
    polyline.map = self.mapView;
    
    self.mapView.camera = camera;
}


#pragma mark - GMSAutocompleteViewControllerDelegate

- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
//    NSLog(@"Place name %@", place.name);
//    NSLog(@"Place address %@", place.formattedAddress);
//    NSLog(@"Place coordinate %ld  %ld", place.coordinate.latitude, place.coordinate.longitude);
    
    
    GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
    marker.title = @"Test Title";
    marker.snippet = @"Test snippet";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
//    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:place.coordinate zoom:9.0];
//    self.mapView.camera = camera;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}




#pragma mark - GoogleMap

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    NSLog(@"willMove - %i", gesture);
}

/*
  Called repeatedly during any animations or gestures on the map (or once, if the camera is
  explicitly set). This may not be called for all intermediate camera positions. It is always
  called for the final position of an animation or gesture.
 */
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"didChangeCameraPosition - %@", position);
}

/*
  Called when the map becomes idle, after any outstanding gestures or animations have completed (or
  after the camera has been explicitly set).
 */
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    NSLog(@"idleAtCameraPosition - %@", position);
    self.destination = position.target;
    self.position = position;
}

/*
  Called after a tap gesture at a particular coordinate, but only if a marker was not tapped.  This
  is called before deselecting any currently selected marker (the implicit action for tapping on
  the map).
 */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"didTapAtCoordinate - %d %d", (int)coordinate.latitude, (int)coordinate.longitude);

   
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    marker.title = @"Test Title";
    marker.snippet = @"Test snippet";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    
//    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:coordinate zoom:15.0];
//    self.mapView.camera = camera;
    NSLog(@"actionAdd");
    
}

/*
 Called after a long-press gesture at a particular coordinate.
  @param mapView The map view that was tapped.
  @param coordinate The location that was tapped.
 */
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"didLongPressAtCoordinate - %d %d", (int)coordinate.latitude, (int)coordinate.longitude);
}

/*
  Called after a marker has been tapped.
  @param mapView The map view that was tapped.
  @param marker The marker that was tapped.
  @return YES if this delegate handled the tap event, which prevents the map from performing its
  default selection behavior, and NO if the map should continue with its default selection
  behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    NSLog(@"didTapMarker -");
    return YES;
}

/*
  Called after a marker's info window has been tapped.
 */
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"didTapInfoWindowOfMarker -");
}

/*
  Called after a marker's info window has been long pressed.
 */
- (void)mapView:(GMSMapView *)mapView didLongPressInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"didLongPressInfoWindowOfMarker -");
}

/*
  Called after an overlay has been tapped.
  This method is not called for taps on markers.
  @param mapView The map view that was tapped.
  @param overlay The overlay that was tapped.
 */
- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
    NSLog(@"didTapOverlay -");
}

/*
  Called after a POI has been tapped.
  @param mapView The map view that was tapped.
  @param placeID The placeID of the POI that was tapped.
  @param name The name of the POI that was tapped.
  @param location The location of the POI that was tapped.
 */
- (void)mapView:(GMSMapView *)mapView
didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location {
    NSLog(@"didTapPOIWithPlaceID -");
}

/*
  Called when a marker is about to become selected, and provides an optional custom info window to
  use for that marker if this method returns a UIView.
  If you change this view after this method is called, those changes will not necessarily be
  reflected in the rendered version.
  The returned UIView must not have bounds greater than 500 points on either dimension.  As there
  is only one info window shown at any time, the returned view may be reused between other info
  windows.
  Removing the marker from the map or changing the map's selected marker during this call results
  in undefined behavior.
  @return The custom info window for the specified marker, or nil for default
 */
//- (nullable UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    NSLog(@"markerInfoWindow -");
//}

/*
  Called when mapView:markerInfoWindow: returns nil. If this method returns a view, it will be
  placed within the default info window frame. If this method returns nil, then the default
  rendering will be used instead.
  @param mapView The map view that was pressed.
  @param marker The marker that was pressed.
  @return The custom view to display as contents in the info window, or nil to use the default
  content rendering instead
 */
//- (nullable UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
//    NSLog(@"markerInfoContents -");
//}

/*
  Called when the marker's info window is closed.
 */
- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker {
    NSLog(@"didCloseInfoWindowOfMarker -");
}

/*
  Called when dragging has been initiated on a marker.
 */
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didBeginDraggingMarker -");
}

/*
  Called after dragging of a marker ended.
 */
- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    NSLog(@"didEndDraggingMarker -");
}

/*
  Called while a marker is dragged.
 */
- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    NSLog(@"didDragMarker -");
}

/*
  Called when the My Location button is tapped.
  @return YES if the listener has consumed the event (i.e., the default behavior should not occur),
          NO otherwise (i.e., the default behavior should occur). The default behavior is for the
          camera to move such that it is centered on the user location.
 */
//- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
//    NSLog(@"didTapMyLocationButtonForMapView - %d", mapView.myLocation);
//    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(55.439505, 37.769421) zoom:12.0];
//    self.mapView.camera = camera;
//
//    return YES;
//}

/*
  Called when tiles have just been requested or labels have just started rendering.
 */
- (void)mapViewDidStartTileRendering:(GMSMapView *)mapView {
    NSLog(@"mapViewDidStartTileRendering -");
}

/*
  Called when all tiles have been loaded (or failed permanently) and labels have been rendered.
 */
- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView {
    NSLog(@"mapViewDidFinishTileRendering -");
}

/*
  Called when map is stable (tiles loaded, labels rendered, camera idle) and overlay objects have
  been rendered.
 */
- (void)mapViewSnapshotReady:(GMSMapView *)mapView {
    NSLog(@"mapViewSnapshotReady -");
}




@end
