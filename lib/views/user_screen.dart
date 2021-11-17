import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../controllers/user_controller.dart';
import '../widgets/birthday_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/pets_button_widget.dart';
import '../widgets/switch_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'home_screen.dart';
import '../animations/ltor_page_route.dart';
import 'package:form_field_validator/form_field_validator.dart';

class UserScreen extends StatefulWidget {
  final String? idUser;

  const UserScreen({
    Key? key,
    this.idUser,
  }) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
 late User user;

  @override
  void initState() {
    super.initState();

    final id = Uuid().v4();
    print('Id: $id');

    user = widget.idUser == null
        ? User(id: id, dateOfBirth: DateTime.now())
        : UserController.getUser(widget.idUser);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          buildUsers(),
          if (widget.idUser == null)
            Positioned(
              left: 16,
              top: 24,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 32),
                onPressed: () => Navigator.of(context).push(LtorPageRoute(
                  child: HomeScreen(),
                )),
              ),
            ),
          if (widget.idUser != null)
            Positioned(
              right: 16,
              top: 24,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 32),
                onPressed: () => Navigator.of(context).push(LtorPageRoute(
                  child: HomeScreen(),
                )),
              ),
            ),
        ],
      ),
    ),
  );

  Widget buildUsers() => ListView(
    padding: EdgeInsets.all(16),
    children: [
      buildImage(),
      const SizedBox(height: 32),
      buildName(),
      const SizedBox(height: 12),
      buildPassword(),
      const SizedBox(height: 12),
      buildBirthday(),
      const SizedBox(height: 12),
      buildIsCreator(),
      const SizedBox(height: 32),
      buildButton(),
    ],
  );

  Widget buildImage() => GestureDetector(
    child: buildAvatar(),
    onTap: () async {
      final image =
      await ImagePicker().getImage(source: ImageSource.gallery);

      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final id = '_${widget.idUser}_${Uuid().v4()}';
      final imageFile = File('${directory.path}/${id}_avatar.png');
      final newImage = await File(image.path).copy(imageFile.path);

      setState(() => user = user.copy(imagePath: newImage.path));
    },
  );

  Widget buildAvatar() {
    final double size = 64;

    if (user.imagePath.isNotEmpty) {
      return CircleAvatar(
        radius: size,
        backgroundColor: Theme.of(context).accentColor,
        child: ClipOval(
          child: Image.file(
            File(user.imagePath),
            width: size * 2,
            height: size * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size,
        backgroundColor: Theme.of(context).unselectedWidgetColor,
        child: Icon(Icons.add, color: Colors.white, size: size),
      );
    }
  }

  Widget buildName() => buildTitle(
    title: 'Name',
    child: TextFormField(
      autovalidate: true,
      initialValue: user.name,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Your Name',
      ),
      validator: MinLengthValidator(1,errorText: "At least write 1 letter ;)"),
      onChanged: (name) => setState(() => user = user.copy(name: name)),
    ),
  );

  Widget buildPassword() => buildTitle(
    title: 'Password',
    child: TextFormField(
      autovalidate: true,
      initialValue: user.password,
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Your Password',

        
      ),
      validator: MinLengthValidator(4,errorText: "Should be at least 4 characters!"),
      onChanged: (password) => setState(() => user = user.copy(password: password)),
    ),
  );

  Widget buildBirthday() => BirthdayWidget(
    birthday: user.dateOfBirth,
    onChangedBirthday: (dateOfBirth) =>
        setState(() => user = user.copy(dateOfBirth: dateOfBirth)),
  );

  Widget buildIsCreator() => SwitchWidget(
    title: 'Are you creator?',
    value: user.settings.isCreator,
    onChanged: (isCreator) {
      final settings = user.settings.copy(
        isCreator: isCreator,
      );

      setState(() => user = user.copy(settings: settings));
    },
  );

  Widget buildButton() => ButtonWidget(
      text: 'Save',
      onClicked: () async {
        if(user.password.length >=4 && user.name.length >0){
        final isNewUser = widget.idUser == null;

        if (isNewUser) {
          await UserController.addUsers(user);
          await UserController.setUser(user);


            Navigator.of(context).pushReplacement(MaterialPageRoute
          (
            builder: (context) => UserScreen(idUser: user.id),
          ));}
        } else {
          await UserController.setUser(user);
        }
      });

  Widget buildTitle({
    required String title,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          child,
        ],
      );
}