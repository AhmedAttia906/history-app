import Map from "@/components/Map";

export default function Home() {
  return (
    <main className="relative h-screen w-screen overflow-hidden">
      <div className="absolute left-4 top-4 z-10 max-w-xs rounded-lg bg-white/95 px-4 py-3 shadow-lg backdrop-blur-sm">
        <h1 className="text-lg font-semibold text-slate-900">
          Arabian Peninsula
        </h1>
        <p className="text-sm text-slate-600">
          Select a marker to learn more about each location.
        </p>
      </div>
      <Map />
    </main>
  );
}
