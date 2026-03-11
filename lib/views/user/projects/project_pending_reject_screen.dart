import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/core/utils/screen_size.dart';
import 'package:srv_paperless/viewmodel/budget_year_view_model.dart';
import 'package:srv_paperless/viewmodel/project_view_model.dart';
import 'package:srv_paperless/widgets/custom_button.dart';
import 'package:srv_paperless/widgets/custom_dropdown.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../../core/routes/app_routes.dart';
import '../../../widgets/project/project_list_view_widget.dart';

class ProjectPendingAndRejectScreen extends ConsumerStatefulWidget {
  const ProjectPendingAndRejectScreen({super.key});

  @override
  ConsumerState<ProjectPendingAndRejectScreen> createState() =>
      _ProjectPendingAndRejectScreenState();
}

class _ProjectPendingAndRejectScreenState
    extends ConsumerState<ProjectPendingAndRejectScreen> {
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
    final pendingProject = ref.watch(pendingProjectsProvider);
    final rejectProject = ref.watch(rejectedProjectsProvider);

    return DefaultTabController(
      length: 2,
      child: MenuWidget(
        title: const HeaderLogoWithBackButton(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitleSmall(
                      title: "ติดตามสถานะ",
                      des: "ตรวจสอบและติดตามความคืบหน้าของโครงการ",
                    ),
                  ],
                ),
              ),
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
                          Icon(Icons.hourglass_empty_rounded, size: 18),
                          SizedBox(width: 8),
                          Text("รออนุมัติ"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_problem_rounded, size: 18),
                          SizedBox(width: 8),
                          Text("ถูกปฏิเสธ"),
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
                        projectsAsync: pendingProject,
                        emptyMessage: "ไม่มีรายการที่รออนุมัติในขณะนี้",
                        routePath: AppRoutes.projectDraft,
                        onRefresh: () async {
                          ref.invalidate(pendingProjectsProvider);
                        },
                      ),
                      ProjectListViewWidget(
                        projectsAsync: rejectProject,
                        emptyMessage: "ยังไม่มีรายการที่ถูกปฏิเสธ",
                        routePath: AppRoutes.projectDraft,
                        onRefresh: () async {
                          ref.invalidate(rejectedProjectsProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  height: 55,
                  text: const Text(
                    "สร้างโครงการใหม่",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  border: 15,
                  color: const Color(0xff3A9AB5),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.projectDraft);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
