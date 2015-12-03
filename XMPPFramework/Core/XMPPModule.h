#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"
#import "XMPP.h"

#define XMPP_NOT_IN_MODULE_QUEUE NSAssert(dispatch_get_specific(moduleQueueTag),@"Invoked method (\"%@\") outside [\"%@\"] moduleQueue(Line:%d)",[NSString stringWithUTF8String:__func__],[self moduleName],__LINE__)

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}


typedef void(^CompletionBlock)(id data, NSError *error);

@class XMPPStream;

/**
 * XMPPModule is the base class that all extensions/modules inherit.
 * They automatically get:
 * 
 * - A dispatch queue.
 * - A multicast delegate that automatically invokes added delegates.
 * 
 * The module also automatically registers/unregisters itself with the
 * xmpp stream during the activate/deactive methods.
**/
@interface XMPPModule : NSObject
{
    XMPPStream *xmppStream;
    
    dispatch_queue_t moduleQueue;
    dispatch_queue_t mainQueue;
    dispatch_queue_t globalModuleQueue;
    
    void *moduleQueueTag;
    
    id multicastDelegate;
    
    BOOL canSendRequest;
    NSMutableDictionary *requestBlockDcitionary;
}


@property (readonly) dispatch_queue_t moduleQueue;
@property (readonly) dispatch_queue_t mainQueue;
@property (readonly) dispatch_queue_t globalModuleQueue;

@property (readonly) void *moduleQueueTag;

@property (strong, readonly) XMPPStream *xmppStream;

@property (assign, nonatomic) BOOL canSendRequest;
@property (strong, nonatomic) NSMutableDictionary *requestBlockDcitionary;

- (NSString *)moduleName;

- (id)init;
- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (BOOL)activate:(XMPPStream *)aXmppStream;
- (void)deactivate;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;

- (void)callBackWithMessage:(NSString *)message completionBlock:(CompletionBlock)completionBlock;

// those methods must uesd in the modeule CGD queue

- (NSTimeInterval)xmpp_request_timeout_delay;
- (NSInteger)xmpp_module_error_code;
- (NSString *)xmpp_module_error_domain;

- (NSString *)requestKey;

- (void)_callBackWithMessage:(NSString *)message completionBlock:(CompletionBlock)completionBlock;
- (void)_removeCompletionBlockWithDictionary:(NSMutableDictionary *)dic requestKey:(NSString *)requestKey;

- (void)_executeRequestBlockWithRequestKey:(NSString *)requestkey valueObject:(id)valueObject;
- (void)_executeRequestBlockWithRequestKey:(NSString *)requestkey errorMessage:(id)message;
- (BOOL)_executeRequestBlockWithElementName:(NSString *)elementName xmlns:(NSString *)xmlns sendIQ:(XMPPIQ *)iq;

@end
