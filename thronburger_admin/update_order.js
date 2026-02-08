const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function updateOrder() {
    const orderRef = db.collection('orders').doc('l2KS5oNu77cGMAqTV3yo');
    await orderRef.update({ status: 'preparing' });
    console.log('Order status updated to preparing');
}

updateOrder();
