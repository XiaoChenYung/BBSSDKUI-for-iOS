//
//  BBSSDKTests.m
//  BBSSDKTests
//
//  Created by 崔林豪 on 2018/7/9.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BBSSDK/BBSSDK.h>
#import <BBSSDK/BBSLocation.h>


@interface BBSSDKTests : XCTestCase

@property (nonatomic, strong) BBSUser *user;


@end

@implementation BBSSDKTests

#pragma mark -XCTAssertNil(a1, format...) 为空判断， a1 为空时通过，反之不通过；
#pragma mark -XCTAssertNotNil(a1, format…) 不为空判断，a1不为空时通过，反之不通过

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - 获取版块列表
- (void)testGetForumListWithFup
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetForumListWithFup"];
    
    [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
        XCTAssertNil(error,@"服务端返回错误"); //判断error为空时通过
        XCTAssertNotNil(forumsList,@"列表为空");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testGetForumListWithFupFor100
{
    for (int i = 0 ; i < 100; i++)
    {
        
        XCTestExpectation *exp = [self expectationWithDescription:[NSString stringWithFormat:@"testGetForumListWithFupFor100_%d",i]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
                XCTAssertNil(error,@"服务端返回错误");
                XCTAssertNotNil(forumsList,@"列表为空");

                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
            
        }];
    }
    
}


