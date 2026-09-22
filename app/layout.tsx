import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Arabian Peninsula Map",
  description: "An interactive map of locations across the Arabian Peninsula.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
