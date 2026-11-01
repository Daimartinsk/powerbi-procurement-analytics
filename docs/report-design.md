# Report design

## Pages
| Page | Visuals |
|---|---|
| Overview | KPI cards (awarded value with YoY, % execution, savings, number of processes); year slicer as buttons |
| By scope | Clustered bar (awarded value) + line (% execution) on a secondary axis; donut by scope |
| Comparison | Line chart, one line per year, to read execution trends |
| Detail | Table by item / process with a data bar on % execution and status colours |

## Conventions
- **Status colours:** green ≥ 90%, amber 80–89%, red < 80% — applied with conditional formatting rules, not hard-coded per visual.
- **Data bars** on % execution in tables (min red, max green, bar only).
- **Cross-filtering** between visuals instead of tabs; edit interactions where a visual must not filter another.
- **Tooltips** carry the measure description, so snapshot metrics explain themselves.

## KPI cards without a paid visual
The premium card visual showed value and variation together. The standard card accepts one field, so one text measure (`KPI Awarded Value` in [`dax/measures.dax`](../dax/measures.dax)) returns both lines:

```
36.1 M€
▲ +12.0% vs previous year
```

(Example figures.)

## Lesson learned
A first YoY variation came out absurdly high because the previous-year measure summed **all** years when no year was selected. The fix was to compute it relative to `MAX(Year)` in the current filter context and to show "no previous year" instead of a misleading percentage when there is none.
