const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

// Initialize with service account credentials
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'throunburger',
});

const db = admin.firestore();

async function seedMenuItems() {
    const menuItems = [
        {
            name: 'Classic Burger',
            category: 'burgers',
            price: 8000,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'Cheese Burger',
            category: 'burgers',
            price: 9500,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1551360768-b47f1b55693e?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'Double Burger',
            category: 'burgers',
            price: 12000,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'Coke',
            category: 'drinks',
            price: 1500,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'Sprite',
            category: 'drinks',
            price: 1500,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'Water',
            category: 'drinks',
            price: 1000,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'French Fries',
            category: 'sides',
            price: 2500,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1630431341973-02e1b662ec35?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
            name: 'Onion Rings',
            category: 'sides',
            price: 3000,
            is_available: true,
            image_url: 'https://images.unsplash.com/photo-1639024471283-03518883512d?w=400&h=400&fit=crop',
            created_at: admin.firestore.FieldValue.serverTimestamp(),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
    ];

    console.log('Adding menu items to Firestore...');

    const batch = db.batch();

    for (const item of menuItems) {
        const docRef = db.collection('menu_items').doc();
        batch.set(docRef, item);
        console.log(`  - ${item.name} (${item.category}): ${item.price} IQD`);
    }

    await batch.commit();
    console.log('\n✅ Successfully added', menuItems.length, 'menu items to Firestore!');
}

seedMenuItems()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error('Error:', error);
        process.exit(1);
    });
