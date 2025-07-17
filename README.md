# 📝 Catatan: Pemisahan Frontend & Backend 
## Aplikasi IoT Pakan Ikan

---

## 🎯 **KONSEP DASAR**

### **Frontend (Client Side)**
- **Apa itu:** Bagian yang dilihat dan diinteraksi oleh user
- **Technology:** Flutter (Mobile App)
- **Tugas:** Menampilkan data, mengumpulkan input user, navigasi

### **Backend (Server Side)**  
- **Apa itu:** Bagian yang memproses data dan komunikasi dengan hardware
- **Technology:** Node.js, Python, PHP, dll
- **Tugas:** Business logic, database, IoT communication, API

### **Komunikasi:** Frontend ↔ Backend melalui **HTTP API / WebSocket**

---

## 🎨 **FRONTEND (Flutter Mobile App)**

### **✅ Yang TETAP di Frontend:**

#### **1. User Interface (UI)**
```
📁 lib/screens/
├── selamat_datang.dart     # Welcome screen
├── login.dart              # Login form
├── signup.dart             # Register form  
├── dashboard.dart          # Dashboard UI
├── berat.dart              # Weight selection UI
├── sudut_pelontar.dart     # Angle selection UI
└── pembukaan_pakan.dart    # Feed control menu UI
```

#### **2. State Management & Interactions**
- Button clicks (`onTap`, `onPressed`)
- Form validation (email format, password validation)
- Loading states (`_isLoading = true/false`)
- Navigation (`Navigator.push/pop`)
- Local UI state (`setState()`)

#### **3. Data Models untuk UI**
```dart
class SensorData {
  final double waterLevel;
  final double temperature;
  final double pH;
  final double turbidity;
}

class PowerData {
  final double inputVoltage;
  final double outputVoltage;
}
```

#### **4. API Service Layer**
```dart
// File baru: lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://your-api.com/api';
  
  static Future<SensorData> getSensorData() async { ... }
  static Future<bool> controlValve(bool isOn) async { ... }
  static Future<bool> setFeedWeight(String weight) async { ... }
}
```

---

## ⚙️ **BACKEND (Server/API)**

### **✅ Yang PINDAH ke Backend:**

#### **1. API Endpoints yang Dibutuhkan**
```
🔐 Authentication:
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
GET  /api/auth/me

📊 Sensor Data:
GET  /api/sensors/water-quality
GET  /api/sensors/power-system
GET  /api/sensors/history

🎮 Device Controls:
POST /api/controls/valve
POST /api/controls/feed-weight
POST /api/controls/feed-angle
GET  /api/controls/status

📱 User Settings:
GET  /api/user/preferences
POST /api/user/preferences
```

#### **2. Firebase Firestore Database Structure**
```javascript
// 🔥 Firebase Firestore Collections

// Collection: users
users/{userId} = {
  email: "user@example.com",
  displayName: "User Name",
  createdAt: timestamp,
  lastLoginAt: timestamp,
  deviceId: "device_001" // untuk link ke IoT device
}

// Collection: sensorReadings  
sensorReadings/{readingId} = {
  userId: "user_123",
  deviceId: "device_001",
  waterLevel: 75.5,        // percentage
  temperature: 27.5,       // celsius
  phLevel: 7.2,           // pH scale
  turbidity: 25.5,        // NTU
  inputVoltage: 13.9,     // volts
  outputVoltage: 12.8,    // volts
  timestamp: timestamp
}

// Collection: deviceSettings
deviceSettings/{userId} = {
  feedWeight: "2KG",       // "1KG", "2KG", "3KG"
  feedAngle: 60,          // 30, 60, 90 degrees
  valveStatus: false,     // true/false
  autoFeedEnabled: true,
  feedSchedule: {
    morning: "08:00",
    evening: "18:00"
  },
  updatedAt: timestamp
}

// Collection: feedLogs
feedLogs/{logId} = {
  userId: "user_123", 
  deviceId: "device_001",
  weight: "2KG",
  angle: 60,
  duration: 30,           // seconds
  triggeredBy: "manual",  // "manual", "scheduled", "auto"
  timestamp: timestamp,
  success: true
}

// Collection: devices (untuk multiple device per user)
devices/{deviceId} = {
  userId: "user_123",
  deviceName: "Kolam Utama",
  deviceType: "fish_feeder_v1",
  isOnline: true,
  lastSeen: timestamp,
  location: {
    latitude: -7.7956,
    longitude: 110.3695
  },
  createdAt: timestamp
}
```

