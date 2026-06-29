import type { CSSProperties } from "react";
import { forwardRef, useCallback, useImperativeHandle, useLayoutEffect, useRef, useState } from "react";
import { motion, useReducedMotion } from "framer-motion";
import { MICRO_TRANSITION } from "../../../lib/motion";

const ITEM_HEIGHT = 44;
const VISIBLE_ROWS = 5;

export interface WheelPickerOption<T extends string | number> {
  value: T;
  label: string;
}

export interface WheelPickerHandle {
  flush: () => string | number;
}

interface WheelPickerProps<T extends string | number> {
  value: T;
  onChange: (value: T) => void;
  options: WheelPickerOption<T>[];
  ariaLabel: string;
}

function findNearestIndex(viewport: HTMLDivElement, itemSelector: string): number {
  const centerY = viewport.scrollTop + viewport.clientHeight / 2;
  const items = viewport.querySelectorAll<HTMLElement>(itemSelector);
  let nearest = 0;
  let minDistance = Number.POSITIVE_INFINITY;

  items.forEach((item, index) => {
    const itemCenter = item.offsetTop + item.offsetHeight / 2;
    const distance = Math.abs(centerY - itemCenter);
    if (distance < minDistance) {
      minDistance = distance;
      nearest = index;
    }
  });

  return nearest;
}

function itemOpacity(distance: number): number {
  if (distance === 0) return 1;
  if (distance === 1) return 0.65;
  return 0.45;
}

function WheelPickerInner<T extends string | number>(
  {
    value,
    onChange,
    options,
    ariaLabel,
  }: WheelPickerProps<T>,
  ref: React.Ref<WheelPickerHandle>,
) {
  const viewportRef = useRef<HTMLDivElement>(null);
  const scrollEndTimer = useRef<number | null>(null);
  const padding = ((VISIBLE_ROWS - 1) / 2) * ITEM_HEIGHT;
  const reduceMotion = useReducedMotion();
  const valueIndex = options.findIndex((option) => option.value === value);
  const [centerIndex, setCenterIndex] = useState(valueIndex >= 0 ? valueIndex : 0);

  const scrollToValue = useCallback(
    (nextValue: T, behavior: ScrollBehavior = "auto") => {
      const viewport = viewportRef.current;
      if (!viewport) return;
      const index = options.findIndex((option) => option.value === nextValue);
      if (index < 0) return;
      const item = viewport.querySelector<HTMLElement>(`[data-wheel-index="${index}"]`);
      item?.scrollIntoView({ block: "center", behavior });
    },
    [options],
  );

  const flush = useCallback((): T => {
    if (scrollEndTimer.current !== null) {
      window.clearTimeout(scrollEndTimer.current);
      scrollEndTimer.current = null;
    }
    const viewport = viewportRef.current;
    if (!viewport) return value;
    const index = findNearestIndex(viewport, "[data-wheel-index]");
    setCenterIndex(index);
    const option = options[index];
    if (!option) return value;
    if (option.value !== value) onChange(option.value);
    scrollToValue(option.value, "auto");
    return option.value;
  }, [onChange, options, scrollToValue, value]);

  useImperativeHandle(ref, () => ({ flush: () => flush() }), [flush]);

  useLayoutEffect(() => {
    scrollToValue(value);
    const viewport = viewportRef.current;
    if (!viewport) return;
    const frame = requestAnimationFrame(() => {
      setCenterIndex(findNearestIndex(viewport, "[data-wheel-index]"));
    });
    return () => cancelAnimationFrame(frame);
  }, [value, scrollToValue]);

  const settleSelection = useCallback(() => {
    flush();
  }, [flush]);

  const onScroll = () => {
    const viewport = viewportRef.current;
    if (viewport) {
      setCenterIndex(findNearestIndex(viewport, "[data-wheel-index]"));
    }
    if (scrollEndTimer.current !== null) window.clearTimeout(scrollEndTimer.current);
    scrollEndTimer.current = window.setTimeout(settleSelection, 100);
  };

  return (
    <div
      className="wheel-picker"
      style={
        {
          "--wheel-item-height": `${ITEM_HEIGHT}px`,
          "--wheel-visible-rows": String(VISIBLE_ROWS),
        } as CSSProperties
      }
    >
      <div className="wheel-picker__chrome" aria-hidden>
        <div className="wheel-picker__selection" />
      </div>
      <div className="wheel-picker__fades" aria-hidden>
        <div className="wheel-picker__fade wheel-picker__fade--top" />
        <div className="wheel-picker__fade wheel-picker__fade--bottom" />
      </div>
      <div
        ref={viewportRef}
        className="wheel-picker__viewport scroll-panel"
        role="listbox"
        aria-label={ariaLabel}
        onScroll={onScroll}
      >
        <div className="wheel-picker__pad" style={{ height: padding }} aria-hidden />
        {options.map((option, index) => {
          const selected = option.value === value;
          const distance = Math.abs(index - centerIndex);
          const centered = index === centerIndex;
          return (
            <motion.button
              key={String(option.value)}
              type="button"
              role="option"
              aria-selected={selected}
              data-wheel-index={index}
              className={[
                "wheel-picker__item",
                centered ? "wheel-picker__item--centered" : "",
                selected ? "wheel-picker__item--selected" : "",
              ]
                .filter(Boolean)
                .join(" ")}
              animate={
                reduceMotion
                  ? { opacity: centered ? 1 : 0.55 }
                  : {
                      opacity: itemOpacity(distance),
                      scale: centered ? 1.04 : 1,
                    }
              }
              transition={MICRO_TRANSITION}
              onClick={() => {
                onChange(option.value);
                scrollToValue(option.value, "smooth");
              }}
            >
              {option.label}
            </motion.button>
          );
        })}
        <div className="wheel-picker__pad" style={{ height: padding }} aria-hidden />
      </div>
    </div>
  );
}

export const WheelPicker = forwardRef(WheelPickerInner) as <T extends string | number>(
  props: WheelPickerProps<T> & { ref?: React.Ref<WheelPickerHandle> },
) => ReturnType<typeof WheelPickerInner>;
