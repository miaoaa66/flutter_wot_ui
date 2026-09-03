import 'package:flutter/material.dart';

import '../../theme/wot_theme.dart';
import '../icon/wot_icon.dart';

/// 搜索框，对应 wot `wd-search`。
class WotSearch extends StatefulWidget {
  const WotSearch({
    super.key,
    this.modelValue,
    this.onChange,
    this.placeholder = '搜索',
    this.disabled = false,
    this.readonly = false,
    this.clearable = true,
    this.shape = 'round',
    this.background,
    this.showAction = false,
    this.actionText = '搜索',
    this.onSearch,
    this.onClickAction,
    this.onClickInput,
    this.searchIconColor,
  });

  final String? modelValue;
  final ValueChanged<String>? onChange;
  final String placeholder;
  final bool disabled;
  final bool readonly;
  final bool clearable;
  final String shape;
  final Color? background;
  final bool showAction;
  final String actionText;
  final VoidCallback? onSearch;
  final VoidCallback? onClickAction;
  final VoidCallback? onClickInput;
  final Color? searchIconColor;

  @override
  State<WotSearch> createState() => _WotSearchState();
}

class _WotSearchState extends State<WotSearch> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.modelValue ?? '');
  }

  @override
  void didUpdateWidget(WotSearch old) {
    super.didUpdateWidget(old);
    if (widget.modelValue != null && widget.modelValue != _c.text) {
      _c.value = _c.value.copyWith(text: widget.modelValue);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _search() {
    widget.onSearch?.call();
    widget.onClickAction?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.wotScheme;
    final radius = widget.shape == 'round'
        ? const BorderRadius.all(Radius.circular(18))
        : const BorderRadius.all(Radius.circular(6));
    final bg = widget.background ?? scheme.filledStrong;

    final field = TextField(
      controller: _c,
      enabled: !widget.disabled,
      readOnly: widget.readonly,
      onChanged: widget.onChange,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _search(),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: TextStyle(fontSize: 14, color: scheme.textMain),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(fontSize: 14, color: scheme.textPlaceholder),
        border: InputBorder.none,
        counterText: '',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );

    final box = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: Row(
        children: [
          WotIcon(name: 'search', size: 16, color: widget.searchIconColor ?? scheme.iconAuxiliary),
          const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(onTap: widget.onClickInput, child: field),
          ),
          if (widget.clearable && _c.text.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _c.clear();
                widget.onChange?.call('');
                setState(() {});
              },
              child: WotIcon(name: 'close-circle', size: 14, color: scheme.iconAuxiliary),
            ),
        ],
      ),
    );

    final action = widget.showAction
        ? InkWell(
            onTap: widget.disabled ? null : _search,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                widget.actionText,
                style: TextStyle(fontSize: 14, color: scheme.primaryOf(6)),
              ),
            ),
          )
        : null;

    return Row(
      children: [
        Expanded(child: box),
        ?action,
      ],
    );
  }
}