const CONNECT_INTENT_KEY = "family-care:calendar-connect-intent";
const ACCESS_TOKEN_PREFIX = "family-care:google-calendar-access-token:";

function accessTokenKey(userId: string): string {
  return `${ACCESS_TOKEN_PREFIX}${userId}`;
}

/** Set before redirecting to Google OAuth for calendar scope. */
export function setCalendarConnectIntent(): void {
  sessionStorage.setItem(CONNECT_INTENT_KEY, "1");
}

export function clearCalendarConnectIntent(): void {
  sessionStorage.removeItem(CONNECT_INTENT_KEY);
}

export function hasCalendarConnectIntent(): boolean {
  return sessionStorage.getItem(CONNECT_INTENT_KEY) === "1";
}

export function persistCalendarAccessToken(userId: string, token: string): void {
  localStorage.setItem(accessTokenKey(userId), token);
}

export function getPersistedCalendarAccessToken(userId: string): string | null {
  return localStorage.getItem(accessTokenKey(userId));
}

export function clearPersistedCalendarTokens(userId: string): void {
  localStorage.removeItem(accessTokenKey(userId));
  clearCalendarConnectIntent();
}
