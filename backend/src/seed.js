const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const { initializeFirebase } = require('./config/firebase');

async function seedDatabase() {
  let app = null;
  try {
    app = initializeFirebase();
    if (!app) {
      console.error('[SEED] Error: Firebase Admin SDK failed to initialize.');
      process.exit(1);
    }

    const db = app.database();

    console.log('[SEED] Starting expanded database seeding...');

    const now = Date.now();

    const seedData = {
      buses: {
        BUS101: {
          busNumber: '101',
          routeId: 'WGL01',
          status: 'moving'
        },
        BUS102: {
          busNumber: '102',
          routeId: 'WGL01',
          status: 'moving'
        },
        BUS103: {
          busNumber: '202',
          routeId: 'HNMK02',
          status: 'moving'
        },
        BUS104: {
          busNumber: '303',
          routeId: 'KZP03',
          status: 'stopped'
        },
        BUS105: {
          busNumber: '404',
          routeId: 'WGL01',
          status: 'offline'
        }
      },
      routes: {
        WGL01: {
          name: 'Warangal → Kazipet Express',
          stopIds: ['STOP001', 'STOP002', 'STOP003', 'STOP004', 'STOP005']
        },
        HNMK02: {
          name: 'Hanamkonda → Subedari Shuttle',
          stopIds: ['STOP001', 'STOP002', 'STOP003']
        },
        KZP03: {
          name: 'Kazipet → NIT Connector',
          stopIds: ['STOP003', 'STOP004', 'STOP005']
        }
      },
      stops: {
        STOP001: {
          name: 'Warangal Bus Station',
          latitude: 17.9784,
          longitude: 79.5941
        },
        STOP002: {
          name: 'Hanamkonda Chowrasta',
          latitude: 17.9820,
          longitude: 79.5850
        },
        STOP003: {
          name: 'Subedari Circle',
          latitude: 17.9870,
          longitude: 79.5890
        },
        STOP004: {
          name: 'NIT Warangal Gate',
          latitude: 17.9826,
          longitude: 79.5307
        },
        STOP005: {
          name: 'Kazipet Junction',
          latitude: 17.9890,
          longitude: 79.5180
        }
      },
      trips: {
        TRIP001: {
          busId: 'BUS101',
          routeId: 'WGL01',
          status: 'in_transit'
        },
        TRIP002: {
          busId: 'BUS102',
          routeId: 'WGL01',
          status: 'in_transit'
        },
        TRIP003: {
          busId: 'BUS103',
          routeId: 'HNMK02',
          status: 'in_transit'
        },
        TRIP004: {
          busId: 'BUS104',
          routeId: 'KZP03',
          status: 'in_transit'
        },
        TRIP005: {
          busId: 'BUS105',
          routeId: 'WGL01',
          status: 'completed'
        }
      },
      liveLocations: {
        BUS101: {
          busId: 'BUS101',
          tripId: 'TRIP001',
          latitude: 17.9784,
          longitude: 79.5941,
          speed: 35,
          heading: 180,
          timestamp: now,
          currentStop: 'STOP001',
          nextStop: 'STOP002',
          status: 'moving'
        },
        BUS102: {
          busId: 'BUS102',
          tripId: 'TRIP002',
          latitude: 17.9820,
          longitude: 79.5850,
          speed: 28,
          heading: 195,
          timestamp: now,
          currentStop: 'STOP002',
          nextStop: 'STOP003',
          status: 'moving'
        },
        BUS103: {
          busId: 'BUS103',
          tripId: 'TRIP003',
          latitude: 17.9870,
          longitude: 79.5890,
          speed: 42,
          heading: 170,
          timestamp: now,
          currentStop: 'STOP003',
          nextStop: 'STOP004',
          status: 'moving'
        },
        BUS104: {
          busId: 'BUS104',
          tripId: 'TRIP004',
          latitude: 17.9826,
          longitude: 79.5307,
          speed: 0,
          heading: 0,
          timestamp: now,
          currentStop: 'STOP004',
          nextStop: 'STOP005',
          status: 'stopped'
        },
        BUS105: {
          busId: 'BUS105',
          tripId: 'TRIP005',
          latitude: 17.9890,
          longitude: 79.5180,
          speed: 0,
          heading: 0,
          timestamp: now - 360000,
          currentStop: 'STOP005',
          nextStop: 'STOP005',
          status: 'offline'
        }
      }
    };

    await db.ref().set(seedData);

    console.log('[SEED] Successfully seeded expanded top-level nodes:');
    console.log(' - buses/ (BUS101, BUS102, BUS103, BUS104, BUS105)');
    console.log(' - routes/ (WGL01, HNMK02, KZP03)');
    console.log(' - stops/ (STOP001, STOP002, STOP003, STOP004, STOP005)');
    console.log(' - trips/ (TRIP001..TRIP005)');
    console.log(' - liveLocations/ (BUS101..BUS105)');
    console.log('[SEED] Database seeding complete.');

    if (app) {
      await app.delete();
    }
    process.exit(0);
  } catch (error) {
    console.error('[SEED] Error during database seeding:', error.message);
    if (app) {
      try { await app.delete(); } catch (e) {}
    }
    process.exit(1);
  }
}

seedDatabase();
