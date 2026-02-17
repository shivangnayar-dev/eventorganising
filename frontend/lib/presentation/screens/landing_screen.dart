import 'dart:math';
import 'dart:ui' as ui;

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/event_venue.dart';
import '../widgets/event_venues_dialog.dart';
import '../../widgets/navbar_services_dropdown.dart';
import 'auth/login_screen.dart' show LoginScreen;
import 'auth/register_screen.dart' show AccountType, RegisterScreen;
import 'user/submit_service_screen.dart' show SubmitServiceScreen;
import '../controllers/auth_controller.dart';

const _bgColor = Color(0xFFFFF5E9);
const _gold = Color(0xFFC6A056);
const _deepText = Color(0xFF1C1B20);
const _lightCream = Color(0xFFFFFFFF);
const _softBeige = Color(0xFFF4E5D5);

const Map<String, List<EventVenue>> _eventVenues = {
  'Weddings': [
    EventVenue(
      name: 'The Royal Palace',
      location: 'Delhi',
      capacity: 500,
      minPrice: 200000,
      priceLabel: '₹2,00,000+',
      image: 'assets/images/venue_wedding_1.jpg',
    ),
    EventVenue(
      name: 'White Orchid Lawn',
      location: 'Mumbai',
      capacity: 800,
      minPrice: 350000,
      priceLabel: '₹3,50,000+',
      image: 'assets/images/venue_wedding_2.jpg',
    ),
    EventVenue(
      name: 'Imperial Banquet',
      location: 'Bengaluru',
      capacity: 300,
      minPrice: 120000,
      priceLabel: '₹1,20,000+',
      image: 'assets/images/venue_wedding_3.jpg',
    ),
  ],
  'Corporate Events': [
    EventVenue(
      name: 'Conference Hall A',
      location: 'Gurgaon',
      capacity: 200,
      minPrice: 50000,
      priceLabel: '₹50,000 – ₹1,20,000',
      image: 'assets/images/venue_corporate_1.jpg',
    ),
    EventVenue(
      name: 'Tech Event Center',
      location: 'Pune',
      capacity: 800,
      minPrice: 250000,
      priceLabel: '₹2,50,000+',
      image: 'assets/images/venue_corporate_2.jpg',
    ),
    EventVenue(
      name: 'Skyline Business Hub',
      location: 'Hyderabad',
      capacity: 450,
      minPrice: 160000,
      priceLabel: '₹1,60,000+',
      image: 'assets/images/venue_corporate_3.jpg',
    ),
  ],
  'Birthdays': [
    EventVenue(
      name: 'Sunset Terrace',
      location: 'Chennai',
      capacity: 150,
      minPrice: 60000,
      priceLabel: '₹60,000 – ₹1,00,000',
      image: 'assets/images/venue_birthday_1.jpg',
    ),
    EventVenue(
      name: 'Joy Hub Playhouse',
      location: 'Delhi NCR',
      capacity: 120,
      minPrice: 45000,
      priceLabel: '₹45,000 – ₹80,000',
      image: 'assets/images/venue_birthday_2.jpg',
    ),
    EventVenue(
      name: 'Neon Loft',
      location: 'Mumbai',
      capacity: 200,
      minPrice: 90000,
      priceLabel: '₹90,000 – ₹1,40,000',
      image: 'assets/images/venue_birthday_3.jpg',
    ),
  ],
  'Festivals & Public': [
    EventVenue(
      name: 'City Promenade Grounds',
      location: 'Ahmedabad',
      capacity: 2000,
      minPrice: 400000,
      priceLabel: '₹4,00,000+',
      image: 'assets/images/venue_festival_1.jpg',
    ),
    EventVenue(
      name: 'Riverside Amphitheatre',
      location: 'Kolkata',
      capacity: 1500,
      minPrice: 320000,
      priceLabel: '₹3,20,000+',
      image: 'assets/images/venue_festival_2.jpg',
    ),
    EventVenue(
      name: 'Open Air Arena',
      location: 'Jaipur',
      capacity: 2500,
      minPrice: 500000,
      priceLabel: '₹5,00,000+',
      image: 'assets/images/venue_festival_3.jpg',
    ),
  ],
};

