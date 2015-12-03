//
//  XMPPvCardTempModule.m
//  XEP-0054 vCard-temp
//
//  Created by Eric Chamberlain on 3/17/11.
//  Copyright 2011 RF.com. All rights reserved.
//

#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardTemp.h"
#import "XMPPIDTracker.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
  static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // | XMPP_LOG_FLAG_TRACE;
#else
  static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface XMPPvCardTempModule()

- (void)_updatevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid;
- (void)_fetchvCardTempForJID:(XMPPJID *)jid;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XMPPvCardTempModule

@synthesize xmppvCardTempModuleStorage = _xmppvCardTempModuleStorage;

- (id)init
{
	// This will cause a crash - it's designed to.
	// Only the init methods listed in XMPPvCardTempModule.h are supported.
	
	return [self initWithvCardStorage:nil dispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
	// This will cause a crash - it's designed to.
	// Only the init methods listed in XMPPvCardTempModule.h are supported.
	
	return [self initWithvCardStorage:nil dispatchQueue:NULL];
}

- (id)initWithvCardStorage:(id <XMPPvCardTempModuleStorage>)storage
{
	return [self initWithvCardStorage:storage dispatchQueue:NULL];
}

- (id)initWithvCardStorage:(id <XMPPvCardTempModuleStorage>)storage dispatchQueue:(dispatch_queue_t)queue
{
	NSParameterAssert(storage != nil);
	
	if ((self = [super initWithDispatchQueue:queue]))
	{
		if ([storage configureWithParent:self queue:moduleQueue])
		{
			_xmppvCardTempModuleStorage = storage;
		}
		else
		{
			XMPPLogError(@"%@: %@ - Unable to configure storage!", THIS_FILE, THIS_METHOD);
		}
	}
	return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
	if ([super activate:aXmppStream])
	{
		// Custom code goes here (if needed)
		
        _myvCardTracker = [[XMPPIDTracker alloc] initWithStream:xmppStream dispatchQueue:moduleQueue];

		return YES;
	}
	
	return NO;
}

- (void)deactivate
{
	// Custom code goes here (if needed)
    
    dispatch_block_t block = ^{ @autoreleasepool {
		
		[_myvCardTracker removeAllIDs];
		_myvCardTracker = nil;
		
	}};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
	
	[super deactivate];
}

- (void)dealloc
{
	_xmppvCardTempModuleStorage = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Fetch vCardTemp methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)fetchvCardTempForJID:(XMPPJID *)jid
{
	return [self fetchvCardTempForJID:jid ignoreStorage:NO];
}

- (void)fetchvCardTempForJID:(XMPPJID *)jid ignoreStorage:(BOOL)ignoreStorage
{	
	dispatch_block_t block = ^{ @autoreleasepool {
		
		XMPPvCardTemp *vCardTemp = nil;
		
		if (!ignoreStorage)
		{
			// Try loading from storage
			vCardTemp = [_xmppvCardTempModuleStorage vCardTempForJID:jid xmppStream:xmppStream];
		}
		
		if (vCardTemp == nil && [_xmppvCardTempModuleStorage shouldFetchvCardTempForJID:jid xmppStream:xmppStream])
		{
			[self _fetchvCardTempForJID:jid];
		}
		
	}};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_async(moduleQueue, block);
}

- (void)requestvCardTempWithTagForJID:(NSString *)bareJidStr
{
    [self requestvCardTempWithTagForJID:bareJidStr ignoreStorage:NO];
}

- (void)requestvCardTempWithTagForJID:(NSString *)bareJidStr ignoreStorage:(BOOL)ignoreStorage
{
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSString *photoHash = [_xmppvCardTempModuleStorage photoHashForvCardTempForJID:[XMPPJID jidWithString:bareJidStr] xmppStream:xmppStream];
        
        XMPPvCardTemp *vCardTemp = nil;
        
        XMPPJID *jid = [XMPPJID jidWithString:bareJidStr];
        
        if (!ignoreStorage)
        {
            // Try loading from storage
            vCardTemp = [_xmppvCardTempModuleStorage vCardTempForJID:jid xmppStream:xmppStream];
        }
        
        if (vCardTemp == nil && [_xmppvCardTempModuleStorage shouldFetchvCardTempForJID:jid xmppStream:xmppStream])
        {
            [self _requestvCardTempWithTag:photoHash bareJidStr:bareJidStr];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)requestvCardTempWithTag:(NSString *)tag bareJidStr:(NSString *)bareJidStr ignoreStorage:(BOOL)ignoreStorage
{
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        XMPPvCardTemp *vCardTemp = nil;
        
        XMPPJID *jid = [XMPPJID jidWithString:bareJidStr];
        
        if (!ignoreStorage)
        {
            // Try loading from storage
            vCardTemp = [_xmppvCardTempModuleStorage vCardTempForJID:jid xmppStream:xmppStream];
        }
        
        if (vCardTemp == nil && [_xmppvCardTempModuleStorage shouldFetchvCardTempForJID:jid xmppStream:xmppStream])
        {
            [self _requestvCardTempWithTag:tag bareJidStr:bareJidStr];
        }

        
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
    
}

- (void)_requestvCardTempWithTag:(NSString *)tag bareJidStr:(NSString *)bareJidStr
{

    if (!dispatch_get_specific(moduleQueueTag)) return;
    
    if(!bareJidStr) return;
    
    [xmppStream sendElement:[XMPPvCardTemp iqvCardRequestForJID:[XMPPJID jidWithString:bareJidStr] photoHash:tag iqId:nil]];
}

- (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid shouldFetch:(BOOL)shouldFetch{
    
    __block XMPPvCardTemp *result;
	
	dispatch_block_t block = ^{ @autoreleasepool {
		
		XMPPvCardTemp *vCardTemp = [_xmppvCardTempModuleStorage vCardTempForJID:jid xmppStream:xmppStream];
		
		if (vCardTemp == nil && shouldFetch && [_xmppvCardTempModuleStorage shouldFetchvCardTempForJID:jid xmppStream:xmppStream])
		{
			[self _fetchvCardTempForJID:jid];
		}
		
		result = vCardTemp;
	}};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
	
	return result;
}

- (XMPPvCardTemp *)myvCardTemp
{
	return [self vCardTempForJID:[xmppStream myJID] shouldFetch:YES];
}

- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp
{
    
    dispatch_block_t block = ^{ @autoreleasepool {

        XMPPvCardTemp *newvCardTemp = [vCardTemp copy];
        
        XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:nil elementID:[xmppStream generateUUID] child:newvCardTemp];
        [xmppStream sendElement:iq];
        
        [_myvCardTracker addElement:iq
                             target:self
                           selector:@selector(handleMyvcard:withInfo:)
                            timeout:600];
        
        [self _updatevCardTemp:newvCardTemp forJID:[xmppStream myJID]];
        
    }};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_async(moduleQueue, block);

}

- (void)vCardWithBareJidStr:(NSString *)bareJidStr completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        // if there is vCard in the database,we should return the existed vCard
        XMPPvCardTemp *vCardTemp = [_xmppvCardTempModuleStorage vCardTempForJID:[XMPPJID jidWithString:bareJidStr] xmppStream:xmppStream];
        
        if (vCardTemp != nil) {
            completionBlock(vCardTemp, nil);
            return;
        }
        
        
        // if there is no vCard in the database, we should request from server
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_template_hash">
             </project>
             </iq>
             */
            // 3. Create the request iq
            
            XMPPIQ *iqElement = [XMPPvCardTemp iqvCardRequestForJID:[XMPPJID jidWithString:bareJidStr] iqId:requestKey];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)requestvCardWithBareJidStr:(NSString *)bareJidStr completionBlock:(CompletionBlock)completionBlock
{
    dispatch_block_t block = ^{@autoreleasepool{
        
        if ([self canSendRequest]) {// we should make sure whether we can send a request to the server
            
            
            // 0. Create a key for storaging completion block
            NSString *requestKey = [self requestKey];;
            
            // 1. add the completionBlock to the dcitionary
            [requestBlockDcitionary setObject:completionBlock forKey:requestKey];
            
            // 2. Listing the request iq XML
            /*
             <iq from="ddde03a3151945abbed57117eb7cb31f@192.168.1.164/Gajim" id="5244001" type="get">
             <project xmlns="aft:project" type="get_template_hash">
             </project>
             </iq>
             */
            // 3. Create the request iq
            
            NSString *photoHash = [_xmppvCardTempModuleStorage photoHashForvCardTempForJID:[XMPPJID jidWithString:bareJidStr] xmppStream:xmppStream];
            
            XMPPIQ *iqElement = [XMPPvCardTemp iqvCardRequestForJID:[XMPPJID jidWithString:bareJidStr] photoHash:photoHash iqId:requestKey];
            
            // 4. Send the request iq element to the server
            [[self xmppStream] sendElement:iqElement];
            
            // 5. add a timer to call back to user after a long time without server's reponse
            [self _removeCompletionBlockWithDictionary:requestBlockDcitionary requestKey:requestKey];
            
        }else{
            // 0. tell the the user that can not send a request
            [self _callBackWithMessage:@"you can not send this iq before logining" completionBlock:completionBlock];
        }
    }};
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_updatevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid
{
    if(!jid) return;
    
	// this method could be called from anywhere
	dispatch_block_t block = ^{ @autoreleasepool {
		
		XMPPLogVerbose(@"%@: %s %@", THIS_FILE, __PRETTY_FUNCTION__, [jid bare]);
		
		[_xmppvCardTempModuleStorage setvCardTemp:vCardTemp forJID:jid xmppStream:xmppStream];
		
		[(id <XMPPvCardTempModuleDelegate>)multicastDelegate xmppvCardTempModule:self
		                                                     didReceivevCardTemp:vCardTemp
		                                                                  forJID:jid];
	}};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_async(moduleQueue, block);
}

- (void)_fetchvCardTempForJID:(XMPPJID *)jid{
    if(!jid) return;

    [xmppStream sendElement:[XMPPvCardTemp iqvCardRequestForJID:jid]];
}

- (void)handleMyvcard:(XMPPIQ *)iq withInfo:(XMPPBasicTrackingInfo *)trackerInfo{

    if([iq isResultIQ])
    {
        [(id <XMPPvCardTempModuleDelegate>)multicastDelegate xmppvCardTempModuleDidUpdateMyvCard:self];
    }
    else if([iq isErrorIQ])
    {
        NSXMLElement *errorElement = [iq elementForName:@"error"];
        [(id <XMPPvCardTempModuleDelegate>)multicastDelegate xmppvCardTempModule:self failedToUpdateMyvCard:errorElement];
    }        

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	// This method is invoked on the moduleQueue.
	
    [_myvCardTracker invokeForElement:iq withObject:iq];
    
	// Remember XML heirarchy memory management rules.
	// The passed parameter is a subnode of the IQ, and we need to pass it to an asynchronous operation.
	// 
	// Therefore we use vCardTempCopyFromIQ instead of vCardTempSubElementFromIQ.
    
    NSXMLElement *vCardTempTagElement = [iq elementForName:kXMPPvCardTempTagElement xmlns:kXMPPNSvCardTemp];
    
    if (vCardTempTagElement != nil) {// 是比较tag的请求
        
        NSXMLElement *vCardElement = [vCardTempTagElement elementForName:kXMPPvCardTempElement xmlns:kXMPPNSvCardTemp];
        
        if (vCardElement != nil) {// 返回有新的vCard，存数据库并返回block
            // 0.新的vCard
            XMPPvCardTemp *vCardObject = [XMPPvCardTemp vCardTempFromElement:vCardElement];
            // 1.存储
            [self _updatevCardTemp:vCardObject forJID:[[iq from] bareJID]];
            // 2.返回给逻辑层
            [self _executeRequestBlockWithRequestKey:[iq elementID] valueObject:vCardObject];
            
        }else{// 相同，没有新的vCard,从数据取给逻辑层
            
            XMPPvCardTemp *vCardTemp = [_xmppvCardTempModuleStorage vCardTempForJID:[[iq from] bareJID] xmppStream:xmppStream];
            [self _executeRequestBlockWithRequestKey:[iq elementID] valueObject:vCardTemp];
        }
        
        return YES;
    }
    
    // 一般请求
	XMPPvCardTemp *vCardTemp = [XMPPvCardTemp vCardTempCopyFromIQ:iq];
	if (vCardTemp != nil){
        // 1.存储
		[self _updatevCardTemp:vCardTemp forJID:[iq from]];
        
        // 2.返回给逻辑层
        [self _executeRequestBlockWithRequestKey:[iq elementID] valueObject:vCardTemp];
        
		return YES;
    }
	
	return NO;
}

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
    
    [_myvCardTracker removeAllIDs];
}

- (BOOL)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    return [self _executeRequestBlockWithElementName:kXMPPvCardTempTagElement xmlns:kXMPPNSvCardTemp sendIQ:iq];
}

@end
