# Metric design: snapshot vs historical

## The question the client asked
"Why did % execution drop from 100% to 67% when nothing went wrong?"

## Why it happens
`% Execution (Current) = Awarded / (Awarded + In progress)` is a snapshot of everything open right now.

| | Awarded | In progress | % Execution |
|---|---|---|---|
| Month 1 — one process, awarded | 100 | 0 | 100% |
| Month 2 — a new process opens | 100 | 50 | 67% |

Nothing got worse. The denominator grew because there is more work. Inverting the measure (`% Still Open`) doesn't fix it; it is the same information mirrored.

## What I did
1. **Kept the measure and named it for what it is** — `% Execution (Current)` — with a description that appears as a tooltip in the report.
2. **Added a process-count version.** Quantity-based % lets one large process dominate. `% Processes Awarded` treats each process equally. Shown side by side, they answer different questions:
   - by quantity: "how much of the volume is secured?"
   - by process: "how much of the workload is closed?"
3. **For a historical view**, the recommendation is to measure by opening period (each month's or year's processes compared only with themselves), so new processes don't dilute older cohorts.

## Validation
An early version divided awarded quantity by a column that, it turned out, did not include the in-progress share. Execution showed ~100% almost everywhere, even for items with a large quantity still to award. The fix was to build the denominator explicitly as awarded + in progress. `Qty Check` (awarded + in progress − total, which must be 0) now guards against that class of error while the model changes.
