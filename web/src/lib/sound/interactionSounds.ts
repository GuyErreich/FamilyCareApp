let sharedContext: AudioContext | null = null;

function prefersReducedMotion(): boolean {
  return (
    typeof window !== "undefined" &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches
  );
}

function getAudioContext(): AudioContext | null {
  if (typeof window === "undefined") return null;

  if (!sharedContext) {
    try {
      sharedContext = new AudioContext();
    } catch {
      return null;
    }
  }

  if (sharedContext.state === "suspended") {
    void sharedContext.resume().catch(() => {});
  }

  return sharedContext;
}

function playTone(
  frequency: number,
  durationS: number,
  type: OscillatorType = "sine",
  peakGain = 0.07,
): void {
  if (prefersReducedMotion()) return;

  const ctx = getAudioContext();
  if (!ctx) return;

  const oscillator = ctx.createOscillator();
  const gain = ctx.createGain();
  const start = ctx.currentTime;

  oscillator.type = type;
  oscillator.frequency.setValueAtTime(frequency, start);
  gain.gain.setValueAtTime(0.0001, start);
  gain.gain.exponentialRampToValueAtTime(peakGain, start + 0.012);
  gain.gain.exponentialRampToValueAtTime(0.0001, start + durationS);

  oscillator.connect(gain);
  gain.connect(ctx.destination);
  oscillator.start(start);
  oscillator.stop(start + durationS + 0.02);
}

/** Desktop pointer hover — soft high tick. */
export function playHoverSound(): void {
  playTone(920, 0.05, "sine", 0.035);
}

/** Primary tap / click — mid tone. */
export function playClickSound(): void {
  playTone(640, 0.07, "triangle", 0.06);
}

/** Mobile press-and-hold affordance — lower tone. */
export function playLongPressSound(): void {
  playTone(480, 0.11, "sine", 0.055);
}

/** Menu or sheet opened. */
export function playMenuOpenSound(): void {
  playTone(760, 0.08, "triangle", 0.05);
}

/** Menu or sheet closed — any dismiss path. */
export function playMenuCloseSound(): void {
  playTone(540, 0.07, "sine", 0.045);
}
