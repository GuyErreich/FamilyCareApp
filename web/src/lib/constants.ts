export const APP_NAME = "Family Care Scheduler";

export const DEFAULT_REMINDER_OFFSETS_MINUTES = [24 * 60, 60, 15];

export const SCHEDULE = {
  dayStartHour: 6,
  snapMinutes: 15,
  heightPerMinute: 1.05,
  defaultDurationMinutes: 120,
  defaultDaysShowed: 3,
} as const;

export const ROUTES = {
  login: "/login",
  register: "/register",
  onboarding: "/onboarding",
  dashboard: "/",
  calendar: "/calendar",
  family: "/family",
  settings: "/settings",
  shiftNew: "/shifts/new",
  shiftEdit: (id: string) => `/shifts/${id}`,
} as const;

export const GOOGLE_CALENDAR_SCOPE =
  "https://www.googleapis.com/auth/calendar";
