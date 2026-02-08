const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

// Initialize with service account credentials
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'throunburger',
});

const db = admin.firestore();

// Image mappings by item name
const imageUrls = {
    'Classic Burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=400&fit=crop',
    'Cheese Burger': 'https://images.unsplash.com/photo-1551360768-b47f1b55693e?w=400&h=400&fit=crop',
    'Double Burger': 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?w=400&h=400&fit=crop',
    'Coke': 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400&h=400&fit=crop',
    'Sprite': 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=400&h=400&fit=crop',
    'Water': 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400&h=400&fit=crop',
    'French Fries': 'https://images.unsplash.com/photo-1630431341973-02e1b662ec35?w=400&h=400&fit=crop',
    'Onion Rings': 'https://images.unsplash.com/photo-1639024471283-03518883512d?w=400&h=400&fit=crop',
};

async function updateMenuImages() {
    console.log('Updating menu item images...\n');

    const snapshot = await db.collection('menu_items').get();

    let updated = 0;
    for (const doc of snapshot.docs) {
        const data = doc.data();
        const name = data.name;

        if (imageUrls[name]) {
            await doc.ref.update({
                image_url: imageUrls[name],
                updated_at: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`✅ Updated: ${name}`);
            updated++;
        } else {
            console.log(`⚠️ Skipped (no image mapping): ${name}`);
        }
    }

    console.log(`\n✅ Updated ${updated} menu items with images!`);
}

updateMenuImages()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error('Error:', error);
        process.exit(1);
    });
