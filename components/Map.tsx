"use client";

import { useEffect, useRef } from "react";
import {
  Map as MapLibreMap,
  Marker,
  NavigationControl,
  Popup,
} from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

import { locations } from "@/data/locations";

export default function Map() {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MapLibreMap | null>(null);

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

    map.addControl(new NavigationControl(), "top-right");

    locations.forEach((location) => {
      const popupContent = document.createElement("div");
      const title = document.createElement("strong");
      const description = document.createElement("p");

      title.textContent = location.name;
      description.textContent = location.description;
      popupContent.append(title, description);

      new Marker({ color: "#b45309" })
        .setLngLat([location.lng, location.lat])
        .setPopup(
          new Popup({ offset: 24 }).setDOMContent(popupContent),
        )
        .addTo(map);
    });

    mapRef.current = map;

    return () => {
      map.remove();
      mapRef.current = null;
    };
  }, []);

  return (
    <div
      ref={containerRef}
      className="h-full w-full"
      aria-label="Interactive map of the Arabian Peninsula"
    />
  );
}
