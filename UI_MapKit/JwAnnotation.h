//
//  JwAnnotation.h
//  UI_MapKit
//
//  Created by lanou on 15/11/12.
//  Copyright © 2015年 陈警卫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface JwAnnotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy)NSString *title;

@property (nonatomic, copy)NSString *subtitle;

@property (nonatomic, copy)NSString *icon;
@end
