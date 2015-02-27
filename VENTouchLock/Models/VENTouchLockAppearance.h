#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VENTouchLockAppearance : NSObject

/**-----------------------------------------------------------------------------
 * @description Passcode View Controller Preferences
 * -----------------------------------------------------------------------------
 */
@property (strong, nonatomic) UIColor *passcodeViewControllerTitleColor;
@property (strong, nonatomic) UIColor *passcodeViewControllerCharacterColor;
@property (strong, nonatomic) UIColor *passcodeViewControllerBackgroundColor;
@property (assign, nonatomic) BOOL passcodeViewControllerShouldEmbedInNavigationController;
@property (strong, nonatomic) NSString *cancelBarButtonItemTitle;

/**-----------------------------------------------------------------------------
 * @description Create Passcode View Controller Preferences
 * -----------------------------------------------------------------------------
 */
@property (strong, nonatomic) NSString *createPasscodeInitialLabelText;
@property (strong, nonatomic) NSString *createPasscodeConfirmLabelText;
@property (strong, nonatomic) NSString *createPasscodeMismatchedLabelText;
@property (strong, nonatomic) NSString *createPasscodeViewControllerTitle;

/**-----------------------------------------------------------------------------
 * @description Enter Passcode View Controller Preferences
 * -----------------------------------------------------------------------------
 */
@property (strong, nonatomic) NSString *enterPasscodeInitialLabelText;
@property (strong, nonatomic) NSString *enterPasscodeIncorrectLabelText;
@property (strong, nonatomic) NSString *enterPasscodeViewControllerTitle;


/**-----------------------------------------------------------------------------
 * @description Splash Preferences
 * -----------------------------------------------------------------------------
 */
@property (assign, nonatomic) BOOL splashShouldEmbedInNavigationController;

/**-----------------------------------------------------------------------------
 * @description Touch ID Prompt Preferences
 * -----------------------------------------------------------------------------
 */

@property (assign, nonatomic) BOOL touchIDCancelPresentsPasscodeViewController;

@end