Future<void> _showEventVenuesDialog(BuildContext context, String eventType) {
  final venues = _eventVenues[eventType] ?? const <EventVenue>[];
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Event venues',
    barrierColor: Colors.black54,
    pageBuilder: (context, _, __) {
      return BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: EventVenuesDialog(eventType: eventType, venues: venues),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: _lightCream.withOpacity(0.96),
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 85,
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: const _HeaderBar(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                SizedBox(height: 32),
                _HeroSection(),
                SizedBox(height: 64),
                _EventGallerySection(),
                SizedBox(height: 64),
                _StatsSection(),
                SizedBox(height: 64),
                _HowItWorksSection(),
                SizedBox(height: 64),
                _HowToAddVenueSection(),
                SizedBox(height: 64),
                _WhyChooseUsSection(),
                SizedBox(height: 72),
                _TestimonialsSection(),
                SizedBox(height: 80),
                _FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBar extends ConsumerWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 980;
    final isVeryCompact = width < 720;

    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [_gold, _softBeige],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.event_available, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EventOrganising',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, 
                    color: _deepText, 
                    height: 1.0,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (!isVeryCompact) ...[
                const SizedBox(height: 1),
                Text(
                  'Premium Event Planning',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                        color: _deepText.withOpacity(0.7),
                        fontSize: 10,
                        height: 1.0,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final menuButtons = [
      _NavButton(label: 'Home', onTap: () {}),
      _NavButton(label: 'About', onTap: () {}),
      NavbarServicesDropdown(
        onSelected: (value) {},
      ),
      _NavButton(label: 'Event Types', onTap: () {}),
      _NavButton(label: 'Testimonials', onTap: () {}),
      _NavButton(label: 'Contact', onTap: () {}),
    ];

    final rightSideWidget = authState.isAuthenticated
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isVeryCompact)
                Flexible(
                  child: Text(
                    'Hi, ${authState.user?.fullName ?? 'User'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _deepText,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              if (!isVeryCompact) const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryCompact ? 16 : 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(LoginScreen.routePath);
                  }
                },
                child: Text(isVeryCompact ? 'Out' : 'Sign Out'),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isVeryCompact)
                TextButton(
                  onPressed: () => context.push(LoginScreen.routePath),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 13)),
                ),
              if (!isVeryCompact) const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isVeryCompact ? 16 : 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => context.go(
                  RegisterScreen.routePath,
                  extra: AccountType.business,
                ),
                child: Text(isVeryCompact ? 'Plan' : 'Plan an Event'),
              ),
            ],
          );

    if (isCompact) {
      return Container(
        decoration: BoxDecoration(
          color: _lightCream,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _softBeige.withOpacity(0.8)),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: brand),
            const Spacer(),
            if (!isVeryCompact) Flexible(child: rightSideWidget),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: _deepText, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _lightCream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _softBeige.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(flex: 1, child: brand),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: menuButtons,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(flex: 1, child: rightSideWidget),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: _deepText),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 960;
    final textTheme = Theme.of(context).textTheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Your Perfect Event With Ease',
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: _deepText,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'From corporate events to private celebrations — we manage everything end-to-end.',
          style:
              textTheme.bodyLarge?.copyWith(color: _deepText.withOpacity(0.75)),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => context.go(RegisterScreen.routePath,
                  extra: AccountType.customer),
              child: const Text('Explore Services'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _gold,
                side: const BorderSide(color: _gold, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => context.go(RegisterScreen.routePath,
                  extra: AccountType.business),
              child: const Text('Add Your Venue'),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .moveY(begin: 28, end: 0, curve: Curves.easeOutCubic);

    final heroVisual = SizedBox(
      height: isWide ? 360 : 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [_lightCream, _softBeige],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gold.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.celebration, color: _gold, size: 32),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                color: Colors.green.shade700, size: 14),
                            const SizedBox(width: 4),
                            Text('Verified',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Premium planning partners',
                    style: textTheme.titleMedium?.copyWith(color: _deepText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Trusted vendors • Transparent pricing • Seamless execution',
                    style: textTheme.bodySmall
                        ?.copyWith(color: _deepText.withOpacity(0.65)),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: 120.ms)
          .scale(begin: const Offset(0.97, 0.97)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _lightCream,
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.14),
              blurRadius: 36,
              offset: const Offset(0, 24),
            ),
          ],
        ),
        padding: const EdgeInsets.all(36),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 36),
                  Expanded(child: heroVisual),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  content,
                  const SizedBox(height: 32),
                  heroVisual,
                ],
              ),
      ),
    );
  }
}

