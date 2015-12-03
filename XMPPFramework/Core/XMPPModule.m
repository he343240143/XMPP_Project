#import "XMPPModule.h"
#import "XMPPStream.h"
#import "XMPPLogging.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

static  NSTimeInterval const XMPP_MODULE_REQUEST_TIMEOUT_DELAY = 30.0f;
static  NSString * const XMPP_MODULE_ERROR_DOMAIN = @"com.afusion.xmpp.%@.error";
static  NSInteger const XMPP_MODULE_ERROR_CODE = 9999;

@implementation XMPPModule

/**
 * Standard init method.
**/
- (id)init
{
	return [self initWithDispatchQueue:NULL];
}

/**
 * Designated initializer.
**/
- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
	if ((self = [super init]))
	{
		if (queue)
		{
			moduleQueue = queue;
			#if !OS_OBJECT_USE_OBJC
			dispatch_retain(moduleQueue);
			#endif
		}
		else
		{
			const char *moduleQueueName = [[self moduleName] UTF8String];
			moduleQueue = dispatch_queue_create(moduleQueueName, NULL);
		}
		
		moduleQueueTag = &moduleQueueTag;
		dispatch_queue_set_specific(moduleQueue, moduleQueueTag, moduleQueueTag, NULL);
        
        mainQueue = dispatch_get_main_queue();
        globalModuleQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        multicastDelegate = [[GCDMulticastDelegate alloc] init];
    
	}
	return self;
}

- (void)dealloc
{
    [requestBlockDcitionary removeAllObjects];
    requestBlockDcitionary = nil;
    
	#if !OS_OBJECT_USE_OBJC
	dispatch_release(moduleQueue);
	#endif
}

