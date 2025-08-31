# QR Code Scanner Feature

## Overview
This feature allows users to scan QR codes to add friends to their Splitemate account. The implementation includes a modern, user-friendly interface with animations and proper error handling.

## Features Implemented

### 1. QR Code Scanner
- **Package**: `mobile_scanner: ^7.0.1`
- **Camera Integration**: Real-time QR code scanning using device camera
- **Auto-scan**: Automatically detects and processes QR codes when positioned within the scanning frame

### 2. User Interface
- **Modern Design**: Dark theme with gradient accents matching the app's design language
- **Animated Scanning Frame**: Beautiful corner decorations with animated scanning line
- **Flashlight Toggle**: Built-in torch/flashlight control for better scanning in low light
- **Responsive Layout**: Adapts to different screen sizes

### 3. API Integration
- **Endpoint**: `POST /api/user/add-friend/{SCANNED_TOKEN}`
- **Service Layer**: Dedicated `FriendService` for handling friend-related API calls
- **Centralized API Service**: `ApiService` with proper interceptor handling
- **Token Management**: Automatic token refresh on 401 responses with loop prevention
- **Error Handling**: Comprehensive error handling for various scenarios:
  - User not found (404)
  - Already friends (409) - Shows user details even if already friends
  - Invalid QR code (400)
  - Network errors
  - Authentication errors (401) - Automatic token refresh and retry

### 4. User Experience
- **Vibration Feedback**: Device vibrates on successful friend addition
- **Loading States**: Shows loading indicator during API calls
- **Success Dialog**: Beautiful custom dialog showing added friend's details
- **Manual Input**: Fallback option to enter friend code manually
- **Error Recovery**: Easy retry mechanism for failed attempts

## Files Created/Modified

### New Files
1. `lib/screens/qr_scanner_screen.dart` - Main QR scanner screen
2. `lib/service/friend_service.dart` - API service for friend operations
3. `lib/service/api_service.dart` - Centralized API service with interceptor
4. `lib/widgets/popup/friend_added_dialog.dart` - Custom success dialog
5. `QR_SCANNER_README.md` - This documentation

### Modified Files
1. `lib/screens/profile.dart` - Connected "Scan Code" button to QR scanner
2. `lib/colors.dart` - Added `kGreenColor` for success states
3. `pubspec.yaml` - Added required dependencies

## Dependencies Added
```yaml
mobile_scanner: ^7.0.1
vibration: ^1.8.4
```

## Usage

### From Profile Screen
1. Navigate to the Profile screen
2. Tap the "Scan Code" button
3. Allow camera permissions when prompted
4. Position the QR code within the scanning frame
5. The app will automatically scan and process the code

### Manual Input
1. In the QR scanner screen, tap "Enter Code Manually"
2. Enter the friend code in the text field
3. Tap "Add Friend" to process

## API Response Format
The API should return a JSON object with the friend's details:
```json
{
  "id": "user_id",
  "name": "Friend Name",
  "email": "friend@example.com",
  "image_url": "https://example.com/avatar.jpg"
}
```

## Error Handling
- **404**: "User not found with this QR code"
- **409**: Shows user details with "Friend Found!" message (even if already friends)
- **400**: "Invalid QR code"
- **401**: Automatic token refresh and request retry (with loop prevention)
- **Network**: "Network error: [message]"
- **General**: "Unexpected error: [message]"

## API Interceptor Features
- **Automatic Token Management**: Adds Bearer token to authenticated requests
- **Token Refresh**: Automatically refreshes expired tokens
- **Loop Prevention**: Prevents infinite refresh loops with `_isRefreshing` flag
- **Request Queuing**: Queues requests during token refresh to prevent race conditions
- **Error Recovery**: Retries failed requests with new tokens

## Permissions Required
- Camera access for QR code scanning
- Vibration permission for haptic feedback

## Future Enhancements
- QR code generation for sharing own friend code
- Friend list management
- Push notifications for friend requests
- Offline QR code storage
- Batch friend addition 