const admin = require('firebase-admin');
const fs = require('fs');

// Initialize the app with a service account, granting admin privileges
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function exportData() {
  const allData = {};
  
  const collections = await db.listCollections();
  for (const collection of collections) {
    const snapshot = await collection.get();
    allData[collection.id] = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  }

  fs.writeFileSync('firestoreData.json', JSON.stringify(allData, null, 2));
  console.log('Data has been exported to firestoreData.json');
}

exportData().catch(console.error);
