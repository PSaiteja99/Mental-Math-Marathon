import 'package:flutter/material.dart';

class EndScrollView extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final List<Widget>? yLabels;
  final double labelWidth;
  final double topPadding;

  const EndScrollView({
    super.key,
    required this.child,
    required this.height,
    required this.width,
    this.yLabels,
    this.labelWidth = 40,
    this.topPadding = 0, 
  });

  @override
  State<EndScrollView> createState() => _EndScrollViewState();
}

class _EndScrollViewState extends State<EndScrollView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_scrollToEnd);
  }

  @override
  void didUpdateWidget(EndScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width) {
      WidgetsBinding.instance.addPostFrameCallback(_scrollToEnd);
    }
  }

  void _scrollToEnd(_) {
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final totalHeight = widget.height + widget.topPadding;

    final chart = SizedBox(
      height: totalHeight,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          width: widget.width,
          height: totalHeight,
          child: Padding(
            padding: EdgeInsets.only(top: widget.topPadding),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.yLabels == null || widget.yLabels!.isEmpty) {
      return chart;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.labelWidth,
          height: totalHeight,
          child: Stack(
            children: [
              Container(color: bgColor),
              Padding(
                padding: EdgeInsets.only(top: widget.topPadding, bottom: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.yLabels!,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: chart),
      ],
    );
  }
}
