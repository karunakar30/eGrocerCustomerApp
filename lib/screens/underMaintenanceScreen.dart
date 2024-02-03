import 'package:GreenfieldNaturals/helper/utils/generalImports.dart';
import 'package:lottie/lottie.dart';

class UnderMaintenanceScreen extends StatelessWidget {
  const UnderMaintenanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Constant.size10,
          horizontal: Constant.size10,
        ),
        child: Center(
          child: Container(
            decoration:
                DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  Constant.getAssetsPath(3, "under_maintenance"),
                  width: MediaQuery.sizeOf(context).width,
                  repeat: true,
                ),
                Widgets.getSizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Constant.size5,
                    horizontal: Constant.size10,
                  ),
                  child: CustomTextLabel(
                    jsonKey: "app_under_maintenance",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: ColorsRes.appColor,
                          fontWeight: FontWeight.w500,
                        ),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Constant.size5,
                    horizontal: Constant.size10,
                  ),
                  child: CustomTextLabel(
                    text: Constant.appMaintenanceModeRemark,
                    textAlign: TextAlign.center,
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
