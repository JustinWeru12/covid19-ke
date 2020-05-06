import 'dart:io';
import 'dart:ui';

import 'package:covid19/widgets/my_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:covid19/services/authentication.dart';
import 'package:covid19/style/theme.dart' as Theme;
import 'package:covid19/services/user.dart';
import 'package:covid19/services/crud.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:covid19/style/primary_button.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({Key key, this.auth, this.loginCallback, this.title})
      : super(key: key);

  final String title;
  final BaseAuth auth;
  final VoidCallback loginCallback;
  @override
  _LoginSignUpPageState createState() => _LoginSignUpPageState();
}

enum FormType { login, register, reset }

class _LoginSignUpPageState extends State<LoginSignUpPage>
    with TickerProviderStateMixin {
  static final _formKey = new GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  CrudMethods crudObj = new CrudMethods();
  String _email;
  String _fullNames;
  DateTime dob;
  File picture;
  bool admin;
  double offset = 0;
  int date = DateTime.now().millisecondsSinceEpoch;
  String _authHint = '';
  FormType _formType = FormType.login;
  String _password;
  // String _errorMessage;

  // bool _isLoginForm;
  bool _isLoading = false;
  Color dobColor = Colors.yellowAccent;
  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String userId = _formType == FormType.login
            ? await widget.auth.signIn(_email, _password)
            : await widget.auth.signUp(_email, _password);
        setState(() {
          _isLoading = false;
        });
        if (_formType == FormType.register) {
          UserData userData = new UserData(
            fullNames: _fullNames,
            email: _email,
            phone: "",
            picture:
                "https://firebasestorage.googleapis.com/v0/b/covid19-ke-80e90.appspot.com/o/IMG_-oxvq7.jpg?alt=media&token=b8d2972a-e54c-49ff-8c4c-c869bd9d9592",
            address: "",
            aColor: 0xFF36C12C,
            dob: dob,
            admin: false,
            date : date
          );
          crudObj.createOrUpdateUserData(userData.getDataMap());
        }

        if (userId == null) {
          print("EMAIL NOT VERIFIED");
          setState(() {
            _authHint = 'Check your email for a verify link';
            _isLoading = false;
            _formType = FormType.login;
          });
        } else {
          _isLoading = false;
          _authHint = '';
          widget.loginCallback();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          switch (e.code) {
            case "ERROR_INVALID_EMAIL":
              _authHint = "Your email address appears to be malformed.";
              break;
            case "ERROR_EMAIL_ALREADY_IN_USE":
              _authHint = "Email address already used in a different account.";
              break;
            case "ERROR_WRONG_PASSWORD":
              _authHint = "Your password is wrong.";
              break;
            case "ERROR_USER_NOT_FOUND":
              _authHint = "User with this email doesn't exist.";
              break;
            case "ERROR_USER_DISABLED":
              _authHint = "User with this email has been disabled.";
              break;
            case "ERROR_TOO_MANY_REQUESTS":
              _authHint =
                  "Too many Attemps. Account has temporarily disabled.\n Try again later.";
              break;
            case "ERROR_OPERATION_NOT_ALLOWED":
              _authHint = "Signing in with Email and Password is not enabled.";
              break;
            case "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL":
              _authHint = "The email is in use by another account";
              break;
            default:
              _authHint = "An undefined Error happened.";
          }
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void moveToRegister() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToReset() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.reset;
      _authHint = '';
    });
  }

  void moveToLogin() {
    _formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        // key: new Key('email'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: Theme.kBackgroundColor.withOpacity(0.75),
          labelText: 'Email',
          labelStyle: Theme.kSubTextStyle,
          icon: new Icon(
            Icons.mail,
            color: Colors.yellowAccent,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(15.0),
            borderSide: new BorderSide(),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
            return 'Enter a valid email';
          }
        },
        onSaved: (value) => _email = value,
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        // key: new Key('namefield'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: Theme.kBackgroundColor.withOpacity(0.75),
          labelText: 'Full Name',
          labelStyle: Theme.kSubTextStyle,
          icon: new Icon(
            Icons.perm_identity,
            color: Colors.yellowAccent,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(15.0),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (String value) {
          if (value.isEmpty) {
            return 'Enter your Name';
          }
        },
        onSaved: (value) => _fullNames = value,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        // key: new Key('password'),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: Theme.kBackgroundColor.withOpacity(0.75),
          labelText: 'Password',
          labelStyle: Theme.kSubTextStyle,
          icon: new Icon(
            Icons.lock,
            color: Colors.yellowAccent,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(15.0),
            borderSide: new BorderSide(),
          ),
        ),
        controller: _passwordTextController,
        obscureText: true,
        validator: (String value) {
          if (value.isEmpty || value.length < 6) {
            return 'Enter a minimum of 6 characters';
          }
        },
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _builConfirmPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 0.0),
          filled: true,
          fillColor: Theme.kBackgroundColor.withOpacity(0.75),
          labelText: 'Confirm Password',
          labelStyle: Theme.kSubTextStyle,
          icon: new Icon(
            Icons.lock,
            color: Colors.yellowAccent,
          ),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(15.0),
            borderSide: new BorderSide(),
          ),
        ),
        obscureText: true,
        validator: (String value) {
          if (_passwordTextController.text != value) {
            return 'Passwords don\'t correspond';
          }
        },
      ),
    );
  }

  Widget _showDatePicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.date_range,
            color: Colors.yellowAccent,
          ),
          FlatButton(
            onPressed: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1960, 1, 1),
                maxTime: DateTime(2009, 1, 1),
                onConfirm: (date) {
                  setState(() {
                    dob = date;
                    dobColor = Colors.yellowAccent;
                  });
                },
                currentTime: DateTime.now(),
                locale: LocaleType.en,
              );
            },
            child: Text(
              dob == null
                  ? 'Date of Birth'
                  : DateFormat('dd/MM/yyyy').format(dob),
              style: TextStyle(color: dobColor, fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
              key: new Key('login'),
              text: 'Login',
              height: 44.0,
              onPressed: validateAndSubmit,
            ),
            SizedBox(height: 10.0),
            FlatButton(
                key: new Key('reset-account'),
                child: Text(
                  "Reset Password",
                ),
                onPressed: moveToReset),
            // SizedBox(height: 10),
            FlatButton(
                key: new Key('need-account'),
                child: Text("Create a New Account"),
                onPressed: moveToRegister),
            SizedBox(height: 20.0),
          ],
        );
      case FormType.reset:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
                key: new Key('reset'),
                text: 'Reset Password',
                height: 44.0,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    widget.auth.resetPassword(_email);
                    setState(() {
                      _authHint = 'Check your email';
                      _formType = FormType.login;
                    });
                  }
                }),
            SizedBox(height: 20.0),
            FlatButton(
                key: new Key('need-login'),
                child: Text("Already Have an Account ? Login"),
                onPressed: moveToLogin),
            SizedBox(height: 20.0),
          ],
        );
      default:
        return ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: <Widget>[
            PrimaryButton(
                key: new Key('register'),
                text: 'Sign Up',
                height: 44.0,
                onPressed: () {
                  if (dob == null) {
                    validateAndSave();
                    setState(() {
                      dobColor = Colors.red[700];
                    });
                  } else {
                    validateAndSubmit();
                  }
                }),
            SizedBox(height: 20.0),
            FlatButton(
                key: new Key('need-login'),
                child: Text("Already Have an Account ? Login"),
                onPressed: moveToLogin),
            SizedBox(height: 20.0),
          ],
        );
    }
  }

  Widget _showCircularProgress() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _showLogo() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Container(
          height: 200,
          width: 500,
          child: Hero(
            tag: 'hero',
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 10.0),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 70.0,
                child: Image.asset('assets/icons/icon.png'),
              ),
            ),
          ),
        ));
  }

  Widget hintText() {
    return Container(
        //height: 80.0,
        padding: const EdgeInsets.all(10.0),
        child: Text(_authHint,
            key: new Key('hint'),
            style: Theme.kAlertTextStyle,
            textAlign: TextAlign.center));
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _showLogo(),
            hintText(),
            _formType == FormType.register
                ? _buildNameField()
                : Container(height: 0.0),
            SizedBox(
              height: 10.0,
            ),
            _buildEmailField(),
            SizedBox(
              height: 10.0,
            ),
           _formType != FormType.reset ? _buildPasswordField():Container(),
            SizedBox(
              height: 10.0,
            ),
            _formType == FormType.register
                ? _builConfirmPasswordTextField()
                : Container(),
            SizedBox(
              height: 10.0,
            ),
            _formType == FormType.register ? _showDatePicker() : Container(),
            SizedBox(
              height: 10.0,
            ),
            _isLoading == false ? submitWidgets() : _showCircularProgress(),
          ],
        ));
  }

  Widget padded({Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.kAppBarColor.withOpacity(0),
      //   title: Center(
      //     child: Text(
      //       widget.title,
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontWeight: FontWeight.bold,
      //         fontSize: 30.0,
      //       ),
      //       textAlign: TextAlign.center,
      //     ),
      //   ),
      // ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Covid19.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          MyHeader(
            image: "assets/icons/Drcorona.svg",
            textTop: "Make a difference",
            textBottom: "   Stay at home.🏡",
            offset: offset,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: <Widget>[
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        color: Colors.transparent,
                        child: Card(
                            elevation: 5.0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Container(
                              padding: EdgeInsets.only(left: 20.0, right: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Theme.kShadowColor.withOpacity(0.7),
                                    Theme.kPrimaryColor.withOpacity(0.7),
                                    Theme.kPrimaryColor.withOpacity(0.8),
                                    Theme.kAppBarColor.withOpacity(0.9),
                                  ],
                                ),
                              ),
                              child: _buildForm(),
                            )),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
