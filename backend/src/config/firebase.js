const path = require('path');
const fs = require('fs');
const admin = require('firebase-admin');

let firebaseApp = null;

const initializeFirebase = () => {
  if (firebaseApp) {
    return firebaseApp;
  }

  const databaseURL = process.env.FIREBASE_DATABASE_URL;
  const serviceAccountPath = path.resolve(__dirname, '../../serviceAccountKey.json');

  if (fs.existsSync(serviceAccountPath)) {
    try {
      const serviceAccount = require(serviceAccountPath);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL
      });
      console.log('[Firebase] Admin SDK initialized successfully with local service account.');
    } catch (err) {
      console.error('[Firebase] Failed to initialize Firebase Admin SDK.');
    }
  } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    try {
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL
      });
      console.log('[Firebase] Admin SDK initialized via FIREBASE_SERVICE_ACCOUNT env var.');
    } catch (err) {
      console.error('[Firebase] Failed to parse FIREBASE_SERVICE_ACCOUNT env var.');
    }
  } else {
    console.warn('[Firebase] Warning: serviceAccountKey.json not found and environment credentials unavailable.');
  }

  return firebaseApp;
};

module.exports = {
  initializeFirebase,
  getFirebaseApp: () => firebaseApp
};
