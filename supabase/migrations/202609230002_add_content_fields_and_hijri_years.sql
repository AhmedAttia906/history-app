begin;

alter table public.sources
  add column author text null;

alter table public.places
  add column location_note text null;

do $$
begin
  if not exists (
    select 1 from public.periods where id = 1 and name = 'أبو بكر الصديق'
  ) then
    raise exception 'Expected period id 1 (أبو بكر الصديق) was not found';
  end if;

  if not exists (
    select 1 from public.periods where id = 2 and name = 'عمر بن الخطاب'
  ) then
    raise exception 'Expected period id 2 (عمر بن الخطاب) was not found';
  end if;

  if not exists (
    select 1 from public.periods where id = 3 and name = 'عثمان بن عفان'
  ) then
    raise exception 'Expected period id 3 (عثمان بن عفان) was not found';
  end if;

  if not exists (
    select 1 from public.periods where id = 4 and name = 'علي بن أبي طالب'
  ) then
    raise exception 'Expected period id 4 (علي بن أبي طالب) was not found';
  end if;
end
$$;

update public.periods set start_year = 11, end_year = 13 where id = 1;
update public.periods set start_year = 13, end_year = 23 where id = 2;
update public.periods set start_year = 23, end_year = 35 where id = 3;
update public.periods set start_year = 35, end_year = 40 where id = 4;

do $$
begin
  if exists (
    select 1
    from (
      values
        (1::bigint, 11, 13),
        (2::bigint, 13, 23),
        (3::bigint, 23, 35),
        (4::bigint, 35, 40)
    ) as expected(id, start_year, end_year)
    left join public.periods as actual using (id)
    where actual.id is null
       or actual.start_year is distinct from expected.start_year
       or actual.end_year is distinct from expected.end_year
  ) then
    raise exception 'Period Hijri year correction verification failed';
  end if;
end
$$;

do $$
declare
  missing_slugs text;
begin
  select string_agg(expected.slug, ', ' order by expected.slug)
  into missing_slugs
  from (
    values
      ('battle-of-al-yamamah'),
      ('collection-of-the-quran'),
      ('umar-receives-al-quds'),
      ('battle-of-al-qadisiyyah'),
      ('standardization-of-the-quran'),
      ('battle-of-the-camel')
  ) as expected(slug)
  where not exists (
    select 1 from public.events where events.slug = expected.slug
  );

  if missing_slugs is not null then
    raise exception 'Expected event slugs were not found: %', missing_slugs;
  end if;
end
$$;

update public.events
set start_year = 12, end_year = null
where slug = 'battle-of-al-yamamah';

update public.events
set start_year = 12, end_year = null
where slug = 'collection-of-the-quran';

update public.events
set start_year = 16, end_year = null
where slug = 'umar-receives-al-quds';

update public.events
set start_year = 15, end_year = null
where slug = 'battle-of-al-qadisiyyah';

update public.events
set start_year = 25, end_year = null
where slug = 'standardization-of-the-quran';

update public.events
set start_year = 36, end_year = null
where slug = 'battle-of-the-camel';

do $$
begin
  if exists (
    select 1
    from (
      values
        ('battle-of-al-yamamah', 12, null::integer),
        ('collection-of-the-quran', 12, null::integer),
        ('umar-receives-al-quds', 16, null::integer),
        ('battle-of-al-qadisiyyah', 15, null::integer),
        ('standardization-of-the-quran', 25, null::integer),
        ('battle-of-the-camel', 36, null::integer)
    ) as expected(slug, start_year, end_year)
    left join public.events as actual using (slug)
    where actual.slug is null
       or actual.start_year is distinct from expected.start_year
       or actual.end_year is distinct from expected.end_year
  ) then
    raise exception 'Event Hijri year correction verification failed';
  end if;
end
$$;

comment on column public.periods.start_year is
  'Hijri calendar year (AH), stored as an integer without conversion.';
comment on column public.periods.end_year is
  'Hijri calendar year (AH), stored as an integer without conversion.';
comment on column public.events.start_year is
  'Hijri calendar year (AH), stored as an integer without conversion.';
comment on column public.events.end_year is
  'Hijri calendar year (AH), stored as an integer without conversion.';

commit;
