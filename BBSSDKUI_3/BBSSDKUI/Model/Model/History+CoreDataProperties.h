//
//  History+CoreDataProperties.h
//
//
//  Created by chuxiao on 2017/9/21.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "History.h"

NS_ASSUME_NONNULL_BEGIN

@interface History (CoreDataProperties)

@property (nullable, nonatomic, retain) id attachments;
@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSNumber *authorId;
@property (nullable, nonatomic, retain) NSString *avatar;
@property (nullable, nonatomic, retain) NSNumber *createdOn;
@property (nullable, nonatomic, retain) NSString *deviceName;
@property (nullable, nonatomic, retain) NSNumber *digest;
@property (nullable, nonatomic, retain) NSNumber *displayOrder;
@property (nullable, nonatomic, retain) NSNumber *fid;
@property (nullable, nonatomic, retain) NSString *forumName;
@property (nullable, nonatomic, retain) NSNumber *heatLevel;
@property (nullable, nonatomic, retain) NSNumber *highLight;
@property (nullable, nonatomic, retain) NSNumber *historyTime;
@property (nullable, nonatomic, retain) id images;
@property (nullable, nonatomic, retain) NSNumber *lastPost;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSNumber *replies;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *summary;
@property (nullable, nonatomic, retain) NSNumber *tid;
@property (nullable, nonatomic, retain) NSNumber *uid;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *views;
@property (nullable, nonatomic, retain) NSNumber *recommend_add;

@property (nullable, nonatomic, retain) NSString *aid;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *authorid;
@property (nullable, nonatomic, retain) NSNumber *dateline;
@property (nullable, nonatomic, retain) NSNumber *viewnum;
@property (nullable, nonatomic, retain) NSNumber *commentnum;
@property (nullable, nonatomic, retain) NSNumber *sharetimes;
@property (nullable, nonatomic, retain) NSNumber *favtimes;
@property (nullable, nonatomic, retain) NSString *pic;
@property (nullable, nonatomic, retain) NSNumber *click1;
@property (nullable, nonatomic, retain) NSNumber *click2;
@property (nullable, nonatomic, retain) NSNumber *click3;
@property (nullable, nonatomic, retain) NSNumber *click4;
@property (nullable, nonatomic, retain) NSNumber *click5;
@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) id related;
@property (nullable, nonatomic, retain) NSNumber *allowcomment;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *catname;
@property (nullable, nonatomic, retain) NSString *shareurl;
@property (nullable, nonatomic, retain) NSNumber *originUid;

@end

NS_ASSUME_NONNULL_END

