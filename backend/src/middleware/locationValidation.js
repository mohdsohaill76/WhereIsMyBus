const VALID_STATUSES = ['offline', 'idle', 'moving', 'stopped', 'location_unavailable'];

/**
 * Validates incoming live location update payload according to the live location contract.
 * @param {object} data 
 * @returns {{ isValid: boolean, errors: string[] }}
 */
const validateLiveLocation = (data) => {
  const errors = [];

  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    return { isValid: false, errors: ['Payload must be a valid JSON object'] };
  }

  // busId
  if (typeof data.busId !== 'string' || !data.busId.trim()) {
    errors.push('busId is required and must be a non-empty string');
  }

  // tripId
  if (typeof data.tripId !== 'string' || !data.tripId.trim()) {
    errors.push('tripId is required and must be a non-empty string');
  }

  // latitude
  if (typeof data.latitude !== 'number' || Number.isNaN(data.latitude) || data.latitude < -90 || data.latitude > 90) {
    errors.push('latitude is required and must be a number between -90 and 90');
  }

  // longitude
  if (typeof data.longitude !== 'number' || Number.isNaN(data.longitude) || data.longitude < -180 || data.longitude > 180) {
    errors.push('longitude is required and must be a number between -180 and 180');
  }

  // speed
  if (typeof data.speed !== 'number' || Number.isNaN(data.speed) || data.speed < 0 || data.speed > 150) {
    errors.push('speed is required and must be a number between 0 and 150 km/h');
  }

  // heading
  if (typeof data.heading !== 'number' || Number.isNaN(data.heading) || data.heading < 0 || data.heading > 360) {
    errors.push('heading is required and must be a number between 0 and 360 degrees');
  }

  // timestamp
  if (typeof data.timestamp !== 'number' || Number.isNaN(data.timestamp) || data.timestamp <= 0) {
    errors.push('timestamp is required and must be a valid positive epoch timestamp in milliseconds');
  }

  // status
  if (typeof data.status !== 'string' || !VALID_STATUSES.includes(data.status)) {
    errors.push(`status is required and must be one of: ${VALID_STATUSES.join(', ')}`);
  }

  // Optional fields validation
  if (data.currentStop !== undefined && data.currentStop !== null && typeof data.currentStop !== 'string') {
    errors.push('currentStop must be a string or null');
  }

  if (data.nextStop !== undefined && data.nextStop !== null && typeof data.nextStop !== 'string') {
    errors.push('nextStop must be a string or null');
  }

  return {
    isValid: errors.length === 0,
    errors
  };
};

module.exports = {
  validateLiveLocation,
  VALID_STATUSES
};
