"use client";

import { useMemo, useState } from "react";

type BiographyBookProps = {
  personId: number;
  personName: string;
  biography: string;
};

type SectionBoundary = {
  heading: string;
  startsWith: string;
};

type BiographySection = {
  heading: string | null;
  text: string;
};

const ABU_BAKR_NAME = "أبو بكر الصديق";

// Presentation-only boundaries. Every marker is an exact substring of the
// stored biography; the text itself is sliced, never rewritten.
export const ABU_BAKR_SECTION_BOUNDARIES: SectionBoundary[] = [
  {
    heading: "نسبه ونشأته",
    startsWith: "أبو بكر الصديق رضي الله عنه هو عبد الله بن عثمان",
  },
  {
    heading: "إسلامه وصحبته",
    startsWith: "وعندما بدأ النبي محمد ﷺ دعوته",
  },
  {
    heading: "الهجرة ومواقفه مع النبي ﷺ",
    startsWith: "وعندما أذن الله بالهجرة",
  },
  {
    heading: "تولّيه الخلافة",
    startsWith: "عند وفاة النبي ﷺ سنة 11هـ",
  },
  {
    heading: "حروب الردة وتثبيت الدولة",
    startsWith: "واجهت الدولة الناشئة فورًا أزمة واسعة",
  },
  {
    heading: "جمع القرآن",
    startsWith: "كانت اليمامة شديدة",
  },
  {
    heading: "التحركات نحو العراق والشام",
    startsWith: "بعد استقرار معظم الجزيرة",
  },
  {
    heading: "وفاته وأثر خلافته",
    startsWith: "مرض أبو بكر في أواخر حياته",
  },
];

const SECTIONS_PER_PAGE = 2;

function sectionBiography(
  personName: string,
  biography: string,
): BiographySection[] {
  if (personName !== ABU_BAKR_NAME) {
    return [{ heading: null, text: biography }];
  }

  const offsets = ABU_BAKR_SECTION_BOUNDARIES.map(({ startsWith }) =>
    biography.indexOf(startsWith),
  );
  const boundariesMatch = offsets.every(
    (offset, index) =>
      offset >= 0 &&
      (index === 0 ? offset === 0 : offset > offsets[index - 1]),
  );

  if (!boundariesMatch) {
    return [{ heading: null, text: biography }];
  }

  const sections = ABU_BAKR_SECTION_BOUNDARIES.map((boundary, index) => ({
    heading: boundary.heading,
    text: biography.slice(offsets[index], offsets[index + 1]),
  }));

  // Defensive preservation check: any unexpected mismatch falls back to the
  // complete biography rather than showing partial content.
  if (sections.map(({ text }) => text).join("") !== biography) {
    return [{ heading: null, text: biography }];
  }

  return sections;
}

function paginateSections(sections: BiographySection[]) {
  const pages: BiographySection[][] = [];

  for (let index = 0; index < sections.length; index += SECTIONS_PER_PAGE) {
    pages.push(sections.slice(index, index + SECTIONS_PER_PAGE));
  }

  return pages.length > 0 ? pages : [[{ heading: null, text: "" }]];
}

export default function BiographyBook({
  personId,
  personName,
  biography,
}: BiographyBookProps) {
  const pages = useMemo(
    () => paginateSections(sectionBiography(personName, biography)),
    [biography, personName],
  );
  const [pageIndex, setPageIndex] = useState(0);
  const [turnDirection, setTurnDirection] = useState<"next" | "previous">(
    "next",
  );

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
      <div className="biography-book-perspective">
        <div
          key={`${personId}-${pageIndex}`}
          className={`biography-book-page biography-book-page--${turnDirection}`}
        >
          <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-l from-transparent via-[#c8a65a]/70 to-transparent" />
          {pages[pageIndex].map((section, sectionIndex) => (
            <section
              key={`${section.heading ?? "biography"}-${sectionIndex}`}
              className="[&+&]:mt-4"
            >
              {section.heading ? (
                <h4 className="mb-1.5 text-sm font-semibold text-[#876522] sm:text-[0.95rem]">
                  {section.heading}
                </h4>
              ) : null}
              <p className="text-[0.82rem] leading-6 text-[#3f493f] sm:text-sm sm:leading-7">
                {section.text}
              </p>
            </section>
          ))}
        </div>
      </div>

      <nav
        className="mt-2.5 flex items-center justify-center gap-4"
        aria-label="التنقل بين صفحات السيرة"
      >
        <button
          type="button"
          onClick={goToPreviousPage}
          disabled={pageIndex === 0}
          aria-label="الصفحة السابقة"
          className="grid size-8 place-items-center rounded-full border border-[#b8954d] bg-[#fffaf0] text-base text-[#315b4b] transition-colors hover:bg-[#f1e2bd] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#a97c2f] focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-30 disabled:hover:bg-[#fffaf0]"
        >
          <span aria-hidden="true">→</span>
        </button>

        <span className="min-w-20 text-center text-xs text-[#806e52]" aria-live="polite">
          صفحة {pageIndex + 1} من {pages.length}
        </span>

        <button
          type="button"
          onClick={goToNextPage}
          disabled={pageIndex === pages.length - 1}
          aria-label="الصفحة التالية"
          className="grid size-8 place-items-center rounded-full border border-[#b8954d] bg-[#fffaf0] text-base text-[#315b4b] transition-colors hover:bg-[#f1e2bd] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#a97c2f] focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-30 disabled:hover:bg-[#fffaf0]"
        >
          <span aria-hidden="true">←</span>
        </button>
      </nav>
    </div>
  );
}
