//
//  EGMapViewController.m
//  My_Navigator
//
//  Created by Евгений Гостев on 03.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "CLLocation+EGCheckCLLocationCoordinate2D.h"
#import "EGFetcherSampleViewController.h"
#import "EGRouteHistoryViewController.h"
#import "EGMarkers.h"
#import "EGRouteData.h"
#import "Realm.h"
#import "EGRouteHistory.h"

@class CLLocationManager;
@class GMSMapView;


typedef enum {
    EGOriginTextFieldType,
    EGDestinationTextFieldType
} EGTextFieldType;


@interface EGMapViewController ()
            <GMSMapViewDelegate,
            CLLocationManagerDelegate,
            EGFetcherSampleViewControllerDelegate,
            EGRouteHistoryViewControllerDelegate,
            EGRouteDataDelegate>

@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *originTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UILabel *informationRouteLabel;
@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;

@end


@implementation EGMapViewController {
    CLLocationManager* _locationManager;
    GMSPlace* _place;
    GMSCameraPosition* _position;
    CLLocationCoordinate2D _originLocation;
    CLLocationCoordinate2D _destinationLocation;
    GMSMarker* _originMarker;
    GMSMarker* _destinationMarker;
    GMSPolyline* _polyline;
    NSString* _addressLocation;
    NSString* _distance;
    NSString* _duration;
    BOOL _isFirstStartTheProgram;
    BOOL _isMyLocationEnabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.informationView setHidden:YES];
    [_myLocationButton setHidden:YES];
    if (!_isMyLocationEnabled) {
        CLLocationCoordinate2D startLocation = CLLocationCoordinate2DMake(0, 10);
        [self _scalingLocation:startLocation andZoom:1];
    }
    [self _loadLocationManager];
    [self _loadMapView];
    _isFirstStartTheProgram = YES;
    _originMarker = [[GMSMarker alloc] init];
    _destinationMarker = [[GMSMarker alloc] init];
}

#pragma mark - Private metods

- (void)_loadLocationManager {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation];
}

- (void)_loadMapView {
    self.mapView.myLocationEnabled = YES;
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.delegate = self;
}

- (void)_scalingLocation:(CLLocationCoordinate2D)location andZoom:(CGFloat)zoom {
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithTarget:location zoom:zoom];
    self.mapView.camera = camera;
}

- (void)_addMarker:(GMSMarker*)marker andLocationType:(EGLocationType)locationType {
    if (locationType == EGOriginLocationType) {
        [self _addOriginMarker:marker];
    } else if (locationType == EGDestinationLocationType) {
        [self _addDestinationMarker:marker];
    }
    [self _scalingLocation:marker.position andZoom:15];
    if ([CLLocation EGCLLocationNoNullCoordinate:_originLocation] &&
        [CLLocation EGCLLocationNoNullCoordinate:_destinationLocation]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _showSimpleAlertWithMessege:@"Построить маршрут?" isOneButton:NO];
        });
    }
}

- (void)_addOriginMarker:(GMSMarker*)marker {
    _originMarker.map = nil;
    _originTextField.text = marker.snippet;
    _originLocation = marker.position;
    _originMarker = marker;
    _originMarker.icon = [UIImage imageNamed:@"OriginLocation(64x64).png"];
    _originMarker.map = self.mapView;
}

- (void)_addDestinationMarker:(GMSMarker*)marker {
    _destinationMarker.map = nil;
    _destinationTextField.text = marker.snippet;
    _addressLocation = marker.snippet;
    _destinationLocation = marker.position;
    _destinationMarker = marker;
    _destinationMarker.icon = [UIImage imageNamed:@"DestinationLocation(64x64).png"];
    _destinationMarker.map = self.mapView;
}

- (void)_choiceOfLocation:(CLLocationCoordinate2D)coordinate {
    EGMarkers* markers = [[EGMarkers alloc] initWithCoordinate:coordinate];
    GMSMarker* marker = [markers marker];
    NSString* message = @"Выбор старта или финиша";
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Старт"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self _addMarker:marker
                                    andLocationType:EGOriginLocationType];
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Финиш"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * _Nonnull action) {
                                   [self _addMarker:marker
                                   andLocationType:EGDestinationLocationType];
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)_buildRoute {
    EGRouteData* routeData = [[EGRouteData alloc] initWithOrigin:_originLocation
                                                     destination:_destinationLocation];
    [routeData setDelegate:self];
}

