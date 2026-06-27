const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.onShiftWrite = onDocumentWritten('shifts/{shiftId}', async (event) => {
  const before = event.data.before?.data();
  const after = event.data.after?.data();

  if (!after) {
    return notifyFamily(before, 'Shift cancelled', 'A companion shift was cancelled.');
  }

  if (!before) {
    return notifyFamily(after, 'New shift', 'A new companion shift was created.');
  }

  if (before.assignedUserId !== after.assignedUserId) {
    return notifyFamily(after, 'Companion changed', 'A shift companion was updated.');
  }

  return notifyFamily(after, 'Shift updated', 'A companion shift was updated.');
});

async function notifyFamily(shift, title, body) {
  if (!shift?.familyId) return;

  const db = getFirestore();
  const users = await db
    .collection('users')
    .where('familyId', '==', shift.familyId)
    .get();

  const tokens = users.docs.flatMap((doc) => doc.data().fcmTokens || []);
  if (tokens.length === 0) return;

  await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: {
      shiftId: shift.id || '',
      familyId: shift.familyId,
    },
  });
}
