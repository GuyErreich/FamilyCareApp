import { useEffect, useState } from "react";
import { Card } from "./Card";
import { PrimaryButton } from "./PrimaryButton";

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

function isIos(): boolean {
  return /iphone|ipad|ipod/i.test(navigator.userAgent);
}

function isStandalone(): boolean {
  return (
    window.matchMedia("(display-mode: standalone)").matches ||
    ("standalone" in navigator && (navigator as Navigator & { standalone?: boolean }).standalone === true)
  );
}

export function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] =
    useState<BeforeInstallPromptEvent | null>(null);
  const [dismissed, setDismissed] = useState(
    () => localStorage.getItem("pwa-install-dismissed") === "1",
  );

  useEffect(() => {
    const handler = (event: Event) => {
      event.preventDefault();
      setDeferredPrompt(event as BeforeInstallPromptEvent);
    };
    window.addEventListener("beforeinstallprompt", handler);
    return () => window.removeEventListener("beforeinstallprompt", handler);
  }, []);

  if (dismissed || isStandalone()) return null;

  const dismiss = () => {
    localStorage.setItem("pwa-install-dismissed", "1");
    setDismissed(true);
  };

  const install = async () => {
    if (!deferredPrompt) return;
    await deferredPrompt.prompt();
    await deferredPrompt.userChoice;
    setDeferredPrompt(null);
    dismiss();
  };

  return (
    <Card className="install-prompt">
      <strong>Install the app</strong>
      {isIos() || !deferredPrompt ? (
        <p className="muted">
          On iPhone: open in Safari, tap Share, then Add to Home Screen. Push
          notifications work from the home screen icon (iOS 16.4+).
        </p>
      ) : (
        <p className="muted">
          Install for quick access and shift alerts on your lock screen.
        </p>
      )}
      <div className="stack" style={{ flexDirection: "row", gap: 8 }}>
        {deferredPrompt ? (
          <PrimaryButton onClick={() => void install()}>Install</PrimaryButton>
        ) : null}
        <PrimaryButton variant="secondary" onClick={dismiss}>
          Not now
        </PrimaryButton>
      </div>
    </Card>
  );
}
