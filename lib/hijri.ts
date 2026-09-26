export function formatHijriYear(hijriYear: number) {
  return `${hijriYear}هـ`;
}

export function formatHijriYearRange(
  startYear: number | null,
  endYear: number | null,
) {
  if (startYear === null) {
    return null;
  }

  if (endYear !== null && endYear !== startYear) {
    return `${startYear}–${endYear}هـ`;
  }

  return formatHijriYear(startYear);
}
