import 'package:flutter/material.dart';
import 'package:maid/providers/session.dart';
import 'package:maid/ui/mobile/widgets/tiles/slider_list_tile.dart';
import 'package:provider/provider.dart';

class PresentPenaltyParameter extends StatelessWidget {
  const PresentPenaltyParameter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return SliderListTile(
          labelText: 'Presence Penalty',
          inputValue: session.model.penaltyPresent,
          sliderMin: 0.0,
          sliderMax: 1.0,
          sliderDivisions: 100,
          onValueChanged: (value) {
            session.model.penaltyPresent = value;
            session.notify();
          }
        );
      }
    );
  }
}
