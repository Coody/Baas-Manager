//
//  BackendServiceManager.h
//  App
//
//  Created by Coody on 2016/7/1.
//

#import <Foundation/Foundation.h>

@protocol BackendServiceObject_Protocol;


// for alloc
@protocol Alloc_Policy <NSObject>

+ (instancetype)alloc;

@end


#pragma mark - Define
/**
 *  成功的回應 Block
 *
 *  @param baasObject 將自己回傳回來讓 NackendServiceManager 可以回應給使用的人使用內部 property
 */
typedef void(^SuccessBlock)(id <BackendServiceObject_Protocol> baasObject);
/**
 *  失敗的回應 Block
 */
typedef void(^FailBlock)(id <BackendServiceObject_Protocol> baasObject);



#pragma mark - Backend service protocol
@protocol BackendServiceObject_Protocol <NSObject , Alloc_Policy >

@optional
//=== Identify Name
@property (nonatomic , strong , readonly) NSString *objectName;

@required
//=== Error part
@property (nonatomic , strong) NSString *errorMsg;
@property (nonatomic , strong) NSNumber *errorCode;

//=== Methods
/**
 *  開始 Backend Service
 */
-(void)startBackendServiceWithSuccessBlock:(SuccessBlock)responseSuccessBlock 
                             withFailBlock:(FailBlock)responseFailBlock;

@end


#pragma mark - Manager
@interface BackendServiceManager : NSObject

@property (nonatomic , strong , readonly) NSMutableDictionary *backendServiceObjectDic;
@property (nonatomic , strong , readonly) NSMutableArray *backendServiceObjectArray;

+(instancetype)sharedInstance;

/**
 *  輸入符合 BackendServiceObject_Protocol 的服務
 *
 *  @param classNames 輸入此 class 的名稱即可（ NSString ），此方法讓您一次輸入多筆
 *  @warning - 詢問順序會從您設定給此工具開始往後排列、設定同樣一組 class 是無效的（會以目前已經存在的為主）
 */
-(void)addServicesWithClasses:(NSArray *)classes;

/**
 *  輸入符合 BackendServiceObject_Protocol 的服務
 *
 *  @param className 輸入此 class 的名稱即可（ NSString ），此方法是讓你獨自加入此 class name
 */
-(void)addServiceWithClass:(Class)tempClass;

/**
 *  開始詢問服務（會依照加入服務的順序來詢問）
 *
 *  @param responseSuccess 當第一個成功就會回應回來，不會往後跑
 *  @param responseFail    全部的服務都失敗的時候，會丟出此錯誤 block
 *
 *  @warning 如果要知道錯誤的詳細資訊，可以直接從此 manager 的 backendServiceObjectDic、或是 backendServiceObjectArray 取出服務來看內部錯誤訊息是什麼？
 */
-(void)startGetBaasWithSuccessBlock:(void(^)(id <BackendServiceObject_Protocol> baasClass))responseSuccess 
                      withFailBlock:(void(^)())responseFail;

/**
 *  取得目前成功詢問的 service
 *
 *  @return 回傳一個符合 BackendServiceObject_Protocol 的 service object，可以從 key 知道此 service 是哪個，但不管是哪個，只要有在去實作各自專案的 property 協定，那就可以使用內部的 property。
 */
-(id <BackendServiceObject_Protocol> )getRecentSuccessService;

@end
