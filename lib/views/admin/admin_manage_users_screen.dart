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
      title: HeaderWithBackButton(),
      child: Column(
        children: [
          TitleNormal(),
          Expanded(
            child: usersAsync.when(
              data:
                  (users) => ListView.builder(
                    itemCount: users.length,
                    padding: EdgeInsets.all(16),

                    itemBuilder: (context, index) {
                      final user = users[index];
                      final division = ref.watch(
                        divisionsByKey(user.divisions),
                      );

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black45, width: 1.0),
                        ),
                        child: ListTile(
                          title: Expanded(
                            child: Text(
                              user.fullname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          subtitle: Expanded(
                            child: Text(division.value?.label ?? ''),
                          ),
                          //TODO: use profile image?
                          leading: Icon(Icons.person),
                          tileColor: Colors.white,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade700,
                                ),
                                onPressed:
                                    () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.adminManageUsers,
                                      arguments: user.id,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              error: (err, stack) => Center(child: Text('Error: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
