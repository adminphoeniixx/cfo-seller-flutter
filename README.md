# seller_app

A new Flutter project.

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

**Base URL:** `https://projects-cfo-marketplace-laravel.rmsiry.easypanel.host`

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