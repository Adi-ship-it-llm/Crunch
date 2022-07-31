import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:koduko/components/create_routine_bottom_sheet.dart';
import 'package:koduko/models/routine.dart';
import 'package:koduko/screens/start_routine.dart';
import 'package:koduko/services/routines_provider.dart';
import 'package:koduko/utils/time_of_day_util.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class RoutineTile extends StatelessWidget {
  const RoutineTile({
    Key? key,
    required this.routine,
    this.isToday = false,
    required this.onEdit,
  }) : super(key: key);
  final Routine routine;
  final bool isToday;
  final void Function(Routine) onEdit;

  void onLongPress(BuildContext context) async {
    Routine? r = await showModalBottomSheet<Routine>(
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
            bottom: Radius.zero,
          ),
        ),
        context: context,
        builder: ((context) => CreateRoutineBottomSheet(
              editRoutine: routine,
            )));
    if (r != null) {
      onEdit(routine.copyWith(
        name: r.name,
        tasks: r.tasks,
        days: r.days,
        time: r.time != null ? dateTimeToTimeOfDay(r.time!) : null,
      ));
    }
  }

  void onPress(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => RoutineScreen(
                  routine: routine,
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Slidable(
        key: Key(routine.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
              closeOnCancel: true,
              confirmDismiss: () async {
                bool? tok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertOnDelete(
                          onCancel: () {
                            Navigator.pop(context, false);
                          },
                          onDelete: () {
                            Navigator.pop(context, true);
                          },
                        ));
                if (tok != null) {
                  return tok;
                }
                return false;
              },
              onDismissed: () {
                Provider.of<RoutineModel>(context, listen: false)
                    .delete(routine.id);
              }),
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                    child: TextButton.icon(
                  onPressed: (() {
                    showDialog(
                        context: context,
                        builder: ((context) => AlertOnDelete(onCancel: () {
                              Navigator.pop(context);
                            }, onDelete: (() {
                              Provider.of<RoutineModel>(context, listen: false)
                                  .delete(routine.id);
                              Navigator.pop(context);
                            }))));
                  }),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red[300],
                  ),
                  label: Text(
                    "Delete",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .apply(color: Colors.red[300]),
                  ),
                )),
              ),
            )
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                    child: TextButton.icon(
                  onPressed: (() {
                    onLongPress(context);
                  }),
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue[300],
                  ),
                  label: Text(
                    "Edit",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .apply(color: Colors.blue[300]),
                  ),
                )),
              ),
            )
          ],
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
                title: Hero(
                  tag: routine.name,
                  child: Text(
                    routine.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                subtitle: isToday
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            routine.inCompletedTasks.isEmpty
                                ? const Text("Completed")
                                : Text(
                                    'Completed ${routine.tasks.length - routine.inCompletedTasks.length} out of ${routine.tasks.length}'),
                            const SizedBox(height: 5),
                            LinearPercentIndicator(
                              animateFromLastPercent: true,
                              animation: true,
                              percent: routine.getPercentage(),
                              barRadius: const Radius.circular(10),
                              lineHeight: 3,
                              progressColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      )
                    : Text(routine.getDays()),
                trailing: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onPress(context);
                    },
                    icon: isToday
                        ? Icon(
                            routine.isCompleted
                                ? Icons.replay_rounded
                                : Icons.play_arrow_rounded,
                            size: 30,
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            size: 30,
                          ))),
          ),
        ),
      ),
    );
  }
}

class AlertOnDelete extends StatelessWidget {
  const AlertOnDelete({
    Key? key,
    required this.onCancel,
    required this.onDelete,
  }) : super(key: key);
  final void Function() onCancel;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete routine?"),
      content: const Text(
          "This routine will be deleted. This will remove all the history of this routine as well."),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text("CANCEL"),
        ),
        TextButton(
          style: TextButton.styleFrom(primary: Theme.of(context).errorColor),
          onPressed: onDelete,
          child: const Text("DELETE"),
        )
      ],
    );
  }
}
