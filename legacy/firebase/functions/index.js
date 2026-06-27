const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.onShiftWrite = onDocumentWritten('shifts/{shiftId}', async (event) => {
  const shiftId = event.params.shiftId;
  const before = event.data.before?.data();
  const after = event.data.after?.data();

  if (!after) {
    const shift = { ...before, id: shiftId };
    return notifyShiftOpened(shift);
  }

  if (!before) {
    return notifyFamily(
      { ...after, id: shiftId },
      'New shift',
      'A new companion shift was created.',
      'shiftCreated',
    );
  }

  if (before.assignedUserId !== after.assignedUserId) {
    return notifyFamily(
      { ...after, id: shiftId },
      'Companion changed',
      'A shift companion was updated.',
      'companionChanged',
    );
  }

  return notifyFamily(
    { ...after, id: shiftId },
    'Shift updated',
    'A companion shift was updated.',
    'shiftUpdated',
  );
});

async function notifyShiftOpened(shift) {
  if (!shift?.familyId) return;

  const db = getFirestore();
  const settingsDoc = await db.collection('settings').doc(shift.familyId).get();
  const chain = settingsDoc.data()?.coverageFallbackUserIds || [];
  const companionName = await resolveCompanionName(db, shift);
  const when = formatShiftWhen(shift);
  const droppedId = shift.assignedUserId;
  const plan = resolveFallbackPlan(chain, droppedId);

  if (!plan.primaryUserId && plan.backupUserIds.length === 0) {
    const title = 'Shift needs coverage';
    const body = `${companionName} can't make their shift on ${when}. Can you take it?`;
    return notifyFamily(shift, title, body, 'shiftCancelled', {
      excludeUserId: droppedId,
    });
  }

  const recipients = [
    plan.primaryUserId,
    ...plan.backupUserIds,
  ].filter(Boolean);

  const userIds = await resolveRecipientUserIds(db, shift.familyId, recipients);

  await Promise.all(
    userIds.map(async ({ authUserId, assignableId }) => {
      const isPrimary = assignableId === plan.primaryUserId;
      const title = isPrimary
        ? "You're up next for coverage"
        : 'Backup coverage needed';
      const body = isPrimary
        ? `${companionName} can't make their shift on ${when}. You're first on the fallback plan — can you cover?`
        : `${companionName} can't make their shift on ${when}. You're on the family backup list.`;
      return notifyUser(shift, authUserId, title, body, 'shiftNeedsCoverage');
    }),
  );
}

function resolveFallbackPlan(chain, droppedId) {
  const withoutDropped = chain.filter((id) => id !== droppedId);
  if (withoutDropped.length === 0) {
    return { primaryUserId: null, backupUserIds: [] };
  }

  const dropIndex = chain.indexOf(droppedId);
  if (dropIndex === -1) {
    return {
      primaryUserId: withoutDropped[0],
      backupUserIds: withoutDropped.slice(1),
    };
  }

  const afterDrop = chain.slice(dropIndex + 1).filter((id) => id !== droppedId);
  if (afterDrop.length > 0) {
    return {
      primaryUserId: afterDrop[0],
      backupUserIds: afterDrop.slice(1),
    };
  }

  const beforeDrop = chain.slice(0, dropIndex).filter((id) => id !== droppedId);
  if (beforeDrop.length === 0) {
    return { primaryUserId: null, backupUserIds: [] };
  }

  return {
    primaryUserId: beforeDrop[0],
    backupUserIds: beforeDrop.slice(1),
  };
}

async function resolveRecipientUserIds(db, familyId, assignableIds) {
  const members = await db
    .collection('familyMembers')
    .where('familyId', '==', familyId)
    .get();

  const byAssignable = new Map();
  for (const doc of members.docs) {
    const data = doc.data();
    const assignableId = data.userId || doc.id;
    byAssignable.set(assignableId, data.userId || null);
  }

  const resolved = [];
  for (const assignableId of assignableIds) {
    const userId = byAssignable.get(assignableId);
    if (userId) {
      resolved.push({ authUserId: userId, assignableId });
      continue;
    }
    const userDoc = await db.collection('users').doc(assignableId).get();
    if (userDoc.exists) {
      resolved.push({ authUserId: assignableId, assignableId });
    }
  }
  return resolved;
}

async function notifyUser(shift, userId, title, body, type) {
  const db = getFirestore();
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists) return;

  await db.collection('notifications').add({
    familyId: shift.familyId,
    userId,
    type,
    shiftId: shift.id || '',
    title,
    body,
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  const tokens = userDoc.data().fcmTokens || [];
  if (tokens.length === 0) return;

  await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: {
      type,
      shiftId: shift.id || '',
      familyId: shift.familyId,
    },
  });
}

async function notifyFamily(shift, title, body, type, options = {}) {
  if (!shift?.familyId) return;

  const db = getFirestore();
  const users = await db
    .collection('users')
    .where('familyId', '==', shift.familyId)
    .get();

  const tokens = [];
  const notifyUsers = [];

  for (const doc of users.docs) {
    if (options.excludeUserId && doc.id === options.excludeUserId) continue;
    notifyUsers.push(doc);
    tokens.push(...(doc.data().fcmTokens || []));
  }

  await Promise.all(
    notifyUsers.map((doc) =>
      db.collection('notifications').add({
        familyId: shift.familyId,
        userId: doc.id,
        type,
        shiftId: shift.id || '',
        title,
        body,
        read: false,
        createdAt: FieldValue.serverTimestamp(),
      }),
    ),
  );

  if (tokens.length === 0) return;

  await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: {
      type,
      shiftId: shift.id || '',
      familyId: shift.familyId,
    },
  });
}

async function resolveCompanionName(db, shift) {
  const members = await db
    .collection('familyMembers')
    .where('familyId', '==', shift.familyId)
    .get();

  for (const doc of members.docs) {
    const data = doc.data();
    if (data.userId === shift.assignedUserId || doc.id === shift.assignedUserId) {
      return data.name || 'A companion';
    }
  }

  const user = await db.collection('users').doc(shift.assignedUserId).get();
  if (user.exists) {
    return user.data().displayName || user.data().email || 'A companion';
  }

  return 'A companion';
}

function formatShiftWhen(shift) {
  const date = shift.date?.toDate?.() ?? new Date(shift.date);
  const hour = shift.startHour ?? 0;
  const minute = shift.startMinute ?? 0;
  const duration = shift.durationMinutes ?? 60;

  const start = new Date(date);
  start.setHours(hour, minute, 0, 0);
  const end = new Date(start.getTime() + duration * 60 * 1000);

  const dateLabel = start.toLocaleDateString('en-US', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
  });
  const timeLabel = `${formatTime(start)}–${formatTime(end)}`;
  return `${dateLabel} ${timeLabel}`;
}

function formatTime(date) {
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
  });
}
