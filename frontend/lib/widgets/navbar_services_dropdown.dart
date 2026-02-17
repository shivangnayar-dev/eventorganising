import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sources/service_remote_source.dart';
import '../data/models/service_category_model.dart';

class NavbarServicesDropdown extends ConsumerStatefulWidget {
  const NavbarServicesDropdown({
    super.key,
    this.onSelected,
  });

  final ValueChanged<String>? onSelected;

  @override
  ConsumerState<NavbarServicesDropdown> createState() => _NavbarServicesDropdownState();
}

class _NavbarServicesDropdownState extends ConsumerState<NavbarServicesDropdown> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isPointerOverTrigger = false;
  bool _isPointerOverMenu = false;
  Timer? _hideTimer;
  List<ServiceCategoryModel> _services = [];
  bool _isLoading = true;

  bool get _isDesktop => MediaQuery.of(context).size.width >= 900;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final remoteSource = ServiceRemoteSource();
      final categories = await remoteSource.fetchNavbarServiceCategories();
      if (mounted) {
        setState(() {
          _services = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<String> get _serviceNames => _services.map((s) => s.name).toList();

  @override
  void dispose() {
    _hideTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (!mounted) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  void _scheduleHide() {
    if (!_isDesktop || !mounted) return;
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted && !_isPointerOverTrigger && !_isPointerOverMenu) {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) return;
    final overlay = Overlay.of(context);
    if (!mounted) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || !mounted) return;
    final triggerSize = renderBox.size;
    final triggerOffset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _removeOverlay,
          child: Stack(
            children: [
              Positioned(
                left: triggerOffset.dx,
                top: triggerOffset.dy + triggerSize.height + 8,
                child: MouseRegion(
                  onEnter: (_) {
                    _isPointerOverMenu = true;
                    _hideTimer?.cancel();
                  },
                  onExit: (_) {
                    _isPointerOverMenu = false;
                    _scheduleHide();
                  },
                  child: _DropdownMenu(
                    services: _serviceNames,
                    isLoading: _isLoading,
                    onSelected: (service) {
                      widget.onSelected?.call(service);
                      _removeOverlay();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (mounted) {
      overlay.insert(_overlayEntry!);
      setState(() => _isOpen = true);
    }
  }

  void _toggleMenu() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isPointerOverTrigger = true;
        if (_isDesktop) {
          _hideTimer?.cancel();
          _showOverlay();
        }
      },
      onExit: (_) {
        _isPointerOverTrigger = false;
        if (_isDesktop) {
          _scheduleHide();
        }
      },
      child: TextButton(
        onPressed: () {
          if (!_isDesktop) {
            _toggleMenu();
          }
        },
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF2C2C2C)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Services',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(
                Icons.expand_more,
                size: 18,
                color: Color(0xFF2C2C2C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownMenu extends StatelessWidget {
  const _DropdownMenu({
    required this.services,
    required this.onSelected,
    this.isLoading = false,
  });

  final List<String> services;
  final ValueChanged<String> onSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              spreadRadius: 1,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : services.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No services available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shrinkWrap: true,
                    itemCount: services.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 0, thickness: 0.5, color: Color(0xFFF2F2F2)),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _DropdownItem(
                        service: service,
                        onSelected: onSelected,
                      );
                    },
                  ),
      ),
    );
  }
}

class _DropdownItem extends StatefulWidget {
  const _DropdownItem({required this.service, required this.onSelected});

  final String service;
  final ValueChanged<String> onSelected;

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => widget.onSelected(widget.service),
        child: Container(
          color: _hovered ? const Color(0xFFF8F0E2) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            widget.service,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Poppins',
              color:
                  _hovered ? const Color(0xFFC6A056) : const Color(0xFF2C2C2C),
            ),
          ),
        ),
      ),
    );
  }
}
