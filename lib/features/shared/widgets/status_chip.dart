import 'package:flutter/material.dart';
import 'package:led_truck/core/theme/app_theme.dart';

class StatusChip extends StatefulWidget {
  final String status;
  final String label;

  const StatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  State<StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<StatusChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.status.toLowerCase() == 'ligado') {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isLigado = widget.status.toLowerCase() == 'ligado';
    if (isLigado && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!isLigado && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'ligado':
        return AppTheme.statusLigado;
      case 'desligado':
        return AppTheme.statusDesligado;
      case 'estoque':
        return AppTheme.statusEstoque;
      case 'manutencao':
        return AppTheme.statusManutencao;
      case 'inativo':
        return AppTheme.statusInativo;
      default:
        return AppTheme.textSecondaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isLigado = widget.status.toLowerCase() == 'ligado';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isLigado)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: _animation.value,
                      height: _animation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor.withValues(alpha: 1.0 - _controller.value),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: (1.0 - _controller.value) * 0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    );
                  },
                ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
