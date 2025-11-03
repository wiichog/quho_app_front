import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quho_app/core/routes/route_names.dart';
import 'package:quho_app/core/utils/validators.dart';
import 'package:quho_app/shared/design_system/design_system.dart';
import 'package:quho_app/shared/widgets/buttons/primary_button.dart';
import 'package:quho_app/shared/widgets/inputs/custom_text_field.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _incomeController = TextEditingController();
  final _rentController = TextEditingController();
  final _savingsGoalController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _rentController.dispose();
    _savingsGoalController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() {
    // TODO: Guardar datos y crear presupuesto inicial
    // Por ahora solo navegamos al dashboard
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: AppSpacing.paddingHorizontalLg,
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 4,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _IncomePage(
                    controller: _incomeController,
                    onNext: _nextPage,
                  ),
                  _ExpensesPage(
                    rentController: _rentController,
                    onNext: _nextPage,
                  ),
                  _SavingsGoalPage(
                    controller: _savingsGoalController,
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.gradientHero,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: AppColors.white,
              size: 60,
            ),
          ),

          AppSpacing.verticalXl,

          Text(
            '¡Bienvenido a QUHO!',
            style: AppTextStyles.h1(),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalMd,

          Text(
            'Vamos a configurar tu perfil financiero en solo 3 pasos',
            style: AppTextStyles.bodyLarge(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalXxl,

          PrimaryButton(
            text: 'Comenzar',
            onPressed: onNext,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}

class _IncomePage extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _IncomePage({
    required this.controller,
    required this.onNext,
  });

  @override
  State<_IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<_IncomePage> {
  final _formKey = GlobalKey<FormState>();

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalXl,

            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.tealPale,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.attach_money,
                color: AppColors.teal,
                size: 40,
              ),
            ),

            AppSpacing.verticalLg,

            Text('¿Cuál es tu ingreso mensual?', style: AppTextStyles.h2()),

            AppSpacing.verticalSm,

            Text(
              'Esto nos ayudará a crear tu presupuesto personalizado',
              style: AppTextStyles.bodyMedium(color: AppColors.gray600),
            ),

            AppSpacing.verticalXl,

            CustomTextField(
              controller: widget.controller,
              label: 'Ingreso Mensual',
              hint: '15000',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.monetization_on_outlined,
              validator: Validators.amount,
            ),

            AppSpacing.verticalXl,

            PrimaryButton(
              text: 'Continuar',
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensesPage extends StatefulWidget {
  final TextEditingController rentController;
  final VoidCallback onNext;

  const _ExpensesPage({
    required this.rentController,
    required this.onNext,
  });

  @override
  State<_ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<_ExpensesPage> {
  final _formKey = GlobalKey<FormState>();

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalXl,

            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.orange,
                size: 40,
              ),
            ),

            AppSpacing.verticalLg,

            Text('Gastos Principales', style: AppTextStyles.h2()),

            AppSpacing.verticalSm,

            Text(
              'Cuéntanos sobre tus gastos fijos más importantes',
              style: AppTextStyles.bodyMedium(color: AppColors.gray600),
            ),

            AppSpacing.verticalXl,

            CustomTextField(
              controller: widget.rentController,
              label: 'Renta/Hipoteca (opcional)',
              hint: '5000',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.home_outlined,
            ),

            AppSpacing.verticalXl,

            PrimaryButton(
              text: 'Continuar',
              onPressed: _handleNext,
            ),

            AppSpacing.verticalMd,

            Center(
              child: TextButton(
                onPressed: widget.onNext,
                child: Text(
                  'Omitir por ahora',
                  style: AppTextStyles.bodyMedium(color: AppColors.gray600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsGoalPage extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onComplete;

  const _SavingsGoalPage({
    required this.controller,
    required this.onComplete,
  });

  @override
  State<_SavingsGoalPage> createState() => _SavingsGoalPageState();
}

class _SavingsGoalPageState extends State<_SavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();

  void _handleComplete() {
    if (_formKey.currentState!.validate()) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.verticalXl,

            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                color: AppColors.green,
                size: 40,
              ),
            ),

            AppSpacing.verticalLg,

            Text('Meta de Ahorro', style: AppTextStyles.h2()),

            AppSpacing.verticalSm,

            Text(
              '¿Cuánto te gustaría ahorrar mensualmente?',
              style: AppTextStyles.bodyMedium(color: AppColors.gray600),
            ),

            AppSpacing.verticalXl,

            CustomTextField(
              controller: widget.controller,
              label: 'Meta de Ahorro Mensual',
              hint: '3000',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.flag_outlined,
              validator: Validators.positiveAmount,
            ),

            AppSpacing.verticalXl,

            PrimaryButton(
              text: '¡Comenzar!',
              onPressed: _handleComplete,
              icon: Icons.check_circle_outline,
            ),

            AppSpacing.verticalMd,

            Center(
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'Configurar después',
                  style: AppTextStyles.bodyMedium(color: AppColors.gray600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

