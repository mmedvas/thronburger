# Thronburger Mobile App - Complete Specification

> **For use with Antigravity App Builder**

---

## 1. Executive Summary

| Field | Value |
|-------|-------|
| **App Name** | Thronburger |
| **Platform** | iOS & Android (Flutter) |
| **Location** | Empire City, Erbil, Iraq |
| **Tagline** | "From Berlin to Erbil, homemade burgers with a unique taste" |
| **Languages** | English, Arabic, Kurdish Badini |

Thronburger is a premium burger restaurant mobile app enabling customers to browse menus, place online orders, and track deliveries in real-time.

---

## 2. Brand Identity

### 2.1 Brand Name
**THRONBURGER** (stylized as "THRON" + "BURGER")
- First part: Gold gradient
- Second part: Foreground color
- Origin: German "Thron" (Throne) + Burger = "King of Burgers"

### 2.2 Brand Positioning
Premium Royal Burger experience - emphasizing quality, authenticity, and a regal dining experience.

---

## 3. Color Palette

### 3.1 Primary Colors
| Color | HSL | Hex | Usage |
|-------|-----|-----|-------|
| Brand Red | 0 72% 51% | `#DC2626` | Primary actions, CTA buttons |
| Brand Gold | 45 100% 51% | `#FBBF24` | Highlights, gradients, premium accents |
| Brand Green | 142 76% 36% | `#16A34A` | Success states |

### 3.2 Neutral Colors
| Color | HSL | Hex | Usage |
|-------|-----|-----|-------|
| Background | 20 14% 8% | `#161312` | Main background (charcoal) |
| Foreground | 0 0% 98% | `#FAFAFA` | Primary text (snow white) |
| Card | 20 20% 12% | `#211C18` | Card backgrounds |
| Muted | 20 15% 18% | `#2D2823` | Secondary backgrounds |
| Muted Foreground | 0 0% 70% | `#B3B3B3` | Secondary text |
| Border | 20 15% 20% | `#3A332D` | Borders and dividers |

### 3.3 Theme Color
- Primary Theme: `#F59E0B` (Amber/Gold)

---

## 4. Typography

### 4.1 Font Families
| Type | Font | Weights | Usage |
|------|------|---------|-------|
| Display | Poppins | 600, 700, 800, 900 | Headlines, titles, brand |
| Body | Inter | 400, 500, 600, 700 | Body text, UI elements |

### 4.2 Font Hierarchy
| Level | Size | Font | Weight |
|-------|------|------|--------|
| H1 | 32-48px | Poppins | Black (900) |
| H2 | 24-32px | Poppins | Black (900) |
| H3 | 18-24px | Poppins | Bold (700) |
| Body | 14-18px | Inter | Medium (500) |
| Small | 12-14px | Inter | Normal (400) |

---

## 5. Visual Design System

### 5.1 Gradients
| Name | Definition | Usage |
|------|------------|-------|
| Hero Gradient | 135deg, primary/90% → background/95% | Hero overlays |
| Gold Gradient | 135deg, brand-gold → amber-500 | Text highlights, premium |
| Card Gradient | 135deg, card/80% → muted/60% | Card backgrounds |

### 5.2 Effects
- **Glassmorphism**: Backdrop blur 10px, semi-transparent backgrounds
- **Shadows**: `0 20px 60px -15px rgba(0,0,0,0.5)`
- **Gold Glow**: `0 0 40px rgba(251,191,36,0.3)`

### 5.3 Animations
| Animation | Duration | Usage |
|-----------|----------|-------|
| Float | 3s ease-in-out infinite | Decorative elements |
| Gentle Float | 6s ease-in-out infinite | Hero images |
| Pulse Glow | 3-4s ease-in-out infinite | Highlights |
| Transition | 0.4s cubic-bezier(0.4, 0, 0.2, 1) | Standard transitions |

### 5.4 Border Radius
- Large: 12px
- Medium: 8px
- Small: 4px

### 5.5 Touch Targets
- Minimum: 44x44 pixels

---

## 6. Iconography

### 6.1 Brand Emojis
- 👑 Crown (Royal/Premium)
- 🍔 Burger (Product)
- 🔥 Fire (Charcoal-grilled)
- ✨ Sparkles (Quality)

### 6.2 Icon Library
Use consistent line icons (Lucide-style)

---

## 7. App Screens & Features

