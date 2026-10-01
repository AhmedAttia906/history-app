begin;

do $schema_check$
declare
  missing_columns text;
begin
  select string_agg(required.table_name || '.' || required.column_name, ', ' order by required.table_name, required.column_name)
  into missing_columns
  from (
    values
      ('people', 'id'), ('people', 'slug'), ('people', 'name'), ('people', 'brief_bio'),
      ('periods', 'id'), ('periods', 'start_year'), ('periods', 'end_year'),
      ('period_people', 'period_id'), ('period_people', 'person_id'),
      ('period_people', 'role'), ('period_people', 'is_primary'),
      ('places', 'id'), ('places', 'slug'), ('places', 'name'), ('places', 'lat'),
      ('places', 'lng'), ('places', 'coordinate_confidence'), ('places', 'location_note'),
      ('events', 'id'), ('events', 'slug'), ('events', 'period_id'), ('events', 'place_id'),
      ('events', 'title'), ('events', 'description'), ('events', 'significance'),
      ('events', 'start_year'), ('events', 'end_year'),
      ('sources', 'id'), ('sources', 'title'), ('sources', 'url'),
      ('sources', 'source_type'), ('sources', 'author'),
      ('event_sources', 'event_id'), ('event_sources', 'source_id'),
      ('person_sources', 'person_id'), ('person_sources', 'source_id')
  ) as required(table_name, column_name)
  left join information_schema.columns as actual
    on actual.table_schema = 'public'
   and actual.table_name = required.table_name
   and actual.column_name = required.column_name
  where actual.column_name is null;

  if missing_columns is not null then
    raise exception 'Ali import cannot run; missing columns: %', missing_columns;
  end if;
end
$schema_check$;

lock table
  public.people,
  public.period_people,
  public.places,
  public.events,
  public.sources,
  public.event_sources,
  public.person_sources
in share row exclusive mode;

