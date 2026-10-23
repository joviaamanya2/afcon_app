import 'package:flutter/material.dart';

const _tournamentMaroon = Color(0xFF800000);
const _tournamentInk = Color(0xFF1E1E1E);
const _tournamentMuted = Color(0xFF666666);

class PamojaTournamentCard extends StatelessWidget {
  const PamojaTournamentCard({super.key, required this.onOpenMatches});

  final VoidCallback onOpenMatches;

  static const _hosts = ['KENYA', 'TANZANIA', 'UGANDA'];

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE4DF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'A historic East African AFCON',
                style: TextStyle(
                  color: _tournamentInk,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'PAMOJA means “together” in Swahili. Kenya, Tanzania and Uganda will jointly host the first AFCON staged across three countries.',
                style: TextStyle(
                  color: _tournamentMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 17),
              const _PamojaFactRow(
                icon: Icons.calendar_month_rounded,
                title: 'Final tournament',
                detail: '19 June – 17 July 2027',
              ),
              const SizedBox(height: 12),
              const _PamojaFactRow(
                icon: Icons.groups_rounded,
                title: 'Qualification format',
                detail: '48 nations · 12 groups · 24 finalists',
              ),
              const SizedBox(height: 12),
              const _PamojaFactRow(
                icon: Icons.flag_rounded,
                title: 'Uganda · Group H',
                detail: 'Tunisia, Uganda, Libya and Botswana',
              ),
              const SizedBox(height: 12),
              const _PamojaFactRow(
                icon: Icons.sports_soccer_rounded,
                title: 'Next qualifying window',
                detail: 'Matchdays 3 & 4 · 9–17 November 2026',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onOpenMatches();
                  },
                  icon: const Icon(Icons.sports_soccer_rounded),
                  label: const Text('Open fixtures and standings'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tournament facts: CAF official AFCON PAMOJA 2027 coverage. Match schedules, venues and live standings are supplied by the connected app backend.',
                style: TextStyle(
                  color: _tournamentMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _showDetails(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5EBE7)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(17, 16, 17, 17),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5C0000), Color(0xFF800000)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.public_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'TOTALENERGIES CAF AFCON',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .82),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.05,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'PAMOJA 2027',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '19 JUNE – 17 JULY 2027  ·  EAST AFRICA',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .55,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOSTED TOGETHER',
                    style: TextStyle(
                      color: _tournamentMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hosts
                        .map(
                          (host) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                        color: const Color(0xFFF5E6E6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              host,
                              style: const TextStyle(
                                color: _tournamentMaroon,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .4,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: _tournamentMaroon,
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '24 nations · Uganda is already through as a co-host',
                          style: TextStyle(
                            color: _tournamentInk,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PamojaFactRow extends StatelessWidget {
  const _PamojaFactRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6E6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _tournamentMaroon, size: 18),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _tournamentInk,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(
                color: _tournamentMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
