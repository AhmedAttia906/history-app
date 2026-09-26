"use client";

import { useMemo, useState } from "react";

type BiographyBookProps = {
  personId: number;
  personName: string;
  biography: string;
};

type SectionBoundary = {
  heading: string | null;
  startsWith: string;
};

type BiographyConfiguration = {
  boundaries: SectionBoundary[];
  pageBreakAfter: number[];
};

type BiographySection = {
  heading: string | null;
  text: string;
};

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

export const UMAR_SECTION_BOUNDARIES: SectionBoundary[] = [
  {
    heading: "نسبه ونشأته",
    startsWith: "عمر بن الخطاب رضي الله عنه هو عمر بن الخطاب بن نفيل",
  },
  {
    heading: "إسلامه وهجرته",
    startsWith: "حين بُعث النبي محمد ﷺ في مكة",
  },
  {
    heading: null,
    startsWith: "ما إن أسلم عمر حتى صار في جماعة المسلمين",
  },
  {
    heading: "مع النبي ﷺ",
    startsWith: "استقر عمر في المدينة",
  },
  {
    heading: "مع أبي بكر وجمع القرآن",
    startsWith: "وعندما توفي رسول الله ﷺ سنة 11هـ",
  },
  {
    heading: null,
    startsWith: "في خلافة أبي بكر كان عمر من أقرب من يشاوره الخليفة",
  },
  {
    heading: "توليه الخلافة",
    startsWith: "لما مرض أبو بكر في سنة 13هـ",
  },
  {
    heading: "فتوح الشام والعراق",
    startsWith: "في الشام استمرت المواجهة مع الدولة البيزنطية",
  },
  {
    heading: null,
    startsWith: "وفي العراق كانت المواجهة الكبرى مع الدولة الساسانية",
  },
  {
    heading: "بيت المقدس وتنظيم الدولة",
    startsWith: "وفي بلاد الشام بلغ المسلمون بيت المقدس",
  },
  {
    heading: null,
    startsWith: "ومع تدفق الأموال واتساع عدد الجند والرعية",
  },
  {
    heading: "عام الرمادة وطاعون عمواس",
    startsWith: "لم تكن سنوات خلافته كلها سنوات فتح ورخاء",
  },
  {
    heading: "فتح مصر ونهاوند",
    startsWith: "ثم اتجهت الجيوش إلى مصر بقيادة عمرو بن العاص",
  },
  {
    heading: "استشهاده والشورى",
    startsWith: "ومع هذه المساحة الواسعة بقي مركز الخلافة في المدينة",
  },
  {
    heading: null,
    startsWith: "وفي أواخر ذي الحجة سنة 23هـ خرج عمر لصلاة الفجر",
  },
];

const BIOGRAPHY_CONFIGURATIONS: Record<string, BiographyConfiguration> = {
  "أبو بكر الصديق": {
    boundaries: ABU_BAKR_SECTION_BOUNDARIES,
    pageBreakAfter: [2, 4, 6, 8],
  },
  "عمر بن الخطاب": {
    boundaries: UMAR_SECTION_BOUNDARIES,
    pageBreakAfter: [1, 3, 4, 6, 7, 9, 11, 12, 13, 15],
  },
};

function sectionBiography(
  biography: string,
  configuration: BiographyConfiguration | undefined,
): BiographySection[] {
  if (!configuration) {
    return [{ heading: null, text: biography }];
  }

  const offsets = configuration.boundaries.map(({ startsWith }) =>
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

  const sections = configuration.boundaries.map((boundary, index) => ({
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

function paginateSections(
  sections: BiographySection[],
  configuration: BiographyConfiguration | undefined,
) {
  if (!configuration) {
    return [sections];
  }

  const pages: BiographySection[][] = [];
  let pageStart = 0;

  for (const pageEnd of configuration.pageBreakAfter) {
    if (pageEnd <= pageStart || pageEnd > sections.length) {
      return [sections];
    }

    pages.push(sections.slice(pageStart, pageEnd));
    pageStart = pageEnd;
  }

  return pageStart === sections.length && pages.length > 0 ? pages : [sections];
}

export default function BiographyBook({
  personId,
  personName,
  biography,
}: BiographyBookProps) {
  const configuration = BIOGRAPHY_CONFIGURATIONS[personName];
  const pages = useMemo(
    () =>
      paginateSections(
        sectionBiography(biography, configuration),
        configuration,
      ),
    [biography, configuration],
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