#### **3. Firebase Backend Integration**
```javascript
// Backend - firebase/firestore_service.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

class FirestoreService {
  // Simpan sensor reading ke Firebase
  async saveSensorReading(userId, sensorData) {
    try {
      const docRef = await db.collection('sensorReadings').add({
        userId,
        deviceId: sensorData.deviceId,
        waterLevel: sensorData.waterLevel,
        temperature: sensorData.temperature,
        phLevel: sensorData.phLevel,
        turbidity: sensorData.turbidity,
        inputVoltage: sensorData.inputVoltage,
        outputVoltage: sensorData.outputVoltage,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
      return docRef.id;
    } catch (error) {
      throw new Error(`Failed to save sensor data: ${error.message}`);
    }
  }
  
  // Get latest sensor readings
  async getLatestSensorData(userId) {
    try {
      const snapshot = await db.collection('sensorReadings')
        .where('userId', '==', userId)
        .orderBy('timestamp', 'desc')
        .limit(1)
        .get();
        
      if (snapshot.empty) {
        return null;
      }
      
      return snapshot.docs[0].data();
    } catch (error) {
      throw new Error(`Failed to get sensor data: ${error.message}`);
    }
  }
  
  // Update device settings
  async updateDeviceSettings(userId, settings) {
    try {
      await db.collection('deviceSettings').doc(userId).set({
        feedWeight: settings.feedWeight,
        feedAngle: settings.feedAngle,
        valveStatus: settings.valveStatus,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
      
      return true;
    } catch (error) {
      throw new Error(`Failed to update settings: ${error.message}`);
    }
  }
  
  // Log feed activity
  async logFeedActivity(userId, feedData) {
    try {
      await db.collection('feedLogs').add({
        userId,
        deviceId: feedData.deviceId,
        weight: feedData.weight,
        angle: feedData.angle,
        duration: feedData.duration,
        triggeredBy: feedData.triggeredBy,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        success: feedData.success
      });
    } catch (error) {
      throw new Error(`Failed to log feed activity: ${error.message}`);
    }
  }
}

module.exports = new FirestoreService();
```

