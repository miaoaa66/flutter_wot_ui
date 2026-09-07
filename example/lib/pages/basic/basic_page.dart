import 'package:flutter/material.dart';
import 'package:flutter_wot_ui/flutter_wot_ui.dart';

/// 基础组件演示页（Button/Icon/Text/Row/Col/Cell）。
class WotBasicPage extends StatelessWidget {
  const WotBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础组件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('WotButton 按钮（type / size / variant / round / block / loading）'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const WotButton(text: '主要'),
              const WotButton(text: '成功', type: WotButtonType.success),
              const WotButton(text: '警告', type: WotButtonType.warning),
              const WotButton(text: '危险', type: WotButtonType.danger),
              const WotButton(text: '信息', type: WotButtonType.info),
              WotButton(
                text: '点击',
                type: WotButtonType.success,
                onClick: () => _toast(context, '点击了按钮'),
              ),
              const WotButton(text: '主色 line', variant: WotButtonVariant.plain),
              const WotButton(text: '虚线', variant: WotButtonVariant.dashed),
              const WotButton(text: '柔和', variant: WotButtonVariant.soft),
              const WotButton(text: '浅淡', variant: WotButtonVariant.subtle),
              const WotButton(text: '文字', variant: WotButtonVariant.text),
              const WotButton(text: '禁用', disabled: true),
              const WotButton(text: '加载中', loading: true),
              WotButton(
                text: '块状大号',
                size: WotButtonSize.large,
                block: true,
                round: true,
                color: const Color(0xFF12B886),
                onClick: () => _toast(context, '块状按钮'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotIcon 图标（Material 兜底渲染）'),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              WotIcon(name: 'add', size: 24),
              WotIcon(name: 'close', size: 24, color: Color(0xFFF14646)),
              WotIcon(name: 'star', size: 24, color: Color(0xFFFAAD14)),
              WotIcon(name: 'heart', size: 24, color: Color(0xFFFF357C)),
              WotIcon(name: 'search', size: 24),
              WotIcon(name: 'arrow-left', size: 24),
              WotIcon(name: 'settings', size: 24),
              WotIcon(name: 'user', size: 24),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotText 文本（type 主题色）'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              WotText('默认灰色 Default（textAuxiliary）', size: 16),
              WotText('主色 Primary', type: WotTextType.primary),
              WotText('成功 Success', type: WotTextType.success),
              WotText('警告 Warning', type: WotTextType.warning),
              WotText('错误 Error', type: WotTextType.error),
              WotText('加粗 Bold', bold: true),
              WotText('这个是超长省略文本这个是超长省略文本这个是超长省略文本', lines: 1),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotText 前后缀 / 装饰线 / 点击'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WotText('前后缀文本', prefix: '【', suffix: '】', size: 16),
              WotText('下划线装饰', decoration: TextDecoration.underline, size: 16),
              WotText('中划线装饰', decoration: TextDecoration.lineThrough, size: 16),
              WotText(
                '点击我（触发反馈）',
                type: WotTextType.primary,
                bold: true,
                decoration: TextDecoration.underline,
                onTap: () => _toast(context, '点击了 WotText'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotInput 输入框（前后缀 / 字数 / 焦点）'),
          Column(
            children: [
              WotInput(
                value: '前后缀示例',
                prefix: const WotIcon(name: 'search', size: 16),
                suffix: const WotText('￥', size: 14),
              ),
              const SizedBox(height: 12),
              WotInput(
                placeholder: '最多输入 10 个字（showWordLimit）',
                showWordLimit: true,
                maxlength: 10,
                clearable: true,
              ),
              const SizedBox(height: 12),
              WotInput(
                placeholder: '聚焦 / 失焦演示',
                onFocus: () => _toast(context, '输入框聚焦'),
                onBlur: () => _toast(context, '输入框失焦'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotTextarea 文本域（字数限制）'),
          const WotTextarea(
            placeholder: '请输入备注',
            maxlength: 500,
            rows: 3,
            showWordLimit: true,
          ),
          const SizedBox(height: 20),
          _section('WotRow / WotCol 栅格'),
          WotRow(
            gutter: 8,
            children: [
              WotCol(
                span: 8,
                child: Container(
                  height: 40,
                  color: context.wotScheme.filledStrong,
                  alignment: Alignment.center,
                  child: const WotText('span=8'),
                ),
              ),
              WotCol(
                span: 16,
                child: Container(
                  height: 40,
                  color: context.wotScheme.filledContent,
                  alignment: Alignment.center,
                  child: const WotText('span=16'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _section('WotCell 单元格'),
          const WotCell(title: '单元格标题', value: '值'),
          const WotCell(title: '带箭头', isLink: true),
          const WotCell(title: '带图标', icon: 'star', value: '5.0'),
          const SizedBox(height: 12),
          _section('WotCell 多样场景（图标 / 标题插槽 / 点击 / 必填）'),
          WotCell(title: '必填项', value: '请输入', required: true),
          const WotCell(title: '带图标', icon: 'star', label: '辅助说明文案'),
          WotCell(
            title: '可点击',
            icon: 'settings',
            value: '进入设置',
            isLink: true,
            onClick: () => _toast(context, '点击了 Cell'),
          ),
          WotCell(
            title: '自定义尾部',
            value: '仅只读',
            trailing: const WotTag(text: '只读', type: WotTagType.primary),
            border: false,
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: WotText(title, type: WotTextType.wotDefault, bold: true),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(milliseconds: 800)));
  }
}