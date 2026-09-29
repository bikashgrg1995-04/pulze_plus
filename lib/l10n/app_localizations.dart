import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// Title for the App Preferences settings section.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// Label for notification preferences.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Label for donation reminder preference.
  ///
  /// In en, this message translates to:
  /// **'Donation Reminder'**
  String get donationReminder;

  /// Label for theme preference.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Label for language preference.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Profile activity section title.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Profile activity section subtitle.
  ///
  /// In en, this message translates to:
  /// **'View your requests and donations'**
  String get viewRequestsAndDonations;

  /// Menu item for the user's blood requests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// Menu item for the user's donation history.
  ///
  /// In en, this message translates to:
  /// **'Donation History'**
  String get donationHistory;

  /// Profile settings section title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile settings section subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and preferences'**
  String get manageAccountAndPreferences;

  /// Privacy and security settings title.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// Account settings title.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Help and support section title.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Sign out action label.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Change password settings option.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Change password option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateAccountPassword;

  /// App permissions settings option.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissions;

  /// App permissions option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage camera and location permissions'**
  String get manageCameraLocationPermissions;

  /// Privacy policy settings option.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how Pulze+ handles your information'**
  String get learnHowPulzeHandlesInformation;

  /// Terms and conditions settings option.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// Terms and conditions option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review Pulze+ terms of use'**
  String get reviewPulzeTerms;

  /// Donor status account setting.
  ///
  /// In en, this message translates to:
  /// **'Donor Status'**
  String get donorStatus;

  /// Subtitle when the user is an active donor.
  ///
  /// In en, this message translates to:
  /// **'You are currently available as a donor'**
  String get currentlyAvailableDonor;

  /// Subtitle when the user is not an active donor.
  ///
  /// In en, this message translates to:
  /// **'You are currently not available as a donor'**
  String get currentlyNotAvailableDonor;

  /// Change phone number account setting.
  ///
  /// In en, this message translates to:
  /// **'Change Phone Number'**
  String get changePhoneNumber;

  /// Change phone number option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your registered phone number'**
  String get updateRegisteredPhone;

  /// Delete account option.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your Pulze+ account'**
  String get permanentlyDeleteAccount;

  /// Notifications preference subtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive important app notifications'**
  String get receiveImportantNotifications;

  /// Donation reminder preference subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get reminded when you can donate again'**
  String get getRemindedWhenCanDonate;

  /// Theme preference subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred appearance'**
  String get choosePreferredAppearance;

  /// Language preference subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// Light theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// English language option.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Nepali language option.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get nepali;

  /// Frequently asked questions option.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// FAQ option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get findAnswersCommonQuestions;

  /// Contact support option.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Contact support option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help from the Pulze+ support team'**
  String get getHelpFromSupportTeam;

  /// Report problem option.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblem;

  /// Report problem option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about an issue in the app'**
  String get tellUsAboutIssue;

  /// Feedback option.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Feedback option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your ideas and suggestions'**
  String get shareIdeasSuggestions;

  /// About Pulze+ option.
  ///
  /// In en, this message translates to:
  /// **'About Pulze+'**
  String get aboutPulze;

  /// About Pulze+ option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about Pulze+'**
  String get learnMoreAboutPulze;

  /// Profile photo change sheet title.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// Profile photo source selection subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to update your profile photo.'**
  String get chooseProfilePhotoMethod;

  /// Camera option for profile photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// Camera option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your camera'**
  String get useCamera;

  /// Gallery option for profile photo.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// Gallery option subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select an existing photo'**
  String get selectExistingPhoto;

  /// Cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Message shown when camera permission is permanently denied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required. Please enable it in Settings.'**
  String get cameraPermissionRequiredSettings;

  /// Message shown when camera permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take a photo.'**
  String get cameraPermissionRequired;

  /// Success message after updating profile photo.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully.'**
  String get profilePhotoUpdated;

  /// Message shown when donor availability is enabled.
  ///
  /// In en, this message translates to:
  /// **'You are now available as a donor.'**
  String get donorAvailableMessage;

  /// Message shown when donor availability is disabled.
  ///
  /// In en, this message translates to:
  /// **'You are no longer available as a donor.'**
  String get donorUnavailableMessage;

  /// Sign out confirmation message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of Pulze+?'**
  String get signOutConfirmation;

  /// Fallback text shown when the user's blood group has not been added.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get bloodGroupNotAdded;

  /// Fallback text shown when information is not available.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// Subtitle describing privacy and security account management.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy and security'**
  String get managePrivacySecurity;

  /// Subtitle shown in the About Pulze+ dialog.
  ///
  /// In en, this message translates to:
  /// **'Connecting people through blood donation.'**
  String get connectingPeopleThroughBloodDonation;

  /// Main description shown in the About Pulze+ dialog.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ is a blood donor matching platform built to help connect people who need blood with eligible donors nearby.\n\nThe platform helps users discover relevant blood donors, manage donor availability, and respond to blood requests more efficiently.\n\nOur goal is to make blood donation and blood requests simpler, faster, and more accessible for everyone.'**
  String get aboutPulzeDescription;

  /// Label shown next to the application version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Tooltip for the close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Heading shown at the top of the FAQ screen.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// Description shown below the FAQ screen heading.
  ///
  /// In en, this message translates to:
  /// **'Find quick answers about Pulze+, blood donation, and your account.'**
  String get findQuickAnswersAboutPulze;

  /// Error message shown when FAQs cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Unable to load FAQs.'**
  String get unableToLoadFaqs;

  /// Button label used to retry loading FAQs.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Message shown when there are no FAQs available.
  ///
  /// In en, this message translates to:
  /// **'No FAQs available right now.'**
  String get noFaqsAvailableRightNow;

  /// Title or action label for reporting a problem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportAProblem;

  /// Action label for submitting feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Subtitle shown when contacting support.
  ///
  /// In en, this message translates to:
  /// **'Tell us how we can help you.'**
  String get tellUsHowWeCanHelp;

  /// Subtitle shown when reporting a problem.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong so we can fix it.'**
  String get tellUsWhatWentWrong;

  /// Subtitle shown when sending feedback.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts and help us improve Pulze+.'**
  String get shareYourThoughtsAndHelpUsImprove;

  /// Subject hint for support requests.
  ///
  /// In en, this message translates to:
  /// **'What do you need help with?'**
  String get whatDoYouNeedHelpWith;

  /// Subject hint for problem reports.
  ///
  /// In en, this message translates to:
  /// **'What problem are you experiencing?'**
  String get whatProblemAreYouExperiencing;

  /// Subject hint for feedback.
  ///
  /// In en, this message translates to:
  /// **'What would you like to share?'**
  String get whatWouldYouLikeToShare;

  /// Message hint for support requests.
  ///
  /// In en, this message translates to:
  /// **'Describe your question or issue...'**
  String get describeYourQuestionOrIssue;

  /// Message hint for problem reports.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem and what happened...'**
  String get describeTheProblemAndWhatHappened;

  /// Message hint for feedback.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience or suggestion...'**
  String get tellUsAboutYourExperienceOrSuggestion;

  /// Button label for sending a support message.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// Button label for submitting a problem report.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// Success message shown after submitting a support request.
  ///
  /// In en, this message translates to:
  /// **'Your support request has been submitted successfully.'**
  String get supportRequestSubmittedSuccessfully;

  /// Success message shown after submitting a problem report.
  ///
  /// In en, this message translates to:
  /// **'Your problem report has been submitted successfully.'**
  String get problemReportSubmittedSuccessfully;

  /// Success message shown after submitting feedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback.'**
  String get thankYouForYourFeedback;

  /// Label for the support request subject field.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// Label for the support request message field.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Validation message when the subject is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject.'**
  String get pleaseEnterASubject;

  /// Validation message when the subject is too short.
  ///
  /// In en, this message translates to:
  /// **'Subject must be at least 3 characters.'**
  String get subjectMustBeAtLeast3Characters;

  /// Validation message when the message is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message.'**
  String get pleaseEnterYourMessage;

  /// Validation message when the message is too short.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 10 characters.'**
  String get messageMustBeAtLeast10Characters;

  /// Information message encouraging users to provide enough details.
  ///
  /// In en, this message translates to:
  /// **'Please provide enough details so we can respond appropriately.'**
  String get provideEnoughDetailsToRespond;

  /// Section title for the user's blood and donation information.
  ///
  /// In en, this message translates to:
  /// **'Blood & Donations'**
  String get bloodAndDonations;

  /// Subtitle describing the blood donation information section.
  ///
  /// In en, this message translates to:
  /// **'View your blood donation information'**
  String get viewYourBloodDonationInformation;

  /// Label for the user's blood group.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// Label for the user's most recent blood donation.
  ///
  /// In en, this message translates to:
  /// **'Last Donation'**
  String get lastDonation;

  /// Label for the next date the user is eligible to donate blood.
  ///
  /// In en, this message translates to:
  /// **'Next Eligible Date'**
  String get nextEligibleDate;

  /// Button label for editing blood donation details.
  ///
  /// In en, this message translates to:
  /// **'Edit donation details'**
  String get editDonationDetails;

  /// Section title for the user's personal information.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// Subtitle describing the personal information section.
  ///
  /// In en, this message translates to:
  /// **'View your personal information'**
  String get viewYourPersonalInformation;

  /// Button label for editing personal information.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Label for the user's full name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Label for the user's email address.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for the user's phone number.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Label for the user's gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Label for the user's date of birth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Label for the user's city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Gender value for male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Gender value for female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Gender value for other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Fallback gender value when gender is not specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// Status shown when an email or phone number is verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Status shown when an email or phone number is not verified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// Fallback text shown when information has not been added.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get notAdded;

  /// Title shown when the user's profile completion is below 50 percent.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// Title shown when the user's profile is at least 50 percent complete.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// Description encouraging the user to complete their profile.
  ///
  /// In en, this message translates to:
  /// **'Add your details to get the most from Pulze+.'**
  String get addDetailsToGetMostFromPulze;

  /// App bar title when editing an existing profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// Header shown when creating a profile.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about you'**
  String get tellUsALittleAboutYou;

  /// Header shown when editing a profile.
  ///
  /// In en, this message translates to:
  /// **'Update your profile'**
  String get updateYourProfile;

  /// Description shown when creating a profile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to start using Pulze+.'**
  String get completeYourProfileToStartUsingPulze;

  /// Description shown when editing a profile.
  ///
  /// In en, this message translates to:
  /// **'Keep your information up to date.'**
  String get keepYourInformationUpToDate;

  /// Label for the phone number field.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// Hint for the phone number field.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// Label for the blood type field.
  ///
  /// In en, this message translates to:
  /// **'Blood type'**
  String get bloodType;

  /// Hint for the blood type field.
  ///
  /// In en, this message translates to:
  /// **'Select your blood type'**
  String get selectYourBloodType;

  /// Hint for the gender field.
  ///
  /// In en, this message translates to:
  /// **'Select your gender'**
  String get selectYourGender;

  /// Gender option allowing the user not to specify their gender.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// Date picker help text for selecting date of birth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// Validation message when date of birth is not selected.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required.'**
  String get dateOfBirthIsRequired;

  /// Hint for the date of birth field.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get selectYourDateOfBirth;

  /// Label for the address field.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Hint for the address field.
  ///
  /// In en, this message translates to:
  /// **'Enter your address'**
  String get enterYourAddress;

  /// Hint for the city field.
  ///
  /// In en, this message translates to:
  /// **'Enter your city'**
  String get enterYourCity;

  /// Title for the location section.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Status shown when a location has been selected.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get locationSelected;

  /// Status shown when no location has been selected.
  ///
  /// In en, this message translates to:
  /// **'Select your location'**
  String get selectYourLocation;

  /// Button label for changing the selected location.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get changeLocation;

  /// Button label or dialog title for selecting a location.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get selectLocation;

  /// Temporary message indicating map integration is not available yet.
  ///
  /// In en, this message translates to:
  /// **'Map selection will be connected later.'**
  String get mapSelectionWillBeConnectedLater;

  /// Dialog message explaining that map selection is not implemented yet.
  ///
  /// In en, this message translates to:
  /// **'Map location selection will be available once map integration is added.'**
  String get mapLocationSelectionWillBeAvailable;

  /// Confirmation button label.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Button label for completing a new profile.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfile;

  /// Button label for saving profile changes.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// Success message shown after a profile is updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccessfully;

  /// Validation message shown when blood type is not selected.
  ///
  /// In en, this message translates to:
  /// **'Blood type is required.'**
  String get bloodTypeIsRequired;

  /// Validation message shown when gender is not selected.
  ///
  /// In en, this message translates to:
  /// **'Gender is required.'**
  String get genderIsRequired;

  /// Title shown on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get welcomeBack;

  /// Title shown on the account creation screen.
  ///
  /// In en, this message translates to:
  /// **'Create your account.'**
  String get createYourAccount;

  /// Subtitle shown on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue helping your community.'**
  String get signInToContinueHelpingYourCommunity;

  /// Subtitle shown on the account creation screen.
  ///
  /// In en, this message translates to:
  /// **'Join Pulze+ and be there when someone needs blood.'**
  String get joinPulzeAndBeThereWhenSomeoneNeedsBlood;

  /// Button label for continuing authentication with Google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Button label for signing up with Google.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get signUpWithGoogle;

  /// Text shown when the user does not have an account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// Text shown when the user already has an account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// Button label for creating a new account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// Button label for signing in to an existing account.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Hint text for the email input field.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Hint text for the password input field.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Button label for starting password recovery.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Hint text for the full name input field.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// Hint text for creating a password.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createAPassword;

  /// Validation message shown when email is empty.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get emailIsRequired;

  /// Validation message shown when the email format is invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// Validation message shown when password is empty.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordIsRequired;

  /// Validation message shown when password is shorter than 8 characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMustBeAtLeast8Characters;

  /// Validation message shown when full name is empty.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get fullNameIsRequired;

  /// Validation message shown when full name is shorter than 2 characters.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 2 characters.'**
  String get fullNameMustBeAtLeast2Characters;

  /// Label shown above the password input field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Validation message shown when the confirmation password does not match the new password.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Title shown on the reset password screen.
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get createNewPassword;

  /// Subtitle shown on the reset password screen.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password for your Pulze+ account.'**
  String get chooseAStrongPasswordForYourPulzeAccount;

  /// Label shown for the new password field.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// Hint shown in the new password field.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterYourNewPassword;

  /// Label shown for the password confirmation field.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Hint shown in the password confirmation field.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get reEnterYourNewPassword;

  /// Button label for resetting the password.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// Fallback name shown when a user's name is unavailable.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Fallback address shown when no address has been added.
  ///
  /// In en, this message translates to:
  /// **'Address not added'**
  String get addressNotAdded;

  /// Status shown when the donor is available for blood donation.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Status shown when the donor is not available for blood donation.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Settings label for the user's donor status.
  ///
  /// In en, this message translates to:
  /// **'I am a donor'**
  String get isDonor;

  /// Description shown below the donor status setting.
  ///
  /// In en, this message translates to:
  /// **'Make yourself available for blood donation'**
  String get availableForBloodDonation;

  /// Last updated date displayed on Pulze+ legal documents.
  ///
  /// In en, this message translates to:
  /// **'Last updated: September 2026'**
  String get legalLastUpdated;

  /// Introduction text displayed at the beginning of the Pulze+ Privacy Policy.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ respects your privacy and is committed to protecting the information you provide while using the platform.'**
  String get privacyPolicyIntro;

  /// Privacy Policy section heading describing the information Pulze+ may collect.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyInformationWeCollect;

  /// Privacy Policy paragraph explaining the types of information Pulze+ may collect from users.
  ///
  /// In en, this message translates to:
  /// **'When you create and use a Pulze+ account, we may collect information such as your name, email address, phone number, blood group, donor status, location information, profile information, and other information you choose to provide.'**
  String get privacyInformationWeCollectParagraph1;

  /// Privacy Policy paragraph explaining how device location may be used for location-based features.
  ///
  /// In en, this message translates to:
  /// **'If you use features that require location access, Pulze+ may use your device location to provide nearby blood requests, blood banks, donors, or distance-related information.'**
  String get privacyInformationWeCollectParagraph2;

  /// Privacy Policy section heading explaining how Pulze+ uses user information.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacyHowWeUseInformation;

  /// Privacy Policy paragraph explaining the purposes for which Pulze+ uses user information.
  ///
  /// In en, this message translates to:
  /// **'We use your information to provide and improve Pulze+ features, manage your account, support blood donation and blood request services, provide relevant notifications, and maintain the security and reliability of the platform.'**
  String get privacyHowWeUseInformationParagraph;

  /// Privacy Policy section heading about location information and location-based features.
  ///
  /// In en, this message translates to:
  /// **'3. Location Information'**
  String get privacyLocationInformation;

  /// Privacy Policy paragraph explaining that location access is optional and how location may be used.
  ///
  /// In en, this message translates to:
  /// **'Location access is optional. If you grant location permission, Pulze+ may use your location to calculate distance and provide location-based features.'**
  String get privacyLocationInformationParagraph1;

  /// Privacy Policy paragraph explaining how users can manage location permission.
  ///
  /// In en, this message translates to:
  /// **'You can manage location permission through your device settings. If location access is unavailable, some location-based features may not work as intended.'**
  String get privacyLocationInformationParagraph2;

  /// Privacy Policy section heading about app notifications.
  ///
  /// In en, this message translates to:
  /// **'4. Notifications'**
  String get privacyNotifications;

  /// Privacy Policy paragraph explaining the types of notifications Pulze+ may send.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ may send notifications related to blood requests, donation reminders, account activity, or other important app information when notification permission is enabled.'**
  String get privacyNotificationsParagraph;

  /// Privacy Policy section heading about sharing and processing user information.
  ///
  /// In en, this message translates to:
  /// **'5. Information Sharing'**
  String get privacyInformationSharing;

  /// Privacy Policy statement about selling personal information.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ does not intend to sell your personal information.'**
  String get privacyInformationSharingParagraph1;

  /// Privacy Policy paragraph explaining circumstances in which information may be processed or shared.
  ///
  /// In en, this message translates to:
  /// **'Information may be processed or shared when necessary to provide requested services, operate the platform, comply with applicable laws, protect users, or maintain the security of the service.'**
  String get privacyInformationSharingParagraph2;

  /// Privacy Policy section heading about user choices and account settings.
  ///
  /// In en, this message translates to:
  /// **'6. Your Choices'**
  String get privacyYourChoices;

  /// Privacy Policy paragraph explaining the settings and preferences users can manage.
  ///
  /// In en, this message translates to:
  /// **'You can review and update available account information through your profile. You may also manage certain device permissions, notification preferences, language, and theme settings through the app or your device settings.'**
  String get privacyYourChoicesParagraph;

  /// Privacy Policy section heading about protecting user information.
  ///
  /// In en, this message translates to:
  /// **'7. Data Security'**
  String get privacyDataSecurity;

  /// Privacy Policy paragraph explaining Pulze+ data security practices and limitations.
  ///
  /// In en, this message translates to:
  /// **'We take reasonable measures to protect information handled through Pulze+. However, no internet-based service can guarantee absolute security.'**
  String get privacyDataSecurityParagraph;

  /// Privacy Policy section heading about future policy changes.
  ///
  /// In en, this message translates to:
  /// **'8. Changes to This Policy'**
  String get privacyChangesToPolicy;

  /// Privacy Policy paragraph explaining how policy updates will be communicated.
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy may be updated from time to time as Pulze+ features, services, or legal requirements change. The updated version will be made available through the app.'**
  String get privacyChangesToPolicyParagraph;

  /// Privacy Policy section heading for privacy-related contact information.
  ///
  /// In en, this message translates to:
  /// **'9. Contact'**
  String get privacyContact;

  /// Privacy Policy paragraph directing users to Pulze+ support for privacy questions.
  ///
  /// In en, this message translates to:
  /// **'If you have questions or concerns about this Privacy Policy or how your information is handled, please contact the Pulze+ support team.'**
  String get privacyContactParagraph;

  /// Introduction text displayed at the beginning of the Pulze+ Terms & Conditions.
  ///
  /// In en, this message translates to:
  /// **'These Terms & Conditions describe the rules for using the Pulze+ platform and its blood donation and blood request related features.'**
  String get termsConditionsIntro;

  /// Terms & Conditions section heading about accepting the terms.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get termsAcceptance;

  /// Terms & Conditions paragraph explaining user acceptance of the terms and Privacy Policy.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using account-based features of Pulze+, you agree to these Terms & Conditions and the Privacy Policy.'**
  String get termsAcceptanceParagraph;

  /// Terms & Conditions section heading about acceptable use of Pulze+.
  ///
  /// In en, this message translates to:
  /// **'2. Use of Pulze+'**
  String get termsUseOfPulze;

  /// Terms & Conditions paragraph explaining users' responsibilities when using Pulze+.
  ///
  /// In en, this message translates to:
  /// **'You agree to provide accurate information when creating or maintaining your account and to use Pulze+ only for lawful purposes.'**
  String get termsUseOfPulzeParagraph;

  /// Terms & Conditions section heading about blood donation information.
  ///
  /// In en, this message translates to:
  /// **'3. Blood Donation Information'**
  String get termsBloodDonationInformation;

  /// Terms & Conditions paragraph explaining the purpose and limitations of blood donation information.
  ///
  /// In en, this message translates to:
  /// **'Information provided through Pulze+ is intended to help connect people with blood donation resources. Pulze+ does not replace professional medical advice, diagnosis, or treatment.'**
  String get termsBloodDonationInformationParagraph1;

  /// Terms & Conditions paragraph advising users to verify important medical and donation information.
  ///
  /// In en, this message translates to:
  /// **'Users should independently verify important medical and blood donation requirements with qualified healthcare professionals or authorized blood banks.'**
  String get termsBloodDonationInformationParagraph2;

  /// Terms & Conditions section heading about blood requests.
  ///
  /// In en, this message translates to:
  /// **'4. Blood Requests'**
  String get termsBloodRequests;

  /// Terms & Conditions paragraph explaining user responsibility when creating or responding to blood requests.
  ///
  /// In en, this message translates to:
  /// **'Users are responsible for providing truthful and appropriate information when creating or responding to blood requests.'**
  String get termsBloodRequestsParagraph1;

  /// Terms & Conditions paragraph explaining that Pulze+ cannot guarantee availability of donors or blood resources.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ does not guarantee that a suitable donor, blood unit, blood bank, or response will always be available.'**
  String get termsBloodRequestsParagraph2;

  /// Terms & Conditions section heading about account security and responsibility.
  ///
  /// In en, this message translates to:
  /// **'5. Account Responsibility'**
  String get termsAccountResponsibility;

  /// Terms & Conditions paragraph explaining responsibility for account credentials and account activity.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the security of your account credentials and for activity performed through your account.'**
  String get termsAccountResponsibilityParagraph1;

  /// Terms & Conditions paragraph advising users not to share account credentials.
  ///
  /// In en, this message translates to:
  /// **'Do not share your password or knowingly allow another person to use your account.'**
  String get termsAccountResponsibilityParagraph2;

  /// Terms & Conditions section heading about prohibited activities.
  ///
  /// In en, this message translates to:
  /// **'6. Prohibited Use'**
  String get termsProhibitedUse;

  /// Terms & Conditions paragraph describing prohibited uses of Pulze+.
  ///
  /// In en, this message translates to:
  /// **'You must not use Pulze+ to provide false information, misuse blood request or donor features, harass other users, attempt unauthorized access, or interfere with the operation or security of the platform.'**
  String get termsProhibitedUseParagraph;

  /// Terms & Conditions section heading about service availability.
  ///
  /// In en, this message translates to:
  /// **'7. Availability of Services'**
  String get termsServiceAvailability;

  /// Terms & Conditions paragraph explaining that Pulze+ may modify or suspend features when necessary.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ may change, suspend, or discontinue features when necessary for maintenance, security, development, or other operational reasons.'**
  String get termsServiceAvailabilityParagraph;

  /// Terms & Conditions section heading about user responsibility and service limitations.
  ///
  /// In en, this message translates to:
  /// **'8. Limitation of Responsibility'**
  String get termsLimitationOfResponsibility;

  /// Terms & Conditions paragraph explaining the responsibilities of users when using the platform.
  ///
  /// In en, this message translates to:
  /// **'Pulze+ provides a platform for connecting users with blood-related resources. Users remain responsible for their own decisions, communications, and actions.'**
  String get termsLimitationOfResponsibilityParagraph;

  /// Terms & Conditions section heading about future changes to the terms.
  ///
  /// In en, this message translates to:
  /// **'9. Changes to These Terms'**
  String get termsChanges;

  /// Terms & Conditions paragraph explaining how updated terms will be made available.
  ///
  /// In en, this message translates to:
  /// **'These Terms & Conditions may be updated as the Pulze+ platform evolves. Updated terms will be made available through the application.'**
  String get termsChangesParagraph;

  /// Terms & Conditions section heading for support contact information.
  ///
  /// In en, this message translates to:
  /// **'10. Contact'**
  String get termsContact;

  /// Terms & Conditions paragraph directing users to Pulze+ support for questions.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about these Terms & Conditions, please contact the Pulze+ support team.'**
  String get termsContactParagraph;

  /// Button label allowing users to enter Pulze+ as a guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Checkbox label requiring users to accept the Terms & Conditions and Privacy Policy before registration.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions and Privacy Policy.'**
  String get agreeToTermsAndPrivacy;

  /// Introductory text for the legal agreement during account registration.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get legalAgreementPrefix;

  /// Connector between the Terms & Conditions and Privacy Policy during account registration.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get legalAgreementConnector;

  /// Ending punctuation for the legal agreement during account registration.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get legalAgreementSuffix;

  /// Description shown in the Change Password dialog.
  ///
  /// In en, this message translates to:
  /// **'Update your password to keep your account secure.'**
  String get changePasswordDescription;

  /// Security guidance shown in the Change Password dialog.
  ///
  /// In en, this message translates to:
  /// **'Use a strong password that you do not use for other accounts.'**
  String get changePasswordSecurityHint;

  /// Label for the current password field.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// Label for the confirm new password field.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// Hint text for the current password field.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// Hint text for the new password field.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// Hint text for the confirm new password field.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password again'**
  String get enterNewPasswordAgain;

  /// Validation message when the current password is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password.'**
  String get currentPasswordRequired;

  /// Validation message when the new password is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password.'**
  String get newPasswordRequired;

  /// Validation message when the new password confirmation is empty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password.'**
  String get confirmPasswordRequired;

  /// Validation message when the new password is shorter than the minimum length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordMinimumLength;

  /// Password requirement hint shown below the new password field.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 8 characters.'**
  String get passwordMinimumHint;

  /// Button label used to submit the password change.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// Tooltip shown when the password is currently hidden.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Tooltip shown when the password is currently visible.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Success message shown after the user's password is changed.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully.'**
  String get passwordChangedSuccessfully;

  /// Section title for blood donation information and activity.
  ///
  /// In en, this message translates to:
  /// **'Blood & Activity'**
  String get bloodAndActivity;

  /// Subtitle for the Blood & Activity section.
  ///
  /// In en, this message translates to:
  /// **'View your blood donation and request activity'**
  String get viewBloodDonationActivity;

  /// Title for the first-time donor location dialog.
  ///
  /// In en, this message translates to:
  /// **'Location helps save lives'**
  String get locationHelpsSaveLives;

  /// Description explaining why donor location is required.
  ///
  /// In en, this message translates to:
  /// **'To make you available as a donor, Pulze+ needs your current location. This helps people find nearby eligible donors when blood is urgently needed.'**
  String get donorLocationDescription;

  /// Privacy heading in the donor location dialog.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is protected'**
  String get yourPrivacyIsProtected;

  /// Privacy information explaining how donor location is used.
  ///
  /// In en, this message translates to:
  /// **'Your exact location is never shown publicly. It is used to calculate distance and connect you with nearby blood requests.'**
  String get donorLocationPrivacyDescription;

  /// Button label to allow location access.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// Button label to dismiss the location dialog.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// Message shown when a user has a saved location but app location setting is disabled while enabling donor status.
  ///
  /// In en, this message translates to:
  /// **'Please turn on location to become a donor.'**
  String get enableLocationToBecomeDonor;

  /// Subtitle shown for the change phone number setting.
  ///
  /// In en, this message translates to:
  /// **'Update your verified phone number.'**
  String get updatePhoneNumber;

  /// Success message shown after the phone number is successfully verified and changed.
  ///
  /// In en, this message translates to:
  /// **'Phone number changed successfully.'**
  String get phoneNumberChangedSuccessfully;

  /// Title shown when the user needs to verify their new phone number.
  ///
  /// In en, this message translates to:
  /// **'Verify phone number'**
  String get verifyPhoneNumber;

  /// Hint shown in the phone number input field.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// Button label used to send a phone verification code.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// Label for the phone verification code field.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// Instruction shown above the phone verification code field.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code.'**
  String get enterVerificationCode;

  /// Button label used to request another phone verification code.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Countdown shown before another phone verification code can be requested.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeIn(int seconds);

  /// Success message shown after a phone verification code is sent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully.'**
  String get verificationCodeSentSuccessfully;

  /// Success message shown after a new phone verification code is sent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent.'**
  String get newVerificationCodeSent;

  /// Validation message shown when the phone number is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get pleaseEnterPhoneNumber;

  /// Validation message shown when the verification code is invalid or incomplete.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit verification code.'**
  String get pleaseEnterSixDigitCode;

  /// Information message explaining why phone verification is required.
  ///
  /// In en, this message translates to:
  /// **'Your phone number must be verified before it can be used for protected account features.'**
  String get phoneVerificationSecurityMessage;

  /// Tooltip or action label used to change the entered phone number.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// Description shown when the user is entering a new phone number.
  ///
  /// In en, this message translates to:
  /// **'Enter your new number. We\'ll send you a verification code.'**
  String get changePhoneNumberDescription;

  /// Description shown when the user has not added a phone number.
  ///
  /// In en, this message translates to:
  /// **'Add and verify your phone number to keep your account secure.'**
  String get addPhoneSecurityDescription;

  /// Description shown when the user is changing their phone number.
  ///
  /// In en, this message translates to:
  /// **'Enter a new phone number. We will send you a verification code.'**
  String get changeNumberDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
