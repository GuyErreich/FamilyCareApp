import { useEffect, useRef, useState, type PointerEvent as ReactPointerEvent } from "react";

const LONG_PRESS_MS = 450;
const DRAG_THRESHOLD_PX = 8;

export type GestureOutcome = "tap" | "long-press" | "drag-start" | "drag-move" | "drag-end";

interface UsePlannerPointerGestureOptions {
  onTap: () => void;
  onLongPress: () => void;
  onDragStart: () => void;
  onDragMove: (deltaY: number) => void;
  onDragEnd: () => void;
  disabled?: boolean;
}

export function usePlannerPointerGesture({
  onTap,
  onLongPress,
  onDragStart,
  onDragMove,
  onDragEnd,
  disabled = false,
}: UsePlannerPointerGestureOptions) {
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const originRef = useRef({ x: 0, y: 0 });
  const draggingRef = useRef(false);
  const longPressFiredRef = useRef(false);
  const [isDragging, setIsDragging] = useState(false);

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

  const onPointerDown = (e: ReactPointerEvent) => {
    if (disabled || e.button !== 0) return;
    e.currentTarget.setPointerCapture(e.pointerId);
    originRef.current = { x: e.clientX, y: e.clientY };
    draggingRef.current = false;
    longPressFiredRef.current = false;

    clearTimer();
    timerRef.current = setTimeout(() => {
      if (!draggingRef.current) {
        longPressFiredRef.current = true;
        navigator.vibrate?.(12);
        onLongPress();
      }
    }, LONG_PRESS_MS);
  };

  const onPointerMove = (e: ReactPointerEvent) => {
    if (disabled) return;
    const dy = e.clientY - originRef.current.y;
    const dx = e.clientX - originRef.current.x;
    const dist = Math.hypot(dx, dy);

    if (!draggingRef.current && dist > DRAG_THRESHOLD_PX) {
      clearTimer();
      draggingRef.current = true;
      setIsDragging(true);
      onDragStart();
    }

    if (draggingRef.current) {
      e.preventDefault();
      onDragMove(dy);
    }
  };

  const onPointerUp = (e: ReactPointerEvent) => {
    if (disabled) return;
    clearTimer();

    if (draggingRef.current) {
      draggingRef.current = false;
      setIsDragging(false);
      onDragEnd();
    } else if (!longPressFiredRef.current) {
      const dy = Math.abs(e.clientY - originRef.current.y);
      const dx = Math.abs(e.clientX - originRef.current.x);
      if (dy < DRAG_THRESHOLD_PX && dx < DRAG_THRESHOLD_PX) {
        onTap();
      }
    }

    longPressFiredRef.current = false;
    try {
      e.currentTarget.releasePointerCapture(e.pointerId);
    } catch {
      /* already released */
    }
  };

  const onPointerCancel = () => {
    clearTimer();
    if (draggingRef.current) {
      draggingRef.current = false;
      setIsDragging(false);
      onDragEnd();
    }
    longPressFiredRef.current = false;
  };

  return {
    isDragging,
    handlers: {
      onPointerDown,
      onPointerMove,
      onPointerUp,
      onPointerCancel,
    },
  };
}
