
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static Future<void> getValue() async {
    await FirebaseRemoteConfig.instance.fetchAndActivate();
    await FirebaseRemoteConfig.instance.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 0),
        minimumFetchInterval: Duration(seconds: 0),
      ),
    );
  }
}
