const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const { validateLiveLocation } = require('./middleware/locationValidation');
const { updateLiveLocation } = require('./services/locationService');
const { initializeFirebase } = require('./config/firebase');

async function runLocationTests() {
  console.log('==================================================');
  console.log('STARTING LIVE LOCATION & VALIDATION TEST SUITE');
  console.log('==================================================\n');

  let passed = 0;
  let failed = 0;

  function assertTest(name, condition, details = '') {
    if (condition) {
      console.log(`[PASS] ${name}`);
      passed++;
    } else {
      console.error(`[FAIL] ${name} ${details ? '- ' + details : ''}`);
      failed++;
    }
  }

  const validPayload = {
    busId: 'BUS101',
    tripId: 'TRIP001',
    latitude: 17.9784,
    longitude: 79.5941,
    speed: 31.5,
    heading: 120,
    timestamp: Date.now(),
    currentStop: 'STOP001',
    nextStop: 'STOP002',
    status: 'moving'
  };

  // 1. Valid live location validation
  const val1 = validateLiveLocation(validPayload);
  assertTest('1. Valid live location payload validation', val1.isValid === true);

  // 2. Missing busId
  const val2 = validateLiveLocation({ ...validPayload, busId: '' });
  assertTest('2. Missing busId rejected', val2.isValid === false && val2.errors.some(e => e.includes('busId')));

  // 3. Missing tripId
  const val3 = validateLiveLocation({ ...validPayload, tripId: '  ' });
  assertTest('3. Missing tripId rejected', val3.isValid === false && val3.errors.some(e => e.includes('tripId')));

  // 4. Invalid latitude
  const val4 = validateLiveLocation({ ...validPayload, latitude: 999 });
  assertTest('4. Invalid latitude rejected', val4.isValid === false && val4.errors.some(e => e.includes('latitude')));

  // 5. Invalid longitude
  const val5 = validateLiveLocation({ ...validPayload, longitude: -999 });
  assertTest('5. Invalid longitude rejected', val5.isValid === false && val5.errors.some(e => e.includes('longitude')));

  // 6. Invalid speed
  const val6 = validateLiveLocation({ ...validPayload, speed: 250 });
  assertTest('6. Invalid speed rejected', val6.isValid === false && val6.errors.some(e => e.includes('speed')));

  // 7. Invalid heading
  const val7 = validateLiveLocation({ ...validPayload, heading: 400 });
  assertTest('7. Invalid heading rejected', val7.isValid === false && val7.errors.some(e => e.includes('heading')));

  // 8. Invalid timestamp
  const val8 = validateLiveLocation({ ...validPayload, timestamp: -5 });
  assertTest('8. Invalid timestamp rejected', val8.isValid === false && val8.errors.some(e => e.includes('timestamp')));

  // 9. Invalid status
  const val9 = validateLiveLocation({ ...validPayload, status: 'flying' });
  assertTest('9. Invalid status rejected', val9.isValid === false && val9.errors.some(e => e.includes('status')));

  // Integration tests requiring Firebase DB connection
  const app = initializeFirebase();
  if (!app) {
    console.error('[ERROR] Firebase Admin SDK unavailable for integration tests.');
    process.exit(1);
  }

  // 10. Non-existent bus
  try {
    const resBus = await updateLiveLocation({ ...validPayload, busId: 'BUS999_NONEXISTENT' });
    assertTest('10. Non-existent bus handled', resBus.status === 'BUS_NOT_FOUND');
  } catch (err) {
    assertTest('10. Non-existent bus handled', false, err.message);
  }

  // 11. Non-existent trip
  try {
    const resTrip = await updateLiveLocation({ ...validPayload, tripId: 'TRIP999_NONEXISTENT' });
    assertTest('11. Non-existent trip handled', resTrip.status === 'TRIP_NOT_FOUND');
  } catch (err) {
    assertTest('11. Non-existent trip handled', false, err.message);
  }

  // 12. Valid live location update & verification
  try {
    const resSuccess = await updateLiveLocation(validPayload);
    assertTest('12. Valid live location update to Firebase', resSuccess.status === 'SUCCESS' && resSuccess.busId === 'BUS101');

    // Verify stored content in liveLocations/BUS101
    const db = app.database();
    const snap = await db.ref('liveLocations/BUS101').once('value');
    const stored = snap.val();
    const isDataValid = stored && stored.latitude === validPayload.latitude && stored.speed === validPayload.speed;
    assertTest('12b. Live location saved accurately in Firebase DB', isDataValid);
  } catch (err) {
    assertTest('12. Valid live location update to Firebase', false, err.message);
  }

  console.log('\n==================================================');
  console.log(`TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('==================================================');

  if (failed > 0) {
    process.exit(1);
  } else {
    process.exit(0);
  }
}

runLocationTests();
