# PerfMon

![PerfMon interface](https://i.imgur.com/rLzLp6c.png)

PerfMon is a lightweight watchdog addon that records frame-time gaps in the Lua UI layer and helps correlate performance spikes with UI events, function calls, and errors.

It is designed for _Warhammer Online: Age of Reckoning_, whose interface and community addons run through a Lua-based UI system. PerfMon helps players and addon authors investigate stutters that may originate in that interface while playing on the Return of Reckoning server.

## How it works

PerfMon measures **elapsed time**: the gap, in milliseconds, between two successive `OnUpdate` callbacks. A large gap means the client spent more time between frames.

To keep logs compact without losing spikes, samples below 200 ms are written once per second instead of on every tick. Logs are saved to `/Interface/logs/` and named with the recording start time, for example:

```text
perfmon_2025_11_03_175617_elapsed.log
```

While recording, PerfMon advances a session-relative monotonic clock on every `OnUpdate` and writes `[t=...]` markers to elapsed samples, UI-log events, function calls, errors, and breakpoints. `PerfMon.html` uses those markers to project both logs onto a shared sub-second timeline, and its precision badge shows when monotonic timing has been detected.

This precision is frame-level: entries emitted during the same frame share a timestamp. Older logs and individual entries without monotonic markers remain supported using the game's one-second wall-clock timestamps.

## Usage

| Command                                | Action                                                                                              |
| -------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `/perfmon start`                       | Starts recording elapsed-time samples, enables DebugWindow filters, and starts core-module logging. |
| `/perfmon stop`                        | Stops recording, disables DebugWindow filters, and stops core-module logging.                       |
| `/perfmon breakpoint`                  | Adds a labelled marker to the current recording.                                                    |

## Log analysis

The addon includes `PerfMon.html`, a browser-based log analyzer. Open it in any modern browser and drag in both files from the same recording session:

- The PerfMon elapsed-time log, such as `perfmon_2025_11_03_175617_elapsed.log`
- The matching `uilog.log`, containing events, function calls, and errors

### Timeline and event overlays

Set the spike threshold to highlight slow samples. The UI log is grouped into events, function calls, and errors; search or filter the list, then select an entry to overlay every occurrence on the timeline. Breakpoints appear as labelled markers.

### Spike analysis

Select a sample above the threshold to inspect what fired around that spike. The analyzer also ranks suspicious entries by how concentrated they are inside spike windows compared with the rest of the recording.

### Burst analysis

The optional burst histogram shows UI-log activity across the visible timeline. Select a bar to inspect the events inside that time bucket; zooming adjusts the bucket size automatically.

## Scope and limitations

PerfMon is a coarse sampler—not a full profiler or benchmarking suite. It runs in the Lua UI layer and uses publicly available data, so it cannot measure GPU time, draw calls, I/O waits, or other engine-level activity.

Its output is best treated as evidence for exploratory troubleshooting: it can identify addons associated with stuttering, but it does not prove causation on its own.

PerfMon is also I/O-intensive. On a slow HDD, log writes may affect the performance being measured. Moving the log directory to a RAM disk can reduce this interference; see the [RAM-disk setup guide](https://www.returnofreckoning.com/forum/viewtopic.php?p=586739#p586739).

## Dependencies

PerfMon requires `EA_UiDebugTools`, an updated core module included in the download archive.
