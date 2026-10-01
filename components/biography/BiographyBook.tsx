"use client";

import { useLayoutEffect, useMemo, useRef, useState } from "react";

import {
  BIOGRAPHY_CONFIGURATIONS,
  PERSON_SLUG_BY_NAME,
} from "./biography-config";
import {
  MAXIMUM_LAYOUT_RETRIES,
  MINIMUM_MEASUREMENT_CONTENT_WIDTH,
  PAGE_FIT_SAFETY_MARGIN,
  paginateToFit,
  sectionBiography,
  type BiographySection,
} from "./biography-pagination";

type BiographyBookProps = {
  personId: number;
  personName: string;
  biography: string;
};

export default function BiographyBook({
  personId,
  personName,
  biography,
}: BiographyBookProps) {
  const personSlug = PERSON_SLUG_BY_NAME[personName];
  const configuration = personSlug
    ? BIOGRAPHY_CONFIGURATIONS[personSlug]
    : undefined;
  const sections = useMemo(
    () => sectionBiography(biography, configuration),
    [biography, configuration],
  );
  const readerRef = useRef<HTMLDivElement>(null);
  const measurementPageRef = useRef<HTMLDivElement>(null);
  const paginationGenerationRef = useRef(0);
  const [pages, setPages] = useState<BiographySection[][]>([]);
  const [paginationError, setPaginationError] = useState(false);
  const [pageIndex, setPageIndex] = useState(0);
  const [turnDirection, setTurnDirection] = useState<"next" | "previous">(
    "next",
  );

  useLayoutEffect(() => {
    const reader = readerRef.current;
    const measurementPage = measurementPageRef.current;

    if (!reader || !measurementPage) {
      return;
    }

    const generation = paginationGenerationRef.current + 1;
    paginationGenerationRef.current = generation;
    let cancelled = false;
    let animationFrame = 0;
    let layoutRetryCount = 0;
    let observedWidth = -1;
    let observedHeight = -1;

    setPages([]);
    setPaginationError(false);

    const paginationIsCurrent = () =>
      !cancelled && paginationGenerationRef.current === generation;

    const calculatePages = () => {
      animationFrame = 0;
      if (!paginationIsCurrent()) {
        return;
      }

      const measurementRect = measurementPage.getBoundingClientRect();
      if (
        measurementRect.width < MINIMUM_MEASUREMENT_CONTENT_WIDTH ||
        measurementRect.height <= PAGE_FIT_SAFETY_MARGIN
      ) {
        layoutRetryCount += 1;
        if (layoutRetryCount <= MAXIMUM_LAYOUT_RETRIES) {
          animationFrame = window.requestAnimationFrame(calculatePages);
          return;
        }

        console.error("Biography pagination could not obtain a usable measurement box.");
        setPaginationError(true);
        return;
      }

      layoutRetryCount = 0;
      const result = paginateToFit(sections, biography, measurementPage);
      if (!paginationIsCurrent()) {
        return;
      }

      if (!result.ok) {
        console.error(`Biography pagination failed: ${result.reason}`);
        setPaginationError(true);
        return;
      }

      setPaginationError(false);
      setPages(result.pages);
      setPageIndex((current) => Math.min(current, result.pages.length - 1));
    };

    const schedulePagination = () => {
      if (!paginationIsCurrent()) {
        return;
      }

      if (animationFrame !== 0) {
        window.cancelAnimationFrame(animationFrame);
      }
      animationFrame = window.requestAnimationFrame(calculatePages);
    };

    schedulePagination();

    const resizeObserver = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      if (
        Math.abs(width - observedWidth) < 0.5 &&
        Math.abs(height - observedHeight) < 0.5
      ) {
        return;
      }

      observedWidth = width;
      observedHeight = height;
      schedulePagination();
    });
    resizeObserver.observe(reader);
    void document.fonts?.ready.then(schedulePagination);

    return () => {
      cancelled = true;
      paginationGenerationRef.current += 1;
      if (animationFrame !== 0) {
        window.cancelAnimationFrame(animationFrame);
      }
      resizeObserver.disconnect();
    };
  }, [biography, sections]);

  const currentPage = pages[pageIndex] ?? [];

  const goToPreviousPage = () => {
    setTurnDirection("previous");
    setPageIndex((current) => Math.max(0, current - 1));
  };

  const goToNextPage = () => {
    setTurnDirection("next");
    setPageIndex((current) => Math.min(pages.length - 1, current + 1));
  };

  return (
    <div className="mt-3" aria-label={`سيرة ${personName}`}>
      <div ref={readerRef} className="biography-book-perspective">
        <div
          ref={measurementPageRef}
          className="biography-book-page biography-book-page--measure"
          aria-hidden="true"
        />
        <div
          key={`${personId}-${pageIndex}`}
          className={`biography-book-page biography-book-page--${turnDirection}`}
          role="region"
          aria-label={`صفحة ${pageIndex + 1} من سيرة ${personName}`}
          aria-busy={pages.length === 0 && !paginationError}
        >
          <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-l from-transparent via-[#c8a65a]/70 to-transparent" />
          {paginationError ? (
            <p className="biography-book-error" role="alert">
              تعذّر إعداد صفحات السيرة. راجع وحدة تحكم المتصفح للتفاصيل.
            </p>
          ) : (
            currentPage.map((section, sectionIndex) => (
              <section
                key={`${section.heading ?? "biography"}-${sectionIndex}`}
                className="biography-book-section"
              >
                {section.heading ? (
                  <h4 className="biography-book-heading">
                    {section.heading}
                  </h4>
                ) : null}
                <p className="biography-book-text">{section.text}</p>
              </section>
            ))
          )}
        </div>
      </div>

      <nav
        className="mt-3 grid grid-cols-[2.5rem_minmax(6rem,auto)_2.5rem] items-center justify-center gap-3"
        aria-label="التنقل بين صفحات السيرة"
      >
        <button
          type="button"
          onClick={goToPreviousPage}
          disabled={pages.length === 0 || pageIndex === 0}
          aria-label="الصفحة السابقة"
          className="grid size-10 cursor-pointer place-items-center rounded-full border border-[#b8954d] bg-[#fffaf0] text-[#315b4b] shadow-sm transition-[background-color,border-color,color,transform] hover:border-[#9d7934] hover:bg-[#f1e2bd] active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#a97c2f] focus-visible:ring-offset-2 disabled:pointer-events-none disabled:cursor-default disabled:opacity-40"
        >
          <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            className="size-4"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="m9 18 6-6-6-6" />
          </svg>
        </button>

        <span className="min-w-20 text-center text-xs text-[#806e52]" aria-live="polite">
          {paginationError
            ? "تعذّر إعداد الصفحات"
            : pages.length > 0
              ? `صفحة ${pageIndex + 1} من ${pages.length}`
              : "جارٍ إعداد الصفحات…"}
        </span>

        <button
          type="button"
          onClick={goToNextPage}
          disabled={pages.length === 0 || pageIndex === pages.length - 1}
          aria-label="الصفحة التالية"
          className="grid size-10 cursor-pointer place-items-center rounded-full border border-[#b8954d] bg-[#fffaf0] text-[#315b4b] shadow-sm transition-[background-color,border-color,color,transform] hover:border-[#9d7934] hover:bg-[#f1e2bd] active:scale-95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#a97c2f] focus-visible:ring-offset-2 disabled:pointer-events-none disabled:cursor-default disabled:opacity-40"
        >
          <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            className="size-4"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="m15 18-6-6 6-6" />
          </svg>
        </button>
      </nav>
    </div>
  );
}
