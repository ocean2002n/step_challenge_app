# Apple Sign-In Setup Guide

This document outlines the manual steps required to complete Apple Sign-In configuration for the Step Challenge app.

## Prerequisites
- Apple Developer Account (paid membership required for Apple Sign-In)
- Xcode with the project opened
- Access to Apple Developer Console

## Step 1: Apple Developer Console Configuration

### 1.1 Configure App ID
1. Go to [Apple Developer Console](https://developer.apple.com/account/)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Select "Identifiers" from the left menu
4. Find or create your App ID (should match Bundle ID in Xcode)
5. Edit the App ID configuration:
   - Check "Sign In with Apple" capability
   - Configure as "Enable as a primary App ID"
   - Save changes

### 1.2 Create Service ID (Optional for deeper integration)
1. In Identifiers, create a new Service ID
2. Use a reverse domain notation (e.g., `com.yourcompany.stepchallenge.service`)
3. Enable "Sign In with Apple" for this Service ID
4. Configure domains and redirect URLs if needed for web integration

## Step 2: Xcode Project Configuration

### 2.1 Bundle ID Setup
1. Open the project in Xcode
2. Select the project file in navigator
3. Under "Signing & Capabilities" tab:
   - Ensure Bundle Identifier matches your Apple Developer App ID
   - Make sure your development team is selected
   - Verify signing certificate is valid

### 2.2 Add Apple Sign-In Capability
1. In "Signing & Capabilities" tab
2. Click the "+" button to add capability
3. Search for and add "Sign In with Apple"
4. This should automatically configure the entitlements

### 2.3 Verify Entitlements File
The following should be automatically added to `Runner.entitlements`:
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

## Step 3: Verification Steps

### 3.1 Build Configuration
- Ensure the app builds successfully in Xcode
- Check that no signing errors occur
- Verify the capability appears in app's entitlements

### 3.2 Device Testing
⚠️ **Important**: Apple Sign-In only works on physical devices, not simulators
1. Deploy to a physical iOS device (iPhone/iPad)
2. Test the Apple Sign-In flow:
   - Tap "使用 Apple 繼續" button
   - Should present Apple ID authentication dialog
   - Complete authentication with Face ID/Touch ID/passcode
   - Verify successful login and account creation

## Step 4: Production Considerations

### 4.1 App Store Connect
- Ensure your app in App Store Connect has the same Bundle ID
- Apple Sign-In capability will be automatically detected during app review

### 4.2 Privacy Policy Updates
- Update privacy policy to mention Apple Sign-In usage
- Include information about data collected from Apple ID (email, name)

## Troubleshooting

### Common Issues:
1. **"Sign In with Apple not available"**: 
   - Check device supports iOS 13+
   - Verify Apple Sign-In capability is properly configured
   
2. **Authentication fails**:
   - Ensure Bundle ID matches exactly in all configurations
   - Check Apple Developer Account status
   - Verify nonce generation is working (already implemented in code)

3. **Entitlements errors**:
   - Clean build folder (Cmd+Shift+K)
   - Rebuild project
   - Check provisioning profile includes Apple Sign-In capability

## Current Implementation Status ✅

The following components are already implemented and ready:

- ✅ **SocialAuthService**: Complete Apple Sign-In implementation with PKCE security
- ✅ **SocialLoginScreen**: Apple Sign-In button with proper styling and loading states
- ✅ **LinkedAccountsWidget**: Apple account management (link/unlink functionality)
- ✅ **Info.plist**: Basic configuration comments added
- ✅ **Dependencies**: `sign_in_with_apple` package included in pubspec.yaml
- ✅ **Localization**: UI text already in place

## Next Steps After Configuration

1. Complete the Xcode configuration steps above
2. Test on physical device
3. Verify integration with existing registration flow
4. Test account linking/unlinking functionality
5. Conduct end-to-end user journey testing

## Code Integration Notes

The app already handles Apple Sign-In in the following flow:
1. User taps Apple Sign-In button → `SocialLoginScreen._signInWithApple()`
2. Calls `SocialAuthService.signInWithApple()` with secure nonce generation
3. On success, either navigates to HomeScreen (existing user) or RegistrationScreen (new user)
4. New users start registration from step 1 with social account data pre-filled
5. Account linking/unlinking available in user settings via `LinkedAccountsWidget`

The implementation follows Apple's security best practices with PKCE (Proof Key for Code Exchange) and proper nonce handling.