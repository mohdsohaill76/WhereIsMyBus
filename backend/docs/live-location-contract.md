# Live Location Data Contract (WhereIsMyBus)

This document defines the real-time location data contract shared between the **Conductor / ETM Phone App**, **Firebase Realtime Database**, **Passenger Mobile App**, and **Authority Dashboard** for the WhereIsMyBus MVP prototype.

---

## 1. Architecture Flow

```text
  [Conductor Phone GNSS/GPS]
              │
              ▼
   [Conductor / ETM App]
              │
              ▼ (Direct Firebase Realtime DB SDK write)
  [Firebase Realtime Database]
  (node: liveLocations/{busId})
         │                 │
         ▼                 ▼ (Realtime Listeners)
  [Passenger App]   [Authority Dashboard]
```

* **Direct Realtime Database Writes**: The conductor's phone app updates location telemetry directly in Firebase Realtime Database without passing through an intermediate Express API layer.
* **Future Extension**: The architecture supports substituting the conductor's phone app with hardware ETMs, IoT VTS boxes, or AIS-140 GPS hardware devices without changing the database contract.

---

## 2. JSON Contract Structure

Location data is stored under the top-level path:

```text
liveLocations/{busId}
```

### JSON Schema Example

```json
{
  "busId": "BUS101",
  "tripId": "TRIP001",
  "latitude": 17.9784,
  "longitude": 79.5941,
  "speed": 31.5,
  "heading": 120,
  "timestamp": 1786711200000,
  "currentStop": "STOP001",
  "nextStop": "STOP002",
  "status": "moving"
}
```

---

## 3. Field Definitions & Specifications

| Field | Data Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `busId` | `string` | **Yes** | Unique identifier of the bus | `"BUS101"` |
| `tripId` | `string` | **Yes** | Unique identifier of the active trip | `"TRIP001"` |
| `latitude` | `number` | **Yes** | Latitude coordinate in decimal degrees | `17.9784` |
| `longitude` | `number` | **Yes** | Longitude coordinate in decimal degrees | `79.5941` |
| `speed` | `number` | **Yes** | Speed in kilometers per hour (km/h) | `31.5` |
| `heading` | `number` | **Yes** | Compass bearing direction in degrees (0–360) | `120` |
| `timestamp` | `number` | **Yes** | Epoch timestamp in milliseconds | `1786711200000` |
| `currentStop` | `string` \| `null` | No | ID of the last passed / current stop | `"STOP001"` |
| `nextStop` | `string` \| `null` | No | ID of the upcoming target stop | `"STOP002"` |
| `status` | `string` | **Yes** | Current operational status of the bus | `"moving"` |

---

## 4. Data Validation Rules

1. **Latitude Range**: `-90.0` to `90.0` (Valid range for India: `8.0000` to `37.0000`).
2. **Longitude Range**: `-180.0` to `180.0` (Valid range for India: `68.0000` to `97.0000`).
3. **Speed Range**: `0.0` to `150.0` km/h. Values below `0` are invalid.
4. **Heading Range**: `0` to `360` degrees.
5. **Timestamp Format**: Standard Unix Epoch timestamp in **milliseconds** (`Date.now()`).
6. **Valid Bus Statuses**:
   - `"offline"`: Bus engine off / trip not active.
   - `"idle"`: Bus active but stationary at start depot.
   - `"moving"`: Bus actively traveling along the route.
   - `"stopped"`: Bus temporarily stopped at a bus stop / signal.
   - `"location_unavailable"`: Phone/device active but GPS signal is lost.

---

## 5. Network & Edge Cases Handling

* **GPS Unavailable**: If the phone loses GPS fix, the app sends a payload retaining last known coordinates, setting `speed: 0` and `status: "location_unavailable"`.
* **Internet Connection Loss**: The Firebase Mobile SDK caches pending updates locally. When internet reconnects, the latest timestamped record synchronizes automatically.
* **Online / Offline Determination**:
  - The Passenger App and Dashboard determine online status via **staleness thresholds**.
  - If `(CurrentTime - timestamp) > 30000 ms` (30 seconds), the client displays the bus as **Offline / Stale**.

---

## 6. Update Frequency (Prototype Recommendation)

* **Recommended Interval**: **3 to 5 seconds** (or on position change > 10 meters).
* **Rationale**:
  - Provides a smooth, real-time tracking experience for passengers during live demos.
  - Minimizes phone battery drain and mobile data usage during the 24-hour hackathon.
  - Keeps Firebase Realtime Database read/write ops well within free tier limits.

---

## 7. Prototype vs. Production Assumptions

| Feature | Prototype Assumption | Production Target |
| :--- | :--- | :--- |
| **Location Telemetry Device** | Conductor Smartphone GNSS/GPS | Hardware ETM / AIS-140 VTS Box / Vehicle Telemetry Unit |
| **Network Path** | Direct SDK write from mobile app | Encrypted MQTT/HTTPS ingestion pipeline via backend API |
| **Stale Timeout** | 30 seconds threshold | Dynamic dead-reckoning & disconnect alerts |
| **Data Verification** | Client-side validation | Server-side payload validation & anomaly detection |
