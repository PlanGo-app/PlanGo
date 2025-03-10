import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:plango_front/model/planning_event.dart';
import 'package:plango_front/service/planning_event_service.dart';
import 'package:plango_front/util/constant.dart';
import 'package:plango_front/views/components/rounded_button.dart';
import 'package:plango_front/views/components/warning_animation.dart';
import 'package:plango_front/views/syncfusion/date_picker_widget.dart';
import 'package:plango_front/views/syncfusion/time_picker_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SyncfusionTest extends StatefulWidget {
  int travelId;
  List<PlanningEvent> all = [];
  CalendarDataSource? _dataSource;
  final DateTime dateBegin;
  final DateTime dateEnd;
  final CalendarController _calendarController = CalendarController();

  SyncfusionTest(
      {Key? key,
      required this.dateBegin,
      required this.dateEnd,
      required this.travelId})
      : super(key: key);

  @override
  _SyncfusionTestState createState() => _SyncfusionTestState();
}

class _SyncfusionTestState extends State<SyncfusionTest> {
  DateTime? selectedDate;
  TimeOfDay? beginHour;
  TimeOfDay? endHour;
  DateTime? currentTime;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.all = [];
    widget._dataSource = _getCalendarDataSource();
    PlanningEventService().getPlanningEvents(widget.travelId).then((value) {
      if (value is List<PlanningEvent>) {
        setState(() {
          for (PlanningEvent planningEvent in value) {
            if (planningEvent.date_start != null) {
              createPlanningEvent(planningEvent, context, false);
            } else {
              widget.all.add(planningEvent);
            }
          }
        });
      } else {
        showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            context: context,
            builder: (BuildContext context) {
              return WarningModal(
                text:
                    "Impossible de charger les plannings event pour le moment",
                url_animation: 'assets/lottieanimate/error.json',
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3),
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              ...widget.all
                  .map((planningEvent) => InkWell(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: kPrimaryColor,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            width: 150,
                            child: Center(
                                child: Text(
                              planningEvent.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            )),
                          )),
                      onTap: () {
                        showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25)),
                          ),
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                    StateSetter setModalState) {
                              return Material(
                                  elevation: 20,
                                  child: SizedBox(
                                    height: 300,
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Row(children: [
                                              Expanded(
                                                  flex: 5, child: Container()),
                                              Expanded(
                                                  flex: 5,
                                                  child: TextButton.icon(
                                                      icon: const Icon(
                                                          Icons.delete_forever,
                                                          color: kPrimaryColor),
                                                      label: const Text(
                                                        "Supprimer du voyage",
                                                        style: TextStyle(
                                                            color:
                                                                kPrimaryColor),
                                                      ),
                                                      onPressed: () {
                                                        AlertDialog alert =
                                                            AlertDialog(
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                print(
                                                                    planningEvent
                                                                        .pinId);
                                                                PlanningEventService()
                                                                    .deletePlanningEvent(
                                                                        planningEvent
                                                                            .pinId)
                                                                    .then(
                                                                        (value) {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  if (value
                                                                          .statusCode ==
                                                                      200) {
                                                                    setState(
                                                                        () {
                                                                      widget.all
                                                                          .remove(
                                                                              planningEvent);
                                                                    });
                                                                  } else {
                                                                    showModalBottomSheet(
                                                                        shape:
                                                                            const RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(25),
                                                                              topRight: Radius.circular(25)),
                                                                        ),
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return WarningModal(
                                                                              text: "Le planning event n'a pas pu être supprimé",
                                                                              url_animation: "assets/lottieanimate/error.json");
                                                                        });
                                                                  }
                                                                });
                                                              },
                                                              child: const Text(
                                                                'Supprimer du voyage',
                                                                style: TextStyle(
                                                                    color:
                                                                        kPrimaryLightColor),
                                                              ),
                                                            ),
                                                            TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                child: const Text(
                                                                    'Annuler',
                                                                    style: TextStyle(
                                                                        color:
                                                                            kPrimaryColor))),
                                                          ],
                                                          title: const Text(
                                                            'Etes-vous sûr de vouloir supprimer ce planning event du voyage ?',
                                                            style: TextStyle(
                                                                color:
                                                                    kPrimaryColor),
                                                          ),
                                                        );
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return alert;
                                                          },
                                                        );
                                                      }))
                                            ])),
                                        Expanded(
                                            flex: 3,
                                            child: Row(children: [
                                              Expanded(
                                                  flex: 10,
                                                  child: DatePickerWidget(
                                                    text:
                                                        "${currentTime!.day.toString().padLeft(2, '0')}/${currentTime!.month.toString().padLeft(2, '0')}/${currentTime!.year}",
                                                    beginDate: widget.dateBegin,
                                                    endDate: widget.dateEnd,
                                                    onDateTimeChanged:
                                                        (newDate) {
                                                      setModalState(() {
                                                        selectedDate = newDate;
                                                        print(newDate);
                                                      });
                                                    },
                                                  ))
                                            ])),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: TimePickerWidget(
                                                  text: "Heure de debut",
                                                  onDateTimeChanged:
                                                      (newDateTime) {
                                                    setModalState(() {
                                                      beginHour = newDateTime;
                                                      print(beginHour);
                                                    });
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: TimePickerWidget(
                                                  text: "Heure de fin",
                                                  beginTime: beginHour,
                                                  onDateTimeChanged:
                                                      (newDateTime) {
                                                    setModalState(() {
                                                      endHour = newDateTime;
                                                      print(endHour);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: !verifyData()
                                              ? Container()
                                              : compareData()
                                                  ? const Text(
                                                      "L'heure de debut doit être inferieure à l'heure de fin",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )
                                                  : Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 5,
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: RoundedButton(
                                                                text: "Ajouter",
                                                                press: () {
                                                                  if (selectedDate != null &&
                                                                      beginHour !=
                                                                          null &&
                                                                      endHour !=
                                                                          null) {
                                                                    createPlanningEvent(
                                                                        planningEvent,
                                                                        context,
                                                                        true);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  }
                                                                }),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                        ),
                                      ],
                                    ),
                                  ));
                            });
                          },
                        ).whenComplete(() {
                          selectedDate = currentTime;
                          beginHour = null;
                          endHour = null;
                        });
                      }))
                  .toList(),
              // IgnorePointer(child: Center(child: buildText(text))),
            ]),
          ),
          Expanded(
            flex: 9,
            child: SfCalendar(
              view: CalendarView.day,
              dataSource: widget._dataSource,
              controller: widget._calendarController,
              onViewChanged: viewChanged,
              allowDragAndDrop: true,
              onDragEnd: dragEnd,
              initialDisplayDate: selectedDate,
              timeSlotViewSettings: const TimeSlotViewSettings(
                timeIntervalHeight: 60,
                timeFormat: "HH:mm",
              ),
              minDate: widget.dateBegin,
              maxDate: widget.dateEnd,
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  print(details.appointments!.first);
                  modal(details.appointments!.first);
                }
              },
            ),
          ),
        ],
      ),
    ));
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    SchedulerBinding.instance!.addPostFrameCallback((Duration duration) {
      currentTime = viewChangedDetails.visibleDates.first;
      selectedDate = currentTime;
    });
  }

  bool verifyData() {
    return (selectedDate != null && beginHour != null && endHour != null);
  }

  bool compareData() {
    return ((beginHour!.hour * 60 + beginHour!.minute) -
            (endHour!.hour * 60 + endHour!.minute) >=
        0);
  }

  void createPlanningEvent(PlanningEvent planningEvent, context, bool save) {
    DateTime startTime = planningEvent.date_start ??
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day,
            beginHour!.hour, beginHour!.minute);
    DateTime endTime = planningEvent.date_end ??
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day,
            endHour!.hour, endHour!.minute);
    Appointment app = Appointment(
      notes: "${planningEvent.id}, ${planningEvent.pinId}",
      startTime: startTime,
      endTime: endTime,
      subject: planningEvent.name,
      color: kPrimaryColor,
    );
    print(app);
    if (save) {
      PlanningEventService().updatePlanningEvent(
          int.parse(app.notes!.split(",").first),
          app.subject,
          app.startTime,
          app.endTime);
    }
    widget._dataSource!.appointments!.add(app);
    widget._dataSource!
        .notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
    setState(() {
      widget.all.remove(planningEvent);
      selectedDate = currentTime;
      beginHour = null;
      endHour = null;
    });
  }

  modal(Appointment appointment) {
    setState(() {
      selectedDate = DateTime(appointment.startTime.year,
          appointment.startTime.month, appointment.startTime.day);
      beginHour = TimeOfDay(
          hour: appointment.startTime.hour,
          minute: appointment.startTime.minute);
      endHour = TimeOfDay(
          hour: appointment.endTime.hour, minute: appointment.endTime.minute);
    });
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Material(
              elevation: 20,
              child: SizedBox(
                height: 300,
                child: Column(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Row(children: [
                          Expanded(
                              flex: 5,
                              child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: kPrimaryColor,
                                  ),
                                  label: const Text(
                                    "Retirer du planning",
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                  onPressed: () {
                                    print("DELETE");
                                    PlanningEventService()
                                        .updatePlanningEvent(
                                            int.parse(appointment.notes
                                                .toString()
                                                .split(",")
                                                .first),
                                            appointment.subject,
                                            null,
                                            null)
                                        .then((value) {
                                      if (value.statusCode == 200) {
                                        PlanningEventService()
                                            .getPlanningEvent(int.parse(
                                                appointment.notes
                                                    .toString()
                                                    .split(",")
                                                    .first))
                                            .then((value) {
                                          if (value is PlanningEvent) {
                                            widget._dataSource!.appointments!
                                                .remove(appointment);
                                            widget._dataSource!.notifyListeners(
                                                CalendarDataSourceAction.remove,
                                                <Appointment>[appointment]);
                                            setState(() {
                                              widget.all.add(value);
                                            });
                                            Navigator.of(context).pop();
                                          } else {
                                            showModalBottomSheet(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  25),
                                                          topRight:
                                                              Radius.circular(
                                                                  25)),
                                                ),
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return WarningModal(
                                                    text:
                                                        "Impossible de charger le planning event pour le moment",
                                                    url_animation:
                                                        'assets/lottieanimate/error.json',
                                                  );
                                                });
                                          }
                                        });
                                      } else {
                                        showModalBottomSheet(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  topRight:
                                                      Radius.circular(25)),
                                            ),
                                            context: context,
                                            builder: (BuildContext context) {
                                              return WarningModal(
                                                text:
                                                    "Impossible de supprimer le planning event pour le moment",
                                                url_animation:
                                                    'assets/lottieanimate/error.json',
                                              );
                                            });
                                      }
                                    });
                                  })),
                          Expanded(
                              flex: 5,
                              child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.delete_forever,
                                    color: kPrimaryColor,
                                  ),
                                  label: const Text(
                                    "Supprimer du voyage",
                                    style: TextStyle(color: kPrimaryColor),
                                  ),
                                  onPressed: () {
                                    AlertDialog alert = AlertDialog(
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            PlanningEventService()
                                                .deletePlanningEvent(int.parse(
                                                    appointment.notes!
                                                        .split(",")
                                                        .last))
                                                .then((value) {
                                              Navigator.of(context).pop();
                                              if (value.statusCode == 200) {
                                                widget
                                                    ._dataSource!.appointments!
                                                    .remove(appointment);
                                                widget._dataSource!
                                                    .notifyListeners(
                                                        CalendarDataSourceAction
                                                            .remove,
                                                        <Appointment>[
                                                      appointment
                                                    ]);
                                              } else {
                                                showModalBottomSheet(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(25),
                                                              topRight: Radius
                                                                  .circular(
                                                                      25)),
                                                    ),
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return WarningModal(
                                                          text:
                                                              "Le planning event n'a pas pu être supprimé",
                                                          url_animation:
                                                              "assets/lottieanimate/error.json");
                                                    });
                                              }
                                            });
                                          },
                                          child: const Text(
                                            'Supprimer du voyage',
                                            style: TextStyle(
                                                color: kPrimaryLightColor),
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Annuler',
                                                style: TextStyle(
                                                    color: kPrimaryColor))),
                                      ],
                                      title: const Text(
                                        'Etes-vous sûr de vouloir supprimer ce planning event du voyage ?',
                                        style: TextStyle(color: kPrimaryColor),
                                      ),
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  }))
                        ])),
                    Expanded(
                        flex: 3,
                        child: Row(children: [
                          Expanded(
                              flex: 10,
                              child: DatePickerWidget(
                                text:
                                    "${appointment.startTime.day.toString().padLeft(2, '0')}/${appointment.startTime.month.toString().padLeft(2, '0')}/${appointment.startTime.year}",
                                beginDate: widget.dateBegin,
                                endDate: widget.dateEnd,
                                onDateTimeChanged: (newDate) {
                                  setModalState(() {
                                    selectedDate = newDate;
                                    print(newDate);
                                  });
                                },
                              ))
                        ])),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TimePickerWidget(
                              text:
                                  "${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')}",
                              onDateTimeChanged: (newDateTime) {
                                setModalState(() {
                                  beginHour = newDateTime;
                                  print(beginHour);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: TimePickerWidget(
                              text:
                                  "${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}",
                              beginTime: beginHour,
                              onDateTimeChanged: (newDateTime) {
                                setModalState(() {
                                  endHour = newDateTime;
                                  print(endHour);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: !verifyData()
                            ? Container()
                            : compareData()
                                ? const Text(
                                    "L'heure de debut doit être inferieur à l'heure de fin",
                                    style: TextStyle(color: Colors.red),
                                  )
                                : Row(children: [
                                    Expanded(
                                        flex: 5,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: RoundedButton(
                                              text: "Modifier",
                                              press: () {
                                                if (selectedDate != null &&
                                                    beginHour != null &&
                                                    endHour != null) {
                                                  DateTime startTime = DateTime(
                                                      selectedDate!.year,
                                                      selectedDate!.month,
                                                      selectedDate!.day,
                                                      beginHour!.hour,
                                                      beginHour!.minute);
                                                  DateTime endTime = DateTime(
                                                      selectedDate!.year,
                                                      selectedDate!.month,
                                                      selectedDate!.day,
                                                      endHour!.hour,
                                                      endHour!.minute);
                                                  PlanningEventService()
                                                      .updatePlanningEvent(
                                                          int.parse(appointment
                                                              .notes!
                                                              .split(",")
                                                              .first),
                                                          appointment.subject,
                                                          startTime,
                                                          endTime)
                                                      .then((value) {
                                                    Navigator.of(context).pop();

                                                    if (value.statusCode ==
                                                        200) {
                                                      widget._dataSource!
                                                          .appointments!
                                                          .remove(appointment);
                                                      widget._dataSource!
                                                          .notifyListeners(
                                                              CalendarDataSourceAction
                                                                  .remove,
                                                              <Appointment>[
                                                            appointment
                                                          ]);

                                                      Appointment app =
                                                          appointment;
                                                      app.startTime = startTime;
                                                      app.endTime = endTime;
                                                      widget._dataSource!
                                                          .appointments!
                                                          .add(app);

                                                      widget._dataSource!
                                                          .notifyListeners(
                                                              CalendarDataSourceAction
                                                                  .add,
                                                              <Appointment>[
                                                            app
                                                          ]);
                                                    } else {
                                                      showModalBottomSheet(
                                                          shape:
                                                              const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        25),
                                                                topRight: Radius
                                                                    .circular(
                                                                        25)),
                                                          ),
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return WarningModal(
                                                                text:
                                                                    "Le planning event n'a pas pu être supprimé",
                                                                url_animation:
                                                                    "assets/lottieanimate/error.json");
                                                          });
                                                    }
                                                  });
                                                }
                                              }),
                                        ))
                                  ])),
                  ],
                ),
              ));
        });
      },
    ).whenComplete(() {
      selectedDate = currentTime;
      beginHour = null;
      endHour = null;
    });
  }
}

void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
  dynamic appointment = appointmentDragEndDetails.appointment;
  PlanningEventService().updatePlanningEvent(
      int.parse(appointment.notes.toString().split(",").first),
      appointment.subject,
      appointment.startTime,
      appointment.endTime);
}

_AppointmentDataSource _getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];
  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
