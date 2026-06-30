import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(
                  (_animation.value * 255).toInt(),
                ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final int lines;
  final double spacing;

  const SkeletonCard({super.key, this.lines = 3, this.spacing = 12});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoading(height: 20, width: 200),
            const SizedBox(height: 12),
            for (int i = 0; i < lines; i++) ...[
              SkeletonLoading(
                height: 14,
                width: i == lines - 1 ? 150 : double.infinity,
              ),
              if (i < lines - 1) SizedBox(height: spacing),
            ],
          ],
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final int linesPerItem;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.linesPerItem = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonCard(lines: linesPerItem),
    );
  }
}

class SkeletonTable extends StatelessWidget {
  final int rows;
  final int columns;

  const SkeletonTable({super.key, this.rows = 5, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: List.generate(
              columns,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                  child: const SkeletonLoading(height: 14),
                ),
              ),
            ),
          ),
        ),
        for (int r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: List.generate(
                columns,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                    child: const SkeletonLoading(height: 12),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