- (void)testGetForumListWithFupWithWrongParameter
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetCommentList"];
    
    [BBSSDK getForumListWithFup:@"123" result:^(NSArray *forumsList, NSError *error) {
        XCTAssertNil(error,@"不应返回错误");//不应该返回错误
        
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testGetForumListWithFupWithBadNetWork
{
    [self expectationForNotification:@"testGetForumListWithFupWithBadNetWork"
                              object:nil
                             handler:^BOOL(NSNotification * _Nonnull notification) {
                                 
                                 return YES;
                             }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        //模拟这个异步操作需要3秒后才能获取结果，比如一个异步网络请求
        sleep(3);

        [BBSSDK getForumListWithFup:0 result:^(NSArray *forumsList, NSError *error) {
            XCTAssertNil(error, @"Fail to get tags.");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"testGetForumListWithFupWithBadNetWork" object:nil];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:40
                                 handler:^(NSError * _Nullable error) {

                                 }];
}

//getGlobalSettings
#pragma mark - 配置信息
- (void)testGetGlobalSettings
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetGlobalSettings"];
    [BBSSDK getGlobalSettings:^(NSDictionary *settings, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(settings,@"没有配置信息");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testGetGlobalSettingsFor100
{

    for (int i = 0 ; i < 100; i++)
    {
        
        XCTestExpectation *exp = [self expectationWithDescription:[NSString stringWithFormat:@"testGetArticlesType_100_%d",i]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK getGlobalSettings:^(NSDictionary *settings, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(settings,@"没有配置信息");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
            
        }];
    }
    
}

- (void)testGetGlobalSettingsWithNil
{
    [BBSSDK getGlobalSettings:nil];
}


#pragma mark - 获取帖子列表
#pragma mark -XCTAssertNil(a1, format...) 为空判断， a1 为空时通过，反之不通过；
#pragma mark -XCTAssertNotNil(a1, format…) 不为空判断，a1不为空时通过，反之不通过

- (void)testGetThreadListWithFid
{
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadListWithFid"];
    
    [BBSSDK getThreadListWithFid:0 orderType:@"lastPost" selectType:@"latest" pageIndex:1 pageSize:10 result:^(NSArray *threadList, NSError *error) {
        XCTAssertNil(error, @"返回错误");
        XCTAssertNotNil(threadList, @"列表为空");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
    }];
    
}

- (void)testGetThreadListWithFidFor100
{
    
    for (NSInteger i = 0 ; i <= 100; i++)
    {
        XCTestExpectation *exp = [self expectationWithDescription:[NSString stringWithFormat:@"testGetThreadListWithFidFor100_%ld",(long)i]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            [BBSSDK getThreadListWithFid:0 orderType:@"lastPost" selectType:@"latest" pageIndex:1 pageSize:10 result:^(NSArray *threadList, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(threadList,@"没有列表");

                [exp fulfill];
            }];
        });

        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {

        }];
    }
}

- (void)testGetThreadListWithFidWithNil
{
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadListWithFidWithNil"];
    [BBSSDK getThreadListWithFid:nil orderType:nil selectType:nil pageIndex:1 pageSize:nil result:^(NSArray *threadList, NSError *error) {
        
        XCTAssertNotNil(error,@"错误为空");//错误不应该为空
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testGetThreadListWithFidWithWrongParam
{
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadListWithFidWithWrongParam"];
    
    [BBSSDK getThreadListWithFid:@"123" orderType:@12 selectType:@33 pageIndex:@"de" pageSize:@"ss" result:^(NSArray *threadList, NSError *error) {
        
        XCTAssertNotNil(error,@"错误为空");//错误不应该为空
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

#pragma mark - 搜索

- (void)testSearchWithType
{
   
    XCTestExpectation *exp = [self expectationWithDescription:@"testSearchWithType"];
    [BBSSDK searchWithType:@"all" wd:@"ss" pageIndex:1 pageSize:10 result:^(NSArray *threadList, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(threadList,@"没有列表");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testSearchWithTypeFor100
{
    
    for (int i = 0 ; i < 100; i++)
    {
        
        XCTestExpectation *exp = [self expectationWithDescription:[NSString stringWithFormat:@"testSearchWithTypeFor100_%d",i]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK searchWithType:@"all" wd:@"ss" pageIndex:1 pageSize:10 result:^(NSArray *threadList, NSError *error) {
                XCTAssertNil(error,@"服务端返回错误");
                XCTAssertNotNil(threadList,@"列表为空");
                
                [exp fulfill];
            }];
            
        });
        
        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)testSearchWithTypeWithNil
{
    [BBSSDK searchWithType:nil wd:nil pageIndex:nil pageSize:nil result:nil];
}

- (void)testSearchWithTypeWithWrongParam
{
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testSearchWithTypeWithWrongParam"];
    
    [BBSSDK searchWithType:@123 wd:@11 pageIndex:@"123" pageSize:@"ee" result:^(NSArray *threadList, NSError *error) {
        XCTAssertNil(error,@"服务端返回错误");
        XCTAssertNotNil(threadList,@"列表为空");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

//getPostListWithFid
#pragma mark - 获取评论列表
- (void)testGetPostListWithFid
{
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetPostListWithFid"];
    [BBSSDK getPostListWithFid:52 tid:22912 authorId:0 pageIndex:1 pageSize:10 result:^(NSArray *postList, NSError *error) {
        XCTAssertNil(error, @"返回错误");
        XCTAssertNotNil(postList, @"没有列表");
        
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testGetPostListWithFidFor100
{
    
    for (NSInteger i = 0; i <= 100; i++) {
        
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetPostListWithFidFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK getPostListWithFid:52 tid:22912 authorId:0 pageIndex:1 pageSize:10 result:^(NSArray *postList, NSError *error) {
                XCTAssertNil(error,@"服务端返回错误");
                XCTAssertNotNil(postList,@"列表为空");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)testGetPostListWithFidWithNil
{
    [BBSSDK getPostListWithFid:nil tid:nil authorId:nil pageIndex:nil pageSize:nil result:nil];
}

- (void)testGetPostListWithFidWithWrongParam
{
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetPostListWithFidFor100"];
    
    [BBSSDK getPostListWithFid:@"as" tid:@"wewe" authorId:@"rr" pageIndex:@"we" pageSize:@"ww" result:^(NSArray *postList, NSError *error) {
        XCTAssertNil(error,@"服务端返回错误");
        XCTAssertNotNil(postList,@"列表为空");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - 上传图片
- (void)testUploadImageWithContentPath
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testUploadImageWithContentPath"];
    
    //NSString *path = [self pathOfsavedImage:[UIImage BBSImageNamed:@"/Common/wnr3@2x.png"]];
    NSString *path = @"/Users/cuilinhao/Desktop/wps.png";
    [BBSSDK uploadImageWithContentPath:path result:^(NSString *url, NSError *error) {
        XCTAssertNil(error,@"服务端返回错误");
        XCTAssertNotNil(url,@"列表为空");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        
    }];
    
}


- (void)testUploadImageWithContentPathFor100
{
    for (NSInteger i = 0; i <= 100; i ++) {
        
        XCTestExpectation *exp = [self expectationWithDescription:@"testUploadImageWithContentPathFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path = @"/Users/cuilinhao/Desktop/wps.png";
            [BBSSDK uploadImageWithContentPath:path result:^(NSString *url, NSError *error) {
                XCTAssertNil(error,@"服务端返回错误");
                XCTAssertNotNil(url,@"列表为空");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
            
        }];
        
    }
    
}

- (void)testUploadImageWithContentPathWithNil
{
    [BBSSDK uploadImageWithContentPath:nil result:nil];
}

- (void)testUploadImageWithContentPathWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testUploadImageWithContentPathWithWrongParam"];
    
    [BBSSDK uploadImageWithContentPath:@"123" result:^(NSString *url, NSError *error) {
        
        XCTAssertNotNil(error,@"错误为空");//错误不应该为空
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - 登录

- (void)testLoginWithUserName
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testPostThreadWithFid"];
    
    [BBSSDK loginWithUserName:@"aaa111" email:@"" password:@"123456" questionid:0 answer:@"" coordinate:nil result:^(BBSUser *user, id res, NSError *error) {
        XCTAssertNil(error,@"服务端返回错误"); //判断error为空时通过
         [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        
    }];
}


- (void)testLoginWithUserNameFor100
{
    for (int i = 0 ; i < 100; i++)
    {
        XCTestExpectation *exp = [self expectationWithDescription:@"testLoginWithUserNameFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK loginWithUserName:@"aaa111" email:@"" password:@"123456" questionid:0 answer:@"" coordinate:nil result:^(BBSUser *user, id res, NSError *error) {
                XCTAssertNil(error,@"服务端返回错误"); //判断error为空时通过
                [exp fulfill];
            }];
            
        });
        
        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
            
        }];
    }
    
}

- (void)testLoginWithUserNameWithNil
{
    [BBSSDK loginWithUserName:nil email:nil password:nil questionid:nil answer:nil coordinate:nil result:nil];
}

- (void)testLoginWithUserNameWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testLoginWithUserNameWithWrongParam"];
    
    [BBSSDK loginWithUserName:@12 email:@33 password:@11 questionid:nil answer:@33 coordinate:nil result:^(BBSUser *user, id res, NSError *error) {
        XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        NSLog(@"error:%@",error);
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        
    }];
    
}



#pragma mark - 发帖
- (void)testPostThreadWithFid
{
    [self testLoginWithUserName];
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testPostThreadWithFid"];
    
    [BBSSDK postThreadWithFid:36 subject:@"1232312" message:@"123213123123123123" isanonymous:0 hiddenreplies:0 location:nil result:^(NSError *error) {
        
         XCTAssertNil(error,@"服务端返回错误"); //判断error为空时通过
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {

    }];
    
}

- (void)testPostThreadWithFidFor100
{
    for (int i = 0 ; i < 100; i++)
    {
        
        XCTestExpectation *exp = [self expectationWithDescription:[NSString stringWithFormat:@"testPostThreadWithFidFor100_%d",i]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK postThreadWithFid:36 subject:@"1232312" message:@"123213123123123123" isanonymous:0 hiddenreplies:0 location:nil result:^(NSError *error) {
                
                XCTAssertNil(error,@"服务端返回错误"); //判断error为空时通过
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)testPostThreadWithFidWithNil
{
    [BBSSDK postThreadWithFid:nil subject:nil message:nil isanonymous:nil hiddenreplies:nil location:nil result:nil];
}

- (void)testPostThreadWithFidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testPostThreadWithFidWithWrongParam"];
    
    [BBSSDK postThreadWithFid:@"" subject:@12 message:@23 isanonymous:@"12" hiddenreplies:0 location:nil result:^(NSError *error) {
        
        XCTAssertNotNil(error,@"服务端返回错误"); //判断error为空时通过
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - 发评论  ???
- (void)testPostCommentWithFid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testPostCommentWithFid"];
    [BBSSDK postCommentWithFid:36 tid:22887 reppid:0 message:@"werwrwerwer" location:nil result:^(BBSPost *bbsPost, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(bbsPost,@"返回为空");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
    
}

- (void)testPostCommentWithFidFor100
{
    for (int i = 0 ; i < 100; i++)
    {
        XCTestExpectation *exp = [self expectationWithDescription:[NSString stringWithFormat:@"testPostCommentWithFidFor100_%d",i]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK postCommentWithFid:36 tid:22887 reppid:0 message:@"werwrwerwer" location:nil result:^(BBSPost *bbsPost, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(bbsPost,@"返回为空");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)testPostCommentWithFidWithNil
{
    [BBSSDK postCommentWithFid:nil tid:nil reppid:nil message:nil location:nil result:nil];
    
}

- (void)testPostCommentWithFidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testPostCommentWithFidWithWrongParam"];
    [BBSSDK postCommentWithFid:@"ww" tid:@"33" reppid:@"er" message:@32 location:nil result:^(BBSPost *bbsPost, NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - 获取贴子详情
- (void)testGetThreadDetailWithFid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetArticlesDetail"];
    
    [BBSSDK getThreadDetailWithFid:36 tid:22887 result:^(BBSThread *bbsThread, NSError *error) {
        
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(bbsThread,@"没有找到目标文章");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetThreadDetailWithFidFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadDetailWithFidFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getThreadDetailWithFid:36 tid:22887 result:^(BBSThread *bbsThread, NSError *error) {
                
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(bbsThread,@"没有找到目标文章");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
    
}


- (void)testGetThreadDetailWithFidWithNil
{
    [BBSSDK getThreadDetailWithFid:nil tid:nil result:nil];
}

- (void)testGetThreadDetailWithFidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadDetailWithFidWithWrongParam"];
    
    [BBSSDK getThreadDetailWithFid:@"" tid:@"" result:^(BBSThread *bbsThread, NSError *error) {
        
         XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 注册接口
- (void)testRegistUserWithUserName
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testRegistUserWithUserName"];
    
    BBSLocationCoordinate *coordinate  = [[BBSLocationCoordinate alloc] init];
    coordinate.latitude = 37.785835;
    coordinate.longitude = -122.406418;
   
    [BBSSDK registUserWithUserName:@"双飞燕" email:@"1550187282@qq.com" password:@"123456" coordinate:coordinate result:^(BBSUser *user, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(user,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testREgisterUserWithUserNameWithNil
{
    [BBSSDK registUserWithUserName:nil email:nil password:nil coordinate:nil result:nil];
}


- (void)testRegisterUserWithUserNameWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testRegisterUserWithUserNameWithWrongParam"];
    
    [BBSSDK registUserWithUserName:@12 email:@12 password:@13 coordinate:nil result:^(BBSUser *user, NSError *error) {
        XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 授权登录
- (void)testAuthLoginWithOpenid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testAuthLoginWithOpenid"];
    BBSLocationCoordinate *coordinate  = [[BBSLocationCoordinate alloc] init];
    coordinate.latitude = 37.785835;
    coordinate.longitude = -122.406418;
    [BBSSDK authLoginWithOpenid:@"07EDECD78B620ECA68E634D7D2BE1222" unionid:nil authType:@"qq" createNew:nil userName:@"天下林子" email:nil password:nil questionId:nil answer:nil coordinate:coordinate result:^(BBSUser *user, id res, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(user,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testAuthLoginWithOpenidFor100
{
    BBSLocationCoordinate *coordinate  = [[BBSLocationCoordinate alloc] init];
    coordinate.latitude = 37.785835;
    coordinate.longitude = -122.406418;
    
    for (NSInteger i = 0; i <= 100; i++) {
        
        XCTestExpectation *exp = [self expectationWithDescription:@"testAuthLoginWithOpenidFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK authLoginWithOpenid:@"07EDECD78B620ECA68E634D7D2BE1222" unionid:nil authType:@"qq" createNew:nil userName:@"天下林子" email:nil password:nil questionId:nil answer:nil coordinate:coordinate result:^(BBSUser *user, id res, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(user,@"没有数据");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
        
    }
}

- (void)testAuthLoginWithOpenidWithNil
{
    [BBSSDK authLoginWithOpenid:nil unionid:nil authType:nil createNew:nil userName:nil email:nil password:nil questionId:nil answer:nil coordinate:nil result:nil];
}

- (void)testAuthLoginWithOpenidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testAuthLoginWithOpenid"];
    BBSLocationCoordinate *coordinate  = [[BBSLocationCoordinate alloc] init];
    coordinate.latitude = 37.785835;
    coordinate.longitude = -122.406418;
    [BBSSDK authLoginWithOpenid:@133 unionid:nil authType:@22 createNew:nil userName:@12 email:nil password:nil questionId:nil answer:nil coordinate:coordinate result:^(BBSUser *user, id res, NSError *error) {
        XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 登出

- (void)testLogout
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testLogout"];
    [BBSSDK logout:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testLogoutWithNil
{
    [BBSSDK logout:nil];
}

#pragma mark - 修改用户信息
- (void)testEditUserInfoWithGender
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testEditUserInfoWithGender"];
    [BBSSDK editUserInfoWithGender:1 birthday:@"2009-05-09" residence:nil sightml:nil avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil result:^(BBSUser *user, NSError *error) {
        
        XCTAssertNil(error,@"返回错误");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testEditUserInfoWithGenderFor100
{
    [self testLoginWithUserName];
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testEditUserInfoWithGenderFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK editUserInfoWithGender:1 birthday:@"2009-05-09" residence:nil sightml:nil avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil result:^(BBSUser *user, NSError *error) {
                
                XCTAssertNil(error,@"返回错误");
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

    }
}

- (void)testEditUserInfoWithGenderWithNil
{
    [BBSSDK editUserInfoWithGender:nil birthday:nil residence:nil sightml:nil avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil result:nil];
    
}

- (void)testEditUserInfoWithGenderWithWrongParam
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testEditUserInfoWithGender"];
    [BBSSDK editUserInfoWithGender:@"" birthday:@22 residence:nil sightml:nil avatarBigUrl:nil avatarMiddleUrl:nil avatarSmallUrl:nil result:^(BBSUser *user, NSError *error) {
        
        XCTAssertNotNil(error,@"返回错误");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 上传头像

#define BBSUIUserAvatarTmpPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BBSUIUserAvatar.JPEG"]

- (void)testUploadAvatarWithContentPath
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testUploadAvatarWithContentPath"];
    ///Users/cuilinhao/Desktop/wps.png
    [BBSSDK uploadAvatarWithContentPath:@"/Users/cuilinhao/Desktop/wps.png" scales:@[@48, @120, @200] result:^(NSArray *urlsDic, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}


- (void)testUploadAvatarWithContentPathFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testUploadAvatarWithContentPathFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK uploadAvatarWithContentPath:@"/Users/cuilinhao/Desktop/wps.png" scales:@[@48, @120, @200] result:^(NSArray *urlsDic, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testUploadAvatarWithContentPathWithNil
{
    [BBSSDK uploadAvatarWithContentPath:nil scales:nil result:nil];
}

- (void)testUploadAvatarWithContentPathWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testUploadAvatarWithContentPathWithWrongParam"];
    
    [BBSSDK uploadAvatarWithContentPath:@"" scales:@[@48, @120, @200] result:^(NSArray *urlsDic, NSError *error) {
         XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

#pragma mark - 获取个人详情页信息

- (void)testGetProfileInfoWithAuthorid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetProfileInfoWithAuthorid"];
    
    [BBSSDK getProfileInfoWithAuthorid:1270 time:@"1531294124" result:^(BBSUser *user, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(user,@"没有获取数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

- (void)testGetProfileInfoWithAuthoridFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetProfileInfoWithAuthoridFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getProfileInfoWithAuthorid:1270 time:@"1531294124" result:^(BBSUser *user, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(user,@"没有获取数据");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
    
}

- (void)testGetProfileInfoWithAuthoridWithNil
{
    [BBSSDK getProfileInfoWithAuthorid:nil time:nil result:nil];
    
}

#pragma mark - 获取个人信息
- (void)testGetUserInfoWithUserName
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetArticlesDetail"];
    
    [BBSSDK getUserInfoWithUserName:@"aaa111" result:^(BBSUser *bbsUser, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(bbsUser,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetUserInfoWithUserNameFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadDetailWithFidFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK getUserInfoWithUserName:@"aaa111" result:^(BBSUser *bbsUser, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(bbsUser,@"没有数据");
                
                [exp fulfill];
            }];
            
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}


- (void)testGetUserInfoWithUserNameWithNil
{
    [BBSSDK getUserInfoWithUserName:nil result:nil];
}


- (void)testGetUserInfoWithUserNameWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetUserInfoWithUserNameWithWrongParam"];
    [BBSSDK getUserInfoWithUserName:@32 result:^(BBSUser *user, NSError *error) {
        XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

#pragma mark - 获取好友列表
- (void)testGetFirendsWithAuthorid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetFirendsWithAuthorid"];
    
    [BBSSDK getFirendsWithAuthorid:nil pageIndex:1 pageSize:10 result:^(NSArray<BBSFans *> *fans, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(fans,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

- (void)testGetFirendsWithAuthoridFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetThreadDetailWithFidFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getFirendsWithAuthorid:nil pageIndex:1 pageSize:10 result:^(NSArray<BBSFans *> *fans, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(fans,@"没有数据");
                
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testGetFirendsWithAuthoridWithNil
{
    [BBSSDK getFirendsWithAuthorid:nil pageIndex:nil pageSize:nil result:nil];
}

#pragma mark - 获取粉丝列表
- (void)testGetFollowersWithAuthorid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetFollowersWithAuthorid"];
    [BBSSDK getFollowersWithAuthorid:nil pageIndex:1 pageSize:10 result:^(NSArray<BBSFans *> *fans, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(fans,@"没有数据");
                        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

- (void)testGetFollowersWithAuthoridFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetFollowersWithAuthoridFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [BBSSDK getFollowersWithAuthorid:nil pageIndex:1 pageSize:10 result:^(NSArray<BBSFans *> *fans, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(fans,@"没有数据");
                
                [exp fulfill];
            }];
            
        });
                
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
            }
}

- (void)testGetFollowersWithAuthoridWithNil
{
    [BBSSDK getFollowersWithAuthorid:nil pageIndex:nil pageSize:nil result:nil];
}


#pragma mark - 关注
- (void)testFollowWithFollowuid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testFollowWithFollowuid"];
    
    [BBSSDK followWithFollowuid:1270 result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
                        
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}


- (void)testFollowWithFollowuidWithNil
{
    [BBSSDK followWithFollowuid:nil result:nil];
}

- (void)testFollowWithFollowuidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testFollowWithFollowuidWithWrongParam"];
    
    [BBSSDK followWithFollowuid:@1 result:^(NSError *error) {
        XCTAssertNotNil(error,"错误为空");//错误不应该为空
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}


#pragma mark - 取消关注
- (void)testUnfollowWithFollowuid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testUnfollowWithFollowuid"];
    
    [BBSSDK unfollowWithFollowuid:1270 result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}


- (void)testUnfollowWithFollowuidWithNil
{
    [BBSSDK unfollowWithFollowuid:nil result:nil];
    
}


#pragma mark - 获取消息列表
- (void)testGetNotificationsWithPageIndex
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetNotificationsWithPageIndex"];
    
    [BBSSDK getNotificationsWithPageIndex:1 pageSize:10 result:^(NSArray<BBSInformation *> *array, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(array,@"没有数据");
                        
        [exp fulfill];
    }];
                        
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

- (void)testGetNotificationsWithPageIndexFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetNotificationsWithPageIndexFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getNotificationsWithPageIndex:1 pageSize:10 result:^(NSArray<BBSInformation *> *array, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(array,@"没有数据");
                
                [exp fulfill];
            }];
     });
                
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
        
    }
}

- (void)testGetNotificationsWithPageIndexWithNil
{
    [BBSSDK getNotificationsWithPageIndex:nil pageSize:nil result:nil];
}

#pragma mark - 获取个人帖子列表

- (void)testGetUserThreadListWithAuthorid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetUserThreadListWithAuthorid"];
    
    [BBSSDK getUserThreadListWithAuthorid:nil pageIndex:1 pageSize:10 result:^(NSArray<BBSThread *> *array, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(array,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];

}

- (void)testGetUserThreadListWithAuthoridFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetUserThreadListWithAuthoridFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK getUserThreadListWithAuthorid:nil pageIndex:1 pageSize:10 result:^(NSArray<BBSThread *> *array, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(array,@"没有数据");
                
                [exp fulfill];
            }];
            
        });
                
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testGetUserThreadListWithAuthoridWithNil
{
    [BBSSDK getUserThreadListWithAuthorid:nil pageIndex:nil pageSize:nil result:nil];
}


#pragma mark - 获取收藏帖子列表
- (void)testGetUserThreadFavoritesWithPageIndex
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetUserThreadFavoritesWithPageIndex"];
    
    [BBSSDK getUserThreadFavoritesWithPageIndex:1 pageSize:10 result:^(NSArray<BBSThread *> *array, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(array,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetUserThreadFavoritesWithPageIndexFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetUserThreadFavoritesWithPageIndexFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [BBSSDK getUserThreadFavoritesWithPageIndex:1 pageSize:10 result:^(NSArray<BBSThread *> *array, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(array,@"没有数据");
                
                [exp fulfill];
            }];
                                
        });
                
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testGetUserThreadFavoritesWithPageIndexWithNil
{
    [BBSSDK getUserThreadFavoritesWithPageIndex:nil pageSize:nil result:nil];
}

- (void)getUser
{
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%lu",time];
    
    __weak typeof(self) weakSelf = self;
    [BBSSDK getProfileInfoWithAuthorid:-1 time:strTime result:^(BBSUser *user, NSError *error) {
        if (!error)
        {
            weakSelf.user = user;
        }
        
    }];
}

#pragma mark - 获取签到地址
- (void)testGetSginUrlWithType
{
    [self getUser];
    long time = [[NSDate date] timeIntervalSince1970];
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetSginUrlWithType"];
    
    [BBSSDK getSginUrlWithType:@"1" userUid:self.user.uid enterSignUrl:self.user.signurl time:time Result:^(NSString *sginUrl, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(sginUrl,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    
}

- (void)testGetSginUrlWithTypeFor100
{
    [self getUser];
    long time = [[NSDate date] timeIntervalSince1970];
    
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetSginUrlWithTypeFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getSginUrlWithType:@"1" userUid:self.user.uid enterSignUrl:self.user.signurl time:time Result:^(NSString *sginUrl, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(sginUrl,@"没有数据");
                
                [exp fulfill];
            }];
        });
                
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testGetSginUrlWithTypeWithNil
{
    long time = [[NSDate date] timeIntervalSince1970];
    [BBSSDK getSginUrlWithType:nil userUid:nil enterSignUrl:nil time:time Result:nil];
}

#pragma mark - 喜欢帖子
- (void)testlikeThreadWithFid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testlikeThreadWithFid"];
    
    [BBSSDK likeThreadWithFid:36 tid:22887 result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");

        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}


- (void)testlikeThreadWithFidWithNil
{
    [BBSSDK likeThreadWithFid:nil tid:nil result:nil];
}

- (void)testlikeThreadWithFidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testlikeThreadWithFidWithWrongParam"];
    
    [BBSSDK likeThreadWithFid:@22 tid:@"" result:^(NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 收藏帖子
- (void)testFavoriteThreadWithFid
{
    [self testLoginWithUserName];
    
    XCTestExpectation *exp = [self expectationWithDescription:@"testFavoriteThreadWithFid"];
    
    [BBSSDK favoriteThreadWithFid:40 tid:22886 result:^(NSDictionary *favorite, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(favorite,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}


- (void)testFavoriteThreadWithFidWithNil
{
    [BBSSDK favoriteThreadWithFid:nil tid:nil result:nil];
}

#pragma mark - 取消收藏
- (void)testUnFavoriteThreadWithFavid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testUnFavoriteThreadWithFavid"];
    
    [BBSSDK unFavoriteThreadWithFavid:@"559" result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testUnFavoriteThreadWithFavidWithNil
{
    [BBSSDK unFavoriteThreadWithFavid:nil result:nil];
}


- (void)testUnFavoriteThreadWithFavidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testUnFavoriteThreadWithFavidWithWrongParam"];
    
    [BBSSDK unFavoriteThreadWithFavid:@"" result:^(NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 设置消息已读
- (void)testReadNotificationWithNoid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testReadNotificationWithNoid"];
    
    [BBSSDK readNotificationWithNoid:@"5b3a1dd4e4b0c974d5d70be5#mob_follow" result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testReadNotificationWithNoidFor100
{
    for (NSInteger i = 0; i <= 100; i++)
    {
        XCTestExpectation *exp = [self expectationWithDescription:@"testReadNotificationWithNoidFor100"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK readNotificationWithNoid:@"5b3a1dd4e4b0c974d5d70be5#mob_follow" result:^(NSError *error) {
                XCTAssertNil(error,@"返回错误");
                [exp fulfill];
            }];
        });
        
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testReadNotificationWithNoidWithNil
{
    [BBSSDK readNotificationWithNoid:nil result:nil];
}

- (void)testReadNotificationWithNoidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testReadNotificationWithNoidWithWrongParam"];
    
    [BBSSDK readNotificationWithNoid:@"" result:^(NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 删除消息
- (void)testDeleteNotificationWithNoid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testDeleteNotificationWithNoid"];
    
    [BBSSDK deleteNotificationWithNoid:@"5b3a1dd4e4b0c974d5d70be5#mob_follow" result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}


- (void)testDeleteNotificationWithNoidWithNil
{
    [BBSSDK deleteNotificationWithNoid:nil result:nil];
}

- (void)testDeleteNotificationWithNoidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testDeleteNotificationWithNoidWithWrongParam"];
    
    [BBSSDK deleteNotificationWithNoid:@"" result:^(NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - 获取banner热帖列表
- (void)testGetBannerList
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetBannerList"];
    
    [BBSSDK getBannerList:^(NSArray *bannnerList, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(bannnerList,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetBannerListFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
         XCTestExpectation *exp = [self expectationWithDescription:@"testGetBannerListFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getBannerList:^(NSArray *bannnerList, NSError *error) {
                XCTAssertNotNil(bannnerList,@"没有数据");
                
                [exp fulfill];
            }];
        });
         [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testGetBannerListWithNil
{
    [BBSSDK getBannerList:nil];
}

#pragma mark - 举报
- (void)testAccusationWithRtype
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testAccusationWithRtype"];
    [BBSSDK accusationWithRtype:@"thread" rid:22887 fid:36 message:@"广告内容" result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}


- (void)testAccusationWithRtypeWithNil
{
    [BBSSDK accusationWithRtype:nil rid:nil fid:nil message:nil result:nil];
}

- (void)testAccusationWithRtypeWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testAccusationWithRtypeWithWrongParam"];
    [BBSSDK accusationWithRtype:@"" rid:0 fid:0 message:@"广告内容" result:^(NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

#pragma mark - *********** 门户 **********
#pragma mark - 获取热帖banner列表
- (void)testGetPortalBannerList
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetPortalBannerList"];
    
    [BBSSDK getPortalBannerList:^(NSArray *bannnerList, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(bannnerList,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetPortalBannerListFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetPortalBannerListFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            [BBSSDK getPortalBannerList:^(NSArray *bannnerList, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(bannnerList,@"没有数据");
                
                [exp fulfill];
            }];
        });
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

#pragma mark -  获取帖子列表
- (void)testGetPortalListWithCatid
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetPortalListWithCatid"];
    
    [BBSSDK getPortalListWithCatid:1 pageIndex:1 pageSize:10 result:^(NSArray *threadList, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(threadList,@"没有数据");
        
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetPortalListWithCatidFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetPortalListWithCatidFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getPortalListWithCatid:1 pageIndex:1 pageSize:10 result:^(NSArray *threadList, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(threadList,@"没有数据");
                
                [exp fulfill];
            }];
        });
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

- (void)testGetPortalListWithCatidWithNil
{
    [BBSSDK getPortalListWithCatid:nil pageIndex:nil pageSize:nil result:nil];
}

#pragma mark - 获取当前用户的关注用户的帖子列表
- (void)testGetFollowThreadsListWithPageIndex
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetFollowThreadsListWithPageIndex"];
    [BBSSDK getFollowThreadsListWithPageIndex:1 pageSize:10 result:^(NSArray *followList, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(followList,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetFollowThreadsListWithPageIndexFor100
{
    for (NSInteger i = 0; i<= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetFollowThreadsListWithPageIndexFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getFollowThreadsListWithPageIndex:1 pageSize:10 result:^(NSArray *followList, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(followList,@"没有数据");
                
                [exp fulfill];
            }];
        });
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

#pragma mark - 获取门户频道列表
- (void)testGetPortalCategories
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testGetPortalCategories"];
    
    [BBSSDK getPortalCategories:^(NSArray *categories, NSError *error) {
        XCTAssertNil(error,@"返回错误");
        XCTAssertNotNil(categories,@"没有数据");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testGetPortalCategoriesFor100
{
    for (NSInteger i = 0; i <= 100; i++) {
        XCTestExpectation *exp = [self expectationWithDescription:@"testGetPortalCategoriesFor100"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [BBSSDK getPortalCategories:^(NSArray *categories, NSError *error) {
                XCTAssertNil(error,@"返回错误");
                XCTAssertNotNil(categories,@"没有数据");
                
                [exp fulfill];
            }];
        });
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
    }
}

#pragma mark - 门户点赞
- (void)testLikePortalWithAid
{
    [self testLoginWithUserName];
    XCTestExpectation *exp = [self expectationWithDescription:@"testLikePortalWithAid"];
    
    [BBSSDK likePortalWithAid:30 clickid:@(1) result:^(NSError *error) {
        XCTAssertNil(error,@"返回错误");
        
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}

- (void)testLikePortalWithAidWithNil
{
    [BBSSDK likePortalWithAid:nil clickid:nil result:nil];
}

- (void)testLikePortalWithAidWithWrongParam
{
    XCTestExpectation *exp = [self expectationWithDescription:@"testLikePortalWithAidWithWrongParam"];
    [BBSSDK likePortalWithAid:0 clickid:@0 result:^(NSError *error) {
        XCTAssertNotNil(error,@"返回错误");
        
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {}];
}


@end
