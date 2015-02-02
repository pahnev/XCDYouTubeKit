//
//  Copyright (c) 2013-2014 Cédric Luthi. All rights reserved.
//

#import "DemoFullScreenViewController.h"

@implementation DemoFullScreenViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.videoIdentifierTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"VideoIdentifier"];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self.view endEditing:YES];
}

- (IBAction) play:(id)sender
{
	[self.view endEditing:YES];
	
	XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.videoIdentifierTextField.text];
	videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"PlayVideoInBackground"];
	videoPlayerViewController.preferredVideoQualities = self.lowQualitySwitch.on ? @[ @(XCDYouTubeVideoQualitySmall240), @(XCDYouTubeVideoQualityMedium360) ] : nil;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:videoPlayerViewController.moviePlayer];
	[self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
}

#pragma mark - Notifications

- (void) moviePlayerPlaybackDidFinish:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:notification.object];
	MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
	if (finishReason == MPMovieFinishReasonPlaybackError)
	{
		NSString *title = NSLocalizedString(@"Video Playback Error", @"Full screen video error alert - title");
		NSError *error = notification.userInfo[XCDMoviePlayerPlaybackDidFinishErrorUserInfoKey];
		NSString *message = [NSString stringWithFormat:@"%@\n%@ (%@)", error.localizedDescription, error.domain, @(error.code)];
		NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Full screen video error alert - cancel button");
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
		[alertView show];
	}
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[self play:textField];
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	[[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"VideoIdentifier"];
}

@end