/**
 * The activate method is the point at which the module gets plugged into the xmpp stream.
 * Subclasses may override this method to perform any custom actions,
 * but must invoke [super activate:aXmppStream] at some point within their implementation.
**/
- (BOOL)activate:(XMPPStream *)aXmppStream
{
	__block BOOL result = YES;
	
	dispatch_block_t block = ^{
		
		if (xmppStream != nil)
		{
			result = NO;
		}
		else
		{
			xmppStream = aXmppStream;
			
			[xmppStream addDelegate:self delegateQueue:moduleQueue];
			[xmppStream registerModule:self];
			
			[self didActivate];
		}
        
        canSendRequest = NO;
        if (requestBlockDcitionary == nil) requestBlockDcitionary = [NSMutableDictionary dictionary];
        
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
	
	return result;
}

/**
 * It is recommended that subclasses override this method (instead of activate:)
 * to perform tasks after the module has been activated.
 * 
 * This method is only invoked if the module is successfully activated.
 * This method is always invoked on the moduleQueue.
**/
- (void)didActivate
{
	// Override me to do custom work after the module is activated
}

/**
 * The deactivate method unplugs a module from the xmpp stream.
 * When this method returns, no further delegate methods on this module will be dispatched.
 * However, there may be delegate methods that have already been dispatched.
 * If this is the case, the module will be properly retained until the delegate methods have completed.
 * If your custom module requires that delegate methods are not run after the deactivate method has been run,
 * then simply check the xmppStream variable in your delegate methods.
**/
- (void)deactivate
{
	dispatch_block_t block = ^{
		
		if (xmppStream)
		{
			[self willDeactivate];
			[xmppStream removeDelegate:self delegateQueue:moduleQueue];
			[xmppStream unregisterModule:self];
			
			xmppStream = nil;
		}
        
        canSendRequest = NO;
        
        [requestBlockDcitionary removeAllObjects];
        requestBlockDcitionary = nil;
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
}

/**
 * It is recommended that subclasses override this method (instead of deactivate:)
 * to perform tasks after the module has been deactivated.
 *
 * This method is only invoked if the module is transitioning from activated to deactivated.
 * This method is always invoked on the moduleQueue.
**/
- (void)willDeactivate
{
	// Override me to do custom work after the module is deactivated
}

- (dispatch_queue_t)moduleQueue
{
	return moduleQueue;
}

- (dispatch_queue_t)mainQueue
{
    return mainQueue;
}

- (dispatch_queue_t)globalModuleQueue
{
    return globalModuleQueue;
}

- (void *)moduleQueueTag
{
	return moduleQueueTag;
}

- (NSString *)moduleName
{
    // Override me (if needed) to provide a customized module name.
    // This name is used as the name of the dispatch_queue which could aid in debugging.
    
    return NSStringFromClass([self class]);
}

- (XMPPStream *)xmppStream
{
	if (dispatch_get_specific(moduleQueueTag))
	{
		return xmppStream;
	}
	else
	{
		__block XMPPStream *result;
		
		dispatch_sync(moduleQueue, ^{
			result = xmppStream;
		});
		
		return result;
	}
}

#pragma mark - puiblic propries
- (BOOL)canSendRequest
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = canSendRequest;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setCanSendRequest:(BOOL)CanSendRequest
{
    dispatch_block_t block = ^{
        
        canSendRequest = CanSendRequest;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (NSMutableDictionary *)requestBlockDcitionary
{
    __block NSMutableDictionary *result = nil;
    
    dispatch_block_t block = ^{
        result = requestBlockDcitionary;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_sync(moduleQueue, block);
    
    return result;
}

- (void)setRequestBlockDcitionary:(NSMutableDictionary *)_requestBlockDcitionary
{
    dispatch_block_t block = ^{
        
        requestBlockDcitionary = _requestBlockDcitionary;
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

#pragma mark - Delegate action methods

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Asynchronous operation (if outside xmppQueue)
	
	dispatch_block_t block = ^{
		[multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_async(moduleQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously
{
	dispatch_block_t block = ^{
		[multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
	};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else if (synchronously)
		dispatch_sync(moduleQueue, block);
	else
		dispatch_async(moduleQueue, block);
	
}
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
	// Synchronous operation (common-case default)
	
	[self removeDelegate:delegate delegateQueue:delegateQueue synchronously:YES];
}

- (void)removeDelegate:(id)delegate
{
	// Synchronous operation (common-case default)
	
	[self removeDelegate:delegate delegateQueue:NULL synchronously:YES];
}

- (NSTimeInterval)xmpp_request_timeout_delay
{
    XMPP_NOT_IN_MODULE_QUEUE;
    return XMPP_MODULE_REQUEST_TIMEOUT_DELAY;
}
- (NSInteger)xmpp_module_error_code
{
    XMPP_NOT_IN_MODULE_QUEUE;
    return XMPP_MODULE_ERROR_CODE;
}
- (NSString *)xmpp_module_error_domain
{
    XMPP_NOT_IN_MODULE_QUEUE;
    return [NSString stringWithFormat:XMPP_MODULE_ERROR_DOMAIN,[self moduleName]];
}
- (NSString *)requestKey
{
    XMPP_NOT_IN_MODULE_QUEUE;
    return [[self xmppStream] generateUUID];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)callBackWithMessage:(NSString *)message completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:(message ? :@"") forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",[self xmpp_module_error_domain]] code:[self xmpp_module_error_code] userInfo:userInfo];
        
        dispatch_main_async_safe(^{
            completionBlock(nil, error);
        });
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)_callBackWithMessage:(NSString *)message completionBlock:(CompletionBlock)completionBlock
{
    // if not this queue we should return
    XMPP_NOT_IN_MODULE_QUEUE;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",[self xmpp_module_error_domain]] code:[self xmpp_module_error_code] userInfo:userInfo];
    
    dispatch_main_async_safe(^{
        completionBlock(nil, error);
    });
}

// call back with error info to who had used it
- (void)_removeCompletionBlockWithDictionary:(NSMutableDictionary *)dic requestKey:(NSString *)requestKey
{
    XMPP_NOT_IN_MODULE_QUEUE;
    
    // We should find our request block after 60 seconds,if there is no reponse from the server,
    //  we should call back with a error to notice the user that the server has no response for this request
    NSTimeInterval delayInSeconds = [self xmpp_request_timeout_delay];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, moduleQueue, ^(void){@autoreleasepool{
        
        if ([dic objectForKey:requestKey]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"request from server with no response for a long time!" forKey:NSLocalizedDescriptionKey];
            NSError *_error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",[self xmpp_module_error_domain]] code:[self xmpp_module_error_code] userInfo:userInfo];
            
            CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestKey];
            if (completionBlock != NULL ) {
                
                //completionBlock(nil, _error);
                dispatch_main_async_safe(^{
                    completionBlock(nil, _error);
                });
                [dic removeObjectForKey:requestKey];
                
            }
        }
        
    }});
}
- (void)_executeRequestBlockWithRequestKey:(NSString *)requestkey valueObject:(id)valueObject
{
    XMPP_NOT_IN_MODULE_QUEUE;

    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
    
    if (completionBlock != NULL ) {
        
        //completionBlock(valueObject, nil);
        dispatch_main_async_safe(^{
            completionBlock(valueObject, nil);
        });
        [requestBlockDcitionary removeObjectForKey:requestkey];
    }
}

- (void)_executeRequestBlockWithRequestKey:(NSString *)requestkey errorMessage:(id)message
{
    XMPP_NOT_IN_MODULE_QUEUE;
    
    CompletionBlock completionBlock = (CompletionBlock)[requestBlockDcitionary objectForKey:requestkey];
    
    if (completionBlock != NULL ) {
        
        [self callBackWithMessage:message completionBlock:completionBlock];
        [requestBlockDcitionary removeObjectForKey:requestkey];
    }
}

- (BOOL)_executeRequestBlockWithElementName:(NSString *)elementName xmlns:(NSString *)xmlns sendIQ:(XMPPIQ *)iq
{
    if ([[iq type] isEqualToString:@"get"]) {
        
        NSXMLElement *queryElement = [iq elementForName:elementName xmlns:xmlns];
        
        if (queryElement){
            
            NSString *requestkey = [iq elementID];
            
            [self _executeRequestBlockWithRequestKey:requestkey errorMessage:@"send iq error"];
            
            return YES;
        }
    }
    
    return NO;
}

/*
#pragma mark - XMPPDelegate methods

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:YES];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    // This method is invoked on the moduleQueue.
    
    [self setCanSendRequest:NO];
    
    for (NSString *requestKey in [requestBlockDcitionary allKeys]) {
        [self _executeRequestBlockWithRequestKey:requestKey errorMessage:@"You had disconnect with the server"];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    return [self _executeRequestBlockWithElementName:<#element name#> xmlns:<#xmlns#> sendIQ:<#IQ#>];
}
*/
////
//// Here is a example method to show how to use block in xmpp moudle
//// you cant write your method like this to use the block function
////-(void)exampleMethodWithCompletionBlock:(CompletionBlock)completionBlock
//{
//    dispatch_block_t block = ^{@autoreleasepool{
//        
//        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
//            
//            
//            // 0. Create a key for storaging completion block
//            NSString *requestKey = [self requestKey];;
//            
//            // 1. add the completionBlock to the dcitionary
//            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
//            
//            // 2. Listing the request iq XML
//            /*
//             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
//             <project xmlns="aft:project" type="get_template_hash">
//             </project>
//             </iq>
//             */
//            // 3. Create the request iq
//            
//            ChildElement *organizationElement = [ChildElement childElementWithName:@"project"
//                                                                             xmlns:[NSString stringWithFormat:@"%@",ORG_REQUEST_XMLNS]
//                                                                         attribute:@{@"type":@"get_template_hash"}
//                                                                       stringValue:nil];
//            
//            IQElement *iqElement = [IQElement iqElementWithFrom:nil
//                                                             to:nil
//                                                           type:@"get"
//                                                             id:requestKey
//                                                   childElement:organizationElement];
//            
//            // 4. Send the request iq element to the server
//            [[self xmppStream] sendElement:iqElement];
//            
//            // 5. add a timer to call back to user after a long time without server's reponse
//            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
//            
//        }else{
//            // 0. tell the the user that can not send a request
//            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
//        }
//    }};
//    
//    if (dispatch_get_specific(moduleQueueTag))
//        block();
//    else
//        dispatch_async(moduleQueue, block);
//}

@end
