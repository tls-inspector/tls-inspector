#import <Foundation/Foundation.h>
#im

@interface AppState : NSObject

+ (AppState *) currentState;
- (id) init;
@property (strong, nonatomic) SplitViewController * splitViewController;
@property (strong, nonatomic) ZoneListTableViewController * zoneListViewController;

@end
