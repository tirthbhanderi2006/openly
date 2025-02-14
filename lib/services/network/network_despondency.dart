import 'package:get/get.dart';
import 'package:mithc_koko_chat_app/controllers/network_controller.dart';

class DependencyInjection{
  static void init(){
    Get.put<NetworkController>(NetworkController(),permanent: true);
  }
}