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
    raise exception 'Uthman import cannot run; missing columns: %', missing_columns;
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
      "personName": "عثمان بن عفان",
      "startYearHijri": 23,
      "endYearHijri": 35
    },
    "instructions": "Map this content to the existing Uthman period_id. Do not create tables, rewrite historical text, add facts, or change coordinates. Preserve approved existing event slugs and Hijri dates from Migration #3."
  },
  "person": {
    "name": "عثمان بن عفان",
    "briefBio": "عثمان بن عفان رضي الله عنه هو عثمان بن عفان بن أبي العاص بن أمية بن عبد شمس بن عبد مناف، القرشي الأموي، أمير المؤمنين وثالث الخلفاء الراشدين. يجتمع نسبه مع نسب النبي محمد ﷺ في عبد مناف. نشأ في مكة في بيت من بيوت بني أمية، وكان قومه من بطون قريش المعروفة بالتجارة والمكانة. اشتغل عثمان بالتجارة، وعُرف بين قريش بالمال والوجاهة، وكانت له خبرة بأسفار التجارة ومعاملات الناس. وتذكر كتب التراجم أنه كان من أهل الحياء والعفة، ولم يكن من أهل اللهو الذي شاع في بعض بيئات الجاهلية. ولا تقدم المصادر المبكرة سجلًا يوميًا متصلًا لشبابه، لكن صورته قبل الإسلام تظهر رجلًا من تجار قريش المعروفين، له مال وصلات واسعة داخل مكة وخارجها.\n\nكان عثمان من السابقين إلى الإسلام. دعاه أبو بكر الصديق رضي الله عنه إلى الإسلام، فاستجاب في مرحلة مبكرة من الدعوة المكية، ودخل بذلك في الجماعة الصغيرة التي آمنت بالنبي ﷺ قبل أن يشتد انتشار الإسلام في مكة. ترتب على إسلامه ما ترتب على إسلام غيره من السابقين من مواجهة ضغط البيئة القرشية، لكنه ثبت على دينه. وتزوج رقية بنت رسول الله ﷺ، فازدادت صلته بالنبي وأهل بيته. ولما اشتد أذى قريش للمسلمين خرج عثمان مع زوجته رقية في الهجرة إلى الحبشة، ثم عاد إلى مكة، وبعد ذلك هاجر إلى المدينة، فجمع بين هجرتين في سبيل المحافظة على دينه.\n\nبعد الهجرة إلى المدينة عاش عثمان في مجتمع المهاجرين والأنصار وشارك في بناء الدولة الجديدة. لم يشهد بدرًا في ميدان القتال لأن زوجته رقية كانت مريضة، وأذن له النبي ﷺ أن يبقى لتمريضها، وضرب له بسهمه وأجره في الغزوة. ماتت رقية في تلك الفترة، ثم زوجه النبي ﷺ بعد ذلك ابنتَه أم كلثوم، ولذلك اشتهر عثمان بلقب ذي النورين لزواجه من ابنتي رسول الله ﷺ. وبعد وفاة أم كلثوم بقيت مكانته وصلته ببيت النبي ظاهرة في كتب السيرة والحديث.\n\nشهد عثمان أحدًا وما بعدها من المشاهد، وكان من الصحابة الذين اعتمد عليهم النبي ﷺ في بعض المهمات. وفي الحديبية سنة 6هـ أرسله النبي إلى مكة للتفاوض مع قريش وإبلاغهم أن المسلمين لم يأتوا للقتال وإنما للعمرة. تأخر عثمان في مكة، وانتشر بين المسلمين خبر أنه قُتل، فدعا النبي ﷺ أصحابه إلى البيعة تحت الشجرة فيما عُرف ببيعة الرضوان. ولما كان عثمان غائبًا وضع النبي ﷺ إحدى يديه على الأخرى في البيعة عنه، ثم ظهر أن خبر قتله لم يكن صحيحًا وعاد إلى المسلمين. وبعد ذلك شهد عثمان فتح مكة وحنينًا وتبوك وغيرها من أحداث السنوات الأخيرة من حياة النبي ﷺ.\n\nبرز إنفاق عثمان في عدد من المواقف. تروي الأحاديث الصحيحة والآثار خبر شرائه بئر رومة وجعلها للمسلمين، كما عُرف بنفقته الكبيرة في تجهيز جيش العسرة عند الاستعداد لغزوة تبوك. ارتبطت هذه المواقف بصورته في المجتمع المدني بوصفه رجلًا ذا مال يستخدم جانبًا منه في مصالح المسلمين. وكان إلى جانب ذلك من كتّاب الوحي، وروى الحديث عن النبي ﷺ، وعُرف بعنايته بالقرآن.\n\nعندما توفي رسول الله ﷺ سنة 11هـ، كان عثمان من كبار الصحابة في المدينة. عاش خلافة أبي بكر ثم خلافة عمر، وشارك في حياة الدولة ومشورتها. وفي أواخر خلافة عمر، بعد أن طُعن سنة 23هـ، جعل عمر أمر اختيار الخليفة في ستة من الصحابة: عثمان وعلي وطلحة والزبير وسعد بن أبي وقاص وعبد الرحمن بن عوف. انتهت المشاورات إلى أن جعل عبد الرحمن بن عوف الاختيار بين عثمان وعلي، وبعد مشاورة واسعة بايع عثمان، ثم بايعه الناس. وبذلك تولى عثمان الخلافة بعد عمر، وبدأت خلافته في أواخر سنة 23هـ واستقر أمرها مع بداية سنة 24هـ.\n\nورث عثمان دولة واسعة امتدت في عهد عمر إلى الشام والعراق ومصر وأجزاء كبيرة من فارس. لذلك لم تبدأ خلافته من نقطة تأسيس جديدة، بل واجهت مهمة إدارة مساحة كبيرة والمحافظة على الفتوح ومتابعة الأقاليم البعيدة. استمرت الجيوش في جبهات متعددة، وتجدد القتال في بعض المناطق التي نقضت العهود أو خرجت عن الطاعة، كما تحركت القوات إلى مناطق أبعد في الشرق والغرب. وتغير عدد من الولاة خلال خلافته، وكان تعيين الولاة وعزلهم من أكثر مسائل الإدارة اتصالًا بما وقع لاحقًا من نقاش واعتراض سياسي.\n\nفي شمال إفريقيا تحرك عبد الله بن سعد بن أبي سرح من مصر إلى إفريقية في سنة 27هـ على المشهور في عدد من كتب التاريخ. واجه المسلمون قوات جرجير في المنطقة التي ارتبطت بسبيطلة، وانتهت الحملة بانتصار المسلمين واتساع نفوذ الدولة غرب مصر. لم يكن ذلك نهاية فتح المغرب، لكنه كان مرحلة مهمة في انتقال العمليات العسكرية إلى إفريقية في خلافة عثمان.\n\nوفي البحر المتوسط وقع تحول مهم. كان معاوية بن أبي سفيان قد طلب الإذن قبل ذلك في ركوب البحر، ثم أذن عثمان بحملة بحرية بشروط تحفظ اختيار المشاركين. خرج المسلمون إلى قبرص، وتذكر المصادر فتحها في سنة 28هـ على قول مشهور. شارك في الحملة عدد من الصحابة، ومنهم عبادة بن الصامت وزوجته أم حرام بنت ملحان. مثّل فتح قبرص توسعًا في قدرة الدولة على العمل البحري إلى جانب الجيوش البرية، وصار البحر المتوسط جبهة عسكرية أكثر حضورًا في تاريخ الدولة الإسلامية.\n\nوفي الشرق استمرت الفتوح في مناطق فارس وما وراءها. تولى عبد الله بن عامر البصرة وتحركت الجيوش في خراسان وفارس ومناطق أخرى، كما تذكر المصادر حملات في طبرستان وأذربيجان وأرمينية. لم تكن هذه الفتوح حملة واحدة يقودها عثمان بنفسه، بل كانت عمليات يقودها الولاة والقادة تحت سلطة الخلافة، وتفاوتت الروايات في تواريخ بعض المدن ومسار السيطرة عليها. ومع اتساع هذه الجبهات زادت المسافات بين المدينة ومراكز الجند الكبرى في الكوفة والبصرة والشام ومصر، وأصبحت إدارة الولاة والأموال والجند أكثر تعقيدًا.\n\nومن أبرز أعمال خلافة عثمان جمع المسلمين على مصحف إمام. كانت الصحف التي جُمع فيها القرآن في عهد أبي بكر قد انتقلت إلى عمر ثم بقيت عند حفصة بنت عمر. ومع اتساع البلاد واختلاط أهل الأمصار ظهرت اختلافات في القراءة أثارت خوف حذيفة بن اليمان من اتساع النزاع. فأرسل عثمان إلى حفصة يطلب الصحف، وكلف لجنة كان في مقدمتها زيد بن ثابت ومعه عبد الله بن الزبير وسعيد بن العاص وعبد الرحمن بن الحارث بن هشام بنسخ مصاحف منها. ثم أُرسلت نسخ إلى الأمصار وأمر بما عداها من الصحف أو المصاحف الخاصة أن يزال حتى لا يتحول اختلاف وجوه القراءة إلى نزاع بين المسلمين. قاعدة هذا المشروع تعتمد سنة 25هـ لهذا الحدث، مع وجود اختلاف في ترتيب الأخبار التاريخية المتعلقة بوقت العمل.\n\nاستمرت كذلك أعمال التوسعة والعمران في الحرمين. تذكر كتب التاريخ توسعة المسجد الحرام في خلافة عثمان، ثم توسعة المسجد النبوي وإعادة بنائه بالحجارة المنقوشة والجص واستعمال أعمدة من الحجارة وسقف من الساج. كانت المدينة ما تزال مقر الخلافة ومركز القرار، على الرغم من أن الثقل العسكري والاقتصادي للدولة صار موزعًا بين أمصار متعددة.\n\nوفي البحر وقعت معركة ذات الصواري، إحدى أشهر الوقائع البحرية في العصر الراشدي. تذكر طائفة من المصادر وقوعها سنة 31هـ، مع وجود أقوال تؤخرها إلى سنوات أخرى. واجه أسطول المسلمين بقيادة عبد الله بن سعد بن أبي سرح قوة بيزنطية كبيرة، وتحول القتال إلى مواجهة شديدة بين السفن، وانتهت بانتصار المسلمين وانسحاب القوة البيزنطية. أظهرت المعركة أن الدولة التي نشأت في بيئة يغلب عليها القتال البري أصبحت قادرة في عهد عثمان على خوض معارك بحرية واسعة في المتوسط.\n\nخلال النصف الثاني من خلافته ازدادت الاعتراضات على بعض الولاة وعلى طريقة إدارة عدد من القضايا. جاءت شكاوى من بعض الأمصار، ووقعت تغييرات في الولاة، ودخلت في النزاع أخبار ودعايات وروايات يصعب التعامل معها جميعًا بدرجة واحدة من الثقة. لذلك لا يصح اختزال السنوات الأخيرة في رواية واحدة بسيطة أو نسبة كل ما وقع إلى سبب منفرد. الثابت أن التوتر السياسي ازداد، وأن جماعات من مصر والكوفة والبصرة قدمت إلى المدينة في سنة 35هـ، وأن الأزمة تطورت من الاعتراض والمفاوضة إلى حصار دار الخليفة.\n\nكان في المدينة عدد من كبار الصحابة وأبنائهم، وعرض بعضهم الدفاع عن عثمان، لكنه لم يرد أن تتحول المدينة إلى قتال واسع بسببه، وأمر من كان يريد الدفاع عنه أن يكف عن القتال في عدد من الروايات. طال الحصار، ومنع عنه في بعض مراحله الوصول المعتاد إلى الماء والخروج. وتذكر المصادر أخبارًا كثيرة عن تفاصيل الحصار وأسماء الداخلين إلى الدار، وهي أخبار متفاوتة في أسانيدها وتفاصيلها؛ ولذلك يكون الأوثق عند العرض العام الاقتصار على ما تتفق عليه الصورة الكبرى: أن جماعة من الخارجين حاصروه في داره، ثم اقتحم بعضهم الدار وقتلوه.\n\nقُتل عثمان رضي الله عنه في المدينة سنة 35هـ وهو في نحو الثانية والثمانين على قول مشهور في عمره، بعد خلافة دامت قرابة اثنتي عشرة سنة. ارتبطت الروايات بقراءته القرآن وقت الهجوم، لكن تفاصيل اللحظات الأخيرة وردت من طرق متعددة متفاوتة. ودُفن في المدينة. كان مقتله نقطة تحول كبرى؛ فلم يكن مجرد انتقال معتاد للخلافة، بل فتح مرحلة من الاضطراب والنزاع الداخلي الذي ظهر مباشرة في خلافة علي بن أبي طالب رضي الله عنه.\n\nامتدت خلافة عثمان من 23هـ إلى 35هـ، وشهدت استمرار اتساع الدولة في شمال إفريقيا وشرق بلاد فارس، وبداية حضور بحري قوي للمسلمين في المتوسط، وجمع الناس على المصحف الإمام، وتوسعات في الحرمين. وفي الوقت نفسه كشفت السنوات الأخيرة عن صعوبة إدارة دولة أصبحت أقاليمها بعيدة ومجتمعاتها متعددة ومراكز القوة فيها موزعة خارج المدينة. لذلك تجمع سيرة خلافته بين اتساع جغرافي وإداري كبير وبين أزمة سياسية انتهت بمقتله، وأثرت أحداثها في المرحلة التالية من تاريخ الخلافة الراشدة."
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
      "key": "sbeitla",
      "name": "سبيطلة",
      "latitude": 35.2333,
      "longitude": 9.1167,
      "coordinateConfidence": "high",
      "note": "المؤشر على مستوى مدينة سبيطلة الحالية في تونس، المرتبطة بحملة إفريقية في خلافة عثمان."
    },
    {
      "key": "cyprus",
      "name": "قبرص",
      "latitude": 35.1264,
      "longitude": 33.4299,
      "coordinateConfidence": "low",
      "note": "نقطة تمثيلية لجزيرة قبرص؛ الحدث متعلق بحملة على الجزيرة وليس بموقع واحد محدد."
    },
    {
      "key": "tabaristan",
      "name": "طبرستان",
      "latitude": 36.45,
      "longitude": 52.35,
      "coordinateConfidence": "low",
      "note": "نقطة تمثيلية للإقليم التاريخي جنوب بحر قزوين، وليست موضعًا واحدًا للفتوح."
    },
    {
      "key": "mediterranean_masts",
      "name": "البحر المتوسط – نطاق ذات الصواري",
      "latitude": 35.0,
      "longitude": 30.0,
      "coordinateConfidence": "low",
      "note": "نقطة تمثيلية تقريبية للمعركة البحرية؛ تحديد موضع معركة ذات الصواري بدقة محل خلاف ولا يمثله مؤشر واحد."
    }
  ],
  "events": [
    {
      "key": "uthman_bayعه",
      "title": "بيعة عثمان بالخلافة",
      "hijriYear": 23,
      "placeKey": "medina",
      "dateConfidence": "high",
      "summary": "بعد طعن عمر بن الخطاب جعل أمر الخلافة شورى في ستة من الصحابة. انتهت المشاورات إلى بيعة عثمان بن عفان، ثم بايعه الناس، فبدأت خلافته في أواخر سنة 23هـ واستقر أمرها مع بداية سنة 24هـ.",
      "significance": "انتقال الخلافة من عمر إلى عثمان عبر مجلس الشورى الذي عينه عمر.",
      "sourceIds": [
        "siyar_uthman",
        "bidaya_uthman_caliphate"
      ]
    },
    {
      "key": "ifriqiya_campaign",
      "title": "حملة إفريقية",
      "hijriYear": 27,
      "placeKey": "sbeitla",
      "dateConfidence": "medium",
      "summary": "تحرك عبد الله بن سعد بن أبي سرح من مصر إلى إفريقية، وواجه المسلمون قوات جرجير في المنطقة المرتبطة بسبيطلة. انتهت الحملة بانتصار المسلمين واتساع عمليات الدولة غرب مصر.",
      "significance": "مرحلة مهمة في امتداد الفتوح الإسلامية إلى شمال إفريقيا في خلافة عثمان.",
      "sourceIds": [
        "bidaya_uthman_caliphate",
        "ifriqiya_source"
      ]
    },
    {
      "key": "conquest_cyprus",
      "title": "فتح قبرص",
      "hijriYear": 28,
      "placeKey": "cyprus",
      "dateConfidence": "medium",
      "summary": "أذن عثمان بحملة بحرية إلى قبرص، فخرج المسلمون بقيادة معاوية بن أبي سفيان ومعهم عدد من الصحابة. يذكر قول مشهور في المصادر أن فتح قبرص كان سنة 28هـ.",
      "significance": "من أبرز بدايات النشاط البحري الإسلامي المنظم في البحر المتوسط.",
      "sourceIds": [
        "bidaya_cyprus",
        "bidaya_uthman_caliphate"
      ]
    },
    {
      "key": "standardization_quran",
      "title": "توحيد المصاحف",
      "hijriYear": 25,
      "placeKey": "medina",
      "dateConfidence": "high",
      "summary": "بعد أن خشي حذيفة بن اليمان من اختلاف أهل الأمصار في القراءة، طلب عثمان الصحف المحفوظة عند حفصة وكلف لجنة بنسخ مصاحف منها، ثم أرسل نسخًا إلى الأمصار. تعتمد قاعدة المشروع سنة 25هـ لهذا الحدث.",
      "significance": "جمع المسلمين على مصحف إمام للحد من النزاع في القراءة مع اتساع الأمصار.",
      "sourceIds": [
        "bukhari_quran_standardization",
        "bidaya_uthman_caliphate"
      ]
    },
    {
      "key": "tabaristan_campaign",
      "title": "الفتوح في طبرستان والمشرق",
      "hijriYear": 30,
      "placeKey": "tabaristan",
      "dateConfidence": "medium",
      "summary": "استمرت في خلافة عثمان العمليات العسكرية شرقًا، وتذكر المصادر في سنة 30هـ فتح طبرستان ضمن سلسلة من الحملات التي شملت مناطق من فارس وخراسان وما حولها.",
      "significance": "استمرار توسع الدولة في الجبهة الشرقية بعد الفتوح الكبرى في عهد عمر.",
      "sourceIds": [
        "bidaya_uthman_caliphate"
      ]
    },
    {
      "key": "battle_masts",
      "title": "معركة ذات الصواري",
      "hijriYear": 31,
      "placeKey": "mediterranean_masts",
      "dateConfidence": "medium",
      "summary": "واجه أسطول المسلمين قوة بيزنطية كبيرة في معركة بحرية شديدة عرفت بذات الصواري. تعتمد هذه الحزمة سنة 31هـ وفق رواية مشهورة، مع وجود أقوال تؤخرها إلى سنوات أخرى.",
      "significance": "إحدى أكبر المعارك البحرية المبكرة، وأظهرت تطور القدرة البحرية للدولة الإسلامية في المتوسط.",
      "sourceIds": [
        "bidaya_masts",
        "kamil_masts"
      ]
    },
    {
      "key": "siege_uthman",
      "title": "حصار عثمان في المدينة",
      "hijriYear": 35,
      "placeKey": "medina",
      "dateConfidence": "high",
      "summary": "بعد تصاعد الاعتراضات السياسية قدمت جماعات من عدد من الأمصار إلى المدينة، وتطورت الأزمة إلى حصار دار عثمان. عرض بعض أهل المدينة الدفاع عنه، لكنه سعى إلى تجنب القتال الواسع بسببه.",
      "significance": "المرحلة الأخيرة من الأزمة السياسية في خلافة عثمان ومقدمة مباشرة لمقتله.",
      "sourceIds": [
        "bidaya_uthman_crisis",
        "siyar_uthman_death"
      ]
    },
    {
      "key": "assassination_uthman",
      "title": "استشهاد عثمان بن عفان",
      "hijriYear": 35,
      "placeKey": "medina",
      "dateConfidence": "high",
      "summary": "انتهى حصار دار عثمان باقتحام جماعة من الخارجين الدار وقتله في المدينة سنة 35هـ. وتختلف الروايات في كثير من تفاصيل اللحظات الأخيرة وأسماء المشاركين.",
      "significance": "نهاية خلافة عثمان وبداية مرحلة من النزاع الداخلي أثرت مباشرة في السنوات التالية من الخلافة الراشدة.",
      "sourceIds": [
        "siyar_uthman_death",
        "bidaya_uthman_crisis"
      ]
    }
  ],
  "sources": [
    {
      "id": "siyar_uthman",
      "title": "سير أعلام النبلاء – سيرة ذي النورين عثمان رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://www.islamweb.net/ar/library/content/60/6486/",
      "type": "classical_biography"
    },
    {
      "id": "bidaya_uthman_caliphate",
      "title": "البداية والنهاية – ملخص خلافة عثمان رضي الله عنه",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/200/18043/",
      "type": "classical_history"
    },
    {
      "id": "bukhari_quran_standardization",
      "title": "صحيح البخاري 4987 – نسخ المصاحف في خلافة عثمان",
      "author": "محمد بن إسماعيل البخاري",
      "url": "https://sunnah.com/bukhari:4987",
      "type": "authenticated_hadith"
    },
    {
      "id": "uthman_well_army",
      "title": "صحيح البخاري 2778 – بئر رومة وتجهيز جيش العسرة",
      "author": "محمد بن إسماعيل البخاري",
      "url": "https://dorar.net/h/HCuSaEpw?osoul=1",
      "type": "authenticated_hadith"
    },
    {
      "id": "ifriqiya_source",
      "title": "البداية والنهاية – غزوة إفريقية في خلافة عثمان",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/index.php?ID=32521&page=listing",
      "type": "classical_history"
    },
    {
      "id": "bidaya_cyprus",
      "title": "البداية والنهاية – فتح قبرص",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/content/59/812/",
      "type": "classical_history"
    },
    {
      "id": "bidaya_masts",
      "title": "البداية والنهاية – غزوة الصواري",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/59/816/",
      "type": "classical_history"
    },
    {
      "id": "kamil_masts",
      "title": "الكامل في التاريخ – غزوة الصواري",
      "author": "عز الدين ابن الأثير",
      "url": "https://www.islamweb.net/ar/library/content/126/477/",
      "type": "classical_history"
    },
    {
      "id": "bidaya_uthman_crisis",
      "title": "البداية والنهاية – أحداث سنة 35هـ وأسباب مقتل عثمان",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/amp/ar/library/content/59/822/",
      "type": "classical_history"
    },
    {
      "id": "siyar_uthman_death",
      "title": "سير أعلام النبلاء – مقتل عثمان رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://islamweb.net/ar/library/content/60/6514/",
      "type": "classical_biography"
    }
  ],
  "personSourceIds": [
    "siyar_uthman",
    "bidaya_uthman_caliphate",
    "uthman_well_army",
    "bukhari_quran_standardization",
    "siyar_uthman_death",
    "bidaya_uthman_crisis"
  ]
}
$json$::jsonb;
  item jsonb;
  source_item jsonb;
  source_alias text;
  place_slug text;
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
     or jsonb_array_length(content -> 'events') <> 8
     or jsonb_array_length(content -> 'sources') <> 10
     or jsonb_array_length(content -> 'personSourceIds') <> 6 then
    raise exception 'Reviewed JSON shape changed: expected 5 places, 8 events, 10 sources, and 6 person sources';
  end if;

  select count(*), min(id)
  into matched_count, resolved_person_id
  from public.people
  where slug = 'uthman-ibn-affan';

  if matched_count <> 1 then
    raise exception 'Expected exactly one person with slug uthman-ibn-affan; found %', matched_count;
  end if;

  select count(*), min(pp.period_id)
  into matched_count, resolved_period_id
  from public.period_people as pp
  where pp.person_id = resolved_person_id
    and pp.role = 'caliph'
    and pp.is_primary = true;

  if matched_count <> 1 then
    raise exception 'Expected exactly one approved primary caliph period for Uthman; found %', matched_count;
  end if;

  if not exists (
    select 1 from public.periods
    where id = resolved_period_id and start_year = 23 and end_year = 35
  ) then
    raise exception 'Uthman period must be the approved 23-35 AH period';
  end if;

  select count(*) into matched_count
  from public.places where slug = 'al-madinah-al-munawwarah';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing place with slug al-madinah-al-munawwarah; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.events where slug = 'standardization-of-the-quran';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing event with slug standardization-of-the-quran; found %', matched_count;
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
      ('sbeitla'),
      ('cyprus'),
      ('tabaristan'),
      ('mediterranean-battle-of-the-masts')
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
      ('pledge-of-allegiance-to-uthman'),
      ('ifriqiya-campaign'),
      ('conquest-of-cyprus'),
      ('tabaristan-campaign'),
      ('battle-of-the-masts'),
      ('siege-of-uthman'),
      ('assassination-of-uthman')
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
      'medina', 'sbeitla', 'cyprus', 'tabaristan', 'mediterranean_masts'
    )
       or place.value ->> 'coordinateConfidence' not in ('high', 'low', 'approximate')
  ) then
    raise exception 'Reviewed JSON contains an unsupported place key or coordinate confidence';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'events') as event(value)
    where event.value ->> 'key' not in (
      'uthman_bayعه', 'ifriqiya_campaign', 'conquest_cyprus',
      'standardization_quran', 'tabaristan_campaign', 'battle_masts',
      'siege_uthman', 'assassination_uthman'
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
      'classical_biography', 'classical_history', 'authenticated_hadith'
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
    raise exception 'Uthman person update affected % rows instead of 1', affected_count;
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'sbeitla' then 'sbeitla'
      when 'cyprus' then 'cyprus'
      when 'tabaristan' then 'tabaristan'
      when 'mediterranean_masts' then 'mediterranean-battle-of-the-masts'
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

    if (item ->> 'key') = 'medina' then
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
      when 'uthman_bayعه' then 'pledge-of-allegiance-to-uthman'
      when 'ifriqiya_campaign' then 'ifriqiya-campaign'
      when 'conquest_cyprus' then 'conquest-of-cyprus'
      when 'standardization_quran' then 'standardization-of-the-quran'
      when 'tabaristan_campaign' then 'tabaristan-campaign'
      when 'battle_masts' then 'battle-of-the-masts'
      when 'siege_uthman' then 'siege-of-uthman'
      when 'assassination_uthman' then 'assassination-of-uthman'
      else null
    end;

    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'sbeitla' then 'sbeitla'
      when 'cyprus' then 'cyprus'
      when 'tabaristan' then 'tabaristan'
      when 'mediterranean_masts' then 'mediterranean-battle-of-the-masts'
      else null
    end;

    -- Migration #3 is authoritative for the existing Quran-standardization event.
    event_year := case item ->> 'key'
      when 'standardization_quran' then 25
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

    if (item ->> 'key') = 'standardization_quran' then
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
      when 'uthman_bayعه' then 'pledge-of-allegiance-to-uthman'
      when 'ifriqiya_campaign' then 'ifriqiya-campaign'
      when 'conquest_cyprus' then 'conquest-of-cyprus'
      when 'standardization_quran' then 'standardization-of-the-quran'
      when 'tabaristan_campaign' then 'tabaristan-campaign'
      when 'battle_masts' then 'battle-of-the-masts'
      when 'siege_uthman' then 'siege-of-uthman'
      when 'assassination_uthman' then 'assassination-of-uthman'
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
  where slug = 'uthman-ibn-affan';
  if matched_count <> 1 then
    raise exception 'Uthman person postcondition failed: found % rows by slug', matched_count;
  end if;

  if (select brief_bio from public.people where id = resolved_person_id)
       is distinct from content #>> '{person,briefBio}' then
    raise exception 'Uthman biography postcondition failed';
  end if;

  select count(*)
  into matched_count
  from public.period_people
  where person_id = resolved_person_id
    and period_id = resolved_period_id
    and role = 'caliph'
    and is_primary = true;
  if matched_count <> 1 then
    raise exception 'Uthman primary period relationship postcondition failed';
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'sbeitla' then 'sbeitla'
      when 'cyprus' then 'cyprus'
      when 'tabaristan' then 'tabaristan'
      when 'mediterranean_masts' then 'mediterranean-battle-of-the-masts'
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
      when 'uthman_bayعه' then 'pledge-of-allegiance-to-uthman'
      when 'ifriqiya_campaign' then 'ifriqiya-campaign'
      when 'conquest_cyprus' then 'conquest-of-cyprus'
      when 'standardization_quran' then 'standardization-of-the-quran'
      when 'tabaristan_campaign' then 'tabaristan-campaign'
      when 'battle_masts' then 'battle-of-the-masts'
      when 'siege_uthman' then 'siege-of-uthman'
      when 'assassination_uthman' then 'assassination-of-uthman'
    end;
    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'sbeitla' then 'sbeitla'
      when 'cyprus' then 'cyprus'
      when 'tabaristan' then 'tabaristan'
      when 'mediterranean_masts' then 'mediterranean-battle-of-the-masts'
    end;
    event_year := case item ->> 'key'
      when 'standardization_quran' then 25
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
      when 'uthman_bayعه' then 'pledge-of-allegiance-to-uthman'
      when 'ifriqiya_campaign' then 'ifriqiya-campaign'
      when 'conquest_cyprus' then 'conquest-of-cyprus'
      when 'standardization_quran' then 'standardization-of-the-quran'
      when 'tabaristan_campaign' then 'tabaristan-campaign'
      when 'battle_masts' then 'battle-of-the-masts'
      when 'siege_uthman' then 'siege-of-uthman'
      when 'assassination_uthman' then 'assassination-of-uthman'
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

  if approved_event_source_count <> 15 then
    raise exception 'Expected 15 approved event_sources relationships; verified %', approved_event_source_count;
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
      raise exception 'Missing approved person_sources relationship: uthman-ibn-affan -> %', source_alias;
    end if;

    approved_person_source_count := approved_person_source_count + 1;
  end loop;

  if approved_person_source_count <> 6 then
    raise exception 'Expected 6 approved person_sources relationships; verified %', approved_person_source_count;
  end if;
end
$import$;

commit;
