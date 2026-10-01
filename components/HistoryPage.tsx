"use client";

import { useEffect, useMemo, useState } from "react";

import BiographyBook from "@/components/biography/BiographyBook";
import Map, { type HistoricalEvent, type Place } from "@/components/Map";
import { formatHijriYearRange } from "@/lib/hijri";

type Era = {
  id: number;
  name: string;
  description: string;
};

type Period = {
  id: number;
  era_id: number;
  name: string;
  start_year: number;
  end_year: number;
  summary: string;
  period_people: Array<{
    is_primary: boolean;
    people: Person;
  }>;
};

type Person = {
  id: number;
  name: string;
  brief_bio: string;
};

type HistoryData = {
  eras: Era[];
  periods: Period[];
  places: Place[];
  events: HistoricalEvent[];
};

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

async function fetchTable<T>(path: string, signal: AbortSignal) {
  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Supabase environment variables are missing.");
  }

  const response = await fetch(`${supabaseUrl}/rest/v1/${path}`, {
    headers: {
      apikey: supabaseAnonKey,
      Authorization: `Bearer ${supabaseAnonKey}`,
    },
    signal,
  });

  if (!response.ok) {
    throw new Error(`Supabase request failed: ${response.status}`);
  }

  return (await response.json()) as T;
}

async function fetchHistoryData(signal: AbortSignal): Promise<HistoryData> {
  const [eras, periods, places, events] = await Promise.all([
    fetchTable<Era[]>("eras?select=id,name,description&order=id&limit=1", signal),
    fetchTable<Period[]>(
      "periods?select=id,era_id,name,start_year,end_year,summary,period_people!inner(is_primary,people!inner(id,name,brief_bio))&period_people.is_primary=eq.true&order=start_year",
      signal,
    ),
    fetchTable<Place[]>("places?select=id,name,lat,lng&order=name", signal),
    fetchTable<HistoricalEvent[]>(
      "events?select=id,period_id,place_id,title,description,start_year,end_year&order=start_year",
      signal,
    ),
  ]);

  return { eras, periods, places, events };
}

