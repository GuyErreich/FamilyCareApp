import { useCallback, useEffect, useRef, type ReactNode } from "react";
import { Drawer } from "vaul";
import { useShellOverlayHost } from "../../../context/shellOverlayContext";
import { playMenuCloseSound, playMenuOpenSound } from "../../../lib/sound/interactionSounds";
import { SheetDismissContext, type DismissMode } from "./sheetDismissContext";

const PRESS_FEEDBACK_MS = 160;

interface BottomSheetProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: ReactNode;
  actions?: ReactNode;
}

export function BottomSheet({ open, onClose, title, children, actions }: BottomSheetProps) {
  const wasOpenRef = useRef(open);
  const container = useShellOverlayHost();

  useEffect(() => {
    if (open && !wasOpenRef.current) {
      playMenuOpenSound();
    }
    if (!open && wasOpenRef.current) {
      playMenuCloseSound();
    }
    wasOpenRef.current = open;
  }, [open]);

  const dismiss = useCallback(
    (mode: DismissMode = "immediate") => {
      const close = () => onClose();
      if (mode === "press") {
        window.setTimeout(close, PRESS_FEEDBACK_MS);
        return;
      }
      close();
    },
    [onClose],
  );

  const onOpenChange = (nextOpen: boolean) => {
    if (!nextOpen) onClose();
  };

  return (
    <Drawer.Root
      open={open}
      onOpenChange={onOpenChange}
      shouldScaleBackground={false}
      repositionInputs={false}
      container={container}
    >
      <Drawer.Portal>
        <Drawer.Overlay className="bottom-sheet-backdrop" />
        <Drawer.Content className="bottom-sheet" aria-describedby={undefined}>
          <SheetDismissContext.Provider value={dismiss}>
            <div className="bottom-sheet__handle" aria-hidden />
            {title ? (
              <Drawer.Title id="bottom-sheet-title" className="bottom-sheet__title">
                {title}
              </Drawer.Title>
            ) : null}
            <div className="bottom-sheet__body">{children}</div>
            {actions ? <div className="bottom-sheet__actions">{actions}</div> : null}
          </SheetDismissContext.Provider>
        </Drawer.Content>
      </Drawer.Portal>
    </Drawer.Root>
  );
}
