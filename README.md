# CFO Seller

Seller operations app for the CFO Marketplace.

## Play Store release

- Upload bundle: `build/app/outputs/bundle/release/app-release.aab`
- Android application ID: `com.cfo.seller_app`
- Version: `1.0.0` (version code `1`)
- Play Store screenshots: `store-assets/screenshots/phone/` (15 emulator-only
  phone PNGs at 1200 × 1920) and `store-assets/screenshots/tablet/` (6
  emulator-only landscape tablet PNGs at 2560 × 1600)
- Launcher source: `assets/branding/cfo_seller_launcher.svg`
- Play Store icon: `store-assets/cfo-seller-app-icon-512.png` (512 × 512)
- Play Store feature graphic:
  `store-assets/cfo-seller-feature-graphic-1024x500.png` (1024 × 500)

The release is signed with the local upload key. Back up the ignored
`android/cfo-seller-upload-key.jks` and `android/release-signing-backup.txt`
outside this repository before publishing. In Play Console, enable Play App
Signing before uploading the first bundle.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Attached Postman collection me only seller app credentials mile. Admin/customer/other roles ke login details is collection me nahi hain.

**Base URL:** `https://callfororders.in`

**Seller login**
```text
Endpoint: POST /api/seller/login
Email: qa-seller@cfomarketplace.test
Password: Qa-UtkcfkyhZApVgYDH-7x!
Device name: postman
```

**Register seller/store sample**
```text
Name: QA Seller
Email: qa-seller@cfomarketplace.test
Password: Qa-UtkcfkyhZApVgYDH-7x!
Phone: 9000000001
Store: QA Test Store
Store email: qa@teststore.test
GST: 33AAPFU0939F1ZV
```

**Team/member login sample**
```text
Name: QA Packing Desk
Email: qa-packing@teststore.test
Password: a-good-password
Phone: 9000000003
```

Note: docs ke according seller app me abhi owner/staff role distinction nahi hai: “There is no owner/staff distinction inside a store yet.” Team login bhi same store data access karta hai; password/devices/notifications private hote hain.

Caution: collection me “Change password” request bhi hai:
```text
current_password: Qa-UtkcfkyhZApVgYDH-7x!
new password: a-newer-password
```
Is request ko run karoge to login password change ho sakta hai.
