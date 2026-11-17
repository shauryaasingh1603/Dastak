export const MAX_PART = 443;

/** Parses "45, 46, 50-52" into [45, 46, 50, 51, 52]. Throws a readable error. */
export function parseBooths(input: string): number[] {
  const parts = new Set<number>();
  for (const piece of input.split(/[,\s]+/).filter(Boolean)) {
    const range = piece.match(/^(\d+)-(\d+)$/);
    const single = piece.match(/^\d+$/);
    if (range) {
      const from = Number(range[1]);
      const to = Number(range[2]);
      if (from > to) throw new Error(`"${piece}" runs backwards.`);
      if (to - from > 60) throw new Error(`"${piece}" is more than 60 booths.`);
      for (let p = from; p <= to; p++) parts.add(p);
    } else if (single) {
      parts.add(Number(piece));
    } else {
      throw new Error(`"${piece}" is not a booth number.`);
    }
  }
  for (const p of parts) {
    if (p < 1 || p > MAX_PART) throw new Error(`Booth ${p} is outside 1–${MAX_PART}.`);
  }
  return [...parts].sort((a, b) => a - b);
}

/** Formats [45, 46, 50, 51, 52] as "45, 46, 50-52". */
export function formatBooths(parts: number[]): string {
  const sorted = [...new Set(parts)].sort((a, b) => a - b);
  const out: string[] = [];
  for (let i = 0; i < sorted.length; i++) {
    let j = i;
    while (j + 1 < sorted.length && sorted[j + 1] === sorted[j] + 1) j++;
    out.push(j - i >= 2 ? `${sorted[i]}-${sorted[j]}` : sorted.slice(i, j + 1).join(", "));
    i = j;
  }
  return out.join(", ");
}
