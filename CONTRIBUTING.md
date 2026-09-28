# Contributing

Thanks for taking a look at double-arrow. It's a small personal utility,
so this is meant to be a quick guide, not a formal process.

## Building

```
swiftc Sources/*.swift -o bin/double-arrow
```

or, to build, sign, and install it as a running LaunchAgent in one step,
use the same script described in the README:

```
Scripts/setup.sh
```

## Testing a change

There's no automated test suite right now. To verify a change:

1. Edit the relevant file in `Sources/`.
2. Run `Scripts/setup.sh` to rebuild, re-sign, and reinstall the agent.
3. Double-tap (and triple-tap, if your change touches that) the modifier
   keys on a real keyboard and confirm the arrow key you expect actually
   fires, and that a single press or a held modifier is left alone.
4. If you're touching `DoubleTapDetector.swift`'s timing, try both a fast
   double-tap and a deliberately slow one to make sure the window still
   feels right.

Check `.github/workflows` for CI before you push; if a workflow exists,
run whatever it runs (tests, lint, etc.) locally first. As of this
writing there isn't one, so manual testing is the whole bar.

Mention what you tested manually in your pull request description.

## Code style

The codebase is intentionally small and dependency-free, and new code
should follow the same shape:

- One class (or enum) per file in `Sources/`, each with a single, clearly
  stated responsibility, e.g. `DoubleTapDetector` only tracks tap timing,
  `KeyTapListener` only owns the event tap, `DoubleArrowRemapper` only
  decides what to swallow and what to send.
- Plain CoreGraphics/Foundation APIs only, no added abstractions,
  frameworks, or third-party packages. If a change needs a dependency,
  it's probably the wrong approach for this project.
- Short doc comments (`///`) on types and non-obvious methods explaining
  *why*, not a restatement of the code.
- Keep it readable over clever. This is a project you should be able to
  read top to bottom in a few minutes.

## Proposing a change

- Fork the repo (or push a branch, if you have access) and open a pull
  request against `main`.
- Keep PRs focused on one thing. Small, reviewable diffs over sweeping
  rewrites.
- Describe what you tested manually, since there's no CI test suite to
  point to.
- If you're changing the key mapping or timing defaults, call that out
  explicitly since it changes behavior for everyone who installs it.

No CLA, no formal review board, just a straightforward look at the diff.
Questions or half-formed ideas are welcome as issues too.
