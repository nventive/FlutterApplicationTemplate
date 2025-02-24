import 'package:app/presentation/mvvm/view_model.dart';
import 'package:flutter/widgets.dart';

class MvvmWidget<TViewModel extends ViewModel> extends StatefulWidget {
  const MvvmWidget(
      {super.key,
      TViewModel? viewModel,
      Widget Function(BuildContext context, TViewModel viewModel)? build})
      : _viewModelFromParameter = viewModel,
        _buildFunctionFromParameter = build;

  final TViewModel? _viewModelFromParameter;
  final Widget Function(BuildContext context, TViewModel viewModel)?
      _buildFunctionFromParameter;

  TViewModel getViewModel() {
    if (_viewModelFromParameter != null) {
      return _viewModelFromParameter;
    }

    throw Exception(
        'You must override getViewModel or provide a viewModel parameter.');
  }

  @override
  State<StatefulWidget> createState() {
    return _MvvmWidgetState();
  }

  Widget build(BuildContext context, TViewModel viewModel) {
    if (_buildFunctionFromParameter != null) {
      return _buildFunctionFromParameter(context, viewModel);
    }

    throw Exception('You must override build or provide a build parameter.');
  }
}

class _MvvmWidgetState<TViewModel extends ViewModel>
    extends State<MvvmWidget<TViewModel>> {
  late TViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.getViewModel();
    _viewModel.addListener(onPropertyChanged);
  }

  void onPropertyChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.removeListener(onPropertyChanged);
    _viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.startRecordingPropertiesToNotify();
    final result = widget.build(context, _viewModel);
    _viewModel.stopRecordingPropertiesToNotify();
    return result;
  }
}