#### **4. IoT Hardware Communication dengan Firebase**
```javascript
// Backend - hardware/sensor_controller.js
const FirestoreService = require('../firebase/firestore_service');

class SensorController {
  constructor() {
    this.deviceId = process.env.DEVICE_ID || 'device_001';
  }
  
  // Baca semua sensor dan simpan ke Firebase
  async readAndSaveSensorData(userId) {
    try {
      const sensorData = {
        deviceId: this.deviceId,
        waterLevel: await this.readWaterLevel(),
        temperature: await this.readTemperature(),
        phLevel: await this.readPH(),
        turbidity: await this.readTurbidity(),
        inputVoltage: await this.readInputVoltage(),
        outputVoltage: await this.readOutputVoltage()
      };
      
      // Simpan ke Firebase
      await FirestoreService.saveSensorReading(userId, sensorData);
      
      return sensorData;
    } catch (error) {
      console.error('Error reading sensors:', error);
      throw error;
    }
  }
  
  // Baca sensor water level via Arduino/ESP32
  async readWaterLevel() {
    // Serial communication atau HTTP request ke microcontroller
    return await this.sendCommand('GET_WATER_LEVEL');
  }
  
  // Kontrol valve dan update Firebase
  async controlValve(userId, isOn) {
    try {
      const result = await this.sendCommand(`SET_VALVE:${isOn ? 1 : 0}`);
      
      // Update status di Firebase
      await FirestoreService.updateDeviceSettings(userId, {
        valveStatus: isOn
      });
      
      return result;
    } catch (error) {
      throw new Error(`Failed to control valve: ${error.message}`);
    }
  }
  
  // Kontrol feed dispenser dan log ke Firebase
  async dispenseFeed(userId, weight, angle) {
    try {
      const startTime = Date.now();
      
      // Set angle servo
      await this.sendCommand(`SET_ANGLE:${angle}`);
      await this.delay(1000); // tunggu servo positioning
      
      // Dispense feed berdasarkan weight
      const duration = this.calculateFeedDuration(weight);
      await this.sendCommand(`DISPENSE_FEED:${duration}`);
      
      const endTime = Date.now();
      const actualDuration = Math.round((endTime - startTime) / 1000);
      
      // Log activity ke Firebase
      await FirestoreService.logFeedActivity(userId, {
        deviceId: this.deviceId,
        weight,
        angle,
        duration: actualDuration,
        triggeredBy: 'manual',
        success: true
      });
      
      return { success: true, duration: actualDuration };
    } catch (error) {
      // Log failed attempt
      await FirestoreService.logFeedActivity(userId, {
        deviceId: this.deviceId,
        weight,
        angle,
        duration: 0,
        triggeredBy: 'manual',
        success: false
      });
      
      throw error;
    }
  }
  
  calculateFeedDuration(weight) {
    // Convert weight to dispenser duration
    const durations = {
      '1KG': 5000,  // 5 seconds
      '2KG': 10000, // 10 seconds  
      '3KG': 15000  // 15 seconds
    };
    return durations[weight] || 5000;
  }
  
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  
  async sendCommand(command) {
    // Implementasi komunikasi dengan hardware
    // Bisa via Serial, HTTP, MQTT, etc.
    console.log(`Sending command: ${command}`);
    // Simulate hardware response
    return { success: true, value: Math.random() * 100 };
  }
}

module.exports = new SensorController();
```

#### **5. Real-time Communication dengan Firebase**
```javascript
// Backend - Firebase Real-time Functions
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Cloud Function untuk otomatis backup sensor data
exports.backupSensorData = functions.firestore
  .document('sensorReadings/{readingId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // Backup ke external storage atau analytics
    console.log('New sensor reading:', data);
    
    // Check for alerts (suhu terlalu tinggi, pH tidak normal)
    if (data.temperature > 30) {
      await sendAlert(data.userId, 'Temperature too high!');
    }
    
    if (data.phLevel < 6.5 || data.phLevel > 8.5) {
      await sendAlert(data.userId, 'pH level abnormal!');
    }
  });

// Cloud Function untuk scheduled feeding
exports.scheduledFeeding = functions.pubsub
  .schedule('0 8,18 * * *') // Daily at 8AM and 6PM
  .onRun(async (context) => {
    const usersSnapshot = await admin.firestore()
      .collection('deviceSettings')
      .where('autoFeedEnabled', '==', true)
      .get();
    
    for (const doc of usersSnapshot.docs) {
      const userId = doc.id;
      const settings = doc.data();
      
      // Trigger automatic feeding
      await triggerAutoFeed(userId, settings);
    }
  });

async function sendAlert(userId, message) {
  // Send push notification via Firebase Cloud Messaging
  const payload = {
    notification: {
      title: 'IoT Fish Feeder Alert',
      body: message
    }
  };
  
  // Get user's FCM token and send notification
  // Implementation depends on your FCM setup
}
```

```dart
// Frontend - Firebase Real-time Listeners
class FirebaseRealtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Listen to real-time sensor updates
  Stream<SensorData> getSensorDataStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();
    
    return _firestore
        .collection('sensorReadings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return SensorData.empty();
      }
      
      final data = snapshot.docs.first.data();
      return SensorData.fromFirestore(data);
    });
  }
  
  // Listen to device settings changes
  Stream<DeviceSettings> getDeviceSettingsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();
    
    return _firestore
        .collection('deviceSettings')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return DeviceSettings.defaultSettings();
      }
      
      return DeviceSettings.fromFirestore(snapshot.data()!);
    });
  }
  
  // Update valve control
  Future<void> controlValve(bool isOn) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('deviceSettings').doc(userId).update({
      'valveStatus': isOn,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Also trigger backend API for hardware control
    await ApiService.controlValve(isOn);
  }
  
  // Set feed settings
  Future<void> setFeedSettings(String weight, int angle) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('deviceSettings').doc(userId).set({
      'feedWeight': weight,
      'feedAngle': angle,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
```

