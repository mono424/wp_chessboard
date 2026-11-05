import { describe, expect, it } from "vitest";
import { trackMoveAnimation } from "../src/moveAnimation";

const flush = () => new Promise((r) => setTimeout(r, 0));

function animation() {
  const calls: string[] = [];
  let finish!: () => void;
  let fail!: (e: Error) => void;
  const finished = new Promise<void>((res, rej) => {
    finish = res;
    fail = rej;
  });
  return { calls, finish, fail, anim: { finished, cancel: () => calls.push("cancel") } };
}

describe("trackMoveAnimation", () => {
  it("commits the square before it cancels, once", async () => {
    const a = animation();
    const stop = trackMoveAnimation(a.anim, () => a.calls.push("commit"));
    a.finish();
    await flush();
    expect(a.calls).toEqual(["commit", "cancel"]);
    stop();
    expect(a.calls).toEqual(["commit", "cancel"]);
  });

  it("cancels without committing when the piece unmounts first", async () => {
    const a = animation();
    const stop = trackMoveAnimation(a.anim, () => a.calls.push("commit"));
    stop();
    expect(a.calls).toEqual(["cancel"]);
    a.finish();
    await flush();
    expect(a.calls).toEqual(["cancel"]);
  });

  it("survives finished rejecting, as a cancelled Web Animation does", async () => {
    const a = animation();
    trackMoveAnimation(a.anim, () => a.calls.push("commit"));
    a.fail(new Error("AbortError"));
    await flush();
    expect(a.calls).toEqual([]);
  });
});
