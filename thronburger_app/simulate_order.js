const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'throunburger',
});

const db = admin.firestore();

async function createOrder() {
    // 1. Get menu items (Double Burger & Coke)
    const burgerSnap = await db.collection('menu_items').where('name', '==', 'Double Burger').get();
    const drinkSnap = await db.collection('menu_items').where('name', '==', 'Coke').get();

    if (burgerSnap.empty || drinkSnap.empty) {
        console.error('Could not find menu items');
        return;
    }

    const burger = burgerSnap.docs[0].data();
    const drink = drinkSnap.docs[0].data();

    // 2. Order Number
    const countSnap = await db.collection('orders').count().get();
    const orderNumber = countSnap.data().count + 1001;

    // 3. Create Order Document
    const orderRef = db.collection('orders').doc();
    const orderData = {
        order_number: orderNumber,
        status: 'pending',
        customer_id: 'test_customer_789',
        customer_name: 'Mike Ross',
        customer_phone: '0750 555 4444',
        customer_address: 'Empire World, Tower C',
        is_online_order: true,
        order_type: 'delivery', // Should map to OrderType.delivery
        payment_method: 'cash',
        total_amount: burger.price + (drink.price * 2),
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
        // Note: 'items' array in doc is ignored by repo, but we keep it for reference if needed
        items: []
    };

    await orderRef.set(orderData);

    // 4. Create Items Subcollection
    const itemsBatch = db.batch();

    // Item 1: Double Burger
    const item1Ref = orderRef.collection('items').doc();
    itemsBatch.set(item1Ref, {
        menu_item_id: burgerSnap.docs[0].id,
        menu_item_name: burger.name,
        quantity: 1,
        unit_price: burger.price
    });

    // Item 2: Coke (x2)
    const item2Ref = orderRef.collection('items').doc();
    itemsBatch.set(item2Ref, {
        menu_item_id: drinkSnap.docs[0].id,
        menu_item_name: drink.name,
        quantity: 2,
        unit_price: drink.price
    });

    await itemsBatch.commit();

    console.log(`✅ Order #${orderNumber} created!`);
    console.log(`👤 Customer: ${orderData.customer_name}`);
    console.log(`🍔 Items: 1x ${burger.name}, 2x ${drink.name}`);
    console.log(`💰 Total: ${orderData.total_amount} IQD`);
}

createOrder().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
