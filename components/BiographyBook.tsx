"use client";

import { useLayoutEffect, useMemo, useRef, useState } from "react";

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
};

type BiographySection = {
  heading: string | null;
  text: string;
};

type PaginationResult =
  | { ok: true; pages: BiographySection[][] }
  | { ok: false; reason: string };

const PAGE_FIT_SAFETY_MARGIN = 4;
const MINIMUM_MEASUREMENT_CONTENT_WIDTH = 120;
const MAXIMUM_LAYOUT_RETRIES = 4;

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

export const UTHMAN_SECTION_BOUNDARIES: SectionBoundary[] = [
  {
    heading: "نسبه ونشأته",
    startsWith: "عثمان بن عفان رضي الله عنه هو عثمان بن عفان بن أبي العاص",
  },
  {
    heading: "إسلامه وهجرته",
    startsWith: "كان عثمان من السابقين إلى الإسلام",
  },
  {
    heading: "مع النبي ﷺ",
    startsWith: "بعد الهجرة إلى المدينة عاش عثمان",
  },
  {
    heading: null,
    startsWith: "شهد عثمان أحدًا وما بعدها من المشاهد",
  },
  {
    heading: null,
    startsWith: "برز إنفاق عثمان في عدد من المواقف",
  },
  {
    heading: "مع أبي بكر وعمر والشورى",
    startsWith: "عندما توفي رسول الله ﷺ سنة 11هـ",
  },
  {
    heading: "توليه الخلافة",
    startsWith: "ورث عثمان دولة واسعة امتدت في عهد عمر",
  },
  {
    heading: "فتوح إفريقية",
    startsWith: "في شمال إفريقيا تحرك عبد الله بن سعد بن أبي سرح",
  },
  {
    heading: "الفتوح البحرية",
    startsWith: "وفي البحر المتوسط وقع تحول مهم",
  },
  {
    heading: "فتوح المشرق",
    startsWith: "وفي الشرق استمرت الفتوح في مناطق فارس وما وراءها",
  },
  {
    heading: "توحيد المصاحف",
    startsWith: "ومن أبرز أعمال خلافة عثمان جمع المسلمين على مصحف إمام",
  },
  {
    heading: "عمارة الحرمين",
    startsWith: "استمرت كذلك أعمال التوسعة والعمران في الحرمين",
  },
  {
    heading: "معركة ذات الصواري",
    startsWith: "وفي البحر وقعت معركة ذات الصواري",
  },
  {
    heading: "الفتنة والحصار",
    startsWith: "خلال النصف الثاني من خلافته ازدادت الاعتراضات",
  },
  {
    heading: null,
    startsWith: "كان في المدينة عدد من كبار الصحابة وأبنائهم",
  },
  {
    heading: "استشهاده",
    startsWith: "قُتل عثمان رضي الله عنه في المدينة سنة 35هـ",
  },
  {
    heading: "أثر خلافته",
    startsWith: "امتدت خلافة عثمان من 23هـ إلى 35هـ",
  },
];

const BIOGRAPHY_CONFIGURATIONS: Record<string, BiographyConfiguration> = {
  "abu-bakr-al-siddiq": {
    boundaries: ABU_BAKR_SECTION_BOUNDARIES,
  },
  "umar-ibn-al-khattab": {
    boundaries: UMAR_SECTION_BOUNDARIES,
  },
  "uthman-ibn-affan": {
    boundaries: UTHMAN_SECTION_BOUNDARIES,
  },
};

