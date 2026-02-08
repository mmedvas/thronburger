const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}

const db = admin.firestore();

async function initCounter() {
    try {
        const counterRef = db.collection('counters').doc('orders');
        await counterRef.set({ current: 1000 });
        console.log('Counter initialized to 1000');
    } catch (error) {
        console.error('Error initializing counter:', error);
    }
}

initCounter();
