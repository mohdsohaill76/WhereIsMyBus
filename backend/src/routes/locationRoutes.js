const express = require('express');
const router = express.Router();
const { validateLiveLocation } = require('../middleware/locationValidation');
const { updateLiveLocation } = require('../services/locationService');

/**
 * POST /api/live-location
 * Ingests live location updates from the conductor/ETM app, validates the payload,
 * verifies bus/trip existence, and updates Firebase Realtime Database.
 */
router.post('/live-location', async (req, res) => {
  try {
    // 1. Payload validation
    const validation = validateLiveLocation(req.body);
    if (!validation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Invalid location data',
        errors: validation.errors
      });
    }

    // 2. Update location via service
    const result = await updateLiveLocation(req.body);

    if (result.status === 'BUS_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Bus not found'
      });
    }

    if (result.status === 'TRIP_NOT_FOUND') {
      return res.status(404).json({
        success: false,
        message: 'Trip not found'
      });
    }

    return res.status(200).json({
      success: true,
      message: result.message,
      busId: result.busId
    });
  } catch (error) {
    console.error('[API /live-location] Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;
