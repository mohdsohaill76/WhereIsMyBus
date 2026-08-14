const { initializeFirebase } = require('../config/firebase');

/**
 * Helper to get initialized Firebase Realtime Database instance.
 */
const getDb = () => {
  const app = initializeFirebase();
  if (!app) {
    throw new Error('Firebase Admin SDK is not initialized');
  }
  return app.database();
};

/**
 * Reads all buses from Firebase Realtime Database node `buses/`.
 */
const getAllBuses = async () => {
  const db = getDb();
  const snapshot = await db.ref('buses').once('value');
  return snapshot.val() || {};
};

/**
 * Reads all routes from Firebase Realtime Database node `routes/`.
 */
const getAllRoutes = async () => {
  const db = getDb();
  const snapshot = await db.ref('routes').once('value');
  return snapshot.val() || {};
};

/**
 * Reads all bus stops from Firebase Realtime Database node `stops/`.
 */
const getAllStops = async () => {
  const db = getDb();
  const snapshot = await db.ref('stops').once('value');
  return snapshot.val() || {};
};

/**
 * Reads the live location for a specific bus from `liveLocations/{busId}`.
 * @param {string} busId 
 */
const getLiveLocation = async (busId) => {
  if (!busId || typeof busId !== 'string') {
    return null;
  }
  const db = getDb();
  const snapshot = await db.ref(`liveLocations/${busId}`).once('value');
  return snapshot.val();
};

module.exports = {
  getAllBuses,
  getAllRoutes,
  getAllStops,
  getLiveLocation
};
