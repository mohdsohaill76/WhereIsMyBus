const { initializeFirebase } = require('../config/firebase');

/**
 * Updates the live location for a bus in Firebase Realtime Database.
 * Verifies that the referenced bus and trip exist before saving.
 * 
 * @param {object} locationData 
 * @returns {Promise<{ status: string, message: string, busId?: string }>}
 */
const updateLiveLocation = async (locationData) => {
  const app = initializeFirebase();
  if (!app) {
    throw new Error('Firebase Admin SDK is not initialized');
  }

  const db = app.database();
  const { busId, tripId } = locationData;

  // 1. Verify referenced bus exists
  const busSnapshot = await db.ref(`buses/${busId}`).once('value');
  if (!busSnapshot.exists()) {
    return {
      status: 'BUS_NOT_FOUND',
      message: 'Bus not found'
    };
  }

  // 2. Verify referenced trip exists
  const tripSnapshot = await db.ref(`trips/${tripId}`).once('value');
  if (!tripSnapshot.exists()) {
    return {
      status: 'TRIP_NOT_FOUND',
      message: 'Trip not found'
    };
  }

  // 3. Construct payload adhering strictly to the contract
  const liveLocationPayload = {
    busId: locationData.busId,
    tripId: locationData.tripId,
    latitude: locationData.latitude,
    longitude: locationData.longitude,
    speed: locationData.speed,
    heading: locationData.heading,
    timestamp: locationData.timestamp,
    currentStop: locationData.currentStop !== undefined ? locationData.currentStop : null,
    nextStop: locationData.nextStop !== undefined ? locationData.nextStop : null,
    status: locationData.status
  };

  // 4. Save to liveLocations/{busId}
  await db.ref(`liveLocations/${busId}`).set(liveLocationPayload);

  return {
    status: 'SUCCESS',
    message: 'Live location updated',
    busId
  };
};

module.exports = {
  updateLiveLocation
};