### 7.1 Splash Screen
- Thronburger logo centered
- Charcoal background (#0A0A0A)
- Gold glow animation
- Duration: 2-3 seconds

### 7.2 Home Screen
**Components:**
1. **Header**
   - Logo (left)
   - Language switcher (EN/AR/KU)
   - Profile/Login button (right)

2. **Hero Section**
   - Featured burger image with gentle float animation
   - Tagline text with gold gradient
   - "Order Now" CTA button (Brand Red)

3. **About Section**
   - Three feature cards:
     - 👑 Royal Taste
     - 🔥 Charcoal Grilled
     - ✨ Premium Quality

4. **Menu Categories**
   - Horizontal scrollable chips:
     - All (🍽️)
     - Burgers (🍔)
     - Sides (🍟)
     - Drinks (🥤)
     - Combos (🎁)

5. **Menu Grid**
   - 2-column grid of menu items
   - Each card shows: Image, Name (trilingual), Price (IQD), Add button

6. **Location & Hours**
   - Address: Empire City, Erbil, Iraq
   - Hours: 16:00 - 23:00 daily

### 7.3 Menu Item Detail (Bottom Sheet)
- Large image
- Name (in selected language)
- Price in IQD
- Description (if available)
- Quantity selector (+/-)
- "Add to Cart" button

### 7.4 Cart Screen
**Components:**
- List of cart items with:
  - Item image thumbnail
  - Name
  - Quantity controls (+/-)
  - Line total
  - Remove button
- Subtotal display
- "Proceed to Checkout" button
- "Clear Cart" option

**Persistence:** Cart saved to local storage

### 7.5 Authentication Flow

#### 7.5.1 Login Modal/Screen
**Step 1: Phone Entry**
- Phone input field (+964 format)
- Country code prefix (Iraq)
- "Send OTP" button
- Rate limit: 3 requests per 10 minutes

**Step 2: OTP Verification**
- 6-digit OTP input (auto-focus, auto-advance)
- 5-minute expiration timer
- "Resend OTP" link
- "Verify" button

**Step 3: Name Entry (New Users Only)**
- Name input field
- "Continue" button

**Success:** JWT token stored locally (30-day expiry)

### 7.6 Checkout Screen
**Form Fields:**
| Field | Required | Notes |
|-------|----------|-------|
| Name | Yes | Pre-filled if logged in |
| Phone | Yes | Pre-filled, disabled if logged in |
| Location/Area | No | General area |
| Delivery Address | Yes | Full address |
| Special Instructions | No | Notes for kitchen |

**Saved Addresses (Logged-in users):**
- Dropdown to select saved address
- "Save this address" checkbox for new addresses
- Edit/Delete saved addresses

**Order Summary:**
- Item list with quantities
- Total amount in IQD
- "Place Order" button

### 7.7 Order Confirmation Screen
- Success animation (checkmark)
- Order number prominently displayed
- "Track Order" button
- "Back to Menu" button

### 7.8 Order Tracking Screen
**Status Timeline (Visual):**
```
[●] Pending (Order Received)
    ↓
[○] Preparing (In Kitchen)
    ↓
[○] Ready (For Pickup/Delivery)
    ↓
[○] Completed
```

**Features:**
- Real-time status updates via WebSocket
- "Live" indicator badge
- Order details summary
- Estimated time (if available)
- Pull-to-refresh fallback

**Status Colors:**
- Pending: Brand Gold
- Preparing: Brand Gold (animated)
- Ready: Brand Green
- Completed: Brand Green

### 7.9 Profile Screen (Logged-in Users)
- Customer name (editable)
- Phone number (display only)
- Saved addresses management
- Order history link
- Language preference
- Logout button

### 7.10 Order History Screen
- List of past orders
- Each showing: Order #, Date, Status, Total
- Tap to view full details
- "Reorder" functionality

### 7.11 Settings/Preferences
- Language selection (EN/AR/KU)
- Notification preferences
- App version info

---

## 8. Internationalization (i18n)

### 8.1 Supported Languages
| Code | Language | Direction |
|------|----------|-----------|
| en | English | LTR |
| ar | Arabic | RTL |
| ku | Kurdish Badini | RTL |

### 8.2 RTL Handling
- Text alignment flips
- Layout order reverses
- Icons mirror where appropriate
- `Directionality` widget wrapping

### 8.3 Key Translations Required
- Navigation labels
- Button text
- Form labels & placeholders
- Status messages
- Error messages
- Menu category names
- About section content

---

## 9. Backend Integration (Supabase)

### 9.1 Base URL
```
https://[PROJECT_ID].supabase.co
```

### 9.2 Database Tables

#### customers
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| phone | text | Unique, E.164 format |
| name | text | Customer name |
| created_at | timestamp | Auto |
| updated_at | timestamp | Auto |

#### customer_addresses
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| customer_id | uuid | Foreign key |
| label | text | e.g., "Home", "Work" |
| location | text | Area/neighborhood |
| address | text | Full address |
| is_default | boolean | Default address flag |
| created_at | timestamp | Auto |

#### menu_items
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| name | text | English name |
| name_ku | text | Kurdish name |
| name_ar | text | Arabic name |
| price | numeric | Price in IQD |
| category | text | burgers/sides/drinks/combos |
| image_url | text | Supabase Storage URL |
| is_available | boolean | Availability flag |
| created_at | timestamp | Auto |
| updated_at | timestamp | Auto |

#### orders
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| order_number | integer | Auto-increment |
| customer_id | uuid | Foreign key (nullable) |
| customer_name | text | Required |
| customer_phone | text | Required |
| customer_location | text | Optional |
| customer_address | text | Required |
| notes | text | Special instructions |
| order_type | enum | online/dine_in/pickup |
| status | enum | pending/preparing/ready/completed/cancelled |
| total_amount | numeric | Total in IQD |
| created_at | timestamp | Auto |
| updated_at | timestamp | Auto |

#### order_items
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| order_id | uuid | Foreign key |
| menu_item_id | uuid | Foreign key |
| quantity | integer | Item quantity |
| unit_price | numeric | Price at time of order |
| created_at | timestamp | Auto |

#### otp_codes
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | Primary key |
| phone | text | Phone number |
| code | text | 6-digit OTP |
| expires_at | timestamp | 5 min from creation |
| verified | boolean | Used flag |
| created_at | timestamp | Auto |

### 9.3 Enums
```sql
order_status: pending, preparing, ready, completed, cancelled
order_type: dine_in, pickup, online
```

---

## 10. API Endpoints

### 10.1 Edge Functions

#### POST /functions/v1/send-otp
**Request:**
```json
{
  "phone": "+9647501234567"
}
```
**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```
**Errors:**
- 400: Invalid phone format
- 429: Rate limit exceeded (3 per 10 min)

#### POST /functions/v1/verify-otp
**Request:**
```json
{
  "phone": "+9647501234567",
  "code": "123456",
  "name": "John Doe"  // Optional, for new users
}
```
**Response:**
```json
{
  "success": true,
  "customer": {
    "id": "uuid",
    "phone": "+9647501234567",
    "name": "John Doe"
  },
  "addresses": [],
  "token": "jwt_token_here",
  "isNewUser": true
}
```

#### POST /functions/v1/update-customer-name
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "name": "New Name"
}
```
**Response:**
```json
{
  "success": true,
  "customer": { ... }
}
```

#### GET /functions/v1/customer-addresses
**Headers:** `Authorization: Bearer <token>`
**Response:**
```json
{
  "addresses": [
    {
      "id": "uuid",
      "label": "Home",
      "location": "Empire City",
      "address": "Building 5, Floor 2",
      "is_default": true
    }
  ]
}
```

#### POST /functions/v1/customer-addresses
**Headers:** `Authorization: Bearer <token>`
**Request:**
```json
{
  "label": "Home",
  "location": "Empire City",
  "address": "Building 5, Floor 2",
  "is_default": true
}
```

### 10.2 Database RPC Functions

#### create_online_order
**Request:**
```json
{
  "customer_name": "John Doe",
  "customer_phone": "+9647501234567",
  "customer_location": "Empire City",
  "customer_address": "Building 5, Floor 2",
  "notes": "Extra sauce please",
  "items": [
    { "menu_item_id": "uuid", "quantity": 2 },
    { "menu_item_id": "uuid", "quantity": 1 }
  ]
}
```
**Response:**
```json
{
  "id": "uuid",
  "order_number": 1234,
  "status": "pending",
  "total_amount": 25000,
  "created_at": "2024-02-06T12:00:00Z"
}
```

#### track_order
**Request:**
```json
{
  "order_number": 1234
}
```
**Response:**
```json
{
  "order_number": 1234,
  "status": "preparing",
  "customer_name": "John Doe",
  "total_amount": 25000,
  "created_at": "2024-02-06T12:00:00Z",
  "items": [
    { "name": "Classic Burger", "quantity": 2, "unit_price": 10000 }
  ]
}
```

### 10.3 Realtime Subscriptions

#### Order Status Updates
**Channel:** `order-status-{order_number}`
**Event:** `status_update`
**Payload:**
```json
{
  "order_number": 1234,
  "status": "ready",
  "updated_at": "2024-02-06T12:15:00Z"
}
```

---

## 11. Data Queries

### 11.1 Fetch Menu Items
```sql
SELECT * FROM menu_items
WHERE is_available = true
ORDER BY category, name;
```

### 11.2 Fetch Customer Orders
```sql
SELECT * FROM orders
WHERE customer_phone = '+9647501234567'
ORDER BY created_at DESC;
```

---

## 12. Local Storage

| Key | Type | Purpose |
|-----|------|---------|
| `cart` | JSON | Cart items array |
| `customer_token` | String | JWT auth token |
| `customer_data` | JSON | Cached customer info |
| `language` | String | Selected language (en/ar/ku) |
| `active_order` | JSON | Current order being tracked |

---

## 13. Push Notifications (Future)

### 13.1 Notification Types
| Type | Trigger | Message |
|------|---------|---------|
| Order Accepted | Status → preparing | "Your order is being prepared!" |
| Order Ready | Status → ready | "Your order is ready for pickup!" |
| Order Completed | Status → completed | "Thank you for your order!" |

---

## 14. Error Handling

### 14.1 Error Messages (Trilingual)
| Code | English | Arabic | Kurdish |
|------|---------|--------|---------|
| INVALID_PHONE | Invalid phone number | رقم هاتف غير صالح | ژمارەی تەلەفۆن نادروستە |
| OTP_EXPIRED | OTP has expired | انتهت صلاحية الرمز | کۆدەکە بەسەرچوو |
| OTP_INVALID | Invalid OTP code | رمز غير صحيح | کۆدی نادروست |
| RATE_LIMIT | Too many requests | طلبات كثيرة جداً | داواکاری زۆر |
| ORDER_FAILED | Order failed | فشل الطلب | داواکاری سەرنەکەوت |
| NETWORK_ERROR | Connection error | خطأ في الاتصال | هەڵەی پەیوەندی |

---

## 15. App Assets Required

### 15.1 App Icons
| File | Size | Purpose |
|------|------|---------|
| app_icon.png | 1024x1024 | Source icon |
| icon-android.png | 192x192 | Android launcher |
| icon-ios.png | 180x180 | iOS app icon |

### 15.2 Splash Screen
| File | Purpose |
|------|---------|
| splash_logo.png | Centered logo |
| splash_background | Charcoal (#0A0A0A) |

### 15.3 Menu Item Placeholders
| Category | Fallback Icon |
|----------|---------------|
| Burgers | 🍔 |
| Sides | 🍟 |
| Drinks | 🥤 |
| Combos | 🎁 |

---

## 16. User Flows

### 16.1 Guest Order Flow
```
Home → Browse Menu → Add to Cart → Cart → Checkout
→ Login Required → Phone → OTP → Name (new user)
→ Address → Place Order → Confirmation → Track Order
```

### 16.2 Returning Customer Flow
```
Home → Browse Menu → Add to Cart → Cart → Checkout
→ Auto-logged in → Select Saved Address → Place Order
→ Confirmation → Track Order
```

### 16.3 Order Tracking Flow
```
Enter Order Number → View Status Timeline → Real-time Updates
→ Order Complete → Rate Experience (optional)
```

---

## 17. Business Rules

### 17.1 Orders
- Online orders always start as "pending"
- Order numbers auto-increment
- Prices validated server-side (prevent manipulation)
- Cannot modify prices after order creation

### 17.2 Customers
- Phone number is unique identifier
- OTP valid for 5 minutes only
- Max 3 OTP requests per 10 minutes
- JWT token expires after 30 days
- Name can be updated anytime

### 17.3 Menu
- Unavailable items hidden from customer view
- Price changes don't affect existing orders
- Images stored in Supabase Storage

### 17.4 Operating Hours
- Daily: 16:00 - 23:00
- Display "Currently Closed" outside hours
- Allow orders during operating hours only

---

## 18. Testing Checklist

### 18.1 Authentication
- [ ] Phone validation (E.164 format)
- [ ] OTP send/receive
- [ ] OTP expiration handling
- [ ] Rate limiting works
- [ ] New user name entry
- [ ] Token persistence
- [ ] Auto-login on app restart

### 18.2 Menu & Cart
- [ ] Menu loads correctly
- [ ] Category filtering works
- [ ] Add/remove items from cart
- [ ] Quantity adjustments
- [ ] Cart persists across sessions
- [ ] Cart total calculates correctly

### 18.3 Checkout
- [ ] Form validation
- [ ] Saved address selection
- [ ] New address saving
- [ ] Order submission
- [ ] Order confirmation display

### 18.4 Order Tracking
- [ ] Real-time status updates
- [ ] Fallback polling works
- [ ] Status timeline displays correctly
- [ ] Connection indicator accurate

### 18.5 Internationalization
- [ ] Language switching works
- [ ] RTL layout correct for AR/KU
- [ ] All strings translated
- [ ] Menu names display in selected language

---

## 19. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | TBD | Initial release |

---

## 20. Contact & Support

- **Location:** Empire City, Erbil, Iraq
- **Hours:** 16:00 - 23:00 Daily
- **Instagram:** @thronburgerberlin
- **Facebook:** /thronburger
- **WhatsApp:** +49 176 69483574

---

*Document generated for Antigravity App Builder*
*Last updated: February 2026*
