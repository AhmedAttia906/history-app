"use client";

import { useEffect, useRef } from "react";
import {
  LngLatBounds,
  Map as MapLibreMap,
  Marker,
  NavigationControl,
  Popup,
} from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

import { formatHijriYearRange } from "@/lib/hijri";

export type Place = {
  id: number;
  name: string;
  lat: number;
  lng: number;
};

export type HistoricalEvent = {
  id: number;
  period_id: number;
  place_id: number | null;
  title: string;
  description: string;
  start_year: number | null;
  end_year: number | null;
};

type MapProps = {
  places: Place[];
  events: HistoricalEvent[];
  selectedPeriodName: string;
};

function formatEventYear(event: HistoricalEvent) {
  return formatHijriYearRange(event.start_year, event.end_year);
}

function createPopupContent(place: Place, events: HistoricalEvent[]) {
  const popupContent = document.createElement("div");
  const placeName = document.createElement("strong");

  popupContent.dir = "rtl";
  placeName.textContent = place.name;
  popupContent.append(placeName);

  events.forEach((event) => {
    const eventSection = document.createElement("section");
    const heading = document.createElement("p");
    const year = document.createElement("span");
    const description = document.createElement("p");
    const formattedYear = formatEventYear(event);

    eventSection.className = "map-popup-event";
    heading.className = "map-popup-event-heading";
    heading.append(event.title);
    if (formattedYear) {
      year.dir = "ltr";
      year.textContent = ` (${formattedYear})`;
      heading.append(year);
    }
    description.textContent = event.description;
    eventSection.append(heading, description);
    popupContent.append(eventSection);
  });

  return popupContent;
}

export default function Map({ places, events, selectedPeriodName }: MapProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const markersRef = useRef<Marker[]>([]);

  useEffect(() => {
    if (!containerRef.current || mapRef.current) {
      return;
    }

    const map = new MapLibreMap({
      container: containerRef.current,
      center: [47, 23],
      zoom: 4.2,
      style: {
        version: 8,
        sources: {
          osm: {
            type: "raster",
            tiles: ["https://tile.openstreetmap.org/{z}/{x}/{y}.png"],
            tileSize: 256,
            attribution:
              '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>',
          },
        },
        layers: [{ id: "osm", type: "raster", source: "osm" }],
      },
    });

    map.addControl(new NavigationControl(), "top-left");
    mapRef.current = map;

    return () => {
      markersRef.current.forEach((marker) => marker.remove());
      markersRef.current = [];
      map.remove();
      mapRef.current = null;
    };
  }, []);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) {
      return;
    }

    markersRef.current.forEach((marker) => marker.remove());
    markersRef.current = [];

    const bounds = new LngLatBounds();

    places.forEach((place) => {
      const placeEvents = events.filter((event) => event.place_id === place.id);
      const marker = new Marker({ color: "#a97c2f" })
        .setLngLat([place.lng, place.lat])
        .setPopup(
          new Popup({ offset: 24 }).setDOMContent(
            createPopupContent(place, placeEvents),
          ),
        )
        .addTo(map);

      markersRef.current.push(marker);
      bounds.extend([place.lng, place.lat]);
    });

    if (places.length === 1) {
      map.easeTo({ center: [places[0].lng, places[0].lat], zoom: 5.2 });
    } else if (places.length > 1) {
      map.fitBounds(bounds, { padding: 80, maxZoom: 5.2, duration: 700 });
    }
  }, [events, places]);

  return (
    <div
      ref={containerRef}
      className="h-full w-full"
      aria-label={`خريطة أحداث عهد ${selectedPeriodName}`}
    />
  );
}