- (void)_loadInformationViewAndScaling {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_originLocation
                                                                       coordinate:_destinationLocation];
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(140.0, 100.0, 100.0, 100.0);
    GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:mapInsets];
    self.mapView.camera = camera;
    self.informationRouteLabel.text = [NSString stringWithFormat:@"%@ (%@)", _duration, _distance];
    [self.informationView setHidden:NO];
}

- (void)_showSimpleAlertWithMessege:(NSString*) message isOneButton:(BOOL) isOneButton {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    if (!isOneButton) {
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"ОК"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [self _buildRoute];
                                        [self _saveRoute];
                                    }];
        [alert addAction:yesButton];
    }
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Отмена"
                               style:UIAlertActionStyleDefault
                               handler:nil];

    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)_saveRoute {
    if (_addressLocation) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        EGRouteHistory* routeHistory = [[EGRouteHistory alloc] init];
        routeHistory.name = _addressLocation;
        [routeHistory setOriginMarker:_originMarker];
        [routeHistory setDestinationMarker:_destinationMarker];
        [realm addObject:routeHistory];
        [realm commitWriteTransaction];
    }
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

- (IBAction)actionMyLocation:(id)sender {
    [self _scalingLocation:self.mapView.myLocation.coordinate andZoom:12];
}

- (IBAction)actionAddRoute:(UIButton *)sender {
    [self _buildRoute];
    [self.view addSubview:self.informationView];
}

- (IBAction)actionCancelRoute:(UIButton *)sender {
    _polyline.map = nil;
    [self.informationView setHidden:YES];
}

- (IBAction)actionRouteHistory:(UIButton *)sender {
    EGRouteHistoryViewController* routeHistoryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EGRouteHistoryViewController"];
    routeHistoryVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:routeHistoryVC animated:YES completion:nil];
    [routeHistoryVC setDelegate:self];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    _position = position;
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    _polyline.map = nil;
    [self _choiceOfLocation:coordinate];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (_isFirstStartTheProgram) {
        [self _scalingLocation:manager.location.coordinate andZoom:12];
        _originLocation = manager.location.coordinate;
        _originTextField.text = @"Мое местоположение";
        _originMarker = [GMSMarker markerWithPosition:manager.location.coordinate];
        _originMarker.snippet = @"Мое местоположение";
        _isFirstStartTheProgram = NO;
    }
    [_myLocationButton setHidden:NO];
    _isMyLocationEnabled = YES;
}

#pragma mark - UItextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.informationView setHidden:YES];
    _polyline.map = nil;
    EGFetcherSampleViewController* fetcherSampleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EGFetcherSampleViewController"];
    fetcherSampleVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    fetcherSampleVC.modalPresentationStyle = UIModalPresentationCustom;
    fetcherSampleVC.isMyLocationEnabled = _isMyLocationEnabled;
    fetcherSampleVC.myLocation = self.mapView.myLocation.coordinate;
    switch (textField.tag) {
        case EGOriginTextFieldType:
            fetcherSampleVC.locationType = EGOriginLocationType;
            break;
        case EGDestinationTextFieldType:
            fetcherSampleVC.locationType = EGDestinationLocationType;
            break;
    }
    [self presentViewController:fetcherSampleVC animated:YES completion:nil];
    [fetcherSampleVC setDelegate:self];
    return NO;
}

#pragma mark - EGFetcherSampleViewControllerDelegate

- (void)autocompleteWithMarker:(GMSMarker*)marker
               andLocationType:(EGLocationType)locationType {
    [self _addMarker:marker andLocationType:locationType];
}

#pragma mark - EGRouteDataDelegate

- (void)getRouteDataWithPolyline:(GMSPolyline *)polyline
                        distance:(NSString *)distance
                        duration:(NSString *)duration
                    messageError:(NSString *)messageError {
    if (polyline) {
        _distance = distance;
        _duration = duration;
        _polyline = polyline;
        _polyline.map = self.mapView;
        [self _loadInformationViewAndScaling];
    } else {
        [self _showSimpleAlertWithMessege:messageError isOneButton:YES];
    }
}

#pragma mark - EGRouteHistoryViewControllerDelegate

- (void)loadingRouteFromHistoryWithOriginMarker:(GMSMarker*)originMarker
                              destinationMarker:(GMSMarker*)destinationMarker {
    [_mapView clear];
    [self _addOriginMarker:originMarker];
    [self _addDestinationMarker:destinationMarker];
    [self _buildRoute];
}

@end