const PERSON_SLUG_BY_NAME: Partial<Record<string, string>> = {
  "أبو بكر الصديق": "abu-bakr-al-siddiq",
  "عمر بن الخطاب": "umar-ibn-al-khattab",
  "عثمان بن عفان": "uthman-ibn-affan",
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

function renderMeasurementPage(
  measurementPage: HTMLDivElement,
  sections: BiographySection[],
) {
  measurementPage.replaceChildren();
  const contentElement = document.createElement("div");
  contentElement.className = "biography-book-measure-content";
  measurementPage.append(contentElement);

  for (const section of sections) {
    const sectionElement = document.createElement("section");
    sectionElement.className = "biography-book-section";

    if (section.heading) {
      const headingElement = document.createElement("h4");
      headingElement.className = "biography-book-heading";
      headingElement.textContent = section.heading;
      sectionElement.append(headingElement);
    }

    const textElement = document.createElement("p");
    textElement.className = "biography-book-text";
    textElement.textContent = section.text;
    sectionElement.append(textElement);
    contentElement.append(sectionElement);
  }

  return contentElement;
}

function pageFits(
  measurementPage: HTMLDivElement,
  sections: BiographySection[],
) {
  const styles = window.getComputedStyle(measurementPage);
  const paddingBlockStart =
    Number.parseFloat(styles.paddingBlockStart) || 0;
  const paddingBlockEnd = Number.parseFloat(styles.paddingBlockEnd) || 0;
  const paddingInlineStart =
    Number.parseFloat(styles.paddingInlineStart) || 0;
  const paddingInlineEnd = Number.parseFloat(styles.paddingInlineEnd) || 0;
  const contentWidth =
    measurementPage.clientWidth -
    paddingInlineStart -
    paddingInlineEnd;
  const availableHeight =
    measurementPage.clientHeight -
    paddingBlockStart -
    paddingBlockEnd -
    PAGE_FIT_SAFETY_MARGIN;

  if (
    availableHeight <= 0 ||
    contentWidth < MINIMUM_MEASUREMENT_CONTENT_WIDTH
  ) {
    return false;
  }

  const contentElement = renderMeasurementPage(measurementPage, sections);
  return contentElement.getBoundingClientRect().height <= availableHeight;
}

function paragraphBreakOffsets(text: string) {
  const offsets = new Set<number>();
  const paragraphEnding = /\n{2,}/gu;

  for (const match of text.matchAll(paragraphEnding)) {
    offsets.add(match.index + match[0].length);
  }

  offsets.add(text.length);
  return [...offsets].sort((first, second) => first - second);
}

function sentenceBreakOffsets(text: string) {
  const offsets = new Set<number>();
  const sentenceEnding = /[.!؟!…]+(?:["'»”\])]*)?(?:\s+|$)/gu;

  for (const match of text.matchAll(sentenceEnding)) {
    offsets.add(match.index + match[0].length);
  }

  offsets.add(text.length);
  return [...offsets].sort((first, second) => first - second);
}

function wordBreakOffsets(text: string) {
  const offsets = new Set<number>();
  const whitespace = /\s+/gu;

  for (const match of text.matchAll(whitespace)) {
    offsets.add(match.index + match[0].length);
  }

  offsets.add(text.length);
  return [...offsets].sort((first, second) => first - second);
}

function characterBreakOffsets(text: string) {
  const offsets: number[] = [];
  let offset = 0;

  for (const character of text) {
    offset += character.length;
    offsets.push(offset);
  }

  return offsets;
}

function largestFittingPrefix(
  measurementPage: HTMLDivElement,
  currentPage: BiographySection[],
  section: BiographySection,
) {
  const findFittingOffset = (offsets: number[]) => {
    let lower = 0;
    let upper = offsets.length - 1;
    let fittingOffset = 0;

    while (lower <= upper) {
      const middle = Math.floor((lower + upper) / 2);
      const offset = offsets[middle];
      const candidate = [
        ...currentPage,
        { heading: section.heading, text: section.text.slice(0, offset) },
      ];

      if (pageFits(measurementPage, candidate)) {
        fittingOffset = offset;
        lower = middle + 1;
      } else {
        upper = middle - 1;
      }
    }

    return fittingOffset;
  };

  return (
    findFittingOffset(paragraphBreakOffsets(section.text)) ||
    findFittingOffset(sentenceBreakOffsets(section.text)) ||
    findFittingOffset(wordBreakOffsets(section.text)) ||
    findFittingOffset(characterBreakOffsets(section.text))
  );
}

function paginateToFit(
  sections: BiographySection[],
  biography: string,
  measurementPage: HTMLDivElement,
): PaginationResult {
  const pages: BiographySection[][] = [];
  let currentPage: BiographySection[] = [];
  let iterationCount = 0;
  const maximumIterations = biography.length * 2 + sections.length * 2;

  for (const section of sections) {
    let remainingText = section.text;
    let heading = section.heading;

    while (remainingText.length > 0) {
      iterationCount += 1;
      if (iterationCount > maximumIterations) {
        return {
          ok: false,
          reason: "Pagination stopped because its progress guard was exceeded.",
        };
      }

      const remainingSection = { heading, text: remainingText };
      const wholeSectionCandidate = [...currentPage, remainingSection];

      if (pageFits(measurementPage, wholeSectionCandidate)) {
        currentPage = wholeSectionCandidate;
        remainingText = "";
        continue;
      }

      const fittingOffset = largestFittingPrefix(
        measurementPage,
        currentPage,
        remainingSection,
      );

      if (fittingOffset > 0) {
        currentPage.push({
          heading,
          text: remainingText.slice(0, fittingOffset),
        });
        remainingText = remainingText.slice(fittingOffset);
        heading = null;
      } else if (currentPage.length > 0) {
        pages.push(currentPage);
        currentPage = [];
        continue;
      } else if (heading) {
        const headingOnlyPage = [{ heading, text: "" }];
        const bodyOffsetWithoutHeading = largestFittingPrefix(
          measurementPage,
          [],
          { heading: null, text: remainingText },
        );

        if (pageFits(measurementPage, headingOnlyPage) && bodyOffsetWithoutHeading > 0) {
          pages.push(headingOnlyPage);
          heading = null;
          continue;
        }

        return {
          ok: false,
          reason: "The measurement box could not fit one body character with its heading.",
        };
      } else {
        return {
          ok: false,
          reason: "The measurement box could not fit one body character.",
        };
      }

      pages.push(currentPage);
      currentPage = [];
    }
  }

  if (currentPage.length > 0) {
    pages.push(currentPage);
  }

  const reconstructedBiography = pages
    .flat()
    .map(({ text }) => text)
    .join("");

  if (
    pages.length === 0 ||
    reconstructedBiography !== biography ||
    pages.some((page) => !pageFits(measurementPage, page))
  ) {
    return {
      ok: false,
      reason: "Pagination failed its fit or exact-text reconstruction check.",
    };
  }

  return { ok: true, pages };
}

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
