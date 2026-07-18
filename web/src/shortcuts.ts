import { createSignal } from "solid-js";
import type { ShortcutOptions } from "./types";

export interface ShortcutSelection {
  file: number | null;
  rank: number | null;
}

const EMPTY: ShortcutSelection = { file: null, rank: null };

/**
 * Keyboard square selection: a-h picks a file, 1-8 picks a rank, space
 * commits (or the rank digit commits directly with commitMode "auto").
 */
export function createShortcuts(
  options: () => (ShortcutOptions & { enabled: boolean }),
  commit: (index: number) => void,
) {
  const [selection, setSelection] = createSignal<ShortcutSelection>(EMPTY);
  const clear = () => setSelection(EMPTY);

  const onKeyDown = (e: KeyboardEvent) => {
    const opts = options();
    if (!opts.enabled || e.metaKey || e.ctrlKey || e.altKey) return;
    const key = e.key.toLowerCase();

    if (key.length === 1 && key >= "a" && key <= "h") {
      setSelection({ file: key.charCodeAt(0) - 97, rank: null });
      e.preventDefault();
      return;
    }

    if (key.length === 1 && key >= "1" && key <= "8") {
      const sel = selection();
      if (sel.file === null) return;
      const rank = key.charCodeAt(0) - 49;
      if (opts.commitMode === "auto") {
        commit(rank * 8 + sel.file);
        clear();
      } else {
        setSelection({ file: sel.file, rank });
      }
      e.preventDefault();
      return;
    }

    if (key === " ") {
      const sel = selection();
      if (sel.file !== null && sel.rank !== null) {
        commit(sel.rank * 8 + sel.file);
        clear();
        e.preventDefault();
      }
      return;
    }

    if (key === "escape") clear();
  };

  return { selection, clear, onKeyDown };
}
