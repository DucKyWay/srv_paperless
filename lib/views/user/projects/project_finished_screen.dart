import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/routes/app_routes.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';

import '../../../core/utils/screen_size.dart';
import '../../../viewmodel/budget_year_view_model.dart';
import '../../../viewmodel/project_view_model.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/menu_header_widget.dart';
import '../../../widgets/project/project_list_view_widget.dart';
import '../../../widgets/title_widget.dart';

class ProjectFinishedScreen extends ConsumerStatefulWidget {
  const ProjectFinishedScreen({super.key});

  @override
  ConsumerState<ProjectFinishedScreen> createState() =>
      _ProjectFinishedScreenState();
}

class _ProjectFinishedScreenState extends ConsumerState<ProjectFinishedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final thisYear = await ref.read(budgetYearByThisYearProvider.future);
      if (thisYear != null && mounted) {
        ref.read(selectedBudgetYearProvider.notifier).setYear(thisYear.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final budgetYearsAsync = ref.watch(allBudgetYearsProvider);
    final selectedYearId = ref.watch(selectedBudgetYearProvider);
    final finishedProject = ref.watch(finishedProjectProvider);

    return MenuWidget(
      title: HeaderLogoWithBackButton(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวและ Dropdown เลือกปี
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.08, 24, width * 0.08, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleSmall(
                    title: "โครงการสำเร็จ",
                    des: "ตรวจสอบและติดตามโครงการที่ดำเนินเสร็จสิ้น",
                  ),
                  const SizedBox(height: 20),
                  budgetYearsAsync.when(
                    data: (years) {
                      return CustomDropdown(
                        label: "เลือกปีงบประมาณ",
                        value: selectedYearId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("แสดงทั้งหมด"),
                          ),
                          ...years.map(
                            (y) => DropdownMenuItem(
                              value: y.id,
                              child: Text("ปีงบประมาณ ${y.year}"),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          ref
                              .read(selectedBudgetYearProvider.notifier)
                              .setYear(val);
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: ProjectListViewWidget(
                  projectsAsync: finishedProject,
                  emptyMessage: "ไม่มีรายการที่เสร็จสิ้นในขณะนี้",
                  routePath: AppRoutes.projectFinishedDetail,
                  onRefresh: () async {
                    ref.invalidate(finishedProjectProvider);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