do $import$
declare
  content constant jsonb := $json$
{
  "metadata": {
    "language": "ar",
    "calendar": "hijri",
    "contentStatus": "editorially_researched_needs_domain_review",
    "periodLookup": {
      "personName": "علي بن أبي طالب",
      "startYearHijri": 35,
      "endYearHijri": 40
    },
    "instructions": "Map this content to the existing Ali period_id. Do not create tables, rewrite historical text, add facts, or change coordinates. Preserve approved existing event slugs and Hijri dates from existing migrations."
  },
  "person": {
    "name": "علي بن أبي طالب",
    "briefBio": "علي بن أبي طالب رضي الله عنه هو علي بن أبي طالب بن عبد المطلب بن هاشم بن عبد مناف، ابن عم رسول الله محمد ﷺ، وزوج فاطمة الزهراء رضي الله عنها، وأبو الحسن والحسين رضي الله عنهما. نشأ في مكة من بني هاشم، وتربى في بيت النبي ﷺ في مرحلة من صباه، فكانت صلته به مبكرة وقريبة. وكان من السابقين إلى الإسلام، وتذكر كتب السيرة أنه أسلم وهو صغير السن، فكان من أوائل من آمن بالنبي ﷺ.\n\nعاش علي مع المسلمين سنوات الدعوة المكية وما صاحبها من أذى وضغط من قريش. وعندما أذن للنبي ﷺ بالهجرة إلى المدينة، بقي علي في مكة مدة قصيرة بعد خروجه ليؤدي الأمانات التي كانت عند النبي ﷺ إلى أصحابها، ثم لحق بالمدينة. وبعد الهجرة أصبح من أبرز رجال المجتمع المسلم الجديد، وزوجه النبي ﷺ ابنته فاطمة رضي الله عنها، فكان له منها الحسن والحسين وزينب وأم كلثوم.\n\nشارك علي في عدد كبير من غزوات النبي ﷺ ومشاهده. شهد بدرًا وأحدًا والخندق وغيرها، وعرف بالشجاعة والقوة في القتال. وفي غزوة خيبر أعطاه النبي ﷺ الراية، وارتبط اسمه بفتح الحصن في الروايات المشهورة. كما كان حاضرًا في مراحل مهمة من بناء الدولة في المدينة، واستعمله النبي ﷺ في بعض المهمات، ومنها بعثه إلى اليمن. وتدل الروايات الحديثية والسيرية على قربه من النبي ﷺ ومكانته بين الصحابة.\n\nعند وفاة رسول الله ﷺ سنة 11هـ دخل المسلمون مرحلة اختيار الخليفة، فكانت البيعة لأبي بكر الصديق رضي الله عنه. عاش علي في المدينة خلال خلافة أبي بكر، ثم عمر، ثم عثمان رضي الله عنهم، وكان من كبار الصحابة الذين يرجع إليهم في العلم والمشورة. وفي خلافة عمر كان ضمن أهل الرأي في المدينة، ثم جعله عمر واحدًا من الستة الذين جعل فيهم الشورى لاختيار الخليفة بعده. وانتهت تلك الشورى إلى بيعة عثمان بن عفان رضي الله عنه.\n\nاستمرت مكانة علي في المدينة خلال خلافة عثمان، وفي السنوات الأخيرة من تلك الخلافة تصاعدت الاعتراضات السياسية في عدد من الأمصار حتى انتهت بحصار عثمان وقتله سنة 35هـ. بعد مقتله دخلت المدينة والدولة في أزمة شديدة، وبايع جماعة من المسلمين عليًا بالخلافة. تولى علي الحكم في ظرف مختلف عن انتقالات الخلافة السابقة؛ إذ كانت قضية مقتل عثمان والخلاف حول كيفية التعامل مع المشاركين في الفتنة حاضرة منذ بداية عهده.\n\nبدأت خلافة علي سنة 35هـ، وكان من أكبر التحديات التي واجهته إعادة الاستقرار إلى دولة اتسعت أقاليمها وتعددت مراكز القوة فيها. رأى علي أن تثبيت السلطة وتهدئة الأوضاع يسبقان تنفيذ القصاص في قتلة عثمان، بينما رأى آخرون ضرورة التعجيل بالمطالبة بدم عثمان. أدى اختلاف الاجتهاد السياسي في هذه القضية وغيرها إلى انقسام داخلي لم تعرفه الدولة بهذه الصورة في العهود السابقة.\n\nفي سنة 36هـ وقعت وقعة الجمل قرب البصرة. خرجت عائشة وطلحة والزبير رضي الله عنهم إلى العراق في سياق المطالبة بالإصلاح والنظر في قضية قتلة عثمان، ثم انتهت التطورات إلى مواجهة عسكرية بين الفريقين. قُتل طلحة والزبير في سياق الأحداث، وانتهت المعركة بانتصار جيش علي. عامل علي عائشة رضي الله عنها بما يليق بمكانتها وأعادها إلى المدينة مكرمة. كانت وقعة الجمل من أشد أحداث الفتنة أثرًا؛ لأنها مثلت قتالًا واسعًا بين جماعات من المسلمين والصحابة.\n\nبعد الجمل استقر علي في الكوفة، وصارت مركز حكمه بدل المدينة. كان العراق أقرب إلى الجبهة التي دار فيها النزاع مع معاوية بن أبي سفيان، والي الشام، الذي امتنع عن البيعة لعلي قبل معالجة قضية عثمان. تحرك الفريقان حتى التقيا عند صفين على الفرات سنة 37هـ. دارت مواجهات ومفاوضات ثم اشتد القتال، وانتهى الأمر إلى رفع المصاحف والدعوة إلى التحكيم.\n\nوافق فريق من جيش علي على التحكيم، مع أن جماعة منهم عادت بعد ذلك فرفضته وعدته خطأ. مثّل عليَّ أبو موسى الأشعري في أشهر الروايات المتعلقة بالتحكيم، ومثّل جانب الشام عمرو بن العاص. اختلفت المصادر في تفاصيل التحكيم ونتائجه، ولا يصح بناء صورة المرحلة كلها على الروايات القصصية المتأخرة التي وردت في بعض الكتب. الثابت أن التحكيم لم ينه النزاع السياسي، وأن الانقسام استمر بعد صفين.\n\nخرجت من جيش علي جماعة عُرفت لاحقًا بالخوارج، ورفضت التحكيم ورفعت شعار «لا حكم إلا لله». ناقشهم علي وأرسل إليهم من يحاورهم، ورجع بعضهم، بينما استمرت جماعة منهم في موقفها وارتبط بها اعتداء وقتل. وفي سنة 38هـ قاتلهم علي في النهروان، وانتهت المعركة بهزيمة القوة الرئيسية منهم، لكن فكر الخوارج وجماعاتهم لم ينتهيا بالمعركة.\n\nأثرت الحروب الداخلية في قدرة الدولة على المحافظة على وحدة السلطة في جميع الأقاليم. ظل الشام تحت سلطة معاوية، ووقعت تحولات في مصر وغيرها، بينما بقي مركز علي في العراق. انشغل الجزء الأكبر من خلافته بمحاولة تثبيت الحكم ومعالجة آثار الفتنة، ولذلك تختلف طبيعة عهده عن عهود الفتوح الواسعة التي سبقته.\n\nوعلى الرغم من الظروف السياسية والعسكرية الصعبة، بقي علي معروفًا بالعلم والقضاء والخطابة. نُقلت عنه أقوال وأحكام كثيرة، وكان من الصحابة المعروفين بالفقه والمعرفة بالقرآن والسنة. كما ارتبطت سيرته في الذاكرة الإسلامية بالشجاعة والزهد والقرب من النبي ﷺ، مع ضرورة التمييز بين الأخبار الثابتة وما أضيف إلى سيرته في عصور لاحقة من روايات متفاوتة الصحة.\n\nفي سنة 40هـ تآمر نفر من الخوارج على قتل عدد من قادة الأطراف المتنازعة. ضرب عبد الرحمن بن ملجم عليًا وهو خارج لصلاة الفجر في مسجد الكوفة، فأصيب إصابة قاتلة، ثم توفي متأثرًا بجراحه. وبوفاته انتهت خلافته التي دامت قرابة خمس سنوات، ثم بويع ابنه الحسن رضي الله عنه مدة قصيرة قبل أن يتنازل لمعاوية سنة 41هـ، وهو العام الذي اشتهر بعام الجماعة.\n\nامتدت خلافة علي من 35هـ إلى 40هـ، وكانت مرحلة يغلب عليها التعامل مع نتائج الأزمة التي بدأت في أواخر خلافة عثمان. شهد عهده وقعة الجمل وصفين والتحكيم وظهور الخوارج ومعركة النهروان، وانتقال مركز الخلافة إلى الكوفة. لذلك تمثل خلافته مرحلة أساسية لفهم الانتقال من وحدة الدولة في العقود الأولى إلى الصراعات السياسية التي أثرت في التاريخ الإسلامي بعد العصر الراشدي."
  },
  "places": [
    {
      "key": "medina",
      "name": "المدينة المنورة",
      "latitude": 24.4672,
      "longitude": 39.6111,
      "coordinateConfidence": "high",
      "note": "المؤشر على مستوى المدينة ولا يحدد مبنى بعينه."
    },
    {
      "key": "basra",
      "name": "البصرة",
      "latitude": 30.5085,
      "longitude": 47.7804,
      "coordinateConfidence": "high",
      "note": "المؤشر على مستوى مدينة البصرة الحالية؛ وقعة الجمل ارتبطت بالمنطقة القريبة من البصرة."
    },
    {
      "key": "kufa",
      "name": "الكوفة",
      "latitude": 32.03,
      "longitude": 44.4,
      "coordinateConfidence": "high",
      "note": "المؤشر على مستوى الكوفة التاريخية، التي اتخذها علي مركزًا لخلافته."
    },
    {
      "key": "siffin",
      "name": "صفين",
      "latitude": 35.95,
      "longitude": 39.02,
      "coordinateConfidence": "low",
      "note": "نقطة تقريبية للمنطقة التاريخية المرتبطة بصفين على الفرات؛ التحديد الدقيق للموقع التاريخي تقريبي."
    },
    {
      "key": "nahrawan",
      "name": "النهروان",
      "latitude": 33.3,
      "longitude": 44.75,
      "coordinateConfidence": "low",
      "note": "نقطة تمثيلية تقريبية لمنطقة النهروان التاريخية شرقي بغداد."
    }
  ],
  "events": [
    {
      "key": "ali_bayعه",
      "title": "بيعة علي بالخلافة",
      "hijriYear": 35,
      "placeKey": "medina",
      "dateConfidence": "high",
      "summary": "بعد مقتل عثمان بن عفان في المدينة سنة 35هـ، بويع علي بن أبي طالب بالخلافة في ظرف سياسي مضطرب، وكانت قضية مقتل عثمان وإعادة الاستقرار من أبرز ما واجه عهده منذ بدايته.",
      "significance": "بداية خلافة علي والمرحلة الأخيرة من عصر الخلفاء الراشدين.",
      "sourceIds": [
        "siyar_ali",
        "bidaya_ali_caliphate"
      ]
    },
    {
      "key": "battle_camel",
      "title": "وقعة الجمل",
      "hijriYear": 36,
      "placeKey": "basra",
      "dateConfidence": "high",
      "summary": "وقعت قرب البصرة مواجهة بين جيش علي من جهة والقوة التي كان فيها عائشة وطلحة والزبير رضي الله عنهم من جهة أخرى، في سياق الأزمة التي أعقبت مقتل عثمان. انتهت المعركة بانتصار جيش علي ومقتل طلحة والزبير، وأعاد علي عائشة إلى المدينة مكرمة.",
      "significance": "من أبرز وقائع الفتنة الأولى وأول مواجهة عسكرية واسعة في خلافة علي.",
      "sourceIds": [
        "bidaya_camel",
        "tabari_ali"
      ]
    },
    {
      "key": "kufa_capital",
      "title": "اتخاذ الكوفة مركزًا للخلافة",
      "hijriYear": 36,
      "placeKey": "kufa",
      "dateConfidence": "medium",
      "summary": "بعد وقعة الجمل استقر علي في الكوفة، وصارت مركز إدارته وتحركاته السياسية والعسكرية خلال بقية خلافته.",
      "significance": "انتقال مركز القرار السياسي من المدينة إلى العراق خلال خلافة علي.",
      "sourceIds": [
        "bidaya_ali_caliphate",
        "tabari_ali"
      ]
    },
    {
      "key": "battle_siffin",
      "title": "وقعة صفين",
      "hijriYear": 37,
      "placeKey": "siffin",
      "dateConfidence": "high",
      "summary": "التقى جيش علي وجيش الشام بقيادة معاوية بن أبي سفيان عند صفين، ودارت بينهما مواجهات انتهت بالدعوة إلى التحكيم بعد قتال شديد.",
      "significance": "عمقت صفين الانقسام السياسي وأدت إلى التحكيم ثم إلى انشقاق جماعة من جيش علي.",
      "sourceIds": [
        "bidaya_siffin",
        "tabari_ali"
      ]
    },
    {
      "key": "arbitration",
      "title": "التحكيم بعد صفين",
      "hijriYear": 37,
      "placeKey": "siffin",
      "dateConfidence": "medium",
      "summary": "بعد توقف القتال في صفين اتفق الطرفان على التحكيم. لم يؤد التحكيم إلى إنهاء النزاع السياسي، واختلفت المصادر في كثير من تفاصيل ما جرى ونتائجه.",
      "significance": "استمرار الأزمة السياسية بعد صفين وارتباطها بانشقاق الخوارج عن جيش علي.",
      "sourceIds": [
        "bidaya_siffin",
        "tabari_ali"
      ]
    },
    {
      "key": "battle_nahrawan",
      "title": "معركة النهروان",
      "hijriYear": 38,
      "placeKey": "nahrawan",
      "dateConfidence": "high",
      "summary": "بعد ظهور الخوارج ووقوع اعتداءات من جماعة منهم، قاتلهم علي في النهروان سنة 38هـ، وانتهت المعركة بهزيمة القوة الرئيسية التي واجهته.",
      "significance": "أبرز مواجهة عسكرية بين علي والخوارج خلال خلافته.",
      "sourceIds": [
        "bidaya_nahrawan",
        "tabari_ali"
      ]
    },
    {
      "key": "assassination_ali",
      "title": "استشهاد علي بن أبي طالب",
      "hijriYear": 40,
      "placeKey": "kufa",
      "dateConfidence": "high",
      "summary": "ضرب عبد الرحمن بن ملجم علي بن أبي طالب في مسجد الكوفة وهو خارج لصلاة الفجر، فتوفي متأثرًا بجراحه سنة 40هـ.",
      "significance": "نهاية خلافة علي واقتراب نهاية العصر الراشدي قبل تنازل الحسن بن علي لمعاوية سنة 41هـ.",
      "sourceIds": [
        "siyar_ali_death",
        "bidaya_ali_death"
      ]
    }
  ],
  "sources": [
    {
      "id": "siyar_ali",
      "title": "سير أعلام النبلاء – علي بن أبي طالب رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://www.islamweb.com/ar/library/content/60/6521/",
      "type": "book"
    },
    {
      "id": "bidaya_ali_caliphate",
      "title": "البداية والنهاية – خلافة علي بن أبي طالب رضي الله عنه",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/59/841/",
      "type": "book"
    },
    {
      "id": "tabari_ali",
      "title": "تاريخ الرسل والملوك – أحداث خلافة علي",
      "author": "محمد بن جرير الطبري",
      "url": "https://books.islam-db.com/book/%D8%AA%D8%A7%D8%B1%D9%8A%D8%AE_%D8%A7%D9%84%D8%B7%D8%A8%D8%B1%D9%8A_%D8%AA%D8%A7%D8%B1%D9%8A%D8%AE_%D8%A7%D9%84%D8%B1%D8%B3%D9%84_%D9%88%D8%A7%D9%84%D9%85%D9%84%D9%88%D9%83_%D9%88%D8%B5%D9%84%D9%87_%D8%AA%D8%A7%D8%B1%D9%8A%D8%AE_%D8%A7%D9%84%D8%B7%D8%A8%D8%B1%D9%8A/2447",
      "type": "book"
    },
    {
      "id": "bidaya_camel",
      "title": "البداية والنهاية – وقعة الجمل",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/59/844/",
      "type": "book"
    },
    {
      "id": "bidaya_siffin",
      "title": "البداية والنهاية – وقعة صفين والتحكيم",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/content/59/848/",
      "type": "book"
    },
    {
      "id": "bidaya_nahrawan",
      "title": "البداية والنهاية – وقعة النهروان",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/amp/ar/library/content/59/863/",
      "type": "book"
    },
    {
      "id": "siyar_ali_death",
      "title": "سير أعلام النبلاء – مقتل علي رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://islamweb.net/ar/library/content/60/6534/",
      "type": "book"
    },
    {
      "id": "bidaya_ali_death",
      "title": "البداية والنهاية – مقتل علي بن أبي طالب",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/content/59/868/",
      "type": "book"
    }
  ],
  "personSourceIds": [
    "siyar_ali",
    "bidaya_ali_caliphate",
    "tabari_ali",
    "siyar_ali_death",
    "bidaya_ali_death"
  ]
}
$json$::jsonb;
  item jsonb;
  source_item jsonb;
  source_alias text;
  place_slug text;
  expected_place_slug text;
  place_confidence text;
  event_slug text;
  event_place_slug text;
  event_year integer;
  normalized_source_type text;
  resolved_person_id bigint;
  resolved_period_id bigint;
  resolved_place_id bigint;
  resolved_event_id bigint;
  resolved_source_id bigint;
  matched_count bigint;
  affected_count bigint;
  duplicate_value text;
  approved_event_source_count integer := 0;
  approved_person_source_count integer := 0;
