import 'package:flutter/material.dart';

import '../../../services/constants/constants.dart';
import '../../../size_config/size_config.dart';

class CardLayout extends StatelessWidget {
  const CardLayout({
    super.key,
    required this.link,
    required this.viewAnyLink,
    required this.detailsCard,
    required this.buttonRow,
    required this.menuButton,
    required this.navigationFunction,
  });
  final String link;
  final Widget viewAnyLink;
  final Widget detailsCard;
  final Widget buttonRow;
  final Function() navigationFunction;
  final Widget menuButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(defaultPadding),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: navigationFunction,
        child: SizedBox(
          height: SizeConfig.screenHeight * .175,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                  child: SizedBox(
                      width: SizeConfig.screenWidth, child: viewAnyLink)),
                      const SizedBox(width: defaultPadding,),
              Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only( top: 8,right: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailsCard,
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              buttonRow,
                              menuButton,
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
