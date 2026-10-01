import type { BiographyConfiguration } from "./biography-config";

export type BiographySection = {
  heading: string | null;
  text: string;
};

export type PaginationResult =
  | { ok: true; pages: BiographySection[][] }
  | { ok: false; reason: string };

export const PAGE_FIT_SAFETY_MARGIN = 4;
export const MINIMUM_MEASUREMENT_CONTENT_WIDTH = 120;
export const MAXIMUM_LAYOUT_RETRIES = 4;

export function sectionBiography(
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

export function paginateToFit(
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
