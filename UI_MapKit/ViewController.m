//
//  ViewController.m
//  UI_MapKit
//
//  Created by lanou on 15/11/11.
//  Copyright © 2015年 陈警卫. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "JwAnnotation.h"

@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic, strong) CLLocationManager *mgr;

/**
 *  地理编码对象
 */
@property (nonatomic ,strong) CLGeocoder *geocoder;
- (IBAction)addAnno:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.设置地图显示的类型
    /*
     typedef enum : NSUInteger {
     MKMapTypeStandard , 标准(默认)
     MKMapTypeSatellite ,卫星
     MKMapTypeHybrid 混合(标准 + 卫星)
     } MKMapType;
     */

//    self.map.mapType = MKMapTypeHybrid;
    
    // 注意:在iOS8中, 如果想要追踪用户的位置, 必须自己主动请求隐私权限
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        // 主动请求权限
        self.mgr = [[CLLocationManager alloc] init];
        self.mgr.delegate = self;
        [self.mgr requestAlwaysAuthorization];
    }

    // 设置不允许地图旋转
    self.map.rotateEnabled = NO;
    
    // 成为mapVIew的代理
    self.map.delegate = self;
    
    
    //追踪
    // 如果想利用MapKit获取用户的位置, 可以追踪
    /*
     typedef NS_ENUM(NSInteger, MKUserTrackingMode) {
     MKUserTrackingModeNone = 0, 不追踪/不准确的
     MKUserTrackingModeFollow, 追踪
     MKUserTrackingModeFollowWithHeading, 追踪并且获取用的方向
     }
     */
    self.map.userTrackingMode =  MKUserTrackingModeFollowWithHeading;
    
    
}

#pragma mark -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    /*
     用户从未选择过权限
     kCLAuthorizationStatusNotDetermined
     无法使用定位服务，该状态用户无法改变
     kCLAuthorizationStatusRestricted
     用户拒绝该应用使用定位服务，或是定位服务总开关处于关闭状态
     kCLAuthorizationStatusDenied
     已经授权（废弃）
     kCLAuthorizationStatusAuthorized
     用户允许该程序无论何时都可以使用地理信息
     kCLAuthorizationStatusAuthorizedAlways
     用户同意程序在可见时使用地理位置
     kCLAuthorizationStatusAuthorizedWhenInUse
     */
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"等待用户授权");
    }else if (status == kCLAuthorizationStatusAuthorizedAlways ||
              status == kCLAuthorizationStatusAuthorizedWhenInUse)
        
    {
        NSLog(@"授权成功");
        // 开始定位
//        [self.mgr startUpdatingLocation];
        self.map.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        
    }else{
        NSLog(@"授权失败");
    }
}

#pragma mark -- MKMapViewDelegate
/**
 *  每次更新到用户的位置就会调用(调用不频繁, 只有位置改变才会调用)
 *
 *  @param mapView      促发事件的控件
 *  @param userLocation 大头针模型
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    /*
     地图上蓝色的点就称之为大头针
     大头针可以拥有标题/子标题/位置信息
     大头针上显示什么内容由大头针模型确定(MKUserLocation)
     */
//    // 设置大头针显示的内容
//        userLocation.title = @"蓝鸥";
//        userLocation.subtitle = @"丽德";

    
    NSLog(@"%f %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    // 利用反地理编码获取位置之后设置标题
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks firstObject];
        NSLog(@"获取地理位置成功 name = %@ locality = %@", placemark.name, placemark.locality);
        userLocation.title = placemark.name;
        userLocation.subtitle = placemark.locality;
    }];
    
    
    
//    // 移动地图到当前用户所在位置
//    // 获取用户当前所在位置的经纬度, 并且设置为地图的中心点
//    [self.map setCenterCoordinate:userLocation.location.coordinate animated:YES];
//    
//    // 设置地图显示的区域
//    // 获取用户的位置
//    CLLocationCoordinate2D center = userLocation.location.coordinate;
//    // 指定经纬度的跨度
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.00001,0.00001);
//    // 将用户当前的位置作为显示区域的中心点, 并且指定需要显示的跨度范围
//    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
//    
//    // 设置显示区域
//    [self.map setRegion:region animated:YES];
    
}

///**
// *  地图区域即将改变时嗲用
// */
//- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
//    NSLog(@"地图区域即将改变时嗲用");
//}
//
///**
// *  地图区域改变完成时嗲用
// */
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//     NSLog(@"地图区域改变完成时嗲用");
//}


//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//   
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // 对用户当前的位置的大头针特殊处理
    if ([annotation isKindOfClass:[JwAnnotation class]] == NO) {
        return nil;
    }
    
    
    // 1.从缓存池中取
    // 注意: 默认情况下MKAnnotationView是无法显示的, 如果想自定义大头针可以使用MKAnnotationView的子类MKPinAnnotationView
    static NSString *identifier = @"anno";
    // 注意: 如果是自定义的大头针, 默认情况点击大头针之后是不会显示标题的, 需要我们自己手动设置显示
    MKPinAnnotationView *annoView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
//    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    // 2.如果缓存池中没有, 创建一个新的
    if (annoView == nil) {
        
        annoView = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:identifier];
//        annoView = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:identifier];
        
        // 设置大头针的颜色
                annoView.pinColor = MKPinAnnotationColorPurple;
        
        // 设置大头针从天而降
                annoView.animatesDrop = YES;
        
        // 设置大头针标题是否显示
        annoView.canShowCallout = YES;
        
        // 设置大头针标题显示的偏移位
        annoView.calloutOffset = CGPointMake(-50, 0);
        
        // 设置大头针左边的辅助视图
        annoView.leftCalloutAccessoryView = [[UISwitch alloc] init];
        // 设置大头针右边的辅助视图
        annoView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        
    }
//    // 设置大头针的图片
//    // 注意: 如果你是使用的MKPinAnnotationView创建的自定义大头针, 那么设置图片无效, 因为系统内部会做一些操作, 覆盖掉我们自己的设置
//    //    annoView.image = [UIImage imageNamed:@"category_4"];
//    HMAnnotation *anno = (HMAnnotation *)annotation;
//    annoView.image = [UIImage imageNamed:anno.icon];
    
    // 3.给大头针View设置数据
    annoView.annotation = annotation;
    
    // 4.返回大头针View
    return annoView;


}

#pragma mark - 懒加载
- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (IBAction)addAnno:(UIButton *)sender {
    
    JwAnnotation *anno = [[JwAnnotation alloc] init];
    anno.title = @"haha";
    anno.subtitle = @"hehe";
    CGFloat latitude = 31.132884 + arc4random_uniform(2);
    CGFloat longitude = 121.299469 + arc4random_uniform(2);
    anno.coordinate = CLLocationCoordinate2DMake(latitude , longitude);
    
    [self.map addAnnotation:anno];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
