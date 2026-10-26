import 'package:flutter/material.dart';

class PamojaTournamentCard extends StatelessWidget {
  const PamojaTournamentCard({super.key, required this.onOpenTournament});

  final VoidCallback onOpenTournament;

  @override
  Widget build(BuildContext context) => Material(
    key: const Key('pamoja-tournament-card'),
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpenTournament,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5EBE7)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 8.5,
                  child: Image.asset(
                    'assets/images/new images/mandela stadium.PNG',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel:
                        'Mandela National Stadium, host venue for PAMOJA 2027',
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xB3000000)],
                        stops: [0.45, 1],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTALENERGIES CAF AFRICA CUP OF NATIONS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PAMOJA 2027',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KENYA  ·  TANZANIA  ·  UGANDA',
                    style: TextStyle(
                      color: Color(0xFF4C5A53),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '19 June – 17 July 2027',
                          style: TextStyle(
                            color: Color(0xFF1E1E1E),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF1E1E1E),
                        size: 18,
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