class _EventGallerySection extends StatelessWidget {
  const _EventGallerySection();

  static const _items = [
    ('Weddings', Icons.favorite),
    ('Corporate Events', Icons.business_center),
    ('Birthdays', Icons.cake),
    ('Festivals & Public', Icons.emoji_events),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: _items
            .map(
              (item) => _GalleryCard(
                title: item.$1,
                icon: item.$2,
                onTap: () => _showEventVenuesDialog(context, item.$1),
              )
                  .animate()
                  .fadeIn(
                      duration: 420.ms, delay: (_items.indexOf(item) * 90).ms)
                  .moveY(begin: 24, end: 0),
            )
            .toList(),
      ),
    );
  }
}

class _GalleryCard extends StatefulWidget {
  const _GalleryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: 200.ms,
            transformAlignment: Alignment.center,
            transform: Matrix4.identity()..scale(_hovering ? 1.04 : 1.0),
            width: 240,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                colors: [_lightCream, _softBeige],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withOpacity(_hovering ? 0.26 : 0.14),
                  blurRadius: _hovering ? 28 : 18,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: _gold.withOpacity(0.2),
                  child: Icon(widget.icon, color: _gold, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600, color: _deepText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  static const _stats = [
    ('1,000+', 'Successful Events'),
    ('500+', 'Venues Onboarded'),
    ('4.8★', 'Client Ratings'),
    ('50+', 'Services Offered'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: _stats
            .map(
              (stat) => Container(
                width: 220,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: _lightCream,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: _softBeige.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.14),
                      blurRadius: 22,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.$1,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.w700, color: _deepText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stat.$2,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: _deepText.withOpacity(0.72)),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                      duration: 380.ms, delay: (_stats.indexOf(stat) * 80).ms)
                  .moveY(begin: 24, end: 0),
            )
            .toList(),
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  static const _steps = [
    (
      Icons.event_note,
      'Submit event requirements',
      'Share your occasion details, preferred dates, and guest profile. We tailor the brief instantly.',
    ),
    (
      Icons.verified_user,
      'We verify venues & vendors',
      'Dedicated planners cross-check availability, credentials, and safety readiness with our verified network.',
    ),
    (
      Icons.assignment_turned_in,
      'Receive curated proposals',
      'Compare short-listed venues, packages, and transparent pricing. Approve with one tap.',
    ),
    (
      Icons.track_changes,
      'Track execution in real time',
      'Logistics, vendor assignments, and approvals stay synced in your live planning dashboard.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Your Event Comes Together',
            style: textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: _deepText),
          ),
          const SizedBox(height: 12),
          Text(
            'A transparent workflow that keeps every milestone in check—from first brief to vendor verification.',
            style: textTheme.bodyLarge
                ?.copyWith(color: _deepText.withOpacity(0.72)),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: _steps
                .map(
                  (step) => SizedBox(
                    width: 240,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _lightCream,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _softBeige.withOpacity(0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: _gold.withOpacity(0.18),
                            child: Icon(step.$1, color: _gold, size: 24),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step.$2,
                            style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600, color: _deepText),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.$3,
                            style: textTheme.bodyMedium
                                ?.copyWith(color: _deepText.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HowToAddVenueSection extends StatelessWidget {
  const _HowToAddVenueSection();

  static const _steps = [
    (
      Icons.person_add,
      'Register as Business',
      'Create your business account in minutes. Provide basic information to get started.',
    ),
    (
      Icons.add_business,
      'Add Your Venue',
      'Fill in your venue details: name, location, capacity, pricing, amenities, and photos.',
    ),
    (
      Icons.verified_user,
      'Our Team Verifies',
      'Our dedicated verification team reviews your venue to ensure quality and authenticity.',
    ),
    (
      Icons.public,
      'Go Live & Get Bookings',
      'Once verified, your venue goes live and customers can discover and book it.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authControllerProvider);
        final isAuthenticated = authState.isAuthenticated;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _gold.withOpacity(0.08),
                _softBeige.withOpacity(0.3),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront, color: _gold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'For Business Owners',
                      style: textTheme.labelLarge?.copyWith(
                        color: _gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How to Add Your Venue',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _deepText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 120 : 24),
                child: Text(
                  'List your venue on our platform and reach thousands of event planners. Our verification process ensures trust and quality.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: _deepText.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: _steps
                    .map(
                      (step) => SizedBox(
                        width: isWide ? 260 : double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _lightCream,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: _softBeige.withOpacity(0.8)),
                            boxShadow: [
                              BoxShadow(
                                color: _gold.withOpacity(0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(step.$1,
                                    color: _gold, size: 28),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                step.$2,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _deepText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                step.$3,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: _deepText.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(
                                duration: 400.ms,
                                delay: (_steps.indexOf(step) * 100).ms)
                            .moveY(begin: 24, end: 0),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _lightCream,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _gold.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _gold.withOpacity(0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        color: Colors.green.shade700, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified by Our Team',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _deepText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All venues are verified for authenticity and quality',
                          style: textTheme.bodySmall?.copyWith(
                            color: _deepText.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                icon: const Icon(Icons.add_business),
                label: Text(isAuthenticated
                    ? 'Add Your Venue Now'
                    : 'Get Started - Register as Business'),
                onPressed: () {
                  if (isAuthenticated) {
                    context.push(SubmitServiceScreen.routePath);
                  } else {
                    context.go(RegisterScreen.routePath,
                        extra: AccountType.business);
                  }
                },
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .moveY(begin: 40, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _WhyChooseUsSection extends StatelessWidget {
  const _WhyChooseUsSection();

  static const _points = [
    ('End-to-end event planning', Icons.event_note),
    ('Verified & Trusted vendors', Icons.verified_user),
    ('Real-time booking & tracking', Icons.track_changes),
    ('Affordable packages', Icons.attach_money),
    ('24/7 support', Icons.support_agent),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final textTheme = Theme.of(context).textTheme;

    final image = Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [_softBeige, _lightCream],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.16),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFFAF0), Color(0xFFFCEED2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.group_work_rounded,
                    size: 120, color: _gold),
              ),
            ),
          ),
          Positioned(
            top: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 6),
                  Icon(Icons.workspace_premium, color: _gold, size: 20),
                  const SizedBox(width: 8),
                  Text('Verified & Trusted by 500+ venues',
                      style: TextStyle(
                          color: _deepText, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final points = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose EventOrganising?',
          style: textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: _deepText),
        ),
        const SizedBox(height: 14),
        Text(
          'We combine creative expertise with operational excellence to deliver unforgettable experiences.',
          style:
              textTheme.bodyLarge?.copyWith(color: _deepText.withOpacity(0.72)),
        ),
        const SizedBox(height: 20),
        ..._points.map(
          (point) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(point.$2, color: _gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point.$1,
                    style: textTheme.bodyMedium?.copyWith(
                        color: _deepText, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          onPressed: () =>
              context.go(RegisterScreen.routePath, extra: AccountType.business),
          child: const Text('Get a Free Consultation'),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 420.ms)
        .moveY(begin: 26, end: 0, curve: Curves.easeOutCubic);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: _lightCream,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: _softBeige.withOpacity(0.75)),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: image),
                  const SizedBox(width: 32),
                  Expanded(child: points),
                ],
              )
            : Column(
                children: [
                  image,
                  const SizedBox(height: 28),
                  points,
                ],
              ),
      ),
    );
  }
}

class _TestimonialsSection extends StatefulWidget {
  const _TestimonialsSection();

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  late PageController _controller;
  double _page = 0;

  static const _testimonials = [
    (
      'Emily Carter',
      'Corporate Annual Meet',
      '“EventOrganising handled our corporate summit flawlessly. Every detail was on point and the team was incredibly supportive.”',
    ),
    (
      'Rahul Mehta',
      'Wedding Celebration',
      '“They transformed our wedding vision into reality. The verified vendors and planning tools made everything stress-free.”',
    ),
    (
      'Sophie Nguyen',
      'Product Launch',
      '“From staging to guest experience, the EventOrganising crew delivered a polished product launch that wowed our clients.”',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85)
      ..addListener(() => setState(() => _page = _controller.page ?? 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'What Our Clients Say',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: _deepText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: PageView.builder(
              controller: _controller,
              itemCount: _testimonials.length,
              itemBuilder: (context, index) {
                final data = _testimonials[index];
                final scale = max(0.9, 1 - (_page - index).abs() * 0.08);
                return Transform.scale(
                  scale: scale,
                  child: _TestimonialCard(
                    name: data.$1,
                    event: data.$2,
                    review: data.$3,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _testimonials.length,
              (index) => AnimatedContainer(
                duration: 250.ms,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: (_page.round() == index) ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      (_page.round() == index) ? _gold : _gold.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.name,
    required this.event,
    required this.review,
  });

  final String name;
  final String event;
  final String review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _lightCream,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _softBeige.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _gold.withOpacity(0.2),
                child: Text(name.characters.first,
                    style: const TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600, color: _deepText)),
                  Text(event,
                      style: textTheme.bodySmall
                          ?.copyWith(color: _deepText.withOpacity(0.7))),
                ],
              ),
              const Spacer(),
              Row(
                children: const [
                  Icon(Icons.star, color: _gold, size: 18),
                  Icon(Icons.star, color: _gold, size: 18),
                  Icon(Icons.star, color: _gold, size: 18),
                  Icon(Icons.star, color: _gold, size: 18),
                  Icon(Icons.star_half, color: _gold, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              review,
              style: textTheme.bodyMedium
                  ?.copyWith(color: _deepText.withOpacity(0.75)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: _deepText,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;
          final columns = [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EventOrganising',
                      style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(
                    'Creating unforgettable events with trusted partners and meticulous planning.',
                    style:
                        textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Icon(Icons.facebook, color: Colors.white70),
                      SizedBox(width: 12),
                      Icon(Icons.camera_alt_outlined, color: Colors.white70),
                      SizedBox(width: 12),
                      Icon(Icons.link_outlined, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Links',
                      style:
                          textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  ...[
                    'Home',
                    'About',
                    'Services',
                    'Event Types',
                    'Testimonials',
                    'Contact'
                  ]
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(item,
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70)),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact',
                      style:
                          textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text('hello@eventorganising.com',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('+1 800 555 2024',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 16),
                  Text(
                      '© ${DateTime.now().year} EventOrganising. All rights reserved.',
                      style:
                          textTheme.bodySmall?.copyWith(color: Colors.white38)),
                ],
              ),
            ),
          ];

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final column in columns) ...[
                  column,
                  const SizedBox(height: 32)
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns,
          );
        },
      ),
    );
  }
}
