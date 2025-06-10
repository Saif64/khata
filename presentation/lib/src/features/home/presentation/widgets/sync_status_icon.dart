import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_state.dart';

class SyncStatusIcon extends StatelessWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          switch (state.syncStatus) {
            case 'Syncing':
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.0)),
              );
            case 'Error':
              return const Icon(FontAwesomeIcons.arrowsRotate,
                  color: Colors.red);
            default:
              return Container();
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}
