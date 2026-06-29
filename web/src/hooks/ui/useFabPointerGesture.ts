import { useEffect, useRef, useState, type PointerEvent as ReactPointerEvent } from "react";
import { playLongPressSound } from "../../lib/sound/interactionSounds";

const LONG_PRESS_MS = 450;
const DRAG_THRESHOLD_PX = 6;
const MAX_DRAG_PX = 24;

interface UseFabPointerGestureOptions {
  onTap: () => void;
  disabled?: boolean;
}

export function useFabPointerGesture({ onTap, disabled = false }: UseFabPointerGestureOptions) {
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const originRef = useRef({ x: 0, y: 0 });
  const longPressFiredRef = useRef(false);
  const draggingRef = useRef(false);
  const [holdActive, setHoldActive] = useState(false);
  const [dragOffset, setDragOffset] = useState({ x: 0, y: 0 });

  useEffect(() => {
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, []);

  const clearTimer = () => {
    if (timerRef.current) {
      clearTimeout(timerRef.current);
      timerRef.current = null;
    }
  };

  const resetGesture = () => {
    clearTimer();
    draggingRef.current = false;
    longPressFiredRef.current = false;
    setHoldActive(false);
    setDragOffset({ x: 0, y: 0 });
  };

  const clampDrag = (dx: number, dy: number) => ({
    x: Math.max(-MAX_DRAG_PX, Math.min(MAX_DRAG_PX, dx)),
    y: Math.max(-MAX_DRAG_PX, Math.min(MAX_DRAG_PX, dy)),
  });

  const onPointerDown = (event: ReactPointerEvent<HTMLButtonElement>) => {
    if (disabled || event.button !== 0) return;

    event.currentTarget.setPointerCapture(event.pointerId);
    originRef.current = { x: event.clientX, y: event.clientY };
    longPressFiredRef.current = false;
    draggingRef.current = false;
    setHoldActive(false);
    setDragOffset({ x: 0, y: 0 });

    clearTimer();
    timerRef.current = setTimeout(() => {
      if (draggingRef.current) return;
      longPressFiredRef.current = true;
      setHoldActive(true);
      playLongPressSound();
      navigator.vibrate?.(12);
    }, LONG_PRESS_MS);
  };

  const onPointerMove = (event: ReactPointerEvent<HTMLButtonElement>) => {
    if (disabled) return;

    const dx = event.clientX - originRef.current.x;
    const dy = event.clientY - originRef.current.y;
    const distance = Math.hypot(dx, dy);

    if (!draggingRef.current && distance > DRAG_THRESHOLD_PX) {
      clearTimer();
      draggingRef.current = true;
      if (!longPressFiredRef.current) {
        setHoldActive(true);
      }
    }

    if (draggingRef.current || longPressFiredRef.current) {
      event.preventDefault();
      setDragOffset(clampDrag(dx, dy));
    }
  };

  const onPointerUp = (event: ReactPointerEvent<HTMLButtonElement>) => {
    if (disabled) return;

    clearTimer();

    if (!draggingRef.current && !longPressFiredRef.current) {
      const dx = Math.abs(event.clientX - originRef.current.x);
      const dy = Math.abs(event.clientY - originRef.current.y);
      if (dx < DRAG_THRESHOLD_PX && dy < DRAG_THRESHOLD_PX) {
        onTap();
      }
    }

    resetGesture();

    try {
      event.currentTarget.releasePointerCapture(event.pointerId);
    } catch {
      /* already released */
    }
  };

  const onPointerCancel = () => {
    resetGesture();
  };

  return {
    holdActive,
    dragOffset,
    handlers: {
      onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel,
    },
  };
}
