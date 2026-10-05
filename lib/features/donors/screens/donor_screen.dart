import 'package:flutter/material.dart';

class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  int selectedTab = 0;
  String selectedBloodGroup = 'All';

  final bloodGroups = ['All', 'O−', 'O+', 'A+', 'B+'];

  final donors = const [
    Donor(name: 'Arif Hasan', initials: 'AH', bloodGroup: 'O−', distance: '1.8 km', available: true),
    Donor(name: 'Nina Patel', initials: 'NP', bloodGroup: 'A+', distance: '3.1 km', available: true),
    Donor(name: 'Omar Ali', initials: 'OA', bloodGroup: 'B+', distance: '4.7 km', available: false),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDonors = selectedBloodGroup == 'All'
        ? donors
        : donors.where((d) => d.bloodGroup == selectedBloodGroup).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            const _AppHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  const Text(
                    'TRUSTED CONNECTIONS',
                    style: TextStyle(
                      color: Color(0xFFD5293D),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Find donors',
                          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                        ),
                      ),
                      _RoundIconButton(
                        icon: Icons.map_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _SearchField(),
                  const SizedBox(height: 16),
                  _DonorTabs(
                    selectedIndex: selectedTab,
                    onChanged: (value) => setState(() => selectedTab = value),
                  ),
                  const SizedBox(height: 12),
                  _BloodGroupFilters(
                    groups: bloodGroups,
                    selected: selectedBloodGroup,
                    onSelected: (value) => setState(() => selectedBloodGroup = value),
                  ),
                  const SizedBox(height: 12),
                  const _LocationBar(),
                  const SizedBox(height: 12),
                  ...filteredDonors.map(
                    (donor) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DonorCard(donor: donor),
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
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD5293D),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.water_drop_outlined, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'Pulze',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const Text(
            '+',
            style: TextStyle(color: Color(0xFFD5293D), fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search blood group or city',
        hintStyle: const TextStyle(color: Color(0xFF9299A3), fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 19, color: Color(0xFF9299A3)),
        suffixIcon: const Icon(Icons.tune, size: 19, color: Color(0xFF9299A3)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE1E4E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFD5293D)),
        ),
      ),
    );
  }
}

class _DonorTabs extends StatelessWidget {
  const _DonorTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(label: 'Pulze donors', selected: selectedIndex == 0, onTap: () => onChanged(0)),
        _TabItem(label: 'External donors', selected: selectedIndex == 1, onTap: () => onChanged(1)),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFD5293D) : const Color(0xFFE2E5E8),
                width: selected ? 1.5 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFFD5293D) : const Color(0xFF454B54),
              fontSize: 12,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _BloodGroupFilters extends StatelessWidget {
  const _BloodGroupFilters({
    required this.groups,
    required this.selected,
    required this.onSelected,
  });

  final List<String> groups;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      children: groups.map((group) {
        final isSelected = group == selected;
        return ChoiceChip(
          label: Text(group),
          selected: isSelected,
          onSelected: (_) => onSelected(group),
          labelStyle: TextStyle(
            fontSize: 10,
            color: isSelected ? const Color(0xFFD5293D) : const Color(0xFF48505A),
          ),
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFFFECEE),
          side: BorderSide(
            color: isSelected ? const Color(0xFFE99AA3) : const Color(0xFFE1E4E8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          visualDensity: VisualDensity.compact,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

class _LocationBar extends StatelessWidget {
  const _LocationBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF747C86)),
        const SizedBox(width: 5),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Showing available donors within ',
              style: TextStyle(fontSize: 10, color: Color(0xFF737B85)),
              children: [
                TextSpan(
                  text: '10 km',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3E4650)),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Change',
            style: TextStyle(color: Color(0xFFD5293D), fontSize: 10),
          ),
        ),
      ],
    );
  }
}

class _DonorCard extends StatelessWidget {
  const _DonorCard({required this.donor});

  final Donor donor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E6E9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFF0F2F4),
            child: Text(
              donor.initials,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF303741)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(donor.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_user_outlined, size: 13, color: Color(0xFF168A64)),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Verified donor · Eligible',
                  style: TextStyle(fontSize: 10, color: Color(0xFF747C86)),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: donor.available ? const Color(0xFFE8F6EF) : const Color(0xFFF0F1F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        donor.available ? '✓ Available' : 'Unavailable',
                        style: TextStyle(
                          fontSize: 8,
                          color: donor.available ? const Color(0xFF18845F) : const Color(0xFF555D67),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(donor.distance, style: const TextStyle(fontSize: 9, color: Color(0xFF858C95))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECEE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 13, color: Color(0xFFD5293D)),
                const SizedBox(width: 3),
                Text(
                  donor.bloodGroup,
                  style: const TextStyle(
                    color: Color(0xFFD5293D),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 17, color: const Color(0xFF303741)),
        ),
      ),
    );
  }
}

class Donor {
  const Donor({
    required this.name,
    required this.initials,
    required this.bloodGroup,
    required this.distance,
    required this.available,
  });

  final String name;
  final String initials;
  final String bloodGroup;
  final String distance;
  final bool available;
}