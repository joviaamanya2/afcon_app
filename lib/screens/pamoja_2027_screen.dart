import 'package:flutter/material.dart';

const _ink = Color(0xFF1E1E1E);
const _muted = Color(0xFF66716B);
const _line = Color(0xFFE4E9E5);
const _green = Color(0xFF176B46);

class Pamoja2027Screen extends StatelessWidget {
  const Pamoja2027Screen({super.key});

  static final _stories = [
    (
      title: 'PAMOJA will also be an AFCON of foods',
      detail: 'A look at how food and host-country culture add to the tournament experience.',
      date: '26 October 2026',
      image: 'https://afconpamoja.ug/wp-content/uploads/2026/10/Chicken-Luwombo-300x199.jpg',
    ),
    (
      title: 'Akii-Bua Stadium honours a sporting legend',
      detail: 'A stadium project being prepared as part of the East African tournament.',
      date: '22 October 2026',
      image: 'https://afconpamoja.ug/wp-content/uploads/2026/10/AKII-BUA-NEW-300x169.jpg',
    ),
    (
      title: 'Denis Onyango on what PAMOJA means for Uganda',
      detail: 'Uganda goalkeeper Denis Onyango shares his perspective on the tournament.',
      date: 'Official tournament coverage',
      image: 'https://afconpamoja.ug/wp-content/uploads/2026/10/Denis-Onyango-300x225.jpeg',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8F7),
    appBar: AppBar(
      title: const Text('PAMOJA 2027'),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const _TournamentHero(),
        const SizedBox(height: 22),
        const Text(
          'Three nations. One tournament.',
          style: TextStyle(
            color: _ink,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Pamoja means “together” in Swahili. Kenya, Tanzania and Uganda will jointly host the 2027 Africa Cup of Nations, bringing the tournament to East Africa.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.55),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: _HostCard(code: 'KE', country: 'Kenya'),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _HostCard(code: 'TZ', country: 'Tanzania'),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _HostCard(code: 'UG', country: 'Uganda'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'The tournament at a glance',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        const Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _TournamentFact(
              icon: Icons.calendar_month_rounded,
              value: '19 Jun – 17 Jul',
              label: '2027 tournament dates',
            ),
            _TournamentFact(
              icon: Icons.groups_rounded,
              value: '24 nations',
              label: 'Final tournament',
            ),
            _TournamentFact(
              icon: Icons.grid_view_rounded,
              value: '12 groups',
              label: 'Qualifying format',
            ),
            _TournamentFact(
              icon: Icons.public_rounded,
              value: '3 co-hosts',
              label: 'Across East Africa',
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'PAMOJA stories',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Stories, people and places shaping the tournament.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        for (final story in _stories) ...[
          _PamojaStoryCard(
            title: story.title,
            detail: story.detail,
            date: story.date,
            imageUrl: story.image,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        const Text(
          'Tournament details and stories are shown here in the app, based on CAF and PAMOJA publications.',
          style: TextStyle(color: _muted, fontSize: 10, height: 1.5),
        ),
      ],
    ),
  );
}

class _TournamentHero extends StatelessWidget {
  const _TournamentHero();

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF171B19),
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: SizedBox(
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/new images/home screen images/afcon_pamoja_q.webp',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xB3000000)],
              ),
            ),
          ),
          const Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTALENERGIES CAF AFRICA CUP OF NATIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.65,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'PAMOJA 2027',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.code, required this.country});

  final String code;
  final String country;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          code,
          style: const TextStyle(
            color: _green,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            country,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text('Co-host', style: TextStyle(color: _muted, fontSize: 10)),
      ],
    ),
  );
}

class _TournamentFact extends StatelessWidget {
  const _TournamentFact({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 41) / 2,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: _green, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PamojaStoryCard extends StatelessWidget {
  const _PamojaStoryCard({
    required this.title,
    required this.detail,
    required this.date,
    required this.imageUrl,
  });

  final String title;
  final String detail;
  final String date;
  final String imageUrl;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 145,
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: Color(0xFFF0F3F1),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: _muted,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.toUpperCase(),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.55,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  detail,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'PAMOJA tournament coverage',
                  style: TextStyle(
                    color: _green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
