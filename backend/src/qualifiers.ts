export const defaultQualifiers = {
  id: 'afcon-pamoja-2027',
  competition: 'TotalEnergies CAF Africa Cup of Nations PAMOJA 2027',
  title: 'AFCON PAMOJA 2027 qualifiers',
  format: '12 groups of four teams',
  groupCount: 12,
  finalistCount: 24,
  hostCountries: ['Kenya', 'Tanzania', 'Uganda'],
  nextWindow: {
    start: '2026-11-09',
    end: '2026-11-17',
    label: '9-17 November 2026',
  },
  qualifyingWindows: [
    {
      matchdays: 'Matchdays 1 & 2',
      start: '2026-09-21',
      end: '2026-10-06',
      label: '21 September-6 October 2026',
    },
    {
      matchdays: 'Matchdays 3 & 4',
      start: '2026-11-09',
      end: '2026-11-17',
      label: '9-17 November 2026',
    },
    {
      matchdays: 'Matchdays 5 & 6',
      start: '2027-03-22',
      end: '2027-03-30',
      label: '22-30 March 2027',
    },
  ],
  qualificationRules: {
    matches: 'Home and away matches across six matchdays.',
    standard: 'The first- and second-placed teams in each group qualify.',
    hostGroups:
      'Kenya in Group D, Uganda in Group H and Tanzania in Group L qualify automatically; only the highest-ranked non-host in each of those groups qualifies.',
  },
  tournament: {
    start: '2027-06-19',
    end: '2027-07-17',
    label: '19 June-17 July 2027',
  },
  drawPotsAsset:
    'assets/images/new images/home screen images/afcon-draw-q-potsjpg.webp',
  groupsAsset: 'assets/images/new images/home screen images/afcon_pamoja_q.webp',
  groups: [
    { code: 'A', teams: ['Morocco', 'Gabon', 'Niger', 'Lesotho'] },
    { code: 'B', teams: ['Egypt', 'Angola', 'Malawi', 'South Sudan'] },
    { code: 'C', teams: ['Côte d’Ivoire', 'Ghana', 'The Gambia', 'Somalia'] },
    { code: 'D', teams: ['South Africa', 'Guinea', 'Kenya', 'Eritrea'] },
    { code: 'E', teams: ['DR Congo', 'Equatorial Guinea', 'Sierra Leone', 'Zimbabwe'] },
    { code: 'F', teams: ['Burkina Faso', 'Benin', 'Mauritania', 'Central African Republic'] },
    { code: 'G', teams: ['Cameroon', 'Comoros', 'Namibia', 'Congo'] },
    { code: 'H', teams: ['Tunisia', 'Uganda', 'Libya', 'Botswana'] },
    { code: 'I', teams: ['Algeria', 'Zambia', 'Togo', 'Burundi'] },
    { code: 'J', teams: ['Senegal', 'Mozambique', 'Sudan', 'Ethiopia'] },
    { code: 'K', teams: ['Mali', 'Cape Verde', 'Rwanda', 'Liberia'] },
    { code: 'L', teams: ['Nigeria', 'Madagascar', 'Tanzania', 'Guinea-Bissau'] },
  ],
  venues: [
    {
      name: 'Akii-Bua Olympic Stadium',
      city: 'Lira City',
      country: 'Uganda',
      capacity: 20000,
      capacityStatus: 'planned upon completion',
      note: 'One of three national stadiums presented to CAF for AFCON PAMOJA 2027.',
      source:
        'https://afconpamoja.ug/akii-bua-stadium-is-befitting-of-ugandas-first-olympic-gold-medalist/',
    },
  ],
  sources: [
    {
      name: 'CAF qualifier draw and competition format',
      url: 'https://www.cafonline.com/caf-africa-cup-of-nations/news/the-road-to-east-africa-mapped-out-the-qualifier-draw-for-the-totalenergies-caf-africa-cup-of-nations-pamoja-2027-concluded/',
    },
    {
      name: 'PAMOJA Akii-Bua stadium profile',
      url: 'https://afconpamoja.ug/akii-bua-stadium-is-befitting-of-ugandas-first-olympic-gold-medalist/',
    },
  ],
  source: 'Official CAF and PAMOJA pages; match data is only shown when published',
} as const;