export default function HistoryPage() {
  const [data, setData] = useState<HistoryData | null>(null);
  const [selectedPeriodId, setSelectedPeriodId] = useState<number | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    const controller = new AbortController();

    async function loadHistory() {
      try {
        const historyData = await fetchHistoryData(controller.signal);
        setData(historyData);
        setSelectedPeriodId(historyData.periods[0]?.id ?? null);
      } catch (loadError) {
        if (!controller.signal.aborted) {
          console.error(loadError);
          setError("تعذّر تحميل بيانات الخلافة الراشدة. حاول تحديث الصفحة.");
        }
      }
    }

    void loadHistory();
    return () => controller.abort();
  }, []);

  const selectedPeriod = data?.periods.find(
    (period) => period.id === selectedPeriodId,
  );
  const selectedPerson = selectedPeriod?.period_people[0]?.people;

  const filteredEvents = useMemo(
    () =>
      data?.events.filter((event) => event.period_id === selectedPeriodId) ?? [],
    [data, selectedPeriodId],
  );

  const filteredPlaces = useMemo(() => {
    const placeIds = new Set(
      filteredEvents.flatMap((event) =>
        event.place_id === null ? [] : [event.place_id],
      ),
    );

    return data?.places.filter((place) => placeIds.has(place.id)) ?? [];
  }, [data, filteredEvents]);

  if (error) {
    return (
      <main className="grid min-h-screen place-items-center bg-[#f3ead8] px-4">
        <p className="rounded-2xl border border-[#caa85e]/50 bg-[#fffaf0] px-6 py-5 text-[#6b2f25] shadow-sm">
          {error}
        </p>
      </main>
    );
  }

  if (!data || !selectedPeriod) {
    return (
      <main className="grid min-h-screen place-items-center bg-[#f3ead8]">
        <p className="text-sm text-[#476052]">جارٍ تحميل الحكاية…</p>
      </main>
    );
  }

  const era = data.eras[0];

  return (
    <main className="min-h-screen bg-[radial-gradient(circle_at_top_right,#fff9eb_0,#f3ead8_48%,#eadcc3_100%)] px-4 py-4 text-[#2e392f] sm:px-6">
      <div className="mx-auto flex w-full max-w-6xl flex-col gap-3">
        <header className="relative overflow-hidden rounded-3xl border border-[#c8a65a]/55 bg-[#173f33] px-6 py-5 text-[#fff9eb] shadow-[0_14px_35px_rgba(61,45,24,0.14)] sm:px-8">
          <div className="absolute inset-y-0 right-0 w-1.5 bg-[#c8a65a]" />
          <p className="mb-1 text-xs font-semibold tracking-[0.18em] text-[#e0c27c]">
            صفحات من التاريخ الإسلامي
          </p>
          <h1 className="text-2xl font-semibold sm:text-3xl">{era?.name}</h1>
          <p className="mt-1 max-w-4xl text-sm leading-6 text-[#edf1e9]/85 sm:text-base">
            {era?.description ?? ""}
          </p>
        </header>

        <section className="rounded-3xl border border-[#d5bc82]/65 bg-[#fffaf0]/95 px-4 py-4 shadow-[0_10px_30px_rgba(75,54,27,0.09)] sm:px-7">
          <div className="mb-3 flex items-center gap-3">
            <span className="h-px flex-1 bg-[#d9c492]" />
            <h2 className="text-sm font-semibold text-[#315b4b]">تعاقب الخلفاء</h2>
            <span className="h-px flex-1 bg-[#d9c492]" />
          </div>

          <div className="relative grid grid-cols-4 gap-2" aria-label="الخط الزمني للخلفاء الراشدين">
            <div className="absolute left-[10%] right-[10%] top-4 h-px bg-[#cbb174]" />
            {data.periods.map((period) => {
              const isSelected = period.id === selectedPeriodId;

              return (
                <button
                  key={period.id}
                  type="button"
                  onClick={() => setSelectedPeriodId(period.id)}
                  className="group relative z-10 flex min-w-0 flex-col items-center text-center focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#a97c2f] focus-visible:ring-offset-2"
                  aria-pressed={isSelected}
                >
                  <span
                    className={`mb-2 grid size-8 place-items-center rounded-full border-2 text-xs font-semibold transition-all ${
                      isSelected
                        ? "border-[#a97c2f] bg-[#b58a3a] text-white shadow-[0_0_0_5px_#f5e8c8]"
                        : "border-[#b99d61] bg-[#fffaf0] text-[#315b4b] group-hover:bg-[#f1e2bd]"
                    }`}
                  >
                    {data.periods.indexOf(period) + 1}
                  </span>
                  <span
                    className={`truncate text-xs font-semibold sm:text-sm ${
                      isSelected ? "text-[#8b6421]" : "text-[#3d5145]"
                    }`}
                  >
                    {period.name}
                  </span>
                  <span className="mt-0.5 text-[10px] text-[#87765c] sm:text-xs" dir="ltr">
                    {formatHijriYearRange(period.start_year, period.end_year)}
                  </span>
                </button>
              );
            })}
          </div>

          <article className="mt-4 rounded-2xl border-r-4 border-[#b58a3a] bg-[#f4ead4]/70 px-4 py-3">
            <div className="mb-1 flex items-baseline justify-between gap-3">
              <h3 className="font-semibold text-[#244d3e]">{selectedPerson?.name}</h3>
              <span className="shrink-0 text-xs text-[#9a742d]">{selectedPeriod.summary}</span>
            </div>
            {selectedPerson ? (
              <BiographyBook
                key={selectedPerson.id}
                personId={selectedPerson.id}
                personName={selectedPerson.name}
                biography={selectedPerson.brief_bio}
              />
            ) : null}
          </article>
        </section>

        <section className="overflow-hidden rounded-3xl border border-[#bfa56b]/70 bg-[#fffaf0] p-2 shadow-[0_12px_35px_rgba(75,54,27,0.12)]">
          <div className="flex items-center justify-between gap-4 px-3 py-2">
            <div>
              <h2 className="font-semibold text-[#244d3e]">خريطة الأحداث</h2>
              <p className="text-xs text-[#75664f]">
                أحداث عهد {selectedPeriod.name} فقط
              </p>
            </div>
            <span className="rounded-full border border-[#cfb46f] bg-[#f5e7c2] px-3 py-1 text-xs font-semibold text-[#76561f]">
              {filteredEvents.length} {filteredEvents.length === 1 ? "حدث" : "أحداث"}
            </span>
          </div>
          <div className="relative h-[400px] overflow-hidden rounded-2xl border border-[#d8c59a]">
            <Map
              places={filteredPlaces}
              events={filteredEvents}
              selectedPeriodName={selectedPeriod.name}
            />
          </div>
        </section>
      </div>
    </main>
  );
}
