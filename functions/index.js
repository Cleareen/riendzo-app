const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.database();

exports.deleteOldStories = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  const cutoff = Date.now() - 24 * 60 * 60 * 1000; // Timestamp for 24 hours ago

  const storiesRef = db.ref('stories');
  const oldStoriesQuery = storiesRef.orderByChild('timestamp').endAt(cutoff); // Query for stories older than 24 hours

  try {
    const snapshot = await oldStoriesQuery.once('value');
    const updates = {};

    snapshot.forEach((childSnapshot) => {
      updates[childSnapshot.key] = null; // Mark the story for deletion
    });

    await storiesRef.update(updates); // Perform the deletion in bulk
    console.log('Old stories deleted successfully');
  } catch (error) {
    console.error('Error deleting old stories:', error);
  }

  return null;
});
