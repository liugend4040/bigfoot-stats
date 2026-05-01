import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data.dart';
import '../widgets/section_title.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'matches_screen.dart';
import 'players_screen.dart';
import 'team_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(
    viewportFraction: 0.86,
  );

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final team = appData.team;

    return Scaffold(
      appBar: AppBar(
        title: Text(team.nickname),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _goTo(context, const TeamSettingsScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Text(
                      team.nickname.isEmpty
                          ? '?'
                          : team.nickname[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    team.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    team.city.isEmpty
                        ? team.category
                        : '${team.city} • ${team.category}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SectionTitle(
              title: 'Acesso rápido',
              subtitle: 'Arraste para o lado e escolha uma área do app.',
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 210,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _CarouselCard(
                  title: 'Jogadores',
                  subtitle:
                      'Gerencie o elenco, edite perfis e acompanhe estatísticas.',
                  icon: Icons.group,
                  buttonText: 'Ver jogadores',
                  onTap: () {
                    _goTo(context, const PlayersScreen());
                  },
                ),

                _CarouselCard(
                  title: 'Partidas',
                  subtitle:
                      'Crie partidas, edite placares e registre desempenhos.',
                  icon: Icons.sports_soccer,
                  buttonText: 'Ver partidas',
                  onTap: () {
                    _goTo(context, const MatchesScreen());
                  },
                ),

                _CarouselCard(
                  title: 'Dashboard',
                  subtitle:
                      'Veja rankings, artilheiros e resumo geral do time.',
                  icon: Icons.dashboard,
                  buttonText: 'Abrir dashboard',
                  onTap: () {
                    _goTo(context, const DashboardScreen());
                  },
                ),

                _CarouselCard(
                  title: 'Configurações',
                  subtitle:
                      'Personalize o nome, apelido, cidade e categoria do time.',
                  icon: Icons.settings,
                  buttonText: 'Editar time',
                  onTap: () {
                    _goTo(context, const TeamSettingsScreen());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                _MiniCard(
                  title: 'Jogadores',
                  value: appData.players.length.toString(),
                  icon: Icons.group,
                ),

                _MiniCard(
                  title: 'Partidas',
                  value: appData.matches.length.toString(),
                  icon: Icons.sports_soccer,
                ),

                _MiniCard(
                  title: 'Elenco',
                  value: team.nickname,
                  icon: Icons.shield,
                ),

                _MiniCard(
                  title: 'Categoria',
                  value: team.category,
                  icon: Icons.flag,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback onTap;

  const _CarouselCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: primary,
              size: 36,
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward),
                label: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: primary,
            size: 32,
          ),

          const SizedBox(height: 12),

          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}