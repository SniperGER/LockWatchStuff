

#import "LWWatchFacePlugin.h"
#import <UIKit/UIKit.h>

#import <WatchFaceBase/WatchIndicators.h>

#error LWWatchFacePlugin is already defined.
@implementation LWWatchFacePlugin

//// IMPORTANT NOTE //////////////////////////////////////////////
//                                                              //
// Watch face plugins must be built for physical devices!       //
// Always build using your physical device or using the         //
// "Generic iOS Device" target                                  //
//                                                              //
// Once built, copy the output (Plugin.watchface) to your       //
// device to /Library/Application Support/LockWatch/Watch faces //
//                                                              //
// Additionally, you should set a name for your watch face.     //
// When doing that, keep in mind that there is an active        //
// localization. Currently there are English and German,        //
// so you should set your watch face name in all languages.     //
//                                                              //
// If you don't want localization, turn it off in the project   //
// settings.                                                    //
//                                                              //
// Also, set the target name (Plugin.watchface) to anything     //
// unique that is not "Plugin". This name is reserved for       //
// internal testing.                                            //
//                                                              //
//////////////////////////////////////////////////////////////////

#warning Have you changed the principal class in Info.plist to this class?
#warning Have you changed the bundle identifier to anything else than "com.yourcompany.watchface.name"?
#warning Have you changed the target name to anything else than "Plugin"?
#warning Have you changed CFBundleDisplayName inside Info.plist (and respective localizations)?

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Set if watch face is customizable
        self.customizable = NO;
        
        // Set your accent color here. Any valid 6 bit Hex string is allowed. Always prepend "#"
        // Default Apple Watch Light Orange: #FF9500
        accentColor = @"#FF9500";
        
        // If you are going to use colored indicators, uncomment the next line
        // Default Apple Watch Blue: #18B5FC
        // accentColorIndicators = @"#18B5FC";
        
        // Watch face initialization code here
        [self renderIndicators:NO];
        [self renderClockHands];
        
        // If customizable, uncomment the next line
        // [self makeCustomizeSheet];
    }
    
    return self;
}

- (void)renderIndicators:(BOOL)customize {
    // Use <WatchFaceBase/WatchIndicators.h> for indicator templates
    
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!customize) {
        indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    }
    
    // Simple Watch face indicators
    // [indicatorContainer addSubview:[[WatchIndicators alloc] simpleIndicators:detailState isCustomizing:customize]];
    
    // Color Watch face indicators
    // [indicatorContainer addSubview:[[WatchIndicators alloc] colorIndicators:accentColorIndicator]];
    
    // Chronograph Watch face indicators
    // [indicatorContainer addSubview:[[WatchIndicators alloc] chronoIndicators]];
    
    [self insertSubview:indicatorContainer atIndex:0];
}
- (void)renderClockHands {
    // Use <WatchFaceBase/WatchHands.h> for hand templates
}

- (void)initWatchFace {
    [super initWatchFace];
    
    // This method gets called everytime the watch face is selected or the app starts with this watch face
    [self updateTime];
}
- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
    
    // This methods gets called everytime the user enters the Selection menu (tap and hold on a watch face)
    // You can differentiate if the watch face was either active or not using wasActiveBefore
}
- (void)reInitWatchFace:(BOOL)initAfterAnimation {
    [super reInitWatchFace:initAfterAnimation];
    
    // This method gets called everytime the user selects a watch face
    // You can differentiate if this watch face is the selected watch face by using initAfterAnimation
}

- (void)makeCustomizeSheet {
    // Use <WatchFaceBase/WatchCustomizations.h> for customization templates;
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    
    // This should probably animate the alpha of customization elements to 1
    // Multi-page support is not yet documented
    
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         // Animate alpha of customization elements
                         [customizeScrollView setAlpha:1]; // Make customize sheet visible
                         
                         // If needed, set the Indicator alpha to 0
                         // [indicatorContainer setAlpha:0];
                         
                         // If needed, set the Watch hand container alpha to 0
                         // [handContainer setAlpha:0];
                         
                         // For visual accessibility, display a customize border
                         // [customizeBorder setAlpha:1];
                         
                     } completion:^(BOOL finished) {
                         // Typically, hands are hidden while customizing a watch face
                         
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                     }];
    
    // Animate the indicators with the pulse as seen on Apple Watch
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [indicatorContainer setTransform:CGAffineTransformMakeScale(0.935, 0.935)];
        [indicatorContainer setTransform:CGAffineTransformMakeScale(1, 1)];
    } completion:nil];
}
-(void) hideCustomizeSheet {
    [super hideCustomizeSheet];
    
    // This method gets called when the user exits editing mode
    // In here, you should set customization alphas to 0 and watch face alphas to 1
}

- (void)updateTime {
    [super updateTime];
    
    // This updates the watch hands to the system time and animates all watch hands
    // If you are using anything else than the stock watch hands, comment [super updateTime] and implement your own method
}

@end
