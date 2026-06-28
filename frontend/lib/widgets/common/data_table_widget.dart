import 'package:flutter/material.dart';

class DataTableWidget extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoading;
  final String? searchQuery;
  final ValueChanged<String>? onSearch;
  final ValueChanged<int>? onPageChanged;
  final Widget? emptyWidget;
  final Widget? Function(dynamic item)? cardBuilder;
  final List<dynamic>? items;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.rows,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoading = false,
    this.searchQuery,
    this.onSearch,
    this.onPageChanged,
    this.emptyWidget,
    this.cardBuilder,
    this.items,
  });

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (widget.onSearch != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch!('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: widget.onSearch,
            ),
          ),
        Expanded(
          child: widget.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: theme.colorScheme.primary,
                  ),
                )
              : widget.rows.isEmpty
                  ? (widget.emptyWidget ??
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withAlpha(80),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.inbox_rounded,
                                size: 48,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune donnée trouvée',
                              style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600 &&
                            widget.cardBuilder != null &&
                            widget.items != null) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            itemCount: widget.items!.length,
                            itemBuilder: (context, index) {
                              return widget.cardBuilder!(widget.items![index]);
                            },
                          );
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DataTable(
                            headingRowHeight: 52,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 64,
                            horizontalMargin: 24,
                            columnSpacing: 32,
                            headingRowColor: WidgetStateProperty.all(
                              theme.colorScheme.surfaceContainerHighest
                                  .withAlpha(80),
                            ),
                            columns: widget.columns,
                            rows: widget.rows,
                          ),
                        );
                      },
                    ),
        ),
        if (widget.lastPage > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.total} résultat(s)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Page ${widget.currentPage}/${widget.lastPage}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed:
                          widget.currentPage > 1 && widget.onPageChanged != null
                              ? () => widget.onPageChanged!(
                                  widget.currentPage - 1)
                              : null,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            widget.currentPage > 1
                                ? theme.colorScheme.surfaceContainerHighest
                                    .withAlpha(120)
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(120),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.currentPage}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed:
                          widget.currentPage < widget.lastPage &&
                                  widget.onPageChanged != null
                              ? () => widget.onPageChanged!(
                                  widget.currentPage + 1)
                              : null,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            widget.currentPage < widget.lastPage
                                ? theme.colorScheme.surfaceContainerHighest
                                    .withAlpha(120)
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