---

## 🔗 **KOMUNIKASI FRONTEND ↔ BACKEND dengan Firebase**

### **Firebase Cloud Functions (untuk API endpoints)**
```javascript
// functions/src/api/sensors.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const SensorController = require('../hardware/sensorController');

exports.getSensorData = functions.https.onCall(async (data, context) => {
  // Verify user authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const userId = context.auth.uid;
  
  try {
    // Get latest sensor reading from hardware
    const sensorData = await SensorController.readAndSaveSensorData(userId);
    
    return {
      success: true,
      data: sensorData
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.controlValve = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { isOn } = data;
  const userId = context.auth.uid;
  
  try {
    await SensorController.controlValve(userId, isOn);
    
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.dispenseFeed = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { weight, angle } = data;
  const userId = context.auth.uid;
  
  try {
    const result = await SensorController.dispenseFeed(userId, weight, angle);
    
    return result;
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

### **Frontend - Firebase Integration**
```dart
// lib/services/firebase_service.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _functions = FirebaseFunctions.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  
  // Call Cloud Function untuk get sensor data
  static Future<SensorData> getSensorData() async {
    try {
      final result = await _functions
          .httpsCallable('getSensorData')
          .call();
      
      if (result.data['success']) {
        return SensorData.fromMap(result.data['data']);
      } else {
        throw Exception('Failed to get sensor data');
      }
    } catch (e) {
      throw Exception('Error calling getSensorData: $e');
    }
  }
  
  // Call Cloud Function untuk control valve
  static Future<bool> controlValve(bool isOn) async {
    try {
      final result = await _functions
          .httpsCallable('controlValve')
          .call({'isOn': isOn});
      
      return result.data['success'] ?? false;
    } catch (e) {
      throw Exception('Error controlling valve: $e');
    }
  }
  
  // Call Cloud Function untuk dispense feed
  static Future<bool> dispenseFeed(String weight, int angle) async {
    try {
      final result = await _functions
          .httpsCallable('dispenseFeed')
          .call({
            'weight': weight,
            'angle': angle
          });
      
      return result.data['success'] ?? false;
    } catch (e) {
      throw Exception('Error dispensing feed: $e');
    }
  }
  
  // Real-time listener untuk sensor data
  static Stream<SensorData> sensorDataStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();
    
    return _firestore
        .collection('sensorReadings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return SensorData.empty();
      }
      
      final data = snapshot.docs.first.data();
      return SensorData.fromFirestore(data);
    });
  }
  
  // Real-time listener untuk device settings
  static Stream<DeviceSettings> deviceSettingsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();
    
    return _firestore
        .collection('deviceSettings')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return DeviceSettings.defaultSettings();
      }
      
      return DeviceSettings.fromFirestore(snapshot.data()!);
    });
  }
  
  // Update settings di Firestore (realtime)
  static Future<void> updateDeviceSettings({
    String? feedWeight,
    int? feedAngle,
    bool? valveStatus,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    if (feedWeight != null) updates['feedWeight'] = feedWeight;
    if (feedAngle != null) updates['feedAngle'] = feedAngle;
    if (valveStatus != null) updates['valveStatus'] = valveStatus;
    
    await _firestore
        .collection('deviceSettings')
        .doc(userId)
        .set(updates, SetOptions(merge: true));
  }
}
```

### **Firestore Security Rules**
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /sensorReadings/{readingId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
    
    match /deviceSettings/{userId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == userId;
    }
    
    match /feedLogs/{logId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
    
    match /devices/{deviceId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 📋 **STRUKTUR PROJECT YANG BENAR**

### **Frontend Structure (Flutter)**
```
aplikasi_pakan_ikan/
├── lib/
│   ├── main.dart
│   ├── screens/          # UI Screens
│   │   ├── auth/
│   │   │   ├── login.dart
│   │   │   └── signup.dart
│   │   └── dashboard/
│   │       ├── dashboard.dart
│   │       ├── berat.dart
│   │       └── sudut_pelontar.dart
│   ├── services/         # API Communication
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── realtime_service.dart
│   ├── models/           # Data Models
│   │   ├── user.dart
│   │   ├── sensor_data.dart
│   │   └── device_settings.dart
│   ├── widgets/          # Reusable UI Components
│   │   ├── info_card.dart
│   │   └── custom_button.dart
│   └── utils/            # Helper Functions
│       ├── constants.dart
│       └── validators.dart
└── pubspec.yaml
```

### **Backend Structure (Firebase + Node.js)**
```
iot-fish-feeder-firebase/
├── functions/                # Firebase Cloud Functions
│   ├── index.js             # Main functions file
│   ├── package.json
│   └── src/
│       ├── api/             # HTTP API Routes
│       │   ├── sensors.js
│       │   ├── controls.js
│       │   └── auth.js
│       ├── triggers/         # Firestore Triggers
│       │   ├── sensorTriggers.js
│       │   └── userTriggers.js
│       ├── scheduled/        # Scheduled Functions
│       │   └── autoFeeding.js
│       ├── hardware/         # IoT Communication
│       │   ├── sensorController.js
│       │   └── deviceController.js
│       └── utils/
│           ├── validation.js
│           └── notifications.js
├── firestore.rules          # Firestore Security Rules
├── firestore.indexes.json   # Database Indexes
├── firebase.json            # Firebase Configuration
└── .env                     # Environment Variables
```

---

## 🚨 **KESALAHAN YANG HARUS DIHINDARI**

### **❌ JANGAN di Frontend:**
1. **Hardcode sensor data**
   ```dart
   // SALAH ❌
   _InfoCard(title: 'Tingkat Air', value: '75%')
   ```

2. **Simpan API keys sensitive**
   ```dart
   // SALAH ❌ 
   const apiKey = "secret_key_123";
   ```

3. **Business logic kompleks**
   ```dart
   // SALAH ❌
   double calculateOptimalFeedAmount(double fishCount, double temperature) {
     // Kompleks calculation tidak boleh di frontend
   }
   ```

### **❌ JANGAN di Backend:**
1. **UI/Styling logic**
2. **Navigation logic**  
3. **Form validation yang bersifat UX**

---

## ✅ **CONTOH IMPLEMENTASI YANG BENAR dengan Firebase**

### **Frontend (dashboard.dart) - SETELAH refactor dengan Firebase:**
```dart
class _DashboardScreenState extends State<DashboardScreen> {
  SensorData? sensorData;
  DeviceSettings? deviceSettings;
  bool isLoading = true;
  
