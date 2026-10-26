class PamojaGroup {
  const PamojaGroup(this.code, this.teams);

  final String code;
  final List<String> teams;
}

class PamojaQualifierWindow {
  const PamojaQualifierWindow(this.matchdays, this.dates);

  final String matchdays;
  final String dates;
}

const pamojaQualifierWindows = [
  PamojaQualifierWindow('Matchdays 1 & 2', '21 September – 6 October 2026'),
  PamojaQualifierWindow('Matchdays 3 & 4', '9 – 17 November 2026'),
  PamojaQualifierWindow('Matchdays 5 & 6', '22 – 30 March 2027'),
];

const pamojaGroups = [
  PamojaGroup('A', ['Morocco', 'Gabon', 'Niger', 'Lesotho']),
  PamojaGroup('B', ['Egypt', 'Angola', 'Malawi', 'South Sudan']),
  PamojaGroup('C', ['Côte d’Ivoire', 'Ghana', 'The Gambia', 'Somalia']),
  PamojaGroup('D', ['South Africa', 'Guinea', 'Kenya', 'Eritrea']),
  PamojaGroup('E', [
    'DR Congo',
    'Equatorial Guinea',
    'Sierra Leone',
    'Zimbabwe',
  ]),
  PamojaGroup('F', [
    'Burkina Faso',
    'Benin',
    'Mauritania',
    'Central African Republic',
  ]),
  PamojaGroup('G', ['Cameroon', 'Comoros', 'Namibia', 'Congo']),
  PamojaGroup('H', ['Tunisia', 'Uganda', 'Libya', 'Botswana']),
  PamojaGroup('I', ['Algeria', 'Zambia', 'Togo', 'Burundi']),
  PamojaGroup('J', ['Senegal', 'Mozambique', 'Sudan', 'Ethiopia']),
  PamojaGroup('K', ['Mali', 'Cape Verde', 'Rwanda', 'Liberia']),
  PamojaGroup('L', ['Nigeria', 'Madagascar', 'Tanzania', 'Guinea-Bissau']),
];
