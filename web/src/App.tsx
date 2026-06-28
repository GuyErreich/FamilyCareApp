import { Navigate, Route, Routes } from "react-router-dom";
import { AppShell } from "./components/ui/common/AppShell";
import { LoadingState } from "./components/ui/common/AsyncStates";
import { ROUTES } from "./lib/constants";
import { useAuth } from "./hooks/auth/useAuth";
import { ThemePaletteProvider } from "./hooks/useThemePalette";
import { CalendarPage } from "./pages/CalendarPage";
import { DashboardPage } from "./pages/DashboardPage";
import { FamilyPage } from "./pages/FamilyPage";
import { LoginPage } from "./pages/LoginPage";
import { OnboardingPage } from "./pages/OnboardingPage";
import { RegisterPage } from "./pages/RegisterPage";
import { SettingsPage } from "./pages/SettingsPage";
import { ShiftEditPage } from "./pages/ShiftEditPage";
import { ShiftFormPage } from "./pages/ShiftFormPage";

function ProtectedRoute() {
  const { user, profile, loading } = useAuth();

  if (loading) return <LoadingState />;
  if (!user) return <Navigate to={ROUTES.login} replace />;
  if (!profile?.family_id) return <Navigate to={ROUTES.onboarding} replace />;

  return <AppShell />;
}

function AuthRoute({ children }: { children: React.ReactNode }) {
  const { user, profile, loading } = useAuth();
  if (loading) return <LoadingState />;
  if (user && profile?.family_id) return <Navigate to={ROUTES.dashboard} replace />;
  return children;
}

export default function App() {
  return (
    <ThemePaletteProvider>
      <Routes>
        <Route
          path={ROUTES.login}
          element={
            <AuthRoute>
              <LoginPage />
            </AuthRoute>
          }
        />
        <Route
          path={ROUTES.register}
          element={
            <AuthRoute>
              <RegisterPage />
            </AuthRoute>
          }
        />
        <Route path={ROUTES.onboarding} element={<OnboardingPage />} />
        <Route element={<ProtectedRoute />}>
          <Route path={ROUTES.dashboard} element={<DashboardPage />} />
          <Route path={ROUTES.calendar} element={<CalendarPage />} />
          <Route path={ROUTES.family} element={<FamilyPage />} />
          <Route path={ROUTES.settings} element={<SettingsPage />} />
          <Route path={ROUTES.shiftNew} element={<ShiftFormPage />} />
          <Route path="/shifts/:id" element={<ShiftEditPage />} />
        </Route>
        <Route path="*" element={<Navigate to={ROUTES.dashboard} replace />} />
      </Routes>
    </ThemePaletteProvider>
  );
}
