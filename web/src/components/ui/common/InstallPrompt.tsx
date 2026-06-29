import { useEffect, useState } from "react";
import { Download, X } from "lucide-react";
import { Card } from "./Card";
import { Button } from "./Button";
import { IconButton } from "./IconButton";

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
    ("standalone" in navigator &&
      (navigator as Navigator & { standalone?: boolean }).standalone === true)
  );
}

export function useInstallPrompt() {
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

  const visible = !dismissed && !isStandalone();

  return { visible, deferredPrompt, dismiss, install };
}

export type InstallPromptState = ReturnType<typeof useInstallPrompt>;

interface InstallPromptCardProps {
  deferredPrompt: BeforeInstallPromptEvent | null;
  onDismiss: () => void;
  onInstall: () => void;
}

export function InstallPromptCard({
  deferredPrompt,
  onDismiss,
  onInstall,
}: InstallPromptCardProps) {
  return (
    <Card className="install-prompt" variant="accent">
      <div className="install-prompt__header">
        <span className="install-prompt__icon">
          <Download size={22} aria-hidden />
        </span>
        <strong>Install the app</strong>
        <IconButton icon={X} label="Dismiss install prompt" variant="ghost" onClick={onDismiss} />
      </div>
      {isIos() || !deferredPrompt ? (
        <p className="muted">
          On iPhone: open in Safari, tap Share, then Add to Home Screen. Push notifications work
          from the home screen icon (iOS 16.4+).
        </p>
      ) : (
        <p className="muted">
          Install for quick access and shift alerts on your lock screen.
        </p>
      )}
      {deferredPrompt ? (
        <Button icon={Download} onClick={onInstall}>
          Install
        </Button>
      ) : null}
    </Card>
  );
}

/** @deprecated Use InstallPromptOverlay in AppShell */
export function InstallPrompt() {
  const prompt = useInstallPrompt();
  if (!prompt.visible) return null;
  return (
    <InstallPromptCard
      deferredPrompt={prompt.deferredPrompt}
      onDismiss={prompt.dismiss}
      onInstall={() => void prompt.install()}
    />
  );
}
