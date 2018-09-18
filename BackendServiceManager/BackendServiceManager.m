//
//  BackendServiceManager.m
//  App
//
//  Created by Coody on 2016/7/1.
//

#import "BackendServiceManager.h"


#pragma mark - Baas Manager
@interface BackendServiceManager()
@property (nonatomic , strong) dispatch_queue_t queue;
@property (nonatomic , assign) NSUInteger serviceIndex;
@property (nonatomic , copy) void(^successBlock)(id <BackendServiceObject_Protocol> baasClass);
@property (nonatomic , copy) void(^failBlock)(void);
@end

@implementation BackendServiceManager

+(instancetype)sharedInstance{
    static BackendServiceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ( sharedInstance == nil ) {
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

-(instancetype)init{
    self = [super init];
    if ( self ) {
        _backendServiceObjectArray = [[NSMutableArray alloc] init];
        _serviceIndex = NSNotFound;
        _queue = dispatch_queue_create("com.normi.BackendService", NULL);
    }
    return self;
}

-(NSMutableDictionary *)backendServiceObjectDic{
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithCapacity:[_backendServiceObjectArray count]];
    for ( id <BackendServiceObject_Protocol> unit in _backendServiceObjectArray ) {
        [tempDic setObject:unit forKey:NSStringFromClass([unit class])];
    }
    return tempDic;
}

-(void)addServicesWithClasses:(NSArray *)classes{
    for (  Class <BackendServiceObject_Protocol> tempClass in classes ) {
        
        // 如果 class name 已經存在，則不處理
        [self addServiceWithClass:tempClass];
    }
}

-(void)addServiceWithClass:(Class)tempClass{
    // 如果 class name 已經存在，則不處理
    NSString *className = NSStringFromClass([tempClass class]);
    if ( [self.backendServiceObjectDic objectForKey:className] ) {
        NSLog(@"\"%@\"此 service 已經存在！請確認！！" , className);
    }
    else{
        [_backendServiceObjectArray addObject:tempClass];
    }
}

-(void)startGetBaasWithSuccessBlock:(void(^)(id <BackendServiceObject_Protocol> baasClass))responseSuccess 
                      withFailBlock:(void(^)(void))responseFail
{
    _serviceIndex = 0;
    self.successBlock = nil;
    self.successBlock = responseSuccess;
    self.failBlock = nil;
    self.failBlock = responseFail;
    
    // 開始取得
    [self startGetBaas];
}


-(id <BackendServiceObject_Protocol> )getRecentSuccessService{
    id <BackendServiceObject_Protocol> baasObject = nil;
    if ( _serviceIndex == NSNotFound ) {
        
    }
    else{
        if ( _serviceIndex < [_backendServiceObjectArray count] ) {
            baasObject = [_backendServiceObjectArray objectAtIndex:_serviceIndex];
        }
    }
    return baasObject;
}

#pragma mark - Private
-(void)startGetBaas{
    
    if ( _serviceIndex >= [_backendServiceObjectArray count]  ) {
        // 全部 service 都錯誤！
        _serviceIndex = NSNotFound;
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.failBlock();
        });
    }
    else{
        id <BackendServiceObject_Protocol> unit = [_backendServiceObjectArray objectAtIndex:_serviceIndex];
        
        if ( unit == nil ) {
            
            // TODO: error
            _serviceIndex = NSNotFound;
            NSLog(@" run 到這裡代表程式有問題！請檢查邏輯！");
            
        }
        else{
            
            if ( [unit respondsToSelector:@selector(startBackendServiceWithSuccessBlock:withFailBlock:)] ) {
                
                __weak __typeof(self)weakSelf = self;
                dispatch_async(_queue, ^{
                    
                    [unit startBackendServiceWithSuccessBlock:^(id <BackendServiceObject_Protocol> baasClass){
                        
                        // 成功！不再繼續問下去！
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            strongSelf.successBlock( [strongSelf.backendServiceObjectArray objectAtIndex:strongSelf.serviceIndex] );
                        });
                        
                    } withFailBlock:^(id <BackendServiceObject_Protocol> baasClass){
                        
                        // 失敗！
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        
                        // 將錯誤印出來
                        NSLog(@"Backend service \"%@\" get fail!! (ErrorCode:%d , ErrorMsg:%@)" ,
                              NSStringFromClass([baasClass class]) ,
                              [baasClass.errorCode intValue] ,
                              baasClass.errorMsg );
                        
                        // 檢查是否可以繼續詢問
                        strongSelf.serviceIndex = strongSelf.serviceIndex + 1;
                        [strongSelf startGetBaas];
                        
                    }];
                });
                
            }
            else{
                
                // 如果沒有實作此方法，印出 log ，繼續下一個 backend service
                _serviceIndex = _serviceIndex + 1;
                [self startGetBaas];
                
            }
        }
    }
}

@end
