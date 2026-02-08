const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'throunburger',
    storageBucket: 'throunburger.firebasestorage.app'
});

async function setCors() {
    const bucket = admin.storage().bucket();

    const corsConfiguration = [
        {
            origin: ["*"],
            method: ["GET", "PUT", "POST", "DELETE", "HEAD", "OPTIONS"],
            responseHeader: ["Content-Type", "x-goog-resumable"],
            maxAgeSeconds: 3600
        }
    ];

    await bucket.setCorsConfiguration(corsConfiguration);

    console.log('✅ CORS configuration set for bucket ' + bucket.name);
    console.log('Images should now load on the web.');
}

setCors().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
