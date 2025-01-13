import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/components/user_tile.dart';
import 'package:mithc_koko_chat_app/services/chat_services.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text('BLOCKED USERS'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String,dynamic>>>(stream: ChatServices().getBlockedUsersStream(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
        if(snapshot.hasError){
          return Center(child: Text("Error : ${snapshot.error}"),);
        }
        if(snapshot.connectionState==ConnectionState.waiting){
          return Center(child: Text('Loading'),);
        }
        final blockeduser=snapshot.data ?? [];
        if(blockeduser.isEmpty){
          return Center(child: Text('No Blocked user found'),);
        }
        return ListView.builder(itemBuilder: (context, index) {
          final user= blockeduser[index];
          return UserTile(text: user['email'], onTap: ()=>_showUnblockDialog(context: context,userId: user['uid']), userId: user['uid'],imgUrl: user['profilePic'],);
        },itemCount: blockeduser.length,);
        },),
    );
  }

  void _showUnblockDialog({required BuildContext context,required String userId}){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('unblock user'),
      content: Text('Are you sure you want to unblock this user?'),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text('cancel')),
        TextButton(onPressed: (){
          ChatServices().unblockUser(userId);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User Unblocked!')));
        }, child: Text('Unblock user'))
      ],
    ),);
  }

}