  // Stream subscriptions untuk real-time updates
  StreamSubscription<SensorData>? _sensorSubscription;
  StreamSubscription<DeviceSettings>? _settingsSubscription;
  
  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }
  
  void _setupRealtimeListeners() {
    // Listen real-time sensor data dari Firestore
    _sensorSubscription = FirebaseService.sensorDataStream().listen(
      (data) {
        setState(() {
          sensorData = data;
          isLoading = false;
        });
      },
      onError: (error) {
        _showErrorSnackbar('Error sensor data: $error');
        setState(() => isLoading = false);
      }
    );
    
    // Listen real-time device settings dari Firestore
    _settingsSubscription = FirebaseService.deviceSettingsStream().listen(
      (settings) {
        setState(() {
          deviceSettings = settings;
        });
      },
      onError: (error) {
        _showErrorSnackbar('Error settings: $error');
      }
    );
    
    // Trigger sensor reading via Cloud Function
    _refreshSensorData();
  }
  
  void _refreshSensorData() async {
    try {
      // Call Cloud Function untuk baca sensor terbaru
      await FirebaseService.getSensorData();
      // Data akan otomatis update via Firestore listener
    } catch (e) {
      _showErrorSnackbar('Gagal refresh sensor: $e');
    }
  }
  
  void _toggleValve(bool value) async {
    try {
      // Update Firestore setting (real-time)
      await FirebaseService.updateDeviceSettings(valveStatus: value);
      
      // Trigger hardware control via Cloud Function
      await FirebaseService.controlValve(value);
      
      _showSuccessSnackbar('Valve ${value ? "ON" : "OFF"}');
    } catch (e) {
      _showErrorSnackbar('Gagal mengontrol valve: $e');
    }
  }
  
  void _dispenseFeed() async {
    if (deviceSettings == null) return;
    
    try {
      final success = await FirebaseService.dispenseFeed(
        deviceSettings!.feedWeight,
        deviceSettings!.feedAngle
      );
      
      if (success) {
        _showSuccessSnackbar('Pakan berhasil diberikan!');
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memberikan pakan: $e');
    }
  }
  
  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard IoT'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshSensorData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshSensorData(),
        child: ListView(
          children: [
            // Real-time sensor data dari Firestore
            SectionTitle('Kualitas Air'),
            Row(
              children: [
                _InfoCard(
                  title: 'Tingkat Air', 
                  value: '${sensorData?.waterLevel?.toStringAsFixed(1) ?? "--"}%'
                ),
                _InfoCard(
                  title: 'Suhu Air',
                  value: '${sensorData?.temperature?.toStringAsFixed(1) ?? "--"}°C'  
                ),
              ],
            ),
            Row(
              children: [
                _InfoCard(
                  title: 'pH Air',
                  value: '${sensorData?.phLevel?.toStringAsFixed(1) ?? "--"} pH'
                ),
                _InfoCard(
                  title: 'Kekeruhan Air',
                  value: '${sensorData?.turbidity?.toStringAsFixed(1) ?? "--"} NTU'
                ),
              ],
            ),
            
            SectionTitle('Sistem Power'),
            Row(
              children: [
                _InfoCard(
                  title: 'Tegangan Masuk',
                  value: '${sensorData?.inputVoltage?.toStringAsFixed(1) ?? "--"} V'
                ),
                _InfoCard(
                  title: 'Tegangan Keluar',
                  value: '${sensorData?.outputVoltage?.toStringAsFixed(1) ?? "--"} V'
                ),
              ],
            ),
            
            SectionTitle('Kontrol'),
            // Valve control dengan Firebase real-time
            ListTile(
              title: Text('Kontrol Valve'),
              trailing: Switch(
                value: deviceSettings?.valveStatus ?? false,
                onChanged: _toggleValve,
                activeColor: Color(0xFF648DDB),
              ),
            ),
            
            // Feed control button
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _dispenseFeed,
                child: Text('Berikan Pakan Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF648DDB),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            // Current settings display
            if (deviceSettings != null) ...[
              SectionTitle('Pengaturan Aktif'),
              ListTile(
                title: Text('Berat Pakan'),
                subtitle: Text(deviceSettings!.feedWeight),
              ),
              ListTile(
                title: Text('Sudut Pelontar'),
                subtitle: Text('${deviceSettings!.feedAngle}°'),
              ),
            ],
            
            // Last update timestamp
            if (sensorData?.timestamp != null)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Update terakhir: ${_formatTimestamp(sensorData!.timestamp)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, "0")}';
  }
  
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }
  
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green)
    );
  }
}
```

### **Data Models untuk Firebase:**
```dart
// lib/models/sensor_data.dart
class SensorData {
  final double waterLevel;
  final double temperature;
  final double phLevel;
  final double turbidity;
  final double inputVoltage;
  final double outputVoltage;
  final DateTime timestamp;
  
