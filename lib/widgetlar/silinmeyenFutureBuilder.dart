// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SilinmeyenFutureBuilder extends StatefulWidget {
  final Future future;
  final AsyncWidgetBuilder builder;

  const SilinmeyenFutureBuilder({
    Key? key,
    required this.future,
    required this.builder,
  }) : super(key: key);

  @override
  State<SilinmeyenFutureBuilder> createState() =>
      _SilinmeyenFutureBuilderState();
}

class _SilinmeyenFutureBuilderState extends State<SilinmeyenFutureBuilder>
    with AutomaticKeepAliveClientMixin<SilinmeyenFutureBuilder> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(future: widget.future, builder: widget.builder);
  }
}
