# PerfMon

![PerfMon interface](https://i.imgur.com/tXJ5oqx.png)

PerfMon is a lightweight watchdog addon that records frame-time gaps in the Lua UI layer and helps correlate performance spikes with UI events, function calls, and errors.

[Download PerfMon 41](https://mega.nz/file/N3wm1R5D#PtDfj89aBexS55BQkS3q9JiZk_NixCv9IwdcJkz6Isg)

## How it works

PerfMon measures **elapsed time**: the gap, in milliseconds, between two successive `OnUpdate` callbacks. A large gap means the client spent more time between frames.

To keep logs compact without losing spikes, samples below 200 ms are written once per second instead of on every tick. Logs are saved to `/Interface/logs/` and named with the recording start time, for example:

```text
perfmon_2025_11_03_175617_elapsed.log
```

## Usage

| Command        | Action                                                                                              |
| -------------- | --------------------------------------------------------------------------------------------------- |
| `/perfmon on`  | Starts recording elapsed-time samples, enables DebugWindow filters, and starts core-module logging. |
| `/perfmon off` | Stops recording, disables DebugWindow filters, and stops core-module logging.                       |

## Log analysis

The addon includes `PerfMon.html`, a browser-based log analyzer. Open it in any modern browser and provide both files from the same recording session:

- The PerfMon elapsed-time log, such as `perfmon_2025_11_03_175617_elapsed.log`
- The matching `uilog.log`, containing events, function calls, and errors

### Data point analysis

Select a point on the top graph to inspect the functions and events recorded during that second. In-game log timestamps have one-second precision.

### Differential analysis

Compare two time ranges to find log lines that appear only during the slower interval. This is useful for investigating intermittent freezes.

### Correlation analysis

Set a lower threshold and, optionally, an upper threshold to find messages shared by every spike in that range. This can help establish whether a particular addon is active during most heavy frames.

Known low-impact functions can be added to the ignore list to reduce noise. Several are already excluded in the source.

## Scope and limitations

PerfMon is a coarse sampler—not a full profiler or benchmarking suite. It runs in the Lua UI layer and uses publicly available data, so it cannot measure GPU time, draw calls, I/O waits, or other engine-level activity.

Its output is best treated as evidence for exploratory troubleshooting: it can identify addons associated with stuttering, but it does not prove causation on its own.

PerfMon is also I/O-intensive. On a slow HDD, log writes may affect the performance being measured. Moving the log directory to a RAM disk can reduce this interference; see the [RAM-disk setup guide](https://www.returnofreckoning.com/forum/viewtopic.php?p=586739#p586739).

## Dependencies

PerfMon requires `EA_UiDebugTools`, an updated core module included in the download archive.
