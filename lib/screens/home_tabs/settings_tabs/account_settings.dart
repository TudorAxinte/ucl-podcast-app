import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podcasts_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccountSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AccountSettingsState();
  }
}

class AccountSettingsState extends State<AccountSettings> {
  late final AuthProvider auth;
  late final TextEditingController _emailController;
  late final TextEditingController _oldPassword;
  late final TextEditingController _newPassword;

  ValueNotifier<bool> editingName = ValueNotifier(false);
  ValueNotifier<bool> editingEmail = ValueNotifier(false);
  ValueNotifier<bool> editingPassword = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);
    _emailController = TextEditingController.fromValue(
      TextEditingValue(
        text: auth.currentUser!.email,
        selection: TextSelection.collapsed(offset: auth.currentUser!.email != "" ? auth.currentUser!.email.length : 0),
      ),
    );
    _oldPassword = TextEditingController();
    _newPassword = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkResponse(
                      child: Icon(
                        Icons.clear,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Spacer(),
                    Text(
                      'Account settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 20),
                settingsCard(auth.currentUser!.username, Icons.person, null),
                ValueListenableBuilder<bool>(
                  valueListenable: editingEmail,
                  builder: (context, editing, _) => editing
                      ? editingCard(
                          "Choose a new email",
                          Icons.email,
                          editingEmail,
                          _emailController,
                          () => auth
                                  .updateEmail(_emailController.text)
                                  .then((value) => editingEmail.value = false)
                                  .onError((error, stackTrace) {
                                BotToast.showSimpleNotification(
                                    title: "Error", subTitle: error.toString(), duration: Duration(seconds: 2));
                                editingEmail.value = false;
                                return true;
                              }),
                          size)
                      : settingsCard(
                          auth.currentUser!.email,
                          Icons.email,
                          () => editingEmail.value = true,
                          editable: !auth.isSocialLogin,
                        ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: editingPassword,
                  builder: (context, editing, _) => editing
                      ? editingCard(
                          "Old Password",
                          Icons.lock,
                          editingPassword,
                          _oldPassword,
                          () => auth
                                  .changePassword(_newPassword.text, _oldPassword.text)
                                  .then((value) => editingPassword.value = false)
                                  .onError((error, stackTrace) {
                                BotToast.showSimpleNotification(
                                    title: "Error", subTitle: error.toString(), duration: Duration(seconds: 2));
                                editingPassword.value = false;
                                return true;
                              }),
                          size,
                          controller2: _newPassword,
                          hint2: "New Password")
                      : settingsCard("Password", Icons.lock, () => editingPassword.value = true, editable: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget editingCard(
      String hint, IconData data, ValueNotifier<bool> valueNotifier, TextEditingController controller, function, size,
      {TextEditingController? controller2, String? hint2}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 200, minHeight: 150),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Spacer(),
            Row(
              children: [
                Icon(
                  data,
                  size: 30,
                  color: Colors.black54,
                ),
                Spacer(),
                Container(
                    width: size.width * 0.7,
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(hintText: hint),
                        ),
                        if (controller2 != null)
                          TextField(
                            controller: controller2,
                            decoration: InputDecoration(hintText: hint2),
                          ),
                        if (controller2 != null) SizedBox(height: 5),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MaterialButton(
                                height: 54,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                color: Colors.black,
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                disabledColor: Colors.grey,
                                onPressed: function),
                            SizedBox(width: 5),
                            TextButton(
                              onPressed: () => valueNotifier.value = false,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              ],
            ),
            Spacer(),
            Container(
              height: 1,
              color: Colors.black26,
            )
          ],
        ),
      ),
    );
  }

  Widget settingsCard(String title, IconData data, function, {editable = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: editable ? function : null,
        child: Container(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
              Row(
                children: [
                  Icon(
                    data,
                    size: 30,
                    color: Colors.black54,
                  ),
                  Spacer(),
                  Container(
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Visibility(
                    visible: editable,
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.black45,
                    ),
                  )
                ],
              ),
              Spacer(),
              Container(
                height: 1,
                color: Colors.black26,
              )
            ],
          ),
        ),
      ),
    );
  }
}
