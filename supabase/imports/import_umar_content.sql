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
    raise exception 'Umar import cannot run; missing columns: %', missing_columns;
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
      "personName": "عمر بن الخطاب",
      "startYearHijri": 13,
      "endYearHijri": 23
    },
    "instructions": "Map this content to the existing Umar period_id. Do not create tables, rewrite historical text, add facts, or change coordinates. Preserve approved existing event slugs and Hijri dates from Migration #3."
  },
  "person": {
    "name": "عمر بن الخطاب",
    "briefBio": "عمر بن الخطاب رضي الله عنه هو عمر بن الخطاب بن نفيل بن عبد العزى بن رياح بن قرط بن رزاح بن عدي بن كعب بن لؤي، القرشي العدوي، أبو حفص. يجتمع نسبه مع نسب النبي محمد ﷺ في كعب بن لؤي. نشأ في مكة في بني عدي، وهم بطن من بطون قريش، في بيئة قريش قبل الإسلام بما فيها من تجارة وأسفار وعصبية قبلية وصلات بين البطون. وكان أبوه الخطاب بن نفيل من رجال قومه، وأمه حنتمة بنت هاشم بن المغيرة المخزومية على ما ذكره جماعة من أهل النسب، وقيل في اسم أبيها غير ذلك. تعلم عمر القراءة في زمن كانت الكتابة فيه محدودة الانتشار بين العرب، وعمل في شبابه ورعى الإبل، ثم اشتغل بالتجارة، فخرج في رحلات قريش وعرف أحوال الناس والأسواق. وكان لقريش نظامها في توزيع بعض الوظائف بين بطونها، وذكرت كتب الأخبار أن لبني عدي شأنًا في السفارة وما يتصل بالمفاخرة والمنازعة بين القبائل. وكان بنو عدي أقل عددًا من بعض البطون القرشية الكبرى، لكنهم كانوا جزءًا من شبكة القرابة والتحالف التي قامت عليها مكة. وفي ذلك المجتمع عرف عمر أنساب قريش ووجوهها، وشهد ما كان بين القبائل من منافسة واتصال. وكانت رحلات التجارة تخرج برجال مكة إلى الشام وغيرها، فتضعهم أمام مدن وأسواق ونظم تختلف عن حياة الحجاز. ولا تسعف المصادر المبكرة بتفاصيل متصلة عن كل سنة من شبابه، ولذلك لا يمكن رسم صورة يومية دقيقة لتلك المرحلة، غير أن ما تفرق في كتب التراجم يضعه في حياة قريش العامة قبل البعثة، ثم ينقله مع ظهور الإسلام إلى الصراع الذي دار في مكة حول الدعوة الجديدة.\n\nحين بُعث النبي محمد ﷺ في مكة، كان عمر في أول أمره على دين قومه، ووقف من الدعوة الجديدة موقف المعارض لها. وكانت قريش ترى في انتشار الإسلام خروجًا على ما ألفته من دين الآباء ونظام المجتمع، فاشتد أذى المسلمين، وكان عمر واحدًا ممن عارضوا الإسلام قبل أن يسلم. ثم وقع التحول الذي غيّر بقية حياته. تروي كتب السيرة أخبارًا متعددة في تفاصيل إسلامه، وأشهرها قصة توجهه إلى النبي ﷺ ثم مروره بأخته فاطمة بنت الخطاب وزوجها سعيد بن زيد وسماعه شيئًا من القرآن، غير أن طرق هذه التفاصيل ليست في درجة واحدة من الثبوت؛ ولذلك يبقى الثابت أن عمر أسلم في مكة في السنوات الأولى للدعوة، وأن إسلامه كان قبل الهجرة بسنوات. وجاء في الحديث أن النبي ﷺ دعا الله أن يعز الإسلام بأحب الرجلين إليه من عمر بن الخطاب أو أبي جهل بن هشام، فكان عمر ممن دخلوا في الإسلام في تلك المرحلة.\n\nما إن أسلم عمر حتى صار في جماعة المسلمين بعد أن كان في صف معارضيهم، وظهر أثر انتقال رجل من بني عدي له مكانته وقوته إلى الدعوة الجديدة. وتذكر الروايات أن المسلمين ازدادوا بإسلامه قدرة على إظهار بعض شعائرهم، وإن كانت التفاصيل المشهورة في كيفية خروجهم وصلاتهم عند الكعبة متفاوتة في أسانيدها. وظل المسلمون مع ذلك يواجهون أذى قريش، ثم أذن النبي ﷺ لأصحابه بالهجرة إلى يثرب. وفي هجرة عمر اشتهرت قصة خروجه متحديًا قريشًا عند الكعبة، إلا أن إسنادها محل كلام عند أهل الحديث؛ أما ما رواه ابن إسحاق عن عمر نفسه فيذكر أنه اتعد مع عياش بن أبي ربيعة وهشام بن العاص عند موضع خارج مكة، فخرج عمر وعياش ووصلَا إلى المدينة، بينما حُبس هشام عن الهجرة.\n\nاستقر عمر في المدينة، ودخل مع المسلمين مرحلة جديدة انتقل فيها الإسلام من جماعة مستضعفة في مكة إلى مجتمع له نظامه وعهوده وغزواته. شهد عمر بدرًا وأحدًا والخندق وسائر المشاهد الكبرى مع رسول الله ﷺ، وكان حاضرًا في عدد من المواقف التي حفظتها كتب الحديث والسيرة. وفي صلح الحديبية سنة 6هـ، لما قبل النبي ﷺ شروط الصلح مع قريش، اشتد الأمر على بعض المسلمين، وكان عمر ممن راجعوا النبي ﷺ وأبا بكر في ذلك، ثم مضت الأيام وظهر للمسلمين ما ترتب على الصلح من فتح أبواب الدعوة والاتصال بالقبائل. وكان عمر كذلك ممن عُرفت لهم آراء نزل القرآن موافقًا لبعضها؛ ففي الصحيح أنه أشار باتخاذ مقام إبراهيم مصلى، وبالحجاب لأمهات المؤمنين، ووردت روايات صحيحة في موافقات أخرى. وفي المدينة آخى النبي ﷺ بين أصحابه على ما تذكره كتب السيرة، وتكون حول المسجد مجتمع المهاجرين والأنصار الذي عاش عمر في وسطه بقية حياة النبي. ولم يكن حضوره مقتصرًا على القتال؛ فقد دخل في المشورة، وشهد نزول الأحكام وتغير أحوال المجتمع عامًا بعد عام. وتزوج النبي ﷺ ابنته حفصة بعد وفاة زوجها خنيس بن حذافة، فصارت حفصة من أمهات المؤمنين، وزادت بذلك صلة عمر ببيت النبي ﷺ. وعندما خرج المسلمون إلى مكة في عمرة الحديبية ثم عادوا في العام التالي، ثم جاء فتح مكة في سنة 8هـ، كان عمر في الجيش الذي دخل البلد الذي خرج منه مهاجرًا قبل ذلك بسنوات. وبعد الفتح شهد حنينًا وما تلاها، ثم خرج مع النبي ﷺ إلى تبوك في السنة التاسعة، وظل في المدينة إلى أن مرض رسول الله ﷺ مرضه الأخير.\n\nوعندما توفي رسول الله ﷺ سنة 11هـ، كان وقع الخبر شديدًا على أهل المدينة. اشتد على عمر تصديق موت النبي ﷺ في اللحظات الأولى، حتى جاء أبو بكر الصديق رضي الله عنه، فدخل على النبي ثم خرج إلى الناس وتلا قول الله تعالى: {وما محمد إلا رسول قد خلت من قبله الرسل}. عندها استقر الخبر في نفوس الناس. ثم اجتمع الأنصار في سقيفة بني ساعدة، ولحق بهم أبو بكر وعمر وأبو عبيدة بن الجراح، وجرى النقاش في أمر من يلي شؤون المسلمين. انتهى الاجتماع ببيعة أبي بكر، وكان عمر من أوائل من بايعوه ودعا الناس إلى بيعته.\n\nفي خلافة أبي بكر كان عمر من أقرب من يشاوره الخليفة في القضايا العامة. وبعد معركة اليمامة وكثرة القتل في قراء القرآن، خشي عمر أن يذهب شيء من القرآن بموت الحفاظ، فأشار على أبي بكر بجمعه في صحف. تردد أبو بكر أول الأمر في فعل شيء لم يفعله النبي ﷺ، ثم شرح الله صدره لذلك، وكُلّف زيد بن ثابت بجمع القرآن. بقيت تلك الصحف عند أبي بكر، ثم صارت إلى عمر بعد وفاته، ثم حفظتها حفصة بنت عمر رضي الله عنها، وكانت بعد ذلك من الأصول التي رجع إليها المسلمون حين نُسخت المصاحف في خلافة عثمان.\n\nلما مرض أبو بكر في سنة 13هـ، شاور عددًا من الصحابة فيمن يلي الأمر بعده، ثم عهد بالخلافة إلى عمر بن الخطاب. توفي أبو بكر، وبويع عمر، فبدأت خلافة امتدت نحو عشر سنين، من سنة 13هـ إلى أواخر سنة 23هـ. وكان المسلمون عند توليه قد خرجوا من حروب الردة، وبدأت جيوشهم تتحرك في العراق والشام. فانتقلت إلى عمر دولة اتسع ميدانها العسكري خارج الجزيرة، وصار عليه أن يتابع جبهات متباعدة وأن ينظم ما يدخل تحت سلطان المسلمين من مدن وأقاليم وسكان. وكانت الأيام الأولى من خلافته متصلة بما بدأ في عهد أبي بكر؛ فالجيوش التي خرجت إلى الشام والعراق لم تبدأ من فراغ عند انتقال الخلافة، وإنما واصل عمر متابعة جبهات كانت قد فتحت بالفعل. ومع ذلك تغير حجم المسؤولية سريعًا. فكل مدينة تدخل تحت سلطان المسلمين كانت تفتح مسائل جديدة: من يتولى الجند، ومن يقضي بين الناس، وكيف تجمع الأموال، وما الذي يبقى من الأرض في أيدي أهلها، وكيف تصل أوامر المدينة إلى قادة تفصل بينهم وبين الخليفة مسافات طويلة. ولهذا كثرت الكتب بين عمر وقادته وولاته، وصارت المدينة مركزًا تصل إليه أخبار الشام والعراق والجزيرة ثم مصر وفارس.\n\nفي الشام استمرت المواجهة مع الدولة البيزنطية. واجتمعت جيوش الروم والمسلمين عند اليرموك، وكانت الوقعة الكبرى في الرواية التي يرجحها عدد من أهل السير سنة 15هـ، مع وجود قول أقدم يجعلها قبل ذلك. انتهت المعركة بانكسار الجيش البيزنطي في الميدان، وتتابع بعدها دخول مدن الشام في سلطان المسلمين. كان أبو عبيدة بن الجراح على رأس الجيوش في الشام ومعه قادة الأجناد، وكانت المراسلات تصل إلى عمر في المدينة فيوجه ويجيب ويولي ويعزل بحسب ما تقتضيه إدارة الجبهة.\n\nوفي العراق كانت المواجهة الكبرى مع الدولة الساسانية. أرسل عمر سعد بن أبي وقاص على رأس الجيش، ووقعت القادسية، وقد اختلفت المصادر في تحديد سنتها بين 14 و15 و16هـ، واعتمدت روايات تاريخية سنة 15هـ. انتهت المعركة بهزيمة الجيش الساساني ومقتل قائده رستم، ثم تحرك المسلمون نحو المدائن، عاصمة الساسانيين، فدخلوها بعد ذلك. ولم يكن اتساع العراق مجرد حركة جيوش؛ فقد ظهرت الحاجة إلى مراكز تستقر فيها القوات وتدار منها البلاد، فنشأت البصرة والكوفة وصارتا من أهم أمصار الدولة في العقود التالية. وبعد القادسية لم تتوقف الجبهة عند حدود ساحة المعركة. سار سعد ومن معه إلى المدائن، حيث كانت قصور الحكم الساساني على دجلة، وانسحب يزدجرد من مركز ملكه مع تقدم المسلمين. ثم جاءت جلولاء وغيرها من الوقائع، وتحركت الجيوش في مناطق العراق وإيران الغربية. وفي الوقت نفسه لم يجعل عمر كل الأرض المفتوحة ملكًا خاصًا للمقاتلين، بل بقيت مساحات من أرض السواد في أيدي من يزرعها مع تنظيم ما يؤخذ عليها من خراج، وصارت مسائل الأرض والجباية من الموضوعات التي تتكرر في مراسلات الدولة. وفي أواخر حياته كان لا يزال يسأل القائمين على أرض السواد عن مقدار ما وضعوه عليها ويتحقق من قدرتها على حمله، كما يروي خبر عمرو بن ميمون في صحيح البخاري.\n\nوفي بلاد الشام بلغ المسلمون بيت المقدس. اختلف المؤرخون في سنة فتحها، فقيل 15هـ، وذهب جماعة من أهل السير إلى سنة 16هـ. طلب أهل إيلياء أن يكون تسليم المدينة للخليفة، فسافر عمر من المدينة إلى الشام، وقدم الجابية ثم دخل بيت المقدس وتسلمها. ارتبطت زيارته للقدس في المصادر بعهد أعطاه لأهلها على أنفسهم وأموالهم وكنائسهم وفق الصياغات التي نقلتها كتب التاريخ بصور متعددة. ثم عاد عمر إلى المدينة، بينما استمرت إدارة أقاليم الشام بولاة وقادة موزعين على الأجناد.\n\nومع تدفق الأموال واتساع عدد الجند والرعية، ظهرت في المدينة مسائل إدارية لم تكن بالحجم نفسه في السنوات الأولى. دُوّنت الدواوين لتنظيم أسماء المقاتلين وأعطياتهم، وفُرضت الأعطية على مراتب واعتبارات ذكرتها المصادر، وصار للدولة سجل تُعرف به الحقوق والمخصصات. ونُظمت أعمال الولاة والعمال والقضاء وبيت المال على نطاق أوسع مع اتساع الأقاليم. وفي عهد عمر كذلك اتخذ المسلمون الهجرة النبوية مبدأ لتأريخ السنين. تذكر المصادر أن ذلك وقع في نحو سنة 17هـ، وقيل 16 أو 18هـ، بعد أن ظهرت الحاجة إلى تاريخ تضبط به الكتب والآجال. اتفقوا على جعل سنة الهجرة بداية للتاريخ، واستقر العمل على المحرم أول شهور السنة. ومع قيام هذه الأمصار صار تعيين الولاة ومتابعتهم جزءًا دائمًا من عمل الخلافة. تولى على الأمصار رجال من الصحابة وغيرهم، وكانت الشكاوى أو التغييرات السياسية والإدارية قد تؤدي إلى عزل والٍ وتولية آخر. كما اتسع عمل القضاء وجباية الخراج وتوزيع العطاء. ولم تكن هذه النظم قد ظهرت كلها دفعة واحدة في سنة محددة، بل نمت خلال سنوات الفتح مع تزايد عدد الجند والأموال واتساع المسافة بين المدينة والأقاليم. ولهذا يصعب رد كل تفصيل إداري تنسبه الكتب إلى عمر إلى لحظة واحدة، لكن تدوين الديوان واعتماد التأريخ بالهجرة وبناء الأمصار من المعالم التي تكرر ذكرها في أخبار خلافته.\n\nلم تكن سنوات خلافته كلها سنوات فتح ورخاء. ففي سنة 18هـ أصاب الحجاز وما حوله قحط شديد عُرف بعام الرمادة. قدم الناس إلى المدينة واشتد نقص الطعام، فاستُعمل ما في بيت المال، وكتب عمر إلى عمال الأقاليم يطلب المدد والمؤن، ووصلت إمدادات إلى الحجاز. وفي العام نفسه تقريبًا انتشر طاعون عمواس في بلاد الشام، ومات فيه خلق كثير ومن كبار الصحابة أبو عبيدة بن الجراح ومعاذ بن جبل وغيرهما. خرج عمر يريد الشام، فلما بلغه خبر الوباء عند سرغ شاور المهاجرين والأنصار ومن كان معه، ثم رجع بالناس ولم يدخل أرض الطاعون، وجرى بينه وبين أبي عبيدة الحديث المشهور في الفرار من قدر الله إلى قدر الله. وكان طاعون عمواس حدثًا آخر أصاب الإدارة والجند في الشام؛ إذ توفي أبو عبيدة، ثم معاذ بن جبل، وغيرهما، وانتقلت القيادة بين من بقي من الأمراء. وقد حفظت كتب الحديث خبر وصول عمر إلى سرغ على طريق الشام، ومشاورته من معه حين علم بوقوع الوباء. لم يدخل عمر الأرض المصابة وعاد بمن معه إلى المدينة، ثم استمرت شؤون الشام بعد موت عدد من قادتها بتعيين من يقوم عليها. وهكذا اجتمع في فترة متقاربة قحط الحجاز والوباء في الشام، بينما كانت جبهات الدولة ومراسلاتها وأعمالها الأخرى مستمرة.\n\nثم اتجهت الجيوش إلى مصر بقيادة عمرو بن العاص. تختلف الأخبار في بدايات المسير وفي بعض تواريخ الفتح، لكن كثيرًا من المصادر يجعل فتح معظم مصر في سنة 20هـ، ثم استكملت السيطرة على الإسكندرية في نحو سنة 21هـ، مع أقوال أخرى في التأريخ. قامت الفسطاط مركزًا للمسلمين في مصر، وأصبح إقليم مصر جزءًا من الدولة في خلافة عمر. وفي الجبهة الشرقية استمرت العمليات بعد سقوط المدائن، ووقعت معركة نهاوند مع جيش فارسي كبير؛ والمشهور عند طائفة من المؤرخين أنها كانت سنة 21هـ، مع أقوال تجعلها في 18 أو 19هـ. انتهت نهاوند بانتصار المسلمين، ثم اتسعت التحركات في أقاليم فارس في السنوات التالية.\n\nومع هذه المساحة الواسعة بقي مركز الخلافة في المدينة. كانت الأخبار تأتي منها وإليها، ويُعيَّن الولاة والقادة وتصل وفود الأقاليم، وتعرض على الخليفة قضايا الأرض والخراج والعطاء والجند. ومن الأخبار الصحيحة المتصلة بأواخر حياته ما رواه عمرو بن ميمون من أن عمر كان يسأل عمال أرض السواد عما فرضوه على الأرض، ويتحقق من ألا يكون ما عليها فوق طاقتها. وفي الوقت نفسه كان يفكر فيمن يحمل أمر المسلمين بعده؛ فلم يعهد بالخلافة إلى رجل واحد كما فعل أبو بكر معه، بل جعل الأمر عند موته شورى في ستة من كبار الصحابة الذين توفي رسول الله ﷺ وهو عنهم راض: عثمان بن عفان، وعلي بن أبي طالب، وطلحة بن عبيد الله، والزبير بن العوام، وسعد بن أبي وقاص، وعبد الرحمن بن عوف رضي الله عنهم.\n\nوفي أواخر ذي الحجة سنة 23هـ خرج عمر لصلاة الفجر في مسجد رسول الله ﷺ بالمدينة. وبينما كان الناس في الصلاة طعنه أبو لؤلؤة، غلام المغيرة بن شعبة، بخنجر، وطعن معه عددًا من المصلين. حمل عمر إلى داره وقد أصيب إصابة بالغة. ولما علم أن أجله قريب، جعل أمر الخلافة في أهل الشورى الستة، وطلب من ابنه عبد الله أن يستأذن عائشة رضي الله عنها في أن يدفن مع صاحبيه رسول الله ﷺ وأبي بكر، فأذنت له. ومات عمر متأثرًا بجراحه، ودُفن في الحجرة إلى جوار النبي ﷺ وأبي بكر. وبموته انتهت خلافة امتدت من سنة 13هـ إلى سنة 23هـ، شهدت انتقال الدولة من حدود الجزيرة وما جاورها إلى بلاد واسعة من الشام والعراق ومصر وفارس، كما شهدت نشوء نظم إدارية ارتبطت بحاجات ذلك الاتساع، ثم انتقلت الخلافة بعد الشورى إلى عثمان بن عفان رضي الله عنه."
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
      "key": "yarmouk",
      "name": "اليرموك",
      "latitude": 32.65,
      "longitude": 35.95,
      "coordinateConfidence": "low",
      "note": "نقطة تمثيلية لنطاق وادي اليرموك؛ موضع انتشار المعركة الواسع لا يمثله مؤشر واحد بدقة."
    },
    {
      "key": "al_qadisiyyah",
      "name": "القادسية",
      "latitude": 31.72,
      "longitude": 44.57,
      "coordinateConfidence": "low",
      "note": "نقطة تقريبية لمنطقة القادسية التاريخية في العراق؛ تحتاج الإحداثيات إلى مراجعة جغرافية متخصصة قبل اعتماد دقة أعلى."
    },
    {
      "key": "al_quds",
      "name": "القدس",
      "latitude": 31.778,
      "longitude": 35.235,
      "coordinateConfidence": "high",
      "note": "المؤشر على مستوى المدينة التاريخية، ولا يحدد موضعًا بعينه داخلها."
    },
    {
      "key": "medain",
      "name": "المدائن",
      "latitude": 33.093,
      "longitude": 44.58,
      "coordinateConfidence": "high",
      "note": "تمثل نطاق المدائن التاريخية قرب طاق كسرى جنوب شرقي بغداد الحالية."
    },
    {
      "key": "hijaz",
      "name": "الحجاز",
      "latitude": 24.0,
      "longitude": 40.0,
      "coordinateConfidence": "low",
      "note": "نقطة تمثيلية لإقليم واسع تضرر من قحط عام الرمادة، وليست موقعًا واحدًا للحدث."
    },
    {
      "key": "fustat",
      "name": "الفسطاط",
      "latitude": 30.005,
      "longitude": 31.231,
      "coordinateConfidence": "high",
      "note": "تمثل موقع الفسطاط التاريخية في نطاق القاهرة القديمة الحالية."
    },
    {
      "key": "nahavand",
      "name": "نهاوند",
      "latitude": 34.188,
      "longitude": 48.376,
      "coordinateConfidence": "high",
      "note": "المؤشر على مستوى مدينة نهاوند التاريخية؛ ميدان المعركة كان في نطاقها ولا يحدد هذا المؤشر نقطة القتال الدقيقة."
    }
  ],
  "events": [
    {
      "key": "battle_yarmouk",
      "title": "معركة اليرموك",
      "hijriYear": 15,
      "placeKey": "yarmouk",
      "dateConfidence": "medium",
      "summary": "واجهت جيوش المسلمين بقيادة أمراء الشام جيشًا بيزنطيًا كبيرًا عند اليرموك. ترجح طائفة من أهل السير وقوع المعركة في رجب سنة 15هـ، مع وجود قول يجعلها قبل ذلك. انتهت المعركة بانكسار الجيش البيزنطي، وتتابعت بعدها عمليات المسلمين في مدن الشام.",
      "significance": "من أكبر معارك جبهة الشام في خلافة عمر، وتبعها اتساع السيطرة الإسلامية في بلاد الشام.",
      "sourceIds": [
        "siyar_yarmouk",
        "bidaya_yarmouk"
      ]
    },
    {
      "key": "battle_qadisiyyah",
      "title": "معركة القادسية",
      "hijriYear": 15,
      "placeKey": "al_qadisiyyah",
      "dateConfidence": "medium",
      "summary": "قاد سعد بن أبي وقاص جيش المسلمين في القادسية في مواجهة الجيش الساساني بقيادة رستم. اختلفت المصادر في سنة الوقعة، واعتمدت قاعدة المشروع 15هـ. انتهت المعركة بهزيمة الجيش الساساني ومقتل رستم، ثم واصل المسلمون تقدمهم في العراق.",
      "significance": "كانت من أبرز وقائع الحرب مع الدولة الساسانية ومهدت للتقدم نحو المدائن.",
      "sourceIds": [
        "siyar_qadisiyyah",
        "kamil_qadisiyyah"
      ]
    },
    {
      "key": "umar_jerusalem",
      "title": "تسلّم عمر بيت المقدس",
      "hijriYear": 16,
      "placeKey": "al_quds",
      "dateConfidence": "medium",
      "summary": "بعد تقدم جيوش المسلمين في فلسطين طلب أهل إيلياء تسليم المدينة للخليفة، فقدم عمر إلى الشام وتسلم بيت المقدس. اختلف المؤرخون في السنة بين 15 و16هـ، واعتمدت قاعدة المشروع 16هـ.",
      "significance": "انتقال بيت المقدس إلى حكم المسلمين وحضور الخليفة بنفسه لإتمام التسليم.",
      "sourceIds": [
        "jerusalem_conquest",
        "siyar_umar"
      ]
    },
    {
      "key": "conquest_madain",
      "title": "دخول المدائن",
      "hijriYear": 16,
      "placeKey": "medain",
      "dateConfidence": "medium",
      "summary": "بعد القادسية تقدم جيش سعد بن أبي وقاص نحو المدائن، عاصمة الدولة الساسانية، وعبر المسلمون إلى المدينة ودخلوها بعد انسحاب يزدجرد وقواته منها. تذكر المصادر الحدث ضمن تتابع فتوح العراق بعد القادسية.",
      "significance": "دخول مركز الحكم الساساني في العراق وانتقال العمليات العسكرية إلى مراحل أبعد شرقًا.",
      "sourceIds": [
        "siyar_qadisiyyah",
        "bidaya_caliphate"
      ]
    },
    {
      "key": "diwans",
      "title": "تدوين الدواوين وتنظيم العطاء",
      "hijriYear": 15,
      "placeKey": "medina",
      "dateConfidence": "medium",
      "summary": "مع اتساع الدولة وكثرة الجند والأموال جرى في عهد عمر تدوين الدواوين لتنظيم أسماء المقاتلين والأعطيات. تذكر بعض المصادر ذلك في سنة 15هـ، مع اختلاف في تفاصيل بدايته وترتيبه.",
      "significance": "إنشاء سجلات منظمة للجند والعطاء استجابة لاتساع موارد الدولة وعدد المستحقين.",
      "sourceIds": [
        "siyar_qadisiyyah",
        "bidaya_caliphate"
      ]
    },
    {
      "key": "hijri_calendar",
      "title": "اعتماد التأريخ بالهجرة",
      "hijriYear": 17,
      "placeKey": "medina",
      "dateConfidence": "low",
      "summary": "ظهرت الحاجة إلى تاريخ تضبط به الكتب والآجال، فاتفق المسلمون في خلافة عمر على جعل سنة هجرة النبي ﷺ مبدأ للتاريخ، واستقر العمل على المحرم أول شهور السنة. تختلف المصادر في سنة اعتماد النظام بين 16 و17 و18هـ.",
      "significance": "تثبيت مبدأ التأريخ بالهجرة الذي صار أساس التقويم الهجري في المكاتبات والتواريخ الإسلامية.",
      "sourceIds": [
        "hijri_calendar_source",
        "bidaya_caliphate"
      ]
    },
    {
      "key": "year_ramada",
      "title": "عام الرمادة",
      "hijriYear": 18,
      "placeKey": "hijaz",
      "dateConfidence": "medium",
      "summary": "أصاب الحجاز وما حوله قحط شديد عُرف بعام الرمادة، واشتد نقص الطعام ووفدت جماعات إلى المدينة. استُعمل ما في بيت المال، وكتب عمر إلى عمال الأقاليم يطلب الإمدادات حتى انكشف القحط.",
      "significance": "أزمة قحط واسعة واجهتها إدارة الدولة بإمداد الحجاز من موارد الأقاليم.",
      "sourceIds": [
        "ramada_source",
        "bidaya_caliphate"
      ]
    },
    {
      "key": "conquest_egypt",
      "title": "فتح مصر وقيام الفسطاط",
      "hijriYear": 20,
      "placeKey": "fustat",
      "dateConfidence": "low",
      "summary": "تحرك عمرو بن العاص إلى مصر في خلافة عمر، وتتابعت العمليات حتى دخلت أجزاء واسعة من مصر في حكم المسلمين وقامت الفسطاط مركزًا لهم. يختلف المؤرخون في تواريخ مراحل الفتح، ويجعل كثير منهم فتح معظم مصر في سنة 20هـ واستكمال الإسكندرية بعد ذلك.",
      "significance": "امتداد الدولة إلى مصر وقيام مركز إداري وعسكري جديد في الفسطاط.",
      "sourceIds": [
        "egypt_conquest",
        "amr_egypt"
      ]
    },
    {
      "key": "battle_nahavand",
      "title": "معركة نهاوند",
      "hijriYear": 21,
      "placeKey": "nahavand",
      "dateConfidence": "low",
      "summary": "تجمع جيش فارسي كبير في نهاوند، فأرسل عمر جيشًا لمواجهته. انتهت الوقعة بانتصار المسلمين. المشهور في عدد من المصادر أنها وقعت سنة 21هـ، مع أقوال تجعلها في 18 أو 19هـ.",
      "significance": "إحدى أكبر وقائع الجبهة الفارسية في خلافة عمر، وأعقبها اتساع العمليات في أقاليم فارس.",
      "sourceIds": [
        "nahavand_source",
        "kamil_nahavand"
      ]
    },
    {
      "key": "assassination_umar",
      "title": "استشهاد عمر بن الخطاب",
      "hijriYear": 23,
      "placeKey": "medina",
      "dateConfidence": "high",
      "summary": "طُعن عمر وهو يؤم الناس في صلاة الفجر بالمدينة في أواخر ذي الحجة سنة 23هـ، على يد أبي لؤلؤة غلام المغيرة بن شعبة. حُمل إلى داره، وجعل أمر الخلافة شورى في ستة من الصحابة، ثم مات متأثرًا بجراحه ودُفن بجوار النبي ﷺ وأبي بكر.",
      "significance": "نهاية خلافة عمر وانتقال اختيار الخليفة التالي إلى مجلس الشورى الذي عينه قبل وفاته.",
      "sourceIds": [
        "bukhari_assassination",
        "siyar_assassination",
        "siyar_umar"
      ]
    }
  ],
  "sources": [
    {
      "id": "siyar_umar",
      "title": "سير أعلام النبلاء – عمر بن الخطاب رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://islamweb.net/ar/library/content/60/6448/",
      "type": "classical_biography"
    },
    {
      "id": "ibn_hisham_hijra",
      "title": "السيرة النبوية لابن هشام – هجرة عمر وقصة عياش",
      "author": "عبد الملك بن هشام",
      "url": "https://islamweb.net/ar/library/content/58/551/",
      "type": "classical_sira"
    },
    {
      "id": "islam_umar",
      "title": "سير أعلام النبلاء – إسلام عمر رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://islamweb.net/ar/library/content/60/6209/",
      "type": "classical_biography"
    },
    {
      "id": "siyar_yarmouk",
      "title": "سير أعلام النبلاء – يوم اليرموك",
      "author": "شمس الدين الذهبي",
      "url": "https://www.islamweb.net/ar/library/content/60/6460/",
      "type": "classical_history"
    },
    {
      "id": "bidaya_yarmouk",
      "title": "البداية والنهاية – وقعة اليرموك واختلاف التأريخ",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/200/17902/",
      "type": "classical_history"
    },
    {
      "id": "siyar_qadisiyyah",
      "title": "سير أعلام النبلاء – وقعة القادسية",
      "author": "شمس الدين الذهبي",
      "url": "https://islamweb.net/ar/library/content/60/6461/",
      "type": "classical_history"
    },
    {
      "id": "kamil_qadisiyyah",
      "title": "الكامل في التاريخ – القادسية وقتل رستم",
      "author": "عز الدين ابن الأثير",
      "url": "https://islamweb.net/ar/library/content/126/397/",
      "type": "classical_history"
    },
    {
      "id": "jerusalem_conquest",
      "title": "البداية والنهاية – فتح بيت المقدس",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/content/200/17956/",
      "type": "classical_history"
    },
    {
      "id": "hijri_calendar_source",
      "title": "البداية والنهاية – ابتداء التاريخ الإسلامي من سنة الهجرة",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/content/200/16957/",
      "type": "classical_history"
    },
    {
      "id": "ramada_source",
      "title": "البداية والنهاية – عام الرمادة",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/200/17985/",
      "type": "classical_history"
    },
    {
      "id": "egypt_conquest",
      "title": "البداية والنهاية – فتح مصر والإسكندرية وغزو النوبة",
      "author": "إسماعيل بن كثير",
      "url": "https://islamweb.net/ar/library/content/200/17990/",
      "type": "classical_history"
    },
    {
      "id": "amr_egypt",
      "title": "عمرو بن العاص – فتح مصر",
      "url": "https://islamweb.net/ar/library/content/1551/1848/",
      "type": "other"
    },
    {
      "id": "nahavand_source",
      "title": "البداية والنهاية – معركة نهاوند",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/content/200/17993/",
      "type": "classical_history"
    },
    {
      "id": "kamil_nahavand",
      "title": "الكامل في التاريخ – وقعة نهاوند",
      "author": "عز الدين ابن الأثير",
      "url": "https://islamweb.net/ar/library/content/126/432/",
      "type": "classical_history"
    },
    {
      "id": "siyar_assassination",
      "title": "سير أعلام النبلاء – استشهاد عمر رضي الله عنه",
      "author": "شمس الدين الذهبي",
      "url": "https://islamweb.net/ar/library/content/60/6452/",
      "type": "classical_biography"
    },
    {
      "id": "bukhari_assassination",
      "title": "صحيح البخاري 3700 – مقتل عمر والشورى بعده",
      "author": "محمد بن إسماعيل البخاري",
      "url": "https://sunnah.com/bukhari:3700",
      "type": "authenticated_hadith"
    },
    {
      "id": "bukhari_agreements",
      "title": "صحيح البخاري – موافقات عمر رضي الله عنه",
      "author": "محمد بن إسماعيل البخاري",
      "url": "https://dorar.net/h/gfWe8w9N?osoul=1",
      "type": "authenticated_hadith"
    },
    {
      "id": "bidaya_caliphate",
      "title": "البداية والنهاية – ملخص خلافة عمر رضي الله عنه",
      "author": "إسماعيل بن كثير",
      "url": "https://www.islamweb.net/ar/library/index.php?ID=17921&bk_no=200&flag=1&page=bookcontents",
      "type": "classical_history"
    }
  ],
  "personSourceIds": [
    "siyar_umar",
    "ibn_hisham_hijra",
    "islam_umar",
    "bukhari_agreements",
    "bidaya_caliphate",
    "siyar_assassination",
    "bukhari_assassination"
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
  if jsonb_array_length(content -> 'places') <> 8
     or jsonb_array_length(content -> 'events') <> 10
     or jsonb_array_length(content -> 'sources') <> 18
     or jsonb_array_length(content -> 'personSourceIds') <> 7 then
    raise exception 'Reviewed JSON shape changed: expected 8 places, 10 events, 18 sources, and 7 person sources';
  end if;

  select count(*), min(id)
  into matched_count, resolved_person_id
  from public.people
  where slug = 'umar-ibn-al-khattab';

  if matched_count <> 1 then
    raise exception 'Expected exactly one person with slug umar-ibn-al-khattab; found %', matched_count;
  end if;

  select count(*), min(pp.period_id)
  into matched_count, resolved_period_id
  from public.period_people as pp
  where pp.person_id = resolved_person_id
    and pp.role = 'caliph'
    and pp.is_primary = true;

  if matched_count <> 1 then
    raise exception 'Expected exactly one approved primary caliph period for Umar; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.places where slug = 'al-madinah-al-munawwarah';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing place with slug al-madinah-al-munawwarah; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.places where slug = 'al-qadisiyyah';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing place with slug al-qadisiyyah; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.places where slug = 'al-quds';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing place with slug al-quds; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.events where slug = 'battle-of-al-qadisiyyah';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing event with slug battle-of-al-qadisiyyah; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.events where slug = 'umar-receives-al-quds';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing event with slug umar-receives-al-quds; found %', matched_count;
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
      ('al-yarmouk'),
      ('al-madain'),
      ('al-hijaz'),
      ('al-fustat'),
      ('nahavand')
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
      ('battle-of-al-yarmouk'),
      ('conquest-of-al-madain'),
      ('establishment-of-the-diwans'),
      ('adoption-of-the-hijri-calendar'),
      ('year-of-al-ramada'),
      ('conquest-of-egypt-and-fustat'),
      ('battle-of-nahavand'),
      ('assassination-of-umar')
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
      'medina', 'yarmouk', 'al_qadisiyyah', 'al_quds',
      'medain', 'hijaz', 'fustat', 'nahavand'
    )
       or place.value ->> 'coordinateConfidence' not in ('high', 'low', 'approximate')
  ) then
    raise exception 'Reviewed JSON contains an unsupported place key or coordinate confidence';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(content -> 'events') as event(value)
    where event.value ->> 'key' not in (
      'battle_yarmouk', 'battle_qadisiyyah', 'umar_jerusalem',
      'conquest_madain', 'diwans', 'hijri_calendar', 'year_ramada',
      'conquest_egypt', 'battle_nahavand', 'assassination_umar'
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
      'classical_biography', 'classical_history',
      'authenticated_hadith', 'classical_sira', 'other'
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
    raise exception 'Umar person update affected % rows instead of 1', affected_count;
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'yarmouk' then 'al-yarmouk'
      when 'al_qadisiyyah' then 'al-qadisiyyah'
      when 'al_quds' then 'al-quds'
      when 'medain' then 'al-madain'
      when 'hijaz' then 'al-hijaz'
      when 'fustat' then 'al-fustat'
      when 'nahavand' then 'nahavand'
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

    if (item ->> 'key') in ('medina', 'al_qadisiyyah', 'al_quds') then
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
      when 'battle_yarmouk' then 'battle-of-al-yarmouk'
      when 'battle_qadisiyyah' then 'battle-of-al-qadisiyyah'
      when 'umar_jerusalem' then 'umar-receives-al-quds'
      when 'conquest_madain' then 'conquest-of-al-madain'
      when 'diwans' then 'establishment-of-the-diwans'
      when 'hijri_calendar' then 'adoption-of-the-hijri-calendar'
      when 'year_ramada' then 'year-of-al-ramada'
      when 'conquest_egypt' then 'conquest-of-egypt-and-fustat'
      when 'battle_nahavand' then 'battle-of-nahavand'
      when 'assassination_umar' then 'assassination-of-umar'
      else null
    end;

    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'yarmouk' then 'al-yarmouk'
      when 'al_qadisiyyah' then 'al-qadisiyyah'
      when 'al_quds' then 'al-quds'
      when 'medain' then 'al-madain'
      when 'hijaz' then 'al-hijaz'
      when 'fustat' then 'al-fustat'
      when 'nahavand' then 'nahavand'
      else null
    end;

    -- Migration #3 is authoritative for these two existing reviewed dates.
    event_year := case item ->> 'key'
      when 'battle_qadisiyyah' then 15
      when 'umar_jerusalem' then 16
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

    if (item ->> 'key') in ('battle_qadisiyyah', 'umar_jerusalem') then
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
      when 'battle_yarmouk' then 'battle-of-al-yarmouk'
      when 'battle_qadisiyyah' then 'battle-of-al-qadisiyyah'
      when 'umar_jerusalem' then 'umar-receives-al-quds'
      when 'conquest_madain' then 'conquest-of-al-madain'
      when 'diwans' then 'establishment-of-the-diwans'
      when 'hijri_calendar' then 'adoption-of-the-hijri-calendar'
      when 'year_ramada' then 'year-of-al-ramada'
      when 'conquest_egypt' then 'conquest-of-egypt-and-fustat'
      when 'battle_nahavand' then 'battle-of-nahavand'
      when 'assassination_umar' then 'assassination-of-umar'
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
  where slug = 'umar-ibn-al-khattab';
  if matched_count <> 1 then
    raise exception 'Umar person postcondition failed: found % rows by slug', matched_count;
  end if;

  if (select brief_bio from public.people where id = resolved_person_id)
       is distinct from content #>> '{person,briefBio}' then
    raise exception 'Umar biography postcondition failed';
  end if;

  select count(*)
  into matched_count
  from public.period_people
  where person_id = resolved_person_id
    and period_id = resolved_period_id
    and role = 'caliph'
    and is_primary = true;
  if matched_count <> 1 then
    raise exception 'Umar primary period relationship postcondition failed';
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'yarmouk' then 'al-yarmouk'
      when 'al_qadisiyyah' then 'al-qadisiyyah'
      when 'al_quds' then 'al-quds'
      when 'medain' then 'al-madain'
      when 'hijaz' then 'al-hijaz'
      when 'fustat' then 'al-fustat'
      when 'nahavand' then 'nahavand'
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
      when 'battle_yarmouk' then 'battle-of-al-yarmouk'
      when 'battle_qadisiyyah' then 'battle-of-al-qadisiyyah'
      when 'umar_jerusalem' then 'umar-receives-al-quds'
      when 'conquest_madain' then 'conquest-of-al-madain'
      when 'diwans' then 'establishment-of-the-diwans'
      when 'hijri_calendar' then 'adoption-of-the-hijri-calendar'
      when 'year_ramada' then 'year-of-al-ramada'
      when 'conquest_egypt' then 'conquest-of-egypt-and-fustat'
      when 'battle_nahavand' then 'battle-of-nahavand'
      when 'assassination_umar' then 'assassination-of-umar'
    end;
    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'yarmouk' then 'al-yarmouk'
      when 'al_qadisiyyah' then 'al-qadisiyyah'
      when 'al_quds' then 'al-quds'
      when 'medain' then 'al-madain'
      when 'hijaz' then 'al-hijaz'
      when 'fustat' then 'al-fustat'
      when 'nahavand' then 'nahavand'
    end;
    event_year := case item ->> 'key'
      when 'battle_qadisiyyah' then 15
      when 'umar_jerusalem' then 16
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
      when 'battle_yarmouk' then 'battle-of-al-yarmouk'
      when 'battle_qadisiyyah' then 'battle-of-al-qadisiyyah'
      when 'umar_jerusalem' then 'umar-receives-al-quds'
      when 'conquest_madain' then 'conquest-of-al-madain'
      when 'diwans' then 'establishment-of-the-diwans'
      when 'hijri_calendar' then 'adoption-of-the-hijri-calendar'
      when 'year_ramada' then 'year-of-al-ramada'
      when 'conquest_egypt' then 'conquest-of-egypt-and-fustat'
      when 'battle_nahavand' then 'battle-of-nahavand'
      when 'assassination_umar' then 'assassination-of-umar'
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

  if approved_event_source_count <> 21 then
    raise exception 'Expected 21 approved event_sources relationships; verified %', approved_event_source_count;
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
      raise exception 'Missing approved person_sources relationship: umar-ibn-al-khattab -> %', source_alias;
    end if;

    approved_person_source_count := approved_person_source_count + 1;
  end loop;

  if approved_person_source_count <> 7 then
    raise exception 'Expected 7 approved person_sources relationships; verified %', approved_person_source_count;
  end if;
end
$import$;

commit;
