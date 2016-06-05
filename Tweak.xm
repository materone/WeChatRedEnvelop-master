#import "WeChatRedEnvelop.h"
#import <unistd.h>



static BOOL wxhbEnable = YES; // Default value
static int mDelay = 2000;

static void loadPrefs()
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.chufan.wxprefr.plist"];
    if(prefs)
    {
        wxhbEnable = ( [prefs objectForKey:@"isOn"] ? [[prefs objectForKey:@"isOn"] boolValue] : wxhbEnable );
        mDelay = ( [prefs objectForKey:@"delay"] ? [[prefs objectForKey:@"delay"] intValue] : mDelay );
    }else{
    	NSLog(@"WX init fail =============");
    }
    [prefs release];
    NSLog(@"WX Prefs is changed ======== %@:%d",wxhbEnable?@"YES":@"NO",mDelay);
}

%ctor 
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.chufan.wxredenvpref/settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
    NSLog(@"WX Prefs is Inited ======== ");
}

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
	%orig;
	//%log(@"In Weixin message =========");
	switch(wrap.m_uiMessageType) {
	case 49: { // AppNode
		if(!wxhbEnable) break;//总开关关闭
		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		CContact *selfContact = [contactManager getSelfContact];

		BOOL isMesasgeFromMe = NO;
		if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
			isMesasgeFromMe = YES;
		}

		if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) { // 红包
			if ([wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound ||
				(isMesasgeFromMe && [wrap.m_nsToUsr rangeOfString:@"@chatroom"].location != NSNotFound)) { // 群组红包或群组里自己发的红包

				NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
				nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

				NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

				/** 构造参数 */
				NSMutableDictionary *params = [@{} mutableCopy];
				[params safeSetObject:nativeUrlDict[@"msgtype"] forKey:@"msgType"];
				[params safeSetObject:nativeUrlDict[@"sendid"] forKey:@"sendId"];
				[params safeSetObject:nativeUrlDict[@"channelid"] forKey:@"channelId"];
				[params safeSetObject:[selfContact getContactDisplayName] forKey:@"nickName"];
				[params safeSetObject:[selfContact m_nsHeadImgUrl] forKey:@"headImg"];
				[params safeSetObject:[[wrap m_oWCPayInfoItem] m_c2cNativeUrl] forKey:@"nativeUrl"];
				[params safeSetObject:wrap.m_nsFromUsr forKey:@"sessionUserName"];	

				//slow the click
				NSUInteger ctime = wrap.m_uiCreateTime;
				NSDate *now = [NSDate date];
				NSInteger interval = round([now timeIntervalSince1970]);  
				if((interval - ctime)< 30){
					usleep(mDelay<<10);//如果红包发放时间小于30s，就暂停2s
				}
				NSLog(@"%lu hbtime, %ld now",ctime,interval);
				WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
				[logicMgr OpenRedEnvelopesRequest:params];
			}
		}	
		break;
	}
	default:
		break;
	}
}
%end
