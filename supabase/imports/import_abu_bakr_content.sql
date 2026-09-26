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
    raise exception 'Abu Bakr import cannot run; missing columns: %', missing_columns;
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
      "personName": "أبو بكر الصديق",
      "startYearHijri": 11,
      "endYearHijri": 13
    },
    "instructions": "Map this content to the existing Abu Bakr period_id. Do not create tables, rewrite historical text, add facts, or change coordinates."
  },
  "person": {
    "name": "أبو بكر الصديق",
    "briefBio": "أبو بكر الصديق رضي الله عنه هو عبد الله بن عثمان بن عامر التيمي القرشي، وأبوه أبو قحافة عثمان بن عامر. كان من وجوه قريش المعروفين بحسن الصحبة والمعرفة بأنساب العرب، وعمل بالتجارة قبل الإسلام. تصفه مصادر السيرة بأنه كان مألوفًا في قومه، سهل المعاملة، يأتيه الناس لعلمه وتجارته وحسن مجالسته. وعندما بدأ النبي محمد ﷺ دعوته كان أبو بكر من السابقين إلى الإسلام، ثم دعا من وثق بهم من أصحابه، فأسلم على يديه عدد من كبار الصحابة. لازم أبو بكر النبي ﷺ في مكة، وأنفق من ماله في نصرة المسلمين وإعتاق بعض المستضعفين الذين عُذّبوا بسبب إسلامهم، ومن أشهرهم بلال بن رباح رضي الله عنه. وعندما أذن الله بالهجرة كان صاحب النبي ﷺ في الطريق من مكة إلى المدينة، وقد خلد القرآن مشهد الغار في قوله تعالى: {إذ يقول لصاحبه لا تحزن إن الله معنا}. وبعد الهجرة شارك مع المسلمين في المشاهد الكبرى، وظل قريبًا من النبي ﷺ في السلم والحرب. وفي مرض النبي الأخير أُمر أن يؤم الناس في الصلاة، وهو من المواقف التي أبرزت منزلته بين الصحابة. عند وفاة النبي ﷺ سنة 11هـ اضطرب الناس من شدة الصدمة، فذكّرهم أبو بكر بأن عبادة الله لا تتعلق بحياة بشر، وتلا قول الله تعالى: {وما محمد إلا رسول قد خلت من قبله الرسل}. ثم اجتمع المهاجرون والأنصار، وانتهى الأمر إلى بيعته خليفة للمسلمين. واجهت الدولة الناشئة فورًا أزمة واسعة؛ فقد ظهرت دعاوى للنبوة، وارتدت جماعات، وامتنعت قبائل عن أداء الزكاة أو عن الخضوع لسلطة المدينة لأسباب متفاوتة. رأى أبو بكر أن تفكيك ركن الزكاة يهدد وحدة الدين والدولة، فثبت على قتال الممتنعين عنها مع قدرتهم عليها، مع أن بعض الصحابة ناقشه في البداية. أصر كذلك على إنفاذ جيش أسامة بن زيد الذي كان النبي ﷺ قد جهزه قبل وفاته، ثم نظم حملات مواجهة حركات الردة في أنحاء الجزيرة. ومن أهم وقائع تلك المرحلة معركتا بزاخة واليمامة. كانت اليمامة شديدة، وقُتل فيها عدد من حفظة القرآن، فاقترح عمر بن الخطاب جمع القرآن في صحف خشية ضياع شيء منه بموت القراء. تردد أبو بكر أولًا لأن النبي ﷺ لم يجمعه في مصحف واحد، ثم اقتنع بالمصلحة، وكلف زيد بن ثابت بتتبع القرآن وجمعه وفق منهج دقيق. بقيت الصحف عند أبي بكر، ثم عمر، ثم حفصة بنت عمر رضي الله عنهم. بعد استقرار معظم الجزيرة بدأت في عهده التحركات العسكرية نحو العراق والشام. قاد خالد بن الوليد عمليات في العراق، ووجه أبو بكر جيوشًا إلى بلاد الشام بقيادة عدد من الصحابة. لم يعش أبو بكر حتى يرى النتائج الكاملة لهذه الفتوح، لكنها وضعت الأساس لما اتسع في خلافة عمر رضي الله عنه. مرض أبو بكر في أواخر حياته، وبعد مشاورة عدد من الصحابة عهد بالخلافة إلى عمر بن الخطاب، ثم توفي في المدينة في جمادى الآخرة سنة 13هـ، ودُفن بجوار النبي ﷺ. لم تتجاوز خلافته نحو سنتين وثلاثة أشهر، لكنها كانت مرحلة حاسمة في تثبيت الدولة بعد وفاة النبي، وإعادة توحيد الجزيرة، وبدء جمع القرآن في الصحف، وفتح الطريق للامتداد خارج الجزيرة العربية."
  },
  "places": [
    {"key":"medina","name":"المدينة المنورة","latitude":24.4672,"longitude":39.6111,"coordinateConfidence":"high","note":"المؤشر على مستوى المدينة ولا يحدد مبنى بعينه."},
    {"key":"buzakha","name":"بزاخة","latitude":26.1,"longitude":41.0,"coordinateConfidence":"low","note":"نقطة تمثيلية لنطاق شمال نجد/جنوب حائل، وليست تحديدًا أثريًا قاطعًا."},
    {"key":"yamama_aqraba","name":"عقرباء – إقليم اليمامة","latitude":24.3,"longitude":46.8,"coordinateConfidence":"low","note":"تمثل إقليم اليمامة القريب من الرياض الحالية؛ موضع المعركة الدقيق يحتاج مراجعة متخصصة."},
    {"key":"al_hira","name":"الحيرة","latitude":31.985,"longitude":44.315,"coordinateConfidence":"high","note":"موقع المدينة التاريخية قرب النجف الحالية."},
    {"key":"bosra","name":"بصرى","latitude":32.5183,"longitude":36.4817,"coordinateConfidence":"high","note":"موقع المدينة التاريخية في جنوب سوريا."}
  ],
  "events": [
    {"key":"dispatch_usama","title":"إنفاذ جيش أسامة","hijriYear":11,"placeKey":"medina","summary":"بعد وفاة النبي ﷺ رأى بعض المسلمين تأجيل الجيش بسبب اضطراب الجزيرة، لكن أبا بكر أصر على إنفاذ الجيش الذي جهزه النبي بقيادة أسامة بن زيد. مثّل القرار التزامًا بأمر النبي ورسالة بأن الدولة لم تنهَر بعد وفاته.","significance":"تثبيت هيبة الدولة واستمرار قرار عسكري بدأ في حياة النبي ﷺ.","sourceIds":["siyar_caliphate","ibn_kathir"]},
    {"key":"battle_buzakha","title":"معركة بزاخة","hijriYear":11,"placeKey":"buzakha","summary":"واجه جيش خالد بن الوليد تجمعات من بني أسد وغطفان ومن انضم إليهم حول طليحة بن خويلد الذي ادعى النبوة. انتهت المواجهة بانكسار التجمع، ثم عاد كثير ممن شاركوا فيه إلى الإسلام، وأسلم طليحة لاحقًا وحسن إسلامه.","significance":"تفكيك واحد من أكبر مراكز التمرد في شمال نجد خلال حروب الردة.","sourceIds":["siyar_caliphate","ibn_kathir"]},
    {"key":"battle_yamama","title":"معركة اليمامة","hijriYear":11,"placeKey":"yamama_aqraba","summary":"دارت المعركة بين جيش المسلمين وأتباع مسيلمة في اليمامة، وكانت من أعنف وقائع حروب الردة. انتهت بمقتل مسيلمة وانهيار حركته، لكن المسلمين فقدوا عددًا كبيرًا من المقاتلين، وكان بين القتلى عدد من قراء القرآن.","significance":"إنهاء أخطر حركة مسلحة في الجزيرة، وكانت خسائر القراء سببًا مباشرًا في اقتراح جمع القرآن في صحف.","sourceIds":["bukhari_collection","yamama_hadith","ibn_kathir"]},
    {"key":"quran_collection","title":"جمع القرآن في الصحف","hijriYear":11,"placeKey":"medina","summary":"اقترح عمر بن الخطاب على أبي بكر جمع القرآن بعد اشتداد القتل بالقراء في اليمامة. كلف أبو بكر زيد بن ثابت بتتبع المكتوب والمحفوظ وجمعه في صحف، وظلت الصحف محفوظة عنده ثم عند عمر ثم حفصة بنت عمر.","significance":"أول جمع رسمي للقرآن في صحف مجموعة تحت إشراف الدولة، وهو الأساس الذي رجع إليه مشروع المصاحف في عهد عثمان.","sourceIds":["bukhari_collection","expanded_collection"]},
    {"key":"al_hira_campaign","title":"فتح الحيرة وبداية حملات العراق","hijriYear":12,"placeKey":"al_hira","dateConfidence":"medium","summary":"تحرك خالد بن الوليد في العراق ضمن سياسة أبي بكر لتأمين حدود الدولة ومواجهة القوى المعادية، وانتهت عمليات مبكرة بعقد الصلح مع الحيرة. كانت الحيرة مركزًا مهمًا على أطراف الدولة الساسانية.","significance":"تأسيس موطئ قدم للمسلمين في العراق وبدء مرحلة جديدة خارج الجزيرة العربية.","sourceIds":["ibn_kathir","siyar_caliphate"]},
    {"key":"levant_campaigns","title":"توجيه جيوش الشام والوصول إلى بصرى","hijriYear":13,"placeKey":"bosra","dateConfidence":"medium","summary":"وجه أبو بكر عدة جيوش إلى الشام بقيادة أمراء من الصحابة، ثم أمر خالد بن الوليد بالانتقال من العراق لدعمها. مثّل الوصول إلى بصرى وما تلاه بداية تثبيت الوجود الإسلامي في جنوب الشام قبل المعارك الكبرى التي اكتملت نتائجها في خلافة عمر.","significance":"بداية منظمة لفتوح الشام وربط الجبهتين العراقية والشامية.","sourceIds":["ibn_kathir","siyar_caliphate"]}
  ],
  "sources": [
    {"id":"siyar_bio","title":"سير أعلام النبلاء – ترجمة أبي بكر الصديق ومناقبه","author":"شمس الدين الذهبي","url":"https://www.islamweb.net/ar/library/content/60/6429/","type":"classical_biography"},
    {"id":"siyar_caliphate","title":"سير أعلام النبلاء – خلافة الصديق","author":"شمس الدين الذهبي","url":"https://www.islamweb.net/ar/library/content/60/6431/","type":"classical_biography"},
    {"id":"ibn_kathir","title":"البداية والنهاية","author":"إسماعيل بن كثير","url":"https://shamela.ws/book/23708","type":"classical_history"},
    {"id":"bukhari_collection","title":"صحيح البخاري 4986 – جمع القرآن بعد اليمامة","author":"محمد بن إسماعيل البخاري","url":"https://dorar.net/hadith/sharh/3839","type":"authenticated_hadith"},
    {"id":"expanded_collection","title":"خبر جمع القرآن في عهد أبي بكر ونسخ المصاحف في عهد عثمان","url":"https://dorar.net/hadith/sharh/3841","type":"hadith_commentary"},
    {"id":"yamama_hadith","title":"حديث ثابت بن قيس يوم اليمامة","url":"https://dorar.net/hadith/sharh/5224","type":"authenticated_hadith"},
    {"id":"early_islam","title":"إسلام أبي بكر ودعوته المبكرة – السيرة النبوية لابن هشام","url":"https://www.islamweb.net/ar/library/content/200/16783/","type":"classical_sira"},
    {"id":"death","title":"وفاة أبي بكر في جمادى الآخرة سنة 13هـ","url":"https://www.islamweb.net/ar/library/content/60/6447/","type":"classical_history"},
    {"id":"quran_cave","title":"سورة التوبة، الآية 40","url":"https://quran.com/9/40","type":"quran"}
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
     or jsonb_array_length(content -> 'events') <> 6
     or jsonb_array_length(content -> 'sources') <> 9 then
    raise exception 'Reviewed JSON shape changed: expected 5 places, 6 events, and 9 sources';
  end if;

  select count(*), min(id)
  into matched_count, resolved_person_id
  from public.people
  where slug = 'abu-bakr-al-siddiq';

  if matched_count <> 1 then
    raise exception 'Expected exactly one person with slug abu-bakr-al-siddiq; found %', matched_count;
  end if;

  select count(*), min(pp.period_id)
  into matched_count, resolved_period_id
  from public.period_people as pp
  where pp.person_id = resolved_person_id
    and pp.role = 'caliph'
    and pp.is_primary = true;

  if matched_count <> 1 then
    raise exception 'Expected exactly one approved primary caliph period for Abu Bakr; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.places where slug = 'al-madinah-al-munawwarah';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing place with slug al-madinah-al-munawwarah; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.events where slug = 'battle-of-al-yamamah';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing event with slug battle-of-al-yamamah; found %', matched_count;
  end if;

  select count(*) into matched_count
  from public.events where slug = 'collection-of-the-quran';
  if matched_count <> 1 then
    raise exception 'Expected exactly one existing event with slug collection-of-the-quran; found %', matched_count;
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
      ('buzakha'),
      ('yamama-aqraba'),
      ('al-hira'),
      ('bosra')
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
      ('dispatch-of-usamas-army'),
      ('battle-of-buzakha'),
      ('conquest-of-al-hira'),
      ('levant-campaigns-to-bosra')
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

  update public.people
  set name = content #>> '{person,name}',
      brief_bio = content #>> '{person,briefBio}'
  where id = resolved_person_id;
  get diagnostics affected_count = row_count;
  if affected_count <> 1 then
    raise exception 'Abu Bakr person update affected % rows instead of 1', affected_count;
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'buzakha' then 'buzakha'
      when 'yamama_aqraba' then 'yamama-aqraba'
      when 'al_hira' then 'al-hira'
      when 'bosra' then 'bosra'
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

    if item ->> 'key' = 'medina' then
      update public.places
      set name = item ->> 'name',
          lat = (item ->> 'latitude')::double precision,
          lng = (item ->> 'longitude')::double precision,
          coordinate_confidence = place_confidence,
          location_note = item ->> 'note'
      where slug = place_slug;
      get diagnostics affected_count = row_count;
      if affected_count <> 1 then
        raise exception 'Existing Medina update affected % rows instead of 1', affected_count;
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
      when 'dispatch_usama' then 'dispatch-of-usamas-army'
      when 'battle_buzakha' then 'battle-of-buzakha'
      when 'battle_yamama' then 'battle-of-al-yamamah'
      when 'quran_collection' then 'collection-of-the-quran'
      when 'al_hira_campaign' then 'conquest-of-al-hira'
      when 'levant_campaigns' then 'levant-campaigns-to-bosra'
      else null
    end;

    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'buzakha' then 'buzakha'
      when 'yamama_aqraba' then 'yamama-aqraba'
      when 'al_hira' then 'al-hira'
      when 'bosra' then 'bosra'
      else null
    end;

    -- Migration #3 is authoritative for these two reviewed dates.
    event_year := case item ->> 'key'
      when 'battle_yamama' then 12
      when 'quran_collection' then 12
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

    if (item ->> 'key') in ('battle_yamama', 'quran_collection') then
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
      when 'dispatch_usama' then 'dispatch-of-usamas-army'
      when 'battle_buzakha' then 'battle-of-buzakha'
      when 'battle_yamama' then 'battle-of-al-yamamah'
      when 'quran_collection' then 'collection-of-the-quran'
      when 'al_hira_campaign' then 'conquest-of-al-hira'
      when 'levant_campaigns' then 'levant-campaigns-to-bosra'
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

  foreach source_alias in array array['siyar_bio', 'early_islam', 'death', 'quran_cave'] loop
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
  where slug = 'abu-bakr-al-siddiq';
  if matched_count <> 1 then
    raise exception 'Abu Bakr person postcondition failed: found % rows by slug', matched_count;
  end if;

  if (select brief_bio from public.people where id = resolved_person_id)
       is distinct from content #>> '{person,briefBio}' then
    raise exception 'Abu Bakr biography postcondition failed';
  end if;

  select count(*)
  into matched_count
  from public.period_people
  where person_id = resolved_person_id
    and period_id = resolved_period_id
    and role = 'caliph'
    and is_primary = true;
  if matched_count <> 1 then
    raise exception 'Abu Bakr primary period relationship postcondition failed';
  end if;

  for item in select value from jsonb_array_elements(content -> 'places') loop
    place_slug := case item ->> 'key'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'buzakha' then 'buzakha'
      when 'yamama_aqraba' then 'yamama-aqraba'
      when 'al_hira' then 'al-hira'
      when 'bosra' then 'bosra'
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
      when 'dispatch_usama' then 'dispatch-of-usamas-army'
      when 'battle_buzakha' then 'battle-of-buzakha'
      when 'battle_yamama' then 'battle-of-al-yamamah'
      when 'quran_collection' then 'collection-of-the-quran'
      when 'al_hira_campaign' then 'conquest-of-al-hira'
      when 'levant_campaigns' then 'levant-campaigns-to-bosra'
    end;
    event_place_slug := case item ->> 'placeKey'
      when 'medina' then 'al-madinah-al-munawwarah'
      when 'buzakha' then 'buzakha'
      when 'yamama_aqraba' then 'yamama-aqraba'
      when 'al_hira' then 'al-hira'
      when 'bosra' then 'bosra'
    end;
    event_year := case item ->> 'key'
      when 'battle_yamama' then 12
      when 'quran_collection' then 12
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
      when 'dispatch_usama' then 'dispatch-of-usamas-army'
      when 'battle_buzakha' then 'battle-of-buzakha'
      when 'battle_yamama' then 'battle-of-al-yamamah'
      when 'quran_collection' then 'collection-of-the-quran'
      when 'al_hira_campaign' then 'conquest-of-al-hira'
      when 'levant_campaigns' then 'levant-campaigns-to-bosra'
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

  if approved_event_source_count <> 13 then
    raise exception 'Expected 13 approved event_sources relationships; verified %', approved_event_source_count;
  end if;

  foreach source_alias in array array['siyar_bio', 'early_islam', 'death', 'quran_cave'] loop
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
      raise exception 'Missing approved person_sources relationship: abu-bakr-al-siddiq -> %', source_alias;
    end if;

    approved_person_source_count := approved_person_source_count + 1;
  end loop;

  if approved_person_source_count <> 4 then
    raise exception 'Expected 4 approved person_sources relationships; verified %', approved_person_source_count;
  end if;
end
$import$;

commit;
