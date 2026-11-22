"use client";

import { useEffect, useRef, useState } from "react";

/** Width of an element, kept up to date as the page resizes. */
function useWidth<T extends HTMLElement>() {
  const ref = useRef<T>(null);
  const [width, setWidth] = useState(0);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const observer = new ResizeObserver(([entry]) => setWidth(entry.contentRect.width));
    observer.observe(el);
    return () => observer.disconnect();
  }, []);
  return [ref, width] as const;
}

export type Series = { key: string; label: string; color: string };
export type TooltipRow = { label: string; value: string; color?: string };

function niceMax(value: number): number {
  if (value <= 5) return 5;
  const pow = 10 ** Math.floor(Math.log10(value));
  for (const step of [1, 2, 2.5, 5, 10]) {
    if (step * pow >= value) return step * pow;
  }
  return 10 * pow;
}

/** A bar with a 4px rounded top, anchored square to the baseline. */
function barPath(x: number, y: number, w: number, h: number): string {
  if (h <= 0) return "";
  const r = Math.min(4, w / 2, h);
  return `M${x},${y + h}V${y + r}Q${x},${y} ${x + r},${y}H${x + w - r}Q${x + w},${y} ${x + w},${y + r}V${y + h}Z`;
}

/**
 * Bars over days, stacked when there is more than one series. Each day is a
 * hover/focus target showing every series for that day. An optional dashed
 * reference line (e.g. the team's daily target) shares the one axis.
 */
export function DailyBars<T extends Record<string, unknown>>({
  rows,
  series,
  xLabel,
  tooltip,
  reference,
  height = 220,
  emptyText,
}: {
  rows: T[];
  series: Series[];
  xLabel: (row: T) => string;
  tooltip: (row: T) => { title: string; rows: TooltipRow[] };
  reference?: { value: number; label: string };
  height?: number;
  emptyText?: string;
}) {
  const [ref, width] = useWidth<HTMLDivElement>();
  const [hover, setHover] = useState<number | null>(null);

  const totals = rows.map((r) => series.reduce((sum, s) => sum + (Number(r[s.key]) || 0), 0));
  const max = niceMax(Math.max(1, ...totals, reference?.value ?? 0));
  const empty = totals.every((t) => t === 0);

  const pad = { top: 12, right: 8, bottom: 26, left: 40 };
  const plotW = Math.max(0, width - pad.left - pad.right);
  const plotH = height - pad.top - pad.bottom;
  const slot = rows.length ? plotW / rows.length : 0;
  const barW = Math.max(2, Math.min(28, slot - 2));
  const y = (v: number) => pad.top + plotH - (v / max) * plotH;
  const ticks = [0, max / 2, max];
  const labelEvery = Math.max(1, Math.ceil(rows.length / Math.max(1, Math.floor(plotW / 56))));

  const tip = hover !== null ? tooltip(rows[hover]) : null;
  const tipX = hover !== null ? pad.left + slot * hover + slot / 2 : 0;

  return (
    <div className="chart" ref={ref} onPointerLeave={() => setHover(null)}>
      {width > 0 && (
        <svg width={width} height={height} role="img" aria-label="Daily chart">
          {ticks.map((t) => (
            <g key={t}>
              <line x1={pad.left} x2={width - pad.right} y1={y(t)} y2={y(t)} className="grid" />
              <text x={pad.left - 8} y={y(t)} className="axis" textAnchor="end" dominantBaseline="middle">
                {Math.round(t).toLocaleString("en-IN")}
              </text>
            </g>
          ))}
          {rows.map((row, i) => {
            const x = pad.left + slot * i + (slot - barW) / 2;
            let base = 0;
            return (
              <g key={i} opacity={hover === null || hover === i ? 1 : 0.55}>
                {series.map((s, si) => {
                  const v = Number(row[s.key]) || 0;
                  if (!v) return null;
                  const top = y(base + v);
                  // 2px surface gap between stacked segments.
                  const h = y(base) - top - (base > 0 ? 2 : 0);
                  base += v;
                  const isTop = series.slice(si + 1).every((n) => !Number(row[n.key]));
                  return isTop ? (
                    <path key={s.key} d={barPath(x, top, barW, h)} fill={s.color} />
                  ) : (
                    <rect key={s.key} x={x} y={top} width={barW} height={Math.max(0, h)} fill={s.color} />
                  );
                })}
                {i % labelEvery === 0 && (
                  <text x={x + barW / 2} y={height - 8} className="axis" textAnchor="middle">
                    {xLabel(row)}
                  </text>
                )}
                <rect
                  x={pad.left + slot * i}
                  y={pad.top}
                  width={slot}
                  height={plotH}
                  fill="transparent"
                  tabIndex={0}
                  onPointerEnter={() => setHover(i)}
                  onFocus={() => setHover(i)}
                  onBlur={() => setHover(null)}
                />
              </g>
            );
          })}
          {reference && reference.value > 0 && (
            <g pointerEvents="none">
              <line
                x1={pad.left}
                x2={width - pad.right}
                y1={y(reference.value)}
                y2={y(reference.value)}
                className="reference"
              />
              <text x={width - pad.right} y={y(reference.value) - 5} className="axis" textAnchor="end">
                {reference.label}
              </text>
            </g>
          )}
          <line x1={pad.left} x2={width - pad.right} y1={y(0)} y2={y(0)} className="baseline" />
        </svg>
      )}
      {empty && emptyText && <div className="chart-empty">{emptyText}</div>}
      {tip && (
        <div
          className="tooltip"
          style={{
            left: Math.min(Math.max(tipX, 90), Math.max(90, width - 90)),
            top: pad.top,
          }}
        >
          <div className="tooltip-title">{tip.title}</div>
          {tip.rows.map((r) => (
            <div className="tooltip-row" key={r.label}>
              {r.color ? <span className="key" style={{ background: r.color }} /> : <span className="key none" />}
              <strong>{r.value}</strong>
              <span>{r.label}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export function Legend({ series }: { series: Series[] }) {
  return (
    <div className="legend">
      {series.map((s) => (
        <span key={s.key}>
          <span className="swatch" style={{ background: s.color }} />
          {s.label}
        </span>
      ))}
    </div>
  );
}

/** A thin progress bar for a share of a whole. */
export function Meter({ value, total, tone }: { value: number; total: number; tone?: "ok" | "warn" }) {
  const pct = total > 0 ? Math.min(100, (value / total) * 100) : 0;
  return (
    <span className={`meter ${tone ?? ""}`} title={`${value.toLocaleString("en-IN")} of ${total.toLocaleString("en-IN")}`}>
      <span style={{ width: `${pct}%` }} />
    </span>
  );
}

/** Labelled horizontal bars, largest first, each with its count and share. */
export function BarList({
  items,
  total,
  color,
}: {
  items: { label: string; value: number; note?: string }[];
  total: number;
  color: string;
}) {
  const max = Math.max(1, ...items.map((i) => i.value));
  return (
    <div className="barlist">
      {items.map((item) => (
        <div className="barlist-row" key={item.label} title={item.note}>
          <div className="barlist-label">
            <span>{item.label}</span>
            <span className="barlist-value">
              <strong>{item.value.toLocaleString("en-IN")}</strong>
              {total > 0 && <span className="muted"> · {Math.round((item.value / total) * 100)}%</span>}
            </span>
          </div>
          <div className="barlist-track">
            <span style={{ width: `${(item.value / max) * 100}%`, background: color }} />
          </div>
        </div>
      ))}
    </div>
  );
}