begin
  if jsonb_array_length(content -> 'places') <> 5
     or jsonb_array_length(content -> 'events') <> 7
     or jsonb_array_length(content -> 'sources') <> 8
     or jsonb_array_length(content -> 'personSourceIds') <> 5 then
    raise exception 'Reviewed JSON shape changed: expected 5 places, 7 events, 8 sources, and 5 person sources';
  end if;

  select count(*), min(id)
  into matched_count, resolved_person_id
  from public.people
  where slug = 'ali-ibn-abi-talib';

  if matched_count <> 1 then
    raise exception 'Expected exactly one person with slug ali-ibn-abi-talib; found %', matched_count;
  end if;

  select count(*), min(pp.period_id)
  into matched_count, resolved_period_id
  from public.period_people as pp
  where pp.person_id = resolved_person_id
    and pp.role = 'caliph'
    and pp.is_primary = true;

  if matched_count <> 1 then
    raise exception 'Expected exactly one approved primary caliph period for Ali; found %', matched_count;
  end if;

  if not exists (
    select 1 from public.periods
    where id = resolved_period_id and start_year = 35 and end_year = 40
  ) then
    raise exception 'Ali period must be the approved 35-40 AH period';
  end if;

  foreach expected_place_slug in array array[
    'al-madinah-al-munawwarah',
    'al-basrah',
    'al-kufah'
  ] loop
    select count(*) into matched_count
    from public.places where slug = expected_place_slug;
    if matched_count <> 1 then
      raise exception 'Expected exactly one existing place with slug %; found %', expected_place_slug, matched_count;
    end if;
  end loop;

  select count(*) into matched_count
  from public.events where slug = 'battle-of-the-camel';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing event with slug battle-of-the-camel; found %', matched_count;
  end if;

  select duplicated.alias
  into duplicate_value
  from (
    select value ->> 'id' as alias
    from jsonb_array_elements(content -> 'sources')
    group by value ->> 'id'
    having count(*) > 1
  ) as duplicated
  limit 1;
  if duplicate_value is not null then
    raise exception 'Duplicate source alias in reviewed JSON: %', duplicate_value;
  end if;

  duplicate_value := null;
  select duplicated.place_key
  into duplicate_value
  from (
    select value ->> 'key' as place_key
    from jsonb_array_elements(content -> 'places')
    group by value ->> 'key'
    having count(*) > 1
  ) as duplicated
  limit 1;
  if duplicate_value is not null then
    raise exception 'Duplicate place key (and therefore proposed slug) in reviewed JSON: %', duplicate_value;
  end if;

  duplicate_value := null;
  select duplicated.event_key
  into duplicate_value
  from (
    select value ->> 'key' as event_key
    from jsonb_array_elements(content -> 'events')
    group by value ->> 'key'
    having count(*) > 1
  ) as duplicated
  limit 1;
  if duplicate_value is not null then
    raise exception 'Duplicate event key (and therefore proposed slug) in reviewed JSON: %', duplicate_value;
  end if;

  duplicate_value := null;
  select proposed.slug
  into duplicate_value
  from (
    values
      ('siffin'),
      ('al-nahrawan')
  ) as proposed(slug)
  group by proposed.slug
  having count(*) > 1
  limit 1;
  if duplicate_value is not null then
    raise exception 'Duplicate approved new place slug: %', duplicate_value;
  end if;

  duplicate_value := null;
  select proposed.slug
  into duplicate_value
  from (
    values
      ('pledge-of-allegiance-to-ali'),
      ('kufa-as-caliphate-center'),
      ('battle-of-siffin'),
      ('arbitration-after-siffin'),
      ('battle-of-al-nahrawan'),
      ('assassination-of-ali')
  ) as proposed(slug)
  group by proposed.slug
  having count(*) > 1
  limit 1;
  if duplicate_value is not null then
    raise exception 'Duplicate approved new event slug: %', duplicate_value;
  end if;

  duplicate_value := null;
  select duplicated.url
  into duplicate_value
  from (
    select value ->> 'url' as url
    from jsonb_array_elements(content -> 'sources')
    group by value ->> 'url'
    having count(*) > 1
  ) as duplicated
  limit 1;
  if duplicate_value is not null then
    raise exception 'Duplicate source URL in reviewed JSON: %', duplicate_value;
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'sources') as source(value)
    where nullif(btrim(source.value ->> 'url'), '') is null
  ) then
    raise exception 'Reviewed JSON contains an empty source URL';
  end if;

  duplicate_value := null;
  select sources.url
  into duplicate_value
  from public.sources
  where url in (
    select value ->> 'url' from jsonb_array_elements(content -> 'sources')
  )
  group by sources.url
  having count(*) > 1
  limit 1;
  if duplicate_value is not null then
    raise exception 'Existing sources are not unique by URL: %', duplicate_value;
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'places') as place(value)
    where place.value ->> 'key' not in (
      'medina', 'basra', 'kufa', 'siffin', 'nahrawan'
    )
       or place.value ->> 'coordinateConfidence' not in ('high', 'low', 'approximate')
  ) then
    raise exception 'Reviewed JSON contains an unsupported place key or coordinate confidence';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'events') as event(value)
    where event.value ->> 'key' not in (
      'ali_bayعه', 'battle_camel', 'kufa_capital', 'battle_siffin',
      'arbitration', 'battle_nahrawan', 'assassination_ali'
    )
       or not exists (
         select 1
         from jsonb_array_elements(content -> 'places') as place(value)
         where place.value ->> 'key' = event.value ->> 'placeKey'
       )
  ) then
    raise exception 'Reviewed JSON contains an unsupported event key or unresolved placeKey';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'sources') as source(value)
    where source.value ->> 'type' not in (
      'book'
    )
  ) then
    raise exception 'Reviewed JSON contains an unsupported source type';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'events') as event(value)
    cross join lateral jsonb_array_elements_text(event.value -> 'sourceIds') as reference(alias)
    where not exists (
      select 1
      from jsonb_array_elements(content -> 'sources') as source(value)
      where source.value ->> 'id' = reference.alias
    )
  ) then
    raise exception 'An event references an unknown source alias';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'events') as event(value)
    cross join lateral jsonb_array_elements_text(event.value -> 'sourceIds') as reference(alias)
    group by event.value ->> 'key', reference.alias
    having count(*) > 1
  ) then
    raise exception 'An event contains a duplicate source alias relationship';
  end if;

  if exists (
    select 1
    from jsonb_array_elements_text(content -> 'personSourceIds') as reference(alias)
    where not exists (
      select 1
      from jsonb_array_elements(content -> 'sources') as source(value)
      where source.value ->> 'id' = reference.alias
    )
  ) then
    raise exception 'personSourceIds contains an unknown source alias';
  end if;

  if exists (
    select 1
    from jsonb_array_elements_text(content -> 'personSourceIds') as reference(alias)
    group by reference.alias
    having count(*) > 1
  ) then
    raise exception 'personSourceIds contains a duplicate source alias relationship';
  end if;

  update public.people
  set name = content #>> '{person,name}',
      brief_bio = content #>> '{person,briefBio}'
  where id = resolved_person_id;
  get diagnostics affected_count = row_count;
  if affected_count <> 1 then
    raise exception 'Ali person update affected % rows instead of 1', affected_count;
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'basra' then 'al-basrah'
      when 'kufa' then 'al-kufah'
      when 'siffin' then 'siffin'
      when 'nahrawan' then 'al-nahrawan'
      else null
    end;

    place_confidence := case item ->> 'coordinateConfidence'
      when 'high' then 'confirmed'
      when 'low' then 'approximate'
      when 'approximate' then 'approximate'
      else null
    end;

    if place_slug is null or place_confidence is null then
      raise exception 'Unsupported place key or coordinate confidence: % / %',
        item ->> 'key', item ->> 'coordinateConfidence';
    end if;

    if (item ->> 'key') in ('medina', 'basra', 'kufa') then
      update public.places
      set name = item ->> 'name',
          lat = (item ->> 'latitude')::double precision,
          lng = (item ->> 'longitude')::double precision,
          coordinate_confidence = place_confidence,
          location_note = item ->> 'note'
      where slug = place_slug;
      get diagnostics affected_count = row_count;
      if affected_count <> 1 then
        raise exception 'Existing place % update affected % rows instead of 1', place_slug, affected_count;
      end if;
    else
      -- This collision check is intentionally immediately before each insert/upsert.
      select count(*) into matched_count
      from public.places
      where slug = place_slug and name is distinct from item ->> 'name';
      if matched_count > 0 then
        raise exception 'New place slug % already belongs to a different record', place_slug;
      end if;

      select count(*) into matched_count
      from public.places
      where name = item ->> 'name' and slug is distinct from place_slug;
      if matched_count > 0 then
        raise exception 'New place name % already exists under another slug', item ->> 'name';
      end if;

      insert into public.places (
        slug, name, lat, lng, coordinate_confidence, location_note
      ) values (
        place_slug,
        item ->> 'name',
        (item ->> 'latitude')::double precision,
        (item ->> 'longitude')::double precision,
        place_confidence,
        item ->> 'note'
      )
      on conflict (slug) do update
      set name = excluded.name,
          lat = excluded.lat,
          lng = excluded.lng,
          coordinate_confidence = excluded.coordinate_confidence,
          location_note = excluded.location_note;
    end if;
  end loop;

  for item in select value from jsonb_array_elements(content -> 'events') loop
    event_slug := case item ->> 'key'
      when 'ali_bayعه' then 'pledge-of-allegiance-to-ali'
      when 'battle_camel' then 'battle-of-the-camel'
      when 'kufa_capital' then 'kufa-as-caliphate-center'
      when 'battle_siffin' then 'battle-of-siffin'
      when 'arbitration' then 'arbitration-after-siffin'
      when 'battle_nahrawan' then 'battle-of-al-nahrawan'
      when 'assassination_ali' then 'assassination-of-ali'
      else null
    end;

    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'basra' then 'al-basrah'
      when 'kufa' then 'al-kufah'
      when 'siffin' then 'siffin'
      when 'nahrawan' then 'al-nahrawan'
      else null
    end;

    -- Migration #3 is authoritative for the existing Battle of the Camel event.
    event_year := case item ->> 'key'
      when 'battle_camel' then 36
      else (item ->> 'hijriYear')::integer
    end;

    if event_slug is null or event_place_slug is null then
      raise exception 'Unsupported event or place key: % / %', item ->> 'key', item ->> 'placeKey';
    end if;

    select count(*), min(id)
    into matched_count, resolved_place_id
    from public.places
    where slug = event_place_slug;
    if matched_count <> 1 then
      raise exception 'Expected exactly one event place with slug %; found %', event_place_slug, matched_count;
    end if;

    if (item ->> 'key') = 'battle_camel' then
      update public.events
      set period_id = resolved_period_id,
          place_id = resolved_place_id,
          title = item ->> 'title',
          description = item ->> 'summary',
          significance = item ->> 'significance',
          start_year = event_year,
          end_year = null
      where slug = event_slug;
      get diagnostics affected_count = row_count;
      if affected_count <> 1 then
        raise exception 'Existing event % update affected % rows instead of 1', event_slug, affected_count;
      end if;
    else
      -- This collision check is intentionally immediately before each insert/upsert.
      select count(*) into matched_count
      from public.events
      where slug = event_slug and title is distinct from item ->> 'title';
      if matched_count > 0 then
        raise exception 'New event slug % already belongs to a different record', event_slug;
      end if;

      insert into public.events (
        slug, period_id, place_id, title, description,
        significance, start_year, end_year
      ) values (
        event_slug, resolved_period_id, resolved_place_id, item ->> 'title', item ->> 'summary',
        item ->> 'significance', event_year, null
      )
      on conflict (slug) do update
      set period_id = excluded.period_id,
          place_id = excluded.place_id,
          title = excluded.title,
          description = excluded.description,
          significance = excluded.significance,
          start_year = excluded.start_year,
          end_year = excluded.end_year;
    end if;
  end loop;

  for item in select value from jsonb_array_elements(content -> 'sources') loop
    normalized_source_type := case item ->> 'type'
      when 'book' then 'book'
      when 'classical_biography' then 'book'
      when 'classical_history' then 'book'
      when 'authenticated_hadith' then 'hadith'
      when 'hadith_commentary' then 'hadith'
      when 'classical_sira' then 'book'
      when 'quran' then 'other'
      when 'other' then 'other'
      else null
    end;

    if normalized_source_type is null then
      raise exception 'Unsupported source type for alias %: %', item ->> 'id', item ->> 'type';
    end if;

    update public.sources
    set title = item ->> 'title',
        author = item ->> 'author',
        source_type = normalized_source_type
    where url = item ->> 'url';
    get diagnostics affected_count = row_count;

    if affected_count = 0 then
      insert into public.sources (title, author, url, source_type)
      values (item ->> 'title', item ->> 'author', item ->> 'url', normalized_source_type);
    elsif affected_count <> 1 then
      raise exception 'Source URL % matched % rows instead of at most 1', item ->> 'url', affected_count;
    end if;
  end loop;

  for item in select value from jsonb_array_elements(content -> 'events') loop
    event_slug := case item ->> 'key'
      when 'ali_bayعه' then 'pledge-of-allegiance-to-ali'
      when 'battle_camel' then 'battle-of-the-camel'
      when 'kufa_capital' then 'kufa-as-caliphate-center'
      when 'battle_siffin' then 'battle-of-siffin'
      when 'arbitration' then 'arbitration-after-siffin'
      when 'battle_nahrawan' then 'battle-of-al-nahrawan'
      when 'assassination_ali' then 'assassination-of-ali'
    end;

    select id into resolved_event_id from public.events where slug = event_slug;

    for source_alias in select jsonb_array_elements_text(item -> 'sourceIds') loop
      select value into source_item
      from jsonb_array_elements(content -> 'sources')
      where value ->> 'id' = source_alias;
      if source_item is null then
        raise exception 'Event % references unknown source alias %', event_slug, source_alias;
      end if;

      select count(*), min(id)
      into matched_count, resolved_source_id
      from public.sources
      where url = source_item ->> 'url';
      if matched_count <> 1 then
        raise exception 'Source alias % resolved to % database rows', source_alias, matched_count;
      end if;

      insert into public.event_sources (event_id, source_id)
      values (resolved_event_id, resolved_source_id)
      on conflict (event_id, source_id) do nothing;
    end loop;
  end loop;

  for source_alias in select jsonb_array_elements_text(content -> 'personSourceIds') loop
    select value into source_item
    from jsonb_array_elements(content -> 'sources')
    where value ->> 'id' = source_alias;
    if source_item is null then
      raise exception 'Person source alias was not found in reviewed JSON: %', source_alias;
    end if;

    select count(*), min(id)
    into matched_count, resolved_source_id
    from public.sources
    where url = source_item ->> 'url';
    if matched_count <> 1 then
      raise exception 'Person source alias % resolved to % database rows', source_alias, matched_count;
    end if;

    insert into public.person_sources (person_id, source_id)
    values (resolved_person_id, resolved_source_id)
    on conflict (person_id, source_id) do nothing;
  end loop;

  select count(*), min(id)
  into matched_count, resolved_person_id
  from public.people
  where slug = 'ali-ibn-abi-talib';
  if matched_count <> 1 then
    raise exception 'Ali person postcondition failed: found % rows by slug', matched_count;
  end if;

  if (select brief_bio from public.people where id = resolved_person_id)
       is distinct from content #>> '{person,briefBio}' then
    raise exception 'Ali biography postcondition failed';
  end if;

  select count(*)
  into matched_count
  from public.period_people
  where person_id = resolved_person_id
    and period_id = resolved_period_id
    and role = 'caliph'
    and is_primary = true;
  if matched_count <> 1 then
    raise exception 'Ali primary period relationship postcondition failed';
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'basra' then 'al-basrah'
      when 'kufa' then 'al-kufah'
      when 'siffin' then 'siffin'
      when 'nahrawan' then 'al-nahrawan'
    end;
    place_confidence := case item ->> 'coordinateConfidence'
      when 'high' then 'confirmed'
      when 'low' then 'approximate'
      when 'approximate' then 'approximate'
    end;

    if not exists (
      select 1 from public.places
      where slug = place_slug
        and name = item ->> 'name'
        and lat = (item ->> 'latitude')::double precision
        and lng = (item ->> 'longitude')::double precision
        and coordinate_confidence = place_confidence
        and location_note = item ->> 'note'
    ) then
      raise exception 'Place postcondition failed for slug %', place_slug;
    end if;
  end loop;

  for item in select value from jsonb_array_elements(content -> 'events') loop
    event_slug := case item ->> 'key'
      when 'ali_bayعه' then 'pledge-of-allegiance-to-ali'
      when 'battle_camel' then 'battle-of-the-camel'
      when 'kufa_capital' then 'kufa-as-caliphate-center'
      when 'battle_siffin' then 'battle-of-siffin'
      when 'arbitration' then 'arbitration-after-siffin'
      when 'battle_nahrawan' then 'battle-of-al-nahrawan'
      when 'assassination_ali' then 'assassination-of-ali'
    end;
    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'basra' then 'al-basrah'
      when 'kufa' then 'al-kufah'
      when 'siffin' then 'siffin'
      when 'nahrawan' then 'al-nahrawan'
    end;
    event_year := case item ->> 'key'
      when 'battle_camel' then 36
      else (item ->> 'hijriYear')::integer
    end;

    if not exists (
      select 1
      from public.events as event
      join public.places as place on place.id = event.place_id
      where event.slug = event_slug
        and event.period_id = resolved_period_id
        and place.slug = event_place_slug
        and event.title = item ->> 'title'
        and event.description = item ->> 'summary'
        and event.significance = item ->> 'significance'
        and event.start_year = event_year
        and event.end_year is null
    ) then
      raise exception 'Event postcondition failed for slug %', event_slug;
    end if;
  end loop;

  for item in select value from jsonb_array_elements(content -> 'sources') loop
    normalized_source_type := case item ->> 'type'
      when 'book' then 'book'
      when 'classical_biography' then 'book'
      when 'classical_history' then 'book'
      when 'authenticated_hadith' then 'hadith'
      when 'hadith_commentary' then 'hadith'
      when 'classical_sira' then 'book'
      when 'quran' then 'other'
      when 'other' then 'other'
    end;

    select count(*)
    into matched_count
    from public.sources
    where url = item ->> 'url';
    if matched_count <> 1 then
      raise exception 'Source URL postcondition failed for alias %: found % rows', item ->> 'id', matched_count;
    end if;

    if not exists (
      select 1 from public.sources
      where url = item ->> 'url'
        and title = item ->> 'title'
        and author is not distinct from item ->> 'author'
        and sources.source_type = normalized_source_type
    ) then
      raise exception 'Source postcondition failed for alias %', item ->> 'id';
    end if;
  end loop;

  for item in select value from jsonb_array_elements(content -> 'events') loop
    event_slug := case item ->> 'key'
      when 'ali_bayعه' then 'pledge-of-allegiance-to-ali'
      when 'battle_camel' then 'battle-of-the-camel'
      when 'kufa_capital' then 'kufa-as-caliphate-center'
      when 'battle_siffin' then 'battle-of-siffin'
      when 'arbitration' then 'arbitration-after-siffin'
      when 'battle_nahrawan' then 'battle-of-al-nahrawan'
      when 'assassination_ali' then 'assassination-of-ali'
    end;

    for source_alias in select jsonb_array_elements_text(item -> 'sourceIds') loop
      select value into source_item
      from jsonb_array_elements(content -> 'sources')
      where value ->> 'id' = source_alias;

      select id into resolved_source_id
      from public.sources
      where url = source_item ->> 'url';

      if not exists (
        select 1
        from public.event_sources as relationship
        join public.events as event on event.id = relationship.event_id
        where event.slug = event_slug
          and relationship.source_id = resolved_source_id
      ) then
        raise exception 'Missing approved event_sources relationship: % -> %', event_slug, source_alias;
      end if;

      approved_event_source_count := approved_event_source_count + 1;
    end loop;
  end loop;

  if approved_event_source_count <> 14 then
    raise exception 'Expected 14 approved event_sources relationships; verified %', approved_event_source_count;
  end if;

  for source_alias in select jsonb_array_elements_text(content -> 'personSourceIds') loop
    select value into source_item
    from jsonb_array_elements(content -> 'sources')
    where value ->> 'id' = source_alias;

    select id into resolved_source_id
    from public.sources
    where url = source_item ->> 'url';

    if not exists (
      select 1
      from public.person_sources
      where person_id = resolved_person_id
        and source_id = resolved_source_id
    ) then
      raise exception 'Missing approved person_sources relationship: ali-ibn-abi-talib -> %', source_alias;
    end if;

    approved_person_source_count := approved_person_source_count + 1;
  end loop;

  if approved_person_source_count <> 5 then
    raise exception 'Expected 5 approved person_sources relationships; verified %', approved_person_source_count;
  end if;
end
$import$;

commit;
