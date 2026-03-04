import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/data/model/budget_year_model.dart';
import 'package:srv_paperless/viewmodel/budget_year_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';
import 'package:srv_paperless/widgets/alert_confirm_widget.dart';

class AdminManageBudgetYearScreen extends ConsumerStatefulWidget {
  const AdminManageBudgetYearScreen({super.key});

  @override
  ConsumerState<AdminManageBudgetYearScreen> createState() =>
      _AdminManageBudgetYearScreenState();
}

class _AdminManageBudgetYearScreenState
    extends ConsumerState<AdminManageBudgetYearScreen> {
  @override
  Widget build(BuildContext context) {
    final budgetYearsAsync = ref.watch(allBudgetYearsProvider);

    return MenuWidget(
      title: const HeaderWithBackButton(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDialog(),
      ),
      child: budgetYearsAsync.when(
        data: (budgetYears) {
          return SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TitleNormal(title: "จัดการข้อมูล", des: "ปีงบประมาณ"),
                  const SizedBox(height: 8),
                  if (budgetYears.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text("ไม่พบข้อมูล"),
                    )
                  else
                    ...budgetYears.map((year) => _card(context, year)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
        error: (e, _) => Center(child: Text("เกิดข้อผิดพลาด: $e")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _card(BuildContext context, BudgetYear budgetYear) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: budgetYear.thisYear ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: budgetYear.thisYear ? Colors.green : Colors.black45,
          width: budgetYear.thisYear ? 2.0 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ปีงบประมาณ ${budgetYear.year}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (budgetYear.thisYear)
                  Text(
                    "ปีปัจจุบัน",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              if (!budgetYear.thisYear)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.white,
                    onPressed: () => _showSetCurrentDialog(budgetYear),
                    tooltip: "ตั้งเป็นปีปัจจุบัน",
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.white,
                  onPressed: () => _showDeleteDialog(budgetYear),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("เพิ่มปีงบประมาณ"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "ปีงบประมาณ (พ.ศ.)",
                hintText: "เช่น 2569",
              ),
            ),
            actions: [
              CancelAndConfirmRowWidget(
                onConfirm: () async {
                  final year = int.tryParse(controller.text);
                  if (year != null) {
                    await ref
                        .read(budgetYearViewModelProvider.notifier)
                        .createBudgetYear(year);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }

  void _showSetCurrentDialog(BudgetYear budgetYear) {
    showDialog(
      context: context,
      builder:
          (context) => AlertConfirmWidget(
            title:
                "คุณต้องการตั้งปี ${budgetYear.year} เป็นปีงบประมาณปัจจุบันใช่หรือไม่?",
            onConfirm: () async {
              if (budgetYear.id != null) {
                await ref
                    .read(budgetYearViewModelProvider.notifier)
                    .setThisYear(budgetYear.id!);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
    );
  }

  void _showDeleteDialog(BudgetYear budgetYear) {
    showDialog(
      context: context,
      builder:
          (context) => AlertConfirmWidget(
            title: "คุณต้องการลบปีงบประมาณ ${budgetYear.year} ใช่หรือไม่?",
            onConfirm: () async {
              if (budgetYear.id != null) {
                await ref
                    .read(budgetYearViewModelProvider.notifier)
                    .deleteBudgetYear(budgetYear.id!);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
    );
  }
}
