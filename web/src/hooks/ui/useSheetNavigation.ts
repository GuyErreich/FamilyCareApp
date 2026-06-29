import { useNavigate } from "react-router-dom";
import { beginSheetNav } from "../../lib/navTransition";
import { playMenuCloseSound, playMenuOpenSound } from "../../lib/sound/interactionSounds";

export function useSheetNavigation() {
  const navigate = useNavigate();

  return {
    openSheet(to: string) {
      beginSheetNav("up");
      playMenuOpenSound();
      navigate(to);
    },
    closeSheet() {
      beginSheetNav("down");
      playMenuCloseSound();
      navigate(-1);
    },
    closeSheetTo(to: string) {
      beginSheetNav("down");
      playMenuCloseSound();
      navigate(to);
    },
  };
}
