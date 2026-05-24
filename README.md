# Luxe Store - Mobile App (Flutter + Firebase)

## Overview
A modern, elegant fashion store mobile application built with Flutter, Firebase Auth, and Firestore.

## Features
- ✅ Firebase Authentication (Email/Password)
- ✅ Real-time Firestore Database for Products, Categories, and Orders
- ✅ Strict Password Validation
- ✅ Product List (All, Women, Men, Kids, Accessories)
- ✅ Product Details + Add to Cart
- ✅ Cart Management
- ✅ Checkout Flow (Cash on Delivery / Credit Card)
- ✅ Order History (per-user)
- ✅ Wishlist Management
- ✅ Dark/Light Mode
- ✅ Search Screen
- ✅ Profile Management (Addresses, Settings, Notifications)

## Firebase Setup (Required Steps)
1. **Firebase Console**: Go to [Firebase Console](https://console.firebase.google.com/)
2. **Enable Email/Password Auth**: Authentication → Sign-in method → Enable "Email/Password"
3. **Create Firestore Database**: Firestore Database → Create database (Test mode for development; update rules for production)
4. **Verify App Package**: Project Settings → Android apps → Ensure package name is `com.example.flutter_demo_app` (matches `android/app/build.gradle.kts`)
5. **google-services.json**: Ensure `android/app/google-services.json` is present (already in repo)

## Getting Started

### Prerequisites
- Flutter SDK (3.11.1+)
- Android Studio / VS Code
- Firebase account

### Installation
```bash
# Clone repository (if not already)
git clone https://github.com/sajidhafarvin/Luxe_Store-.git
cd Luxe_Store-

# Install dependencies
flutter pub get

# Run app (debug)
flutter run
```

### Build Release APK
```bash
# Build release APK
flutter build apk --release

# Output location: build/app/outputs/flutter-apk/app-release.apk
```

## Project Structure
```
lib/
├── constants/          # App colors, routes, text styles
├── models/             # Product, Order, User data models
├── repositories/       # Firebase Auth, Product, Order data access
├── screens/            # All UI screens (Auth, Home, Products, Cart, Checkout, Orders, Profile)
├── services/           # Firestore data seeder (initial products/categories)
├── utils/              # Cart/Order/User/Wishlist managers, theme manager
└── main.dart           # App entry + Firebase init + routes
```

## Firebase Firestore Structure
```
categories/
  {categoryId}/
    name: "Women"
    sortOrder: 1

products/
  {productId}/
    name: "Cashmere Overcoat"
    price: 450.00
    originalPrice: 550.00
    imageAsset: "assets/images/products/product1.png"
    category: "Women"
    description: "..."
    material: "100% Cashmere"
    materialDescription: "Premium Italian cashmere..."
    rating: 4.9
    reviewsCount: 124
    isNew: true
    isOnSale: false

users/
  {userId}/
    orders/
      {orderId}/
        orderNumber: "LX-12345"
        createdAt: Timestamp
        totalAmount: 450.00
        status: "Pending"
        paymentMethod: "Cash on Delivery"
        deliveryAddress: "..."
        items: [
          {
            name: "Cashmere Overcoat",
            price: 450.00,
            imageAsset: "...",
            quantity: 1,
            size: "M",
            color: "Navy"
          }
        ]
```

## License
MIT
