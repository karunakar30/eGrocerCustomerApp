import 'package:GreenfieldNaturals/helper/utils/generalImports.dart';

class CancelProductDialog extends StatelessWidget {
  final Order order;
  final String orderItemId;

  const CancelProductDialog(
      {Key? key, required this.order, required this.orderItemId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (context.read<UpdateOrderStatusProvider>().getUpdateOrderStatus() ==
            UpdateOrderStatus.inProgress) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: AlertDialog(
        title: CustomTextLabel(
            jsonKey:"sure_to_cancel_product",
        ),
        actions: [
          Consumer<UpdateOrderStatusProvider>(builder: (context, provider, _) {
            if (provider.getUpdateOrderStatus() ==
                UpdateOrderStatus.inProgress) {
              return const Center(
                child: CustomCircularProgressIndicator(),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: CustomTextLabel(
                    jsonKey: "no",
                    style: TextStyle(color: ColorsRes.mainTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<UpdateOrderStatusProvider>().updateStatus(
                        order: order,
                        orderItemId: orderItemId,
                        status: Constant.orderStatusCode[6],
                        context: context).then((value) => Navigator.pop(context,value));
                  },
                  child: CustomTextLabel(
                    jsonKey:"yes",
                    style: TextStyle(color: ColorsRes.appColor),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
