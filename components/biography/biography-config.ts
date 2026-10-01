export type SectionBoundary = {
  heading: string | null;
  startsWith: string;
};

export type BiographyConfiguration = {
  boundaries: SectionBoundary[];
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

export const ALI_SECTION_BOUNDARIES: SectionBoundary[] = [
  {
    heading: "النشأة والسبق إلى الإسلام",
    startsWith: "علي بن أبي طالب رضي الله عنه هو علي بن أبي طالب بن عبد المطلب",
  },
  {
    heading: "الهجرة والحياة في المدينة",
    startsWith: "عاش علي مع المسلمين سنوات الدعوة المكية",
  },
  {
    heading: "مع النبي ﷺ",
    startsWith: "شارك علي في عدد كبير من غزوات النبي ﷺ ومشاهده",
  },
  {
    heading: "في عهد الخلفاء الثلاثة",
    startsWith: "عند وفاة رسول الله ﷺ سنة 11هـ",
  },
  {
    heading: "توليه الخلافة",
    startsWith: "استمرت مكانة علي في المدينة خلال خلافة عثمان",
  },
  {
    heading: "وقعة الجمل",
    startsWith: "في سنة 36هـ وقعت وقعة الجمل قرب البصرة",
  },
  {
    heading: "الكوفة وصفين",
    startsWith: "بعد الجمل استقر علي في الكوفة",
  },
  {
    heading: "التحكيم",
    startsWith: "وافق فريق من جيش علي على التحكيم",
  },
  {
    heading: "الخوارج والنهروان",
    startsWith: "خرجت من جيش علي جماعة عُرفت لاحقًا بالخوارج",
  },
  {
    heading: "أحوال الدولة في خلافته",
    startsWith: "أثرت الحروب الداخلية في قدرة الدولة",
  },
  {
    heading: "علمه ومكانته",
    startsWith: "وعلى الرغم من الظروف السياسية والعسكرية الصعبة",
  },
  {
    heading: "استشهاده",
    startsWith: "في سنة 40هـ تآمر نفر من الخوارج",
  },
  {
    heading: "أثر خلافته",
    startsWith: "امتدت خلافة علي من 35هـ إلى 40هـ",
  },
];

export const BIOGRAPHY_CONFIGURATIONS: Record<string, BiographyConfiguration> = {
  "abu-bakr-al-siddiq": {
    boundaries: ABU_BAKR_SECTION_BOUNDARIES,
  },
  "umar-ibn-al-khattab": {
    boundaries: UMAR_SECTION_BOUNDARIES,
  },
  "uthman-ibn-affan": {
    boundaries: UTHMAN_SECTION_BOUNDARIES,
  },
  "ali-ibn-abi-talib": {
    boundaries: ALI_SECTION_BOUNDARIES,
  },
};

export const PERSON_SLUG_BY_NAME: Partial<Record<string, string>> = {
  "أبو بكر الصديق": "abu-bakr-al-siddiq",
  "عمر بن الخطاب": "umar-ibn-al-khattab",
  "عثمان بن عفان": "uthman-ibn-affan",
  "علي بن أبي طالب": "ali-ibn-abi-talib",
};
