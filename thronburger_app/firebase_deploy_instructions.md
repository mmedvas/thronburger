# Firebase Security Rules Deployment

## Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Logged in to Firebase: `firebase login`

## Deployment Steps

### 1. Initialize Firebase in the project (first time only)
```bash
cd /Users/mivan/Developer/throunBurger/thronburger_app
firebase init
```

When prompted:
- **Select features**: Choose "Firestore" and "Storage"
- **Use existing project**: Select your Firebase project (452905851509)
- **Firestore rules file**: Press Enter to accept `firestore.rules`
- **Firestore indexes file**: Press Enter to accept `firestore.indexes.json`
- **Storage rules file**: Press Enter to accept `storage.rules`

### 2. Deploy Security Rules
```bash
# Deploy both Firestore and Storage rules
firebase deploy --only firestore:rules,storage:rules

# Or deploy individually:
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### 3. Verify Deployment
1. Go to Firebase Console: https://console.firebase.google.com/project/452905851509
2. Navigate to **Firestore Database** → **Rules** tab
3. Verify the rules are deployed
4. Navigate to **Storage** → **Rules** tab
5. Verify the storage rules are deployed

## Testing the Rules

### Test Menu Access (should work - public read)
```dart
// In the app, try loading menu items without authentication
final menuRepo = MenuRepository(firestore, storage);
final items = await menuRepo.getMenuItems();
```

### Test Customer Data Access (requires authentication)
```dart
// Should only work for authenticated users accessing their own data
final customerRepo = CustomerRepository(firebaseAuth, firestore);
final customer = await customerRepo.getCustomer(currentUser.uid);
```

### Test Staff Operations (requires staff role)
```dart
// Should only work for users with entries in user_roles collection
final orderRepo = OrderRepository(firestore);
final orders = await orderRepo.getAllOrders(); // Staff only
```

## Important Notes

⚠️ **Menu items are publicly readable** - Anyone can see the menu (this is by design for the customer app)

⚠️ **Customer data is private** - Customers can only access their own data

⚠️ **Staff permissions** - Staff users need a document in `user_roles` collection with their UID

⚠️ **Initial staff setup** - You'll need to manually add the first admin user to `user_roles` collection in Firebase Console

## Creating the First Admin User

1. Sign up a staff member using the app (email/password)
2. Note their User ID from Firebase Console → Authentication
3. In Firestore, create a document:
   - Collection: `user_roles`
   - Document ID: `<user-uid>`
   - Fields:
     ```
     role: "admin"
     ```
