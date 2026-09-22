export type MapLocation = {
  name: string;
  lat: number;
  lng: number;
  description: string;
};

export const locations: MapLocation[] = [
  {
    name: "Riyadh",
    lat: 24.7136,
    lng: 46.6753,
    description: "Saudi Arabia's capital in the heart of the peninsula.",
  },
  {
    name: "Muscat",
    lat: 23.588,
    lng: 58.3829,
    description: "Oman's coastal capital between mountains and sea.",
  },
  {
    name: "Sana'a",
    lat: 15.3694,
    lng: 44.191,
    description: "A historic highland city known for its old town.",
  },
];
