const express = require('express');
const router = express.Router();
const {
  getAllBuses,
  getAllRoutes,
  getAllStops,
  getLiveLocation
} = require('../services/transitService');

/**
 * GET /api/buses
 * Returns all registered buses.
 */
router.get('/buses', async (req, res) => {
  try {
    const buses = await getAllBuses();
    return res.status(200).json({
      success: true,
      data: buses
    });
  } catch (error) {
    console.error('[API GET /buses] Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

/**
 * GET /api/routes
 * Returns all registered bus routes.
 */
router.get('/routes', async (req, res) => {
  try {
    const routes = await getAllRoutes();
    return res.status(200).json({
      success: true,
      data: routes
    });
  } catch (error) {
    console.error('[API GET /routes] Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

/**
 * GET /api/stops
 * Returns all registered bus stops.
 */
router.get('/stops', async (req, res) => {
  try {
    const stops = await getAllStops();
    return res.status(200).json({
      success: true,
      data: stops
    });
  } catch (error) {
    console.error('[API GET /stops] Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

/**
 * GET /api/live-location/:busId
 * Returns the latest live location telemetry for a specific bus.
 */
router.get('/live-location/:busId', async (req, res) => {
  try {
    const { busId } = req.params;
    const locationData = await getLiveLocation(busId);

    if (!locationData) {
      return res.status(404).json({
        success: false,
        message: 'Bus live location not found'
      });
    }

    return res.status(200).json({
      success: true,
      data: locationData
    });
  } catch (error) {
    console.error('[API GET /live-location/:busId] Error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;
