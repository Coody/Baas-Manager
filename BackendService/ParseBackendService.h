//
//  ParseBackendService.h
//  App
//
//  Created by Coody on 2016/7/4.
//

#import <Foundation/Foundation.h>

#import "BackendServiceManager.h"
#import "App_BackendService_Properties.h"

@interface ParseBackendService : NSObject <BackendServiceObject_Protocol , App_BackendService_Properties>

#pragma mark -
//=== Other properties and methods you wnat to use.
@property (nonnull , nonatomic , strong) NSString *parseAppID;
@property (nonnull , nonatomic , strong) NSString *parseClientKey;
@property (nonnull , nonatomic , strong) NSString *parseObjectName;
-(void)initialParse;


#pragma mark - BackendServiceObject_Protocol
//=== Identify Name
@property (nullable , nonatomic , strong , readonly) NSString *objectName;

//=== Error part
@property (nullable , nonatomic , strong) NSString *errorMsg;
@property (nullable , nonatomic , strong) NSNumber *errorCode;

//=== <BackendServiceObject_Protocol>
//=== Methods
/**
 *  開始 Backend Service
 */
-(void)startBackendServiceWithSuccessBlock:(_Nullable SuccessBlock)responseSuccessBlock 
                             withFailBlock:(_Nullable FailBlock)responseFailBlock;

#pragma mark - App_BackendService_Properties
//======== 要使用的 Properties（實作 App_BackendService_Properties 這個 protocol）
@property (nullable , nonatomic , strong , readonly) NSString *testProperty;

@end
