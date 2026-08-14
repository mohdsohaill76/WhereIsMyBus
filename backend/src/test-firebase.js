const path = require('path');
const dotenv = require('dotenv');

// Ensure environment variables from backend/.env are loaded
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const { initializeFirebase } = require('./config/firebase');

async function runFirebaseTest() {
  try {
    const app = initializeFirebase();
    if (!app) {
      console.error('[FIREBASE TEST] Firebase Admin initialization: FAILED');
      process.exit(1);
    }

    const db = app.database();
    const testRef = db.ref('connectionTest');
    const timestamp = Date.now();
    const testPayload = {
      status: 'connected',
      source: 'WhereIsMyBus backend',
      timestamp: timestamp
    };

    // 1. WRITE TEST
    try {
      await testRef.set(testPayload);
      console.log('[FIREBASE TEST] Write: SUCCESS');
    } catch (err) {
      console.error('[FIREBASE TEST] Write: FAILED -', err.message);
      process.exit(1);
    }

    // 2. READ TEST
    let readData = null;
    try {
      const snapshot = await testRef.once('value');
      readData = snapshot.val();
      console.log('[FIREBASE TEST] Read: SUCCESS');
    } catch (err) {
      console.error('[FIREBASE TEST] Read: FAILED -', err.message);
      process.exit(1);
    }

    // 3. VERIFY DATA
    if (
      readData &&
      readData.status === testPayload.status &&
      readData.source === testPayload.source &&
      readData.timestamp === testPayload.timestamp
    ) {
      console.log('[FIREBASE TEST] Data verification: SUCCESS');
      console.log('[FIREBASE TEST] Firebase connection: HEALTHY');
    } else {
      console.error('[FIREBASE TEST] Data verification: FAILED - Data mismatch');
      process.exit(1);
    }

    // 4. CLEANUP TEST
    try {
      await testRef.remove();
      console.log('[FIREBASE TEST] Cleanup: SUCCESS');
    } catch (err) {
      console.error('[FIREBASE TEST] Cleanup: FAILED -', err.message);
      process.exit(1);
    }

    process.exit(0);
  } catch (error) {
    console.error('[FIREBASE TEST] Unexpected Error:', error.message);
    process.exit(1);
  }
}

runFirebaseTest();
