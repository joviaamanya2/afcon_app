UPDATE qualifier_content
SET payload = jsonb_set(payload || jsonb_build_object(
      'qualifyingWindows',
      jsonb_build_array(
        jsonb_build_object(
          'matchdays', 'Matchdays 1 & 2',
          'start', '2026-09-21',
          'end', '2026-10-06',
          'label', '21 September-6 October 2026'
        ),
        jsonb_build_object(
          'matchdays', 'Matchdays 3 & 4',
          'start', '2026-11-09',
          'end', '2026-11-17',
          'label', '9-17 November 2026'
        ),
        jsonb_build_object(
          'matchdays', 'Matchdays 5 & 6',
          'start', '2027-03-22',
          'end', '2027-03-30',
          'label', '22-30 March 2027'
        )
      ),
      'qualificationRules',
      jsonb_build_object(
        'matches', 'Home and away matches across six matchdays.',
        'standard', 'The first- and second-placed teams in each group qualify.',
        'hostGroups',
          'Kenya in Group D, Uganda in Group H and Tanzania in Group L qualify automatically; only the highest-ranked non-host in each of those groups qualifies.'
      ),
      'venues',
      jsonb_build_array(
        jsonb_build_object(
          'name', 'Akii-Bua Olympic Stadium',
          'city', 'Lira City',
          'country', 'Uganda',
          'capacity', 20000,
          'capacityStatus', 'planned upon completion',
          'note', 'One of three national stadiums presented to CAF for AFCON PAMOJA 2027.',
          'source',
            'https://afconpamoja.ug/akii-bua-stadium-is-befitting-of-ugandas-first-olympic-gold-medalist/'
        )
      ),
      'sources',
      jsonb_build_array(
        jsonb_build_object(
          'name', 'CAF qualifier draw and competition format',
          'url',
            'https://www.cafonline.com/caf-africa-cup-of-nations/news/the-road-to-east-africa-mapped-out-the-qualifier-draw-for-the-totalenergies-caf-africa-cup-of-nations-pamoja-2027-concluded/'
        ),
        jsonb_build_object(
          'name', 'PAMOJA Akii-Bua stadium profile',
          'url',
            'https://afconpamoja.ug/akii-bua-stadium-is-befitting-of-ugandas-first-olympic-gold-medalist/'
        )
      ),
      'source',
      'Official CAF and PAMOJA pages; match data is only shown when published'
    ), '{groups,2,teams,0}', to_jsonb('Côte d’Ivoire'::text), true),
    updated_at = now()
WHERE id = 'afcon-pamoja-2027';
