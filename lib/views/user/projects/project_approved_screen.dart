import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/budget_year_view_model.dart';
import 'package:srv_paperless/widgets/custom_dropdown.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/screen_size.dart';
import '../../../viewmodel/project_view_model.dart';
import '../../../widgets/menu_header_widget.dart';
import '../../../widgets/project/project_list_view_widget.dart';
import '../../../widgets/title_widget.dart';

class ProjectApproved extends ConsumerStatefulWidget {
  const ProjectApproved({super.key});

  @override
  ConsumerState<ProjectApproved> createState() => _ProjectApprovedState();
}

class _ProjectApprovedState extends ConsumerState<ProjectApproved> {
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
    final approvedProjects = ref.watch(approvedProjectsProvider);

    return MenuWidget(
      title: const HeaderWithBackButton(),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              const TitleNormal(title: "ติดตามโครงการ"),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: budgetYearsAsync.when(
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
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: ProjectListViewWidget(
                    projectsAsync: approvedProjects,
                    emptyMessage: "ยังไม่มีรายการที่อนุมัติ",
                    routePath: AppRoutes.budgetProjectRequest,
                    onRefresh: () async {
                      ref.invalidate(approvedProjectsProvider);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