  SensorData({
    required this.waterLevel,
    required this.temperature,
    required this.phLevel,
    required this.turbidity,
    required this.inputVoltage,
    required this.outputVoltage,
    required this.timestamp,
  });
  
  factory SensorData.fromFirestore(Map<String, dynamic> data) {
    return SensorData(
      waterLevel: (data['waterLevel'] ?? 0).toDouble(),
      temperature: (data['temperature'] ?? 0).toDouble(),
      phLevel: (data['phLevel'] ?? 7.0).toDouble(),
      turbidity: (data['turbidity'] ?? 0).toDouble(),
      inputVoltage: (data['inputVoltage'] ?? 0).toDouble(),
      outputVoltage: (data['outputVoltage'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
  
  factory SensorData.empty() {
    return SensorData(
      waterLevel: 0,
      temperature: 0,
      phLevel: 7.0,
      turbidity: 0,
      inputVoltage: 0,
      outputVoltage: 0,
      timestamp: DateTime.now(),
    );
  }
}

// lib/models/device_settings.dart
class DeviceSettings {
  final String feedWeight;
  final int feedAngle;
  final bool valveStatus;
  final bool autoFeedEnabled;
  final DateTime updatedAt;
  
  DeviceSettings({
    required this.feedWeight,
    required this.feedAngle,
    required this.valveStatus,
    required this.autoFeedEnabled,
    required this.updatedAt,
  });
  
  factory DeviceSettings.fromFirestore(Map<String, dynamic> data) {
    return DeviceSettings(
      feedWeight: data['feedWeight'] ?? '1KG',
      feedAngle: data['feedAngle'] ?? 30,
      valveStatus: data['valveStatus'] ?? false,
      autoFeedEnabled: data['autoFeedEnabled'] ?? false,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  factory DeviceSettings.defaultSettings() {
    return DeviceSettings(
      feedWeight: '1KG',
      feedAngle: 30,
      valveStatus: false,
      autoFeedEnabled: false,
      updatedAt: DateTime.now(),
    );
  }
}
```

---

## 🎯 **KEUNTUNGAN SEPARATION dengan Firebase**

### **1. Scalability & Performance**
- **Firebase Auto-scaling:** Tidak perlu setup server manual
- **Real-time Updates:** Firestore listener lebih efisien dari polling API
- **Global CDN:** Data tersebar di multiple data centers worldwide
- **Offline Support:** App tetap bisa baca data meski offline

### **2. Security & Authentication** 
- **Firebase Auth:** Built-in authentication (email, Google, Facebook)
- **Firestore Rules:** Security rules di database level
- **Cloud Functions:** Server-side validation yang aman
- **No exposed API keys:** Client tidak pegang sensitive keys

### **3. Development Speed**
- **No Backend Setup:** Tidak perlu setup server, database, load balancer
- **Built-in Features:** Authentication, real-time, push notifications ready
- **Cloud Functions:** Deploy backend logic tanpa manage servers
- **Firebase Console:** Monitoring dan analytics built-in

### **4. Real-time IoT Benefits**
- **Instant Updates:** Sensor data langsung sync ke semua devices
- **Push Notifications:** Alert otomatis untuk kondisi abnormal
- **Historical Data:** Query sensor history dengan mudah
- **Multi-device:** Dashboard bisa dibuka di multiple devices bersamaan

### **5. Cost Effective untuk IoT**
- **Pay per Use:** Bayar sesuai data yang digunakan
- **Free Tier:** Cukup untuk prototyping dan testing
- **No Server Maintenance:** Tidak ada biaya maintenance server
- **Built-in Backup:** Data otomatis di-backup Google

---

## 📚 **LANGKAH SELANJUTNYA dengan Firebase**

### **1. Fase 1: Setup Firebase Project**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login ke Firebase
firebase login

# Initialize Firebase project
firebase init

# Pilih features:
# ✅ Firestore
# ✅ Functions  
# ✅ Authentication
# ✅ Hosting (optional)
```

### **2. Fase 2: Setup Firestore & Authentication**
```javascript
// Setup Firestore collections & indexes
// Setup Authentication providers (Email, Google)
// Configure Firestore security rules
// Setup Firebase SDK di Flutter app
```

### **3. Fase 3: Refactor Frontend**
```dart
// Replace hardcoded data dengan Firestore listeners
// Implement Firebase Authentication
// Add Cloud Function calls untuk hardware control
// Setup offline caching dengan Firestore
```

### **4. Fase 4: Implement Cloud Functions**
```javascript
// Buat Cloud Functions untuk:
// - Sensor data collection
// - Hardware control (valve, feeder)
// - Scheduled feeding
// - Alert notifications
// - Data analytics
```

### **5. Fase 5: IoT Hardware Integration**
```javascript
// Setup komunikasi hardware dengan Cloud Functions
// Implement sensor reading automation
// Setup device status monitoring
// Test end-to-end functionality
```

### **6. Fase 6: Advanced Features**
```dart
// Push notifications untuk alerts
// Historical data charts
// Feed scheduling automation
// Multiple device support
// Data export/analytics
```

### **7. Fase 7: Deployment & Monitoring**
```bash
# Deploy Cloud Functions
firebase deploy --only functions

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Build & publish Flutter app
flutter build apk --release

# Setup Firebase Analytics
# Configure Crashlytics untuk error monitoring
```

---

## 💡 **TIPS KHUSUS untuk Firebase IoT Development**

### **1. Firestore Structure Best Practices**
```javascript
// ✅ GOOD - Denormalized structure
users/{userId}/devices/{deviceId}/sensorReadings/{readingId}

// ❌ BAD - Too deep nesting  
users/{userId}/locations/{locationId}/devices/{deviceId}/sensors/{sensorId}/readings/{readingId}
```

### **2. Real-time Optimization**
```dart
// ✅ GOOD - Use limit() untuk real-time queries
FirebaseFirestore.instance
  .collection('sensorReadings')
  .limit(1) // Only get latest reading
  .snapshots()

// ❌ BAD - Listen to all documents
FirebaseFirestore.instance
  .collection('sensorReadings')
  .snapshots() // Expensive for many documents
```

### **3. Cloud Functions Optimization**
```javascript
// ✅ GOOD - Cache hasil sensor reading
let cachedSensorData = null;
let lastUpdate = 0;

exports.getSensorData = functions.https.onCall(async (data, context) => {
  const now = Date.now();
  
  // Cache for 30 seconds
  if (cachedSensorData && (now - lastUpdate) < 30000) {
    return cachedSensorData;
  }
  
  // Read fresh data from hardware
  cachedSensorData = await readSensorHardware();
  lastUpdate = now;
  
  return cachedSensorData;
});
```

### **4. Offline-First Design**
```dart
// Setup Firestore offline persistence
FirebaseFirestore.instance.enablePersistence();

// Use cached data when offline
stream.listen((snapshot) => {
  if (snapshot.metadata.isFromCache) {
    showOfflineIndicator();
  } else {
    hideOfflineIndicator();
  }
});
```

### **5. Security Rules untuk IoT**
```javascript
// Firestore rules untuk IoT security
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only device owner dapat kontrol
    match /deviceSettings/{userId} {
      allow read, write: if request.auth != null && 
                        request.auth.uid == userId &&
                        isValidDeviceCommand();
    }
    
    function isValidDeviceCommand() {
      return request.resource.data.keys().hasAll(['valveStatus']) ||
             request.resource.data.keys().hasAll(['feedWeight', 'feedAngle']);
    }
  }
}
```

### **6. Push Notifications untuk IoT Alerts**
```javascript
// Cloud Function untuk kirim alert
exports.sendAlert = functions.firestore
  .document('sensorReadings/{readingId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    if (data.temperature > 30) {
      await admin.messaging().send({
        token: userFCMToken,
        notification: {
          title: '🚨 Temperature Alert!',
          body: `Water temperature is ${data.temperature}°C`
        },
        data: {
          type: 'temperature_alert',
          value: data.temperature.toString()
        }
      });
    }
  });
```

---

**🔥 Firebase + Flutter + IoT = Powerful Combination!**
*Perfect untuk rapid prototyping dan production IoT applications.*

---

**🎉 Selamat belajar Full-Stack Development!**
*Catatan ini bisa dijadikan referensi saat develop aplikasi IoT.*
