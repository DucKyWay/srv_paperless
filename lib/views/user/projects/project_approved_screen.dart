import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/budget_year_view_model.dart';
import 'package:srv_paperless/widgets/custom_dropdown.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/screen_size.dart';
import '../../../viewmodel/auth_view_model.dart';
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
    final startedProjects = ref.watch(startedProjectsProvider);

    return DefaultTabController(
      length: 2,
      child: MenuWidget(
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.08),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text("อนุมัติแล้ว"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text("เริ่มโครงการ"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ProjectListViewWidget(
                          projectsAsync: approvedProjects,
                          emptyMessage: "ยังไม่มีรายการที่อนุมัติ",
                          routePath: AppRoutes.projectApprovedSubmit,
                          onRefresh: () async {
                            ref.invalidate(approvedProjectsProvider);
                          },
                        ),
                        ProjectListViewWidget(
                          projectsAsync: startedProjects,
                          emptyMessage: "ยังไม่มีโครงการที่เริ่มดำเนินการ",
                          routePath: AppRoutes.projectApprovedSubmit,
                          onRefresh: () async {
                            ref.invalidate(startedProjectsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
