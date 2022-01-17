import 'package:cidade_singular_admin/app/screens/singularities/address_search.dart';
import 'package:cidade_singular_admin/app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

class AddSingularityPage extends StatefulWidget {
  const AddSingularityPage({Key? key}) : super(key: key);

  static String routeName = "/add_singularity";

  @override
  _AddSingularityPageState createState() => _AddSingularityPageState();
}

class _AddSingularityPageState extends State<AddSingularityPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleTextEdtCtrl = TextEditingController();
  TextEditingController descriptionTextEdtCtrl = TextEditingController();
  TextEditingController addressTextEdtCtrl = TextEditingController();
  TextEditingController visitingHoursInitTextEdtCtrl = TextEditingController();
  TextEditingController visitingHoursEndTextEdtCtrl = TextEditingController();

  TimeOfDay selectedTime = TimeOfDay.now();

  List dayHour = [
    {"day": "Seg", "open": true, "hourInit": "", "hourEnd": ""},
    {"day": "Ter", "open": true, "hourInit": "", "hourEnd": ""},
    {"day": "Qua", "open": true, "hourInit": "", "hourEnd": ""},
    {"day": "Qui", "open": true, "hourInit": "", "hourEnd": ""},
    {"day": "Sex", "open": true, "hourInit": "", "hourEnd": ""},
    {"day": "Sáb", "open": true, "hourInit": "", "hourEnd": ""},
    {"day": "Dom", "open": true, "hourInit": "", "hourEnd": ""}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar singularidade"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildFormField(title: "Título", controller: titleTextEdtCtrl),
                SizedBox(height: 16),
                buildFormField(
                  title: "Descrição",
                  controller: descriptionTextEdtCtrl,
                  minLines: 10,
                ),
                SizedBox(height: 16),
                buildFormField(
                  title: "Endereço",
                  controller: addressTextEdtCtrl,
                  readOnly: true,
                  prefixIcon: Container(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      "assets/images/places.svg",
                      width: 10,
                      fit: BoxFit.contain,
                    ),
                  ),
                  onTap: () async {
                    final sessionToken = Uuid().v4();
                    final result = await showSearch(
                      context: context,
                      delegate: AddressSearch(sessionToken),
                      query: addressTextEdtCtrl.text,
                    );
                    if (result != null) {
                      setState(() {
                        addressTextEdtCtrl.text = result.description;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Horário de visitação",
                  style: TextStyle(
                    fontSize: 18,
                    color: Constants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                ...dayHour.map(
                  (day) => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150,
                        child: SwitchListTile(
                          title: Text(
                            day["day"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          value: day["open"],
                          onChanged: (value) {
                            setState(() {
                              day["open"] = value;
                            });
                          },
                        ),
                      ),
                      if (day["open"])
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildTimeImput(
                                context: context,
                                title: "Início",
                                hour: day["hourInit"],
                                onSelect: (hour) {
                                  setState(() {
                                    day["hourInit"] = hour;
                                  });
                                },
                              ),
                              SizedBox(width: 5),
                              Text("ás"),
                              SizedBox(width: 5),
                              buildTimeImput(
                                context: context,
                                title: "Fim",
                                hour: day["hourEnd"],
                                onSelect: (hour) {
                                  setState(() {
                                    day["hourEnd"] = hour;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _formKey.currentState?.validate();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Constants.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white38,
                            blurRadius: 2,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Text(
                        "Adicionar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimeImput({
    required BuildContext context,
    required String hour,
    required String title,
    required Function(String) onSelect,
  }) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 8, minute: 0),
          cancelText: "CANCELAR",
          confirmText: "CONFIRMAR",
          helpText: "Horário de visitação - $title",
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          String hourFormated =
              "${newTime.hour.toString().padLeft(2, "0")}:${newTime.minute.toString().padLeft(2, "0")}";
          onSelect(hourFormated);
        }
      },
      child: Container(
        width: 70,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        decoration: BoxDecoration(
            color: Constants.grey, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/images/hour.svg",
              width: 15,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 3),
            Text(hour)
          ],
        ),
      ),
    );
  }

  Widget buildFormField({
    String? title,
    required TextEditingController controller,
    int minLines = 1,
    String? Function(String?)? validator,
    void Function()? onTap,
    bool readOnly = false,
    Widget? prefixIcon,
    TextStyle? titleStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title,
            style: titleStyle ??
                TextStyle(
                  fontSize: 18,
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        TextFormField(
          onTap: onTap,
          readOnly: readOnly,
          controller: controller,
          validator: validator ?? emptyValidator,
          textAlign: TextAlign.justify,
          maxLines: null,
          minLines: minLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(10),
            hintText: "",
            counterText: "",
            helperMaxLines: 0,
            filled: true,
            fillColor: Constants.grey,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }

  String? emptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Campo não pode ser vazio";
    }
    return null;
  }
}
