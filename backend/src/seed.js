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

    console.log('[SEED] Starting MVP database seeding...');

    const seedData = {
      buses: {
        BUS101: {
          busNumber: '101',
          routeId: 'WGL01',
          status: 'offline'
        }
      },
      routes: {
        WGL01: {
          name: 'Warangal → Kazipet',
          stopIds: ['STOP001', 'STOP002', 'STOP003']
        }
      },
      stops: {
        STOP001: {
          name: 'Hanamkonda',
          latitude: 17.9784,
          longitude: 79.5941
        },
        STOP002: {
          name: 'Subedari',
          latitude: 17.9870,
          longitude: 79.5890
        },
        STOP003: {
          name: 'NIT Warangal',
          latitude: 17.9826,
          longitude: 79.5307
        }
      },
      trips: {
        TRIP001: {
          busId: 'BUS101',
          routeId: 'WGL01',
          status: 'not_started'
        }
      },
      liveLocations: {
        BUS101: {
          latitude: 17.9784,
          longitude: 79.5941,
          speed: 0,
          heading: 0,
          timestamp: 0,
          currentStop: 'STOP001',
          nextStop: 'STOP002'
        }
      }
    };

    await db.ref().update(seedData);

    console.log('[SEED] Successfully seeded top-level nodes:');
    console.log(' - buses/BUS101');
    console.log(' - routes/WGL01');
    console.log(' - stops/ (STOP001, STOP002, STOP003)');
    console.log(' - trips/TRIP001');
    console.log(' - liveLocations/BUS101');
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
