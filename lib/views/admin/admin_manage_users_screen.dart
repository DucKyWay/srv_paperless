import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srv_paperless/viewmodel/user_view_model.dart';
import 'package:srv_paperless/widgets/menu_header_widget.dart';
import 'package:srv_paperless/widgets/menu_widget.dart';
import 'package:srv_paperless/widgets/title_widget.dart';

import '../../core/routes/app_routes.dart';
import '../../viewmodel/divisions_view_model.dart';

class AdminManageUsersScreen extends ConsumerStatefulWidget {
  const AdminManageUsersScreen({super.key});

  @override
  ConsumerState<AdminManageUsersScreen> createState() =>
      _AdminManageUsersScreenState();
}

class _AdminManageUsersScreenState
    extends ConsumerState<AdminManageUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return MenuWidget(
      title: const HeaderWithBackButton(),
      child: Column(
        children: [
          const TitleNormal(des: "จัดการข้อมูลผู้ใช้"),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
                }
                return ListView.builder(
                  itemCount: users.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final division = ref.watch(divisionsByKey(user.divisions));

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        title: Text(
                          user.fullname,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          division.value?.label ?? 'ไม่ระบุฝ่ายงาน',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.adminManageUsers,
                              arguments: user.id,
                            ),
                      ),
                    );
                  },
                );
              },
              error:
                  (err, stack) => Center(child: Text('เกิดข้อผิดพลาด: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
