import 'package:flutter/material.dart';

class DockSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback? onLogout;
  final String language;

  const DockSidebar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.onLogout,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    const localizedLabels = <String, Map<String, String>>{
      'ta': {
        'Dashboard': 'முகப்பு', 'New Docking': 'புதிய Docking', 'Protein Search': 'புரத தேடல்',
        'Ligand Search': 'Ligand தேடல்', 'History': 'வரலாறு', 'Saved Results': 'சேமித்த முடிவுகள்',
        'Analysis': 'பகுப்பாய்வு', 'Protein Details': 'புரத விவரங்கள்', 'Ligand Details': 'Ligand விவரங்கள்',
        'Interactions': 'தொடர்புகள்', 'Drug-Likeness': 'மருந்து தன்மை', 'Molecular Structure': 'மூலக்கூறு அமைப்பு',
        'Complete Report': 'முழு அறிக்கை', 'Account': 'கணக்கு', 'My Profile': 'என் சுயவிவரம்',
        'Settings': 'அமைப்புகள்', 'Language': 'மொழி', 'Logout': 'வெளியேறு',
      },
      'hi': {
        'Dashboard': 'डैशबोर्ड', 'New Docking': 'नई डॉकिंग', 'Protein Search': 'प्रोटीन खोज',
        'Ligand Search': 'लिगैंड खोज', 'History': 'इतिहास', 'Saved Results': 'सहेजे परिणाम',
        'Analysis': 'विश्लेषण', 'Protein Details': 'प्रोटीन विवरण', 'Ligand Details': 'लिगैंड विवरण',
        'Interactions': 'अंतःक्रियाएँ', 'Drug-Likeness': 'दवा-समानता', 'Molecular Structure': 'आणविक संरचना',
        'Complete Report': 'पूरी रिपोर्ट', 'Account': 'खाता', 'My Profile': 'मेरी प्रोफ़ाइल',
        'Settings': 'सेटिंग्स', 'Language': 'भाषा', 'Logout': 'लॉग आउट',
      },
      'te': {
        'Dashboard': 'డాష్‌బోర్డ్', 'New Docking': 'కొత్త డాకింగ్', 'Protein Search': 'ప్రోటీన్ శోధన',
        'Ligand Search': 'లిగాండ్ శోధన', 'History': 'చరిత్ర', 'Saved Results': 'సేవ్ చేసిన ఫలితాలు',
        'Analysis': 'విశ్లేషణ', 'Protein Details': 'ప్రోటీన్ వివరాలు', 'Ligand Details': 'లిగాండ్ వివరాలు',
        'Interactions': 'పరస్పర చర్యలు', 'Drug-Likeness': 'ఔషధ లక్షణం', 'Molecular Structure': 'అణు నిర్మాణం',
        'Complete Report': 'పూర్తి నివేదిక', 'Account': 'ఖాతా', 'My Profile': 'నా ప్రొఫైల్',
        'Settings': 'సెట్టింగ్‌లు', 'Language': 'భాష', 'Logout': 'లాగ్ అవుట్',
      },
    };
    String localize(String label) => localizedLabels[language]?[label] ?? label;
    final navItems = [
      _NavSection(
        title: 'DockHub Bio',
        items: [
          const _NavItem('Dashboard', Icons.dashboard_rounded, 0),
          const _NavItem('New Docking', Icons.add_circle_rounded, 1),
          const _NavItem('Protein Search', Icons.search_rounded, 2),
          const _NavItem('Ligand Search', Icons.science_rounded, 3),
          const _NavItem('History', Icons.history_rounded, 4),
          const _NavItem('Saved Results', Icons.bookmark_rounded, 5),
        ],
      ),
      _NavSection(
        title: 'Analysis',
        items: [
          const _NavItem('Docking', Icons.bolt_rounded, 6),
          const _NavItem('Protein Details', Icons.biotech_rounded, 7),
          const _NavItem('Ligand Details', Icons.local_pharmacy_rounded, 8),
          const _NavItem('Interactions', Icons.link_rounded, 9),
          const _NavItem('ADMET', Icons.health_and_safety_rounded, 10),
          const _NavItem('Drug-Likeness', Icons.verified_user_rounded, 11),
          const _NavItem('Ramachandran', Icons.insights_rounded, 12),
          const _NavItem('Molecular Structure', Icons.view_in_ar_rounded, 13),
          const _NavItem('Complete Report', Icons.description_rounded, 18),
        ],
      ),
      _NavSection(
        title: 'Account',
        items: [
          const _NavItem('My Profile', Icons.person_rounded, 14),
          const _NavItem('Settings', Icons.settings_rounded, 15),
          const _NavItem('Language', Icons.language_rounded, 16),
          const _NavItem('Logout', Icons.logout_rounded, 17, isAction: true),
        ],
      ),
    ];

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary = textPrimary.withValues(alpha: 0.7);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(right: BorderSide(color: primaryColor.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.biotech_rounded, color: primaryColor, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'DockHub Bio',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: navItems.map((section) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 10, bottom: 8),
                            child: Text(
                              localize(section.title),
                              style: TextStyle(
                                color: primaryColor.withValues(alpha: 0.85),
                                fontSize: 12,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ...section.items.map((item) {
                            final isSelected = selectedIndex == item.index;
                            return _SidebarTile(
                              item: item,
                              label: localize(item.label),
                              isSelected: isSelected,
                              onTap: () {
                                if (item.isAction && item.label == 'Logout') {
                                  if (onLogout != null) {
                                    onLogout!();
                                  } else {
                                    onChanged(item.index);
                                  }
                                } else {
                                  onChanged(item.index);
                                }
                              },
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              Divider(height: 24, color: theme.dividerColor),
              Row(
                children: [
                  Icon(Icons.language_rounded, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(language.toUpperCase(), style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final _NavItem item;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.item,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.item.isAction ? theme.colorScheme.error : theme.colorScheme.primary;
    final textSecondary = theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? activeColor.withValues(alpha: 0.16)
              : _isHovered
                  ? activeColor.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? activeColor.withValues(alpha: 0.5)
                : _isHovered
                    ? activeColor.withValues(alpha: 0.25)
                    : Colors.transparent,
          ),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            widget.item.icon,
            color: widget.isSelected
                ? activeColor
                : _isHovered
                    ? activeColor.withValues(alpha: 0.9)
                    : textSecondary,
            size: 20,
          ),
          title: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected
                  ? activeColor
                  : _isHovered
                      ? theme.colorScheme.onSurface
                      : textSecondary,
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class _NavSection {
  final String title;
  final List<_NavItem> items;

  const _NavSection({required this.title, required this.items});
}

class _NavItem {
  final String label;
  final IconData icon;
  final int index;
  final bool isAction;

  const _NavItem(this.label, this.icon, this.index, {this.isAction = false});
}
