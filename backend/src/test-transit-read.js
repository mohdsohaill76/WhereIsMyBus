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

  // 1. Test getAllBuses() contains multiple buses
  try {
    const buses = await getAllBuses();
    const busKeys = Object.keys(buses || {});
    const hasMultipleBuses = busKeys.length >= 5 && buses.BUS101 && buses.BUS102 && buses.BUS103;
    assertTest(`1. getAllBuses() contains ${busKeys.length} buses (BUS101..BUS105)`, hasMultipleBuses);
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

  // 4. Test getLiveLocation('BUS101') and 'BUS102'
  try {
    const liveLoc101 = await getLiveLocation('BUS101');
    const liveLoc102 = await getLiveLocation('BUS102');
    const isLiveValid = liveLoc101 && liveLoc101.busId === 'BUS101' && liveLoc102 && liveLoc102.busId === 'BUS102';
    assertTest('4. getLiveLocation() returns live telemetry for BUS101 and BUS102', isLiveValid);
  } catch (err) {
    assertTest('4. getLiveLocation()', false, err.message);
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
