const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const {
  getAllBuses,
  getAllRoutes,
  getAllStops,
  getLiveLocation
} = require('./services/transitService');

async function runTransitReadTests() {
  console.log('==================================================');
  console.log('STARTING TRANSIT READ SERVICE TEST SUITE');
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

  // 1. Test getAllBuses()
  try {
    const buses = await getAllBuses();
    const hasBus101 = buses && buses.BUS101 && buses.BUS101.busNumber === '101';
    assertTest('1. getAllBuses() contains BUS101 with accurate metadata', hasBus101);
  } catch (err) {
    assertTest('1. getAllBuses()', false, err.message);
  }

  // 2. Test getAllRoutes()
  try {
    const routes = await getAllRoutes();
    const hasWgl01 = routes && routes.WGL01 && Array.isArray(routes.WGL01.stopIds);
    assertTest('2. getAllRoutes() contains WGL01 with valid stopIds list', hasWgl01);
  } catch (err) {
    assertTest('2. getAllRoutes()', false, err.message);
  }

  // 3. Test getAllStops()
  try {
    const stops = await getAllStops();
    const hasAllStops = stops && stops.STOP001 && stops.STOP002 && stops.STOP003;
    assertTest('3. getAllStops() contains STOP001, STOP002, and STOP003', hasAllStops);
  } catch (err) {
    assertTest('3. getAllStops()', false, err.message);
  }

  // 4. Test getLiveLocation('BUS101')
  try {
    const liveLoc = await getLiveLocation('BUS101');
    const isLiveValid = liveLoc && liveLoc.busId === 'BUS101' && typeof liveLoc.latitude === 'number';
    assertTest('4. getLiveLocation("BUS101") returns current live location', isLiveValid);
  } catch (err) {
    assertTest('4. getLiveLocation("BUS101")', false, err.message);
  }

  // 5. Test getLiveLocation('BUS999') non-existent
  try {
    const liveLocNull = await getLiveLocation('BUS999');
    assertTest('5. getLiveLocation("BUS999") returns null/not found', liveLocNull === null);
  } catch (err) {
    assertTest('5. getLiveLocation("BUS999")', false, err.message);
  }

  console.log('\n==================================================');
  console.log(`TRANSIT READ TEST RESULTS: ${passed} PASSED, ${failed} FAILED`);
  console.log('==================================================');

  if (failed > 0) {
    process.exit(1);
  } else {
    process.exit(0);
  }
}

runTransitReadTests();
