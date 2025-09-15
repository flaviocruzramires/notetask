import 'package:flutter/material.dart';
import 'package:notetask/screens/settings_screen.dart';
import 'package:notetask/screens/statistics_screen.dart';
import 'package:notetask/screens/about_screen.dart';
import 'package:notetask/screens/ai_chat_screen.dart';
import 'package:notetask/screens/category_screen.dart'; // Importe a nova tela

class ReusableDrawer extends StatelessWidget {
  final Function(bool) onThemeChanged;

  const ReusableDrawer({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final appBarColor = isLightMode ? Colors.white : Colors.black;
    final iconColor = isLightMode ? Colors.black : Colors.white;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: appBarColor),
            child: Text(
              'Menu',
              style: TextStyle(color: iconColor, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.category, color: iconColor),
            title: Text('Categorias', style: TextStyle(color: iconColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.psychology_outlined, color: iconColor),
            title: Text('Chat com IA', style: TextStyle(color: iconColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: iconColor),
            title: Text('Estatísticas', style: TextStyle(color: iconColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: iconColor),
            title: Text('Sobre o App', style: TextStyle(color: iconColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: iconColor),
            title: Text('Configurações', style: TextStyle(color: iconColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsScreen(onThemeChanged: onThemeChanged),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
