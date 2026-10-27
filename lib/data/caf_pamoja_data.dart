class CafQualifierMatch {
  const CafQualifierMatch({
    required this.group,
    required this.home,
    required this.away,
    required this.dateLabel,
    this.homeScore,
    this.awayScore,
  });

  final String group;
  final String home;
  final String away;
  final String dateLabel;
  final int? homeScore;
  final int? awayScore;

  bool get hasScore => homeScore != null && awayScore != null;
}

const cafAfcon2027Source =
    'https://www.cafonline.com/caf-africa-cup-of-nations/';
const cafAfcon2027OverviewSource =
    'https://www.cafonline.com/afcon2025/news/everything-you-need-to-know-about-totalenergies-caf-africa-cup-of-nations-pamoja-2027/';
const cafAfcon2027ResultsSource =
    'https://www.cafonline.com/afcon2025/news/group-by-group-perfect-starts-for-morocco-cote-d-ivoire-and-guinea-bissau-after-matchday-two-of-afcon-2027-qualifiers/';
const cafAngolaMalawiSource =
    'https://www.cafonline.com/afcon2025/news/angola-defeat-malawi-in-race-for-place-at-totalenergies-caf-afcon-pamoja-2027/';
const cafGuineaKenyaSource =
    'https://www.cafonline.com/afcon2025/news/guirassy-strike-gives-guinea-crucial-win-over-kenya-in-afcon-2027-qualifier/';

const cafAfcon2027QualifierResults = <CafQualifierMatch>[
  CafQualifierMatch(group: 'A', home: 'Lesotho', away: 'Morocco', homeScore: 0, awayScore: 2, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'A', home: 'Gabon', away: 'Niger', homeScore: 2, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'B', home: 'South Sudan', away: 'Egypt', homeScore: 0, awayScore: 5, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'B', home: 'Angola', away: 'Malawi', homeScore: 3, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'C', home: 'Ghana', away: 'The Gambia', homeScore: 2, awayScore: 4, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'C', home: 'Somalia', away: 'Côte d’Ivoire', homeScore: 0, awayScore: 2, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'D', home: 'Eritrea', away: 'South Africa', homeScore: 0, awayScore: 5, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'D', home: 'Guinea', away: 'Kenya', homeScore: 1, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'E', home: 'Equatorial Guinea', away: 'Sierra Leone', homeScore: 1, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'E', home: 'Zimbabwe', away: 'DR Congo', homeScore: 1, awayScore: 2, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'F', home: 'Central African Republic', away: 'Burkina Faso', homeScore: 0, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'F', home: 'Benin', away: 'Mauritania', homeScore: 2, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'G', home: 'Comoros', away: 'Namibia', homeScore: 1, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'G', home: 'Congo', away: 'Cameroon', homeScore: 1, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'H', home: 'Tunisia', away: 'Botswana', homeScore: 2, awayScore: 2, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'H', home: 'Uganda', away: 'Libya', homeScore: 1, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'I', home: 'Burundi', away: 'Algeria', homeScore: 2, awayScore: 2, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'I', home: 'Zambia', away: 'Togo', homeScore: 2, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'J', home: 'Ethiopia', away: 'Senegal', homeScore: 0, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'J', home: 'Mozambique', away: 'Sudan', homeScore: 4, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'K', home: 'Cape Verde', away: 'Rwanda', homeScore: 1, awayScore: 2, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'K', home: 'Liberia', away: 'Mali', homeScore: 0, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'L', home: 'Guinea-Bissau', away: 'Nigeria', homeScore: 3, awayScore: 0, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
  CafQualifierMatch(group: 'L', home: 'Madagascar', away: 'Tanzania', homeScore: 1, awayScore: 1, dateLabel: 'Matchday 2 · 21 Sep–6 Oct 2026 window'),
];

const cafAfcon2027UpcomingFixtures = <CafQualifierMatch>[
  CafQualifierMatch(group: 'A', home: 'Morocco', away: 'Niger', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'A', home: 'Gabon', away: 'Lesotho', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'B', home: 'Angola', away: 'South Sudan', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'B', home: 'Egypt', away: 'Malawi', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'C', home: 'Ghana', away: 'Somalia', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'C', home: 'Côte d’Ivoire', away: 'The Gambia', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'D', home: 'Guinea', away: 'Eritrea', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'D', home: 'South Africa', away: 'Kenya', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'E', home: 'DR Congo', away: 'Sierra Leone', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'E', home: 'Equatorial Guinea', away: 'Zimbabwe', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'F', home: 'Benin', away: 'Central African Republic', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'F', home: 'Burkina Faso', away: 'Mauritania', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'G', home: 'Cameroon', away: 'Namibia', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'G', home: 'Comoros', away: 'Congo', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'H', home: 'Tunisia', away: 'Libya', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'H', home: 'Uganda', away: 'Botswana', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'I', home: 'Algeria', away: 'Togo', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'I', home: 'Zambia', away: 'Burundi', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'J', home: 'Mozambique', away: 'Ethiopia', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'J', home: 'Senegal', away: 'Sudan', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'K', home: 'Cape Verde', away: 'Liberia', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'K', home: 'Mali', away: 'Rwanda', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'L', home: 'Madagascar', away: 'Guinea-Bissau', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
  CafQualifierMatch(group: 'L', home: 'Nigeria', away: 'Tanzania', dateLabel: 'Matchday 3 · 9–17 Nov 2026'),
];